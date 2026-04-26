import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../api/http/async_handler.dart';
import '../../../api/service/user_api.dart';
import '../../../common/utils/loading_util.dart';
import '../../../common/utils/oss_upload_util.dart';
import '../../../common/utils/permission_util.dart';
import '../../../common/utils/toast.dart';

class EditProfileLogic extends GetxController {
  // 原始数据（用于判断是否有变化）
  String _originalNickname = '';
  String _originalAvatar = '';
  String _originalCity = '';
  String _originalCityId = '';

  // 当前编辑数据
  final nickname = ''.obs;
  final avatar = ''.obs;
  final city = ''.obs;
  final cityId = ''.obs;

  // 昵称输入控制器
  late TextEditingController nicknameController;

  // 是否正在上传头像
  final isUploading = false.obs;

  // 是否有变化
  bool get hasChanges {
    return nickname.value != _originalNickname ||
        avatar.value != _originalAvatar ||
        city.value != _originalCity;
  }

  @override
  void onInit() {
    super.onInit();
    nicknameController = TextEditingController();

    // 从路由参数获取初始数据
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      _originalNickname = args['nickname'] ?? '';
      _originalAvatar = args['avatar'] ?? '';
      _originalCity = args['city'] ?? '';
      _originalCityId = args['cityId'] ?? '';

      nickname.value = _originalNickname;
      avatar.value = _originalAvatar;
      city.value = _originalCity;
      cityId.value = _originalCityId;

      nicknameController.text = _originalNickname;
    }
  }

  @override
  void onClose() {
    nicknameController.dispose();
    super.onClose();
  }

  /// 更新昵称
  void updateNickname(String value) {
    // 移除换行符，限制10字
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

  /// 更新城市
  void updateCity(String cityName, String id) {
    city.value = cityName;
    cityId.value = id;
  }

  /// 选择并上传头像
  Future<void> pickAndUploadAvatar(BuildContext context) async {
    if (isUploading.value) return;

    try {
      // 请求相册权限
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

      // 打开相册选择单张图片
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

      // 获取文件
      final asset = result.first;
      final File? file = await asset.file;
      if (file == null) {
        FToastUtil.show("获取图片失败");
        return;
      }

      // 上传到 OSS
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
      FToastUtil.show("选择图片失败: $e");
    } finally {
      LoadingUtil.dismiss();
      isUploading.value = false;
    }
  }

  /// 保存编辑内容
  Future<bool> saveProfile() async {
    // 检查昵称是否为空
    if (nickname.value.trim().isEmpty) {
      FToastUtil.show("昵称不能为空");
      return false;
    }

    LoadingUtil.show();

    final response = await AsyncHandler.handle(
      future: postUserEdit(
        userName: nickname.value != _originalNickname ? nickname.value : null,
        avatar: avatar.value != _originalAvatar ? avatar.value : null,
        address: city.value != _originalCity ? city.value : null,
      ),
      onSuccess: () {
        FToastUtil.show("保存成功");
      },
      onFinally: () {
        LoadingUtil.dismiss();
      },
    );

    if (response.ok) {
      return true;
    } else {
      // 检查是否昵称重复
      final errorMsg = response.message ?? response.desc ?? '';
      if (errorMsg.contains('昵称') || errorMsg.contains('已存在') || errorMsg.contains('重复')) {
        FToastUtil.show("该昵称已存在");
      }
      return false;
    }
  }
}
