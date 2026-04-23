import 'package:cxq_merchant_flutter/api/service/user_api.dart';
import 'package:cxq_merchant_flutter/common/utils/loading_util.dart';
import 'package:cxq_merchant_flutter/common/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';

class InviteCodeLogic extends GetxController {
  late TextEditingController codeController;

  final code = ''.obs;
  final isHintExpanded = false.obs;
  final isVerifying = false.obs;

  var showSkipButton = true.obs;

  @override
  void onInit() {
    super.onInit();
    codeController = TextEditingController();
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

  void onCodeChanged(String value) {
    code.value = value.toUpperCase();
    if (code.value.length == 6) {
      _verifyCode();
    }
  }

  void toggleHint() {
    isHintExpanded.value = !isHintExpanded.value;
  }

  Future<void> _verifyCode() async {
    if (isVerifying.value) return;
    isVerifying.value = true;

    LoadingUtil.show();

    try {
      final res = await postInvitationCodeVerify(invitationCode: code.value);

      if (res.ok) {
        Get.toNamed(Routes.uploadAvatarNickname);
      } else {
        FToastUtil.show(res.message ?? '密钥无效');
        _clearCode();
      }
    } catch (e) {
      FToastUtil.show('验证失败');
      _clearCode();
    } finally {
      LoadingUtil.dismiss();
      isVerifying.value = false;
    }
  }

  void _clearCode() {
    codeController.clear();
    code.value = '';
  }

  Future<void> skip() async {
    if (isVerifying.value) return;
    isVerifying.value = true;

    LoadingUtil.show();

    try {
      final res = await postInvitationCodeVerify(invitationCode: '111111');
      if (res.ok) {
        Get.toNamed(Routes.uploadAvatarNickname);
      } else {
        FToastUtil.show(res.message ?? '跳过失败');
      }
    } catch (e) {
      FToastUtil.show('请求失败');
    } finally {
      LoadingUtil.dismiss();
      isVerifying.value = false;
    }
  }
}
