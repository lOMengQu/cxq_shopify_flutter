import 'dart:io';

import 'package:cxq_merchant_flutter/api/http/async_handler.dart';
import 'package:cxq_merchant_flutter/api/service/user_api.dart';
import 'package:cxq_merchant_flutter/app/routes/app_pages.dart';
import 'package:cxq_merchant_flutter/common/utils/loading_util.dart';
import 'package:cxq_merchant_flutter/common/utils/oss_upload_util.dart';
import 'package:cxq_merchant_flutter/common/utils/service/user_service.dart';
import 'package:cxq_merchant_flutter/common/utils/permission_util.dart';
import 'package:cxq_merchant_flutter/common/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class UploadAvatarNicknameLogic extends GetxController {
  final nicknameController = TextEditingController();
  final nicknameFocusNode = FocusNode();
  final isFocused = false.obs;

  final nickname = ''.obs;
  final avatar = ''.obs;

  final isUploading = false.obs;
  final isSubmitting = false.obs;

  bool get isFormValid => nickname.value.trim().isNotEmpty;

  @override
  void onReady() {
    super.onReady();
    nicknameFocusNode.addListener(() {
      isFocused.value = nicknameFocusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    nicknameFocusNode.dispose();
    nicknameController.dispose();
    super.onClose();
  }

  void updateNickname(String value) {
    final cleanValue = value.replaceAll('\n', '');
    if (cleanValue.length <= 10) {
      nickname.value = cleanValue;
    } else {
      nickname.value = cleanValue.substring(0, 10);
      nicknameController.text = nickname.value;
      nicknameController.selection = TextSelection.fromPosition(
        TextPosition(offset: nickname.value.length),
      );
    }
  }

  Future<void> pickAndUploadAvatar(BuildContext context) async {
    if (isUploading.value) return;

    try {
      final bool alreadyGranted = await hasPhotoPermission();
      if (!alreadyGranted) {
        showPermissionSnackbarPersistent(
          context: '为便于您上传头像，我们需要申请访问您的相册/存储权限。\n我们仅在您主动选择上传头像时使用该权限，不会收集、存储或上传与头像无关的任何内容。\n请放心授权。',
        );
        await Future.delayed(const Duration(milliseconds: 500));
      }
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!alreadyGranted) {
        Get.closeCurrentSnackbar();
      }
      if (!ps.hasAccess) {
        FToastUtil.show("请授予相册访问权限");
        return;
      }

      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          requestType: RequestType.image,
          selectedAssets: const <AssetEntity>[],
          pathNameBuilder: (AssetPathEntity path) => switch (path) {
            final p when p.isAll => '最近图片',
            final p when p.name.toLowerCase().contains('camera') => '相机',
            final p when p.name.toLowerCase().contains('weixin') => '微信',
            final p when p.name.toLowerCase().contains('qq') => 'QQ',
            final p when p.name.toLowerCase().contains('screenshots') => '截图',
            _ => path.name,
          },
        ),
      );

      if (result == null || result.isEmpty) return;

      isUploading.value = true;
      LoadingUtil.show();

      final asset = result.first;
      final File? file = await asset.file;
      if (file == null) {
        FToastUtil.show("获取图片失败");
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String? avatarUrl = await OssUploadUtil.uploadFileWithTimestamp(
        file,
        timestamp,
        'img',
      );

      if (avatarUrl == null) {
        FToastUtil.show("图片上传失败");
        return;
      }

      avatar.value = avatarUrl;
    } catch (e) {
      FToastUtil.show("选择图片失败");
    } finally {
      LoadingUtil.dismiss();
      isUploading.value = false;
    }
  }

  Future<void> submit() async {
    if (!isFormValid) return;

    if (nickname.value.trim().isEmpty) {
      FToastUtil.show("请输入昵称");
      return;
    }

    if (isSubmitting.value) return;
    isSubmitting.value = true;

    LoadingUtil.show();

    final response = await AsyncHandler.handle(
      future: postAccountUser(
        nickname.value,
        avatar.value.isNotEmpty ? avatar.value : '',
      ),
      onFinally: () {
        LoadingUtil.dismiss();
        isSubmitting.value = false;
      },
    );

    if (response.ok) {
      UserService.saveAvatar(avatar.value);
      await UserService.clearRegistrationInProgress();
      Get.offAllNamed(Routes.mainHome);
    } else {
      final errorMsg = response.message ?? response.desc ?? '';
      if (errorMsg.contains('昵称') ||
          errorMsg.contains('已存在') ||
          errorMsg.contains('重复')) {
        FToastUtil.show("该昵称已存在");
      } else {
        FToastUtil.show(errorMsg.isNotEmpty ? errorMsg : "保存失败");
      }
    }
  }
}
