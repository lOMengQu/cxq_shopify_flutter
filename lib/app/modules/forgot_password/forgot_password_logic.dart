import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cxq_merchant_flutter/api/service/user_api.dart';
import 'package:cxq_merchant_flutter/common/utils/toast.dart';
import 'package:cxq_merchant_flutter/common/constants/app_constants.dart';

import '../../../api/http/async_handler.dart';

class ForgotPasswordLogic extends GetxController {
  late TextEditingController phoneController;
  final captchaController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final phone = ''.obs;
  final captcha = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final countdown = 0.obs;
  final isCountingDown = false.obs;
  Timer? _timer;

  final isLoading = false.obs;

  final imageCaptchaController = TextEditingController();
  final imageCaptchaInput = ''.obs;
  final imageCodeBase64 = ''.obs;
  final oneKey = ''.obs;
  final isCaptchaLoading = false.obs;

  bool get isPhoneValid => phone.value.length == 11;

  bool get isPhoneFormatValid {
    if (phoneController.text.length != 11) return false;
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phoneController.text);
  }

  bool get isPasswordFormatValid {
    if (password.value.length < 6 || password.value.length > 16) return false;
    return RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]{6,16}$').hasMatch(password.value);
  }

  bool get isFormValid {
    return phone.value.length == 11 &&
        captcha.value.length == 6 &&
        password.value.length >= 6 &&
        confirmPassword.value.length >= 6;
  }

  @override
  void onInit() {
    super.onInit();
    var currentPhone = Get.arguments?['phone'] ?? '';
    phoneController = TextEditingController(text: currentPhone);
    phone.value = currentPhone;
    phoneController.addListener(() => phone.value = phoneController.text);
    captchaController.addListener(() => captcha.value = captchaController.text);
    passwordController.addListener(() => password.value = passwordController.text);
    confirmPasswordController.addListener(() => confirmPassword.value = confirmPasswordController.text);
  }

  @override
  void onClose() {
    _timer?.cancel();
    phoneController.dispose();
    captchaController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    imageCaptchaController.dispose();
    super.onClose();
  }

  void clearPhone() {
    phoneController.clear();
  }

  void clearCaptcha() {
    captchaController.clear();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void startCountdown() {
    countdown.value = 60;
    isCountingDown.value = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        isCountingDown.value = false;
        timer.cancel();
      }
    });
  }

  void onGetCaptchaTap() {
    if (!isPhoneValid && phoneController.text.isEmpty) {
      FToastUtil.show('请输入11位手机号');
      return;
    }

    if (!isPhoneFormatValid) {
      FToastUtil.show('手机号格式错误');
      return;
    }

    showImageCaptchaDialog();
  }

  Future<void> fetchImageCode() async {
    if (isCaptchaLoading.value) return;
    isCaptchaLoading.value = true;

    try {
      final res = await postGetVerifyImage(phoneNumber: phone.value);
      if (res.data != null) {
        imageCodeBase64.value = res.data!.image ?? '';
        oneKey.value = res.data!.oneKey ?? '';
      }
    } catch (e) {
      FToastUtil.show('获取验证码失败');
    } finally {
      isCaptchaLoading.value = false;
    }
  }

  void showImageCaptchaDialog() {
    imageCaptchaController.clear();
    imageCaptchaInput.value = '';
    fetchImageCode();

    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300.w,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '输入图片信息获取验证码',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 20.h),
                Obx(() => isCaptchaLoading.value
                    ? SizedBox(
                        height: 60.h,
                        child: Center(
                          child: CircularProgressIndicator(color: primary),
                        ),
                      )
                    : imageCodeBase64.value.isNotEmpty
                        ? Image.memory(
                            _decodeBase64Image(imageCodeBase64.value),
                            height: 60.h,
                            fit: BoxFit.contain,
                          )
                        : SizedBox(
                            height: 60.h,
                            child: Center(
                              child: Text('加载失败', style: TextStyle(color: textAssist)),
                            ),
                          )),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: dividerColor2, width: 1),
                          ),
                        ),
                        child: TextField(
                          controller: imageCaptchaController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 14.sp, color: textFiledColor),
                          onChanged: (value) => imageCaptchaInput.value = value,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: InputDecoration(
                            hintText: '请输入验证码',
                            hintStyle: TextStyle(fontSize: 14.sp, color: hintColor),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    GestureDetector(
                      onTap: fetchImageCode,
                      child: Text(
                        '换一换',
                        style: TextStyle(fontSize: 14.sp, color: textAssist),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),
                Obx(() {
                  var isEmpty = imageCaptchaInput.isEmpty;
                  return GestureDetector(
                      onTap: isEmpty ? null : onImageCaptchaConfirm,
                      child: Container(
                        width: 110.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: isEmpty ? Color(0XFFEEF1F5) : primary,
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        child: Center(
                          child: Text(
                            '确定',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: isEmpty ? textAssist : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ));
                }),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.black54,
    );
  }

  Uint8List _decodeBase64Image(String base64String) {
    String base64Data = base64String;
    if (base64String.contains(',')) {
      base64Data = base64String.split(',').last;
    }
    return base64Decode(base64Data);
  }

  void onImageCaptchaConfirm() async {
    if (imageCaptchaInput.value.isEmpty) {
      FToastUtil.show('请输入验证码');
      return;
    }

    if (isCaptchaLoading.value) return;
    isCaptchaLoading.value = true;

    try {
      final res = await AsyncHandler.handle(
          future: postGetVerifyCode(
        phoneNumber: phone.value,
        type: 3,
        oneKey: oneKey.value,
        imageCode: imageCaptchaInput.value,
      ));

      if (res.ok) {
        showOkToast("验证码发送成功");
        Get.back();
        startCountdown();
      } else {
        FToastUtil.show(res.message ?? '验证码错误');
        imageCaptchaController.clear();
        imageCaptchaInput.value = '';
        fetchImageCode();
      }
    } catch (e) {
      FToastUtil.show('请求失败，请重试');
      imageCaptchaController.clear();
      imageCaptchaInput.value = '';
      fetchImageCode();
    } finally {
      isCaptchaLoading.value = false;
    }
  }

  void validateAndSubmit() {
    if (phone.value.length != 11) {
      FToastUtil.show('请输入11位手机号');
      return;
    }
    if (captcha.value.length != 6) {
      FToastUtil.show('请输入6位验证码');
      return;
    }
    if (password.value.length < 6) {
      FToastUtil.show('请输入密码');
      return;
    }
    if (confirmPassword.value.length < 6) {
      FToastUtil.show('请再次输入密码');
      return;
    }
    onSubmit();
  }

  Future<void> onSubmit() async {
    if (!isFormValid) return;

    if (!isPhoneFormatValid) {
      FToastUtil.show('手机号格式错误');
      return;
    }

    if (!isPasswordFormatValid) {
      FToastUtil.show('密码为6-16位字母和数字的组合');
      return;
    }

    if (password.value != confirmPassword.value) {
      FToastUtil.show('两次密码输入不一致');
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final encryptedPwd = _encryptPassword(password.value);
      final res = await postResetPassword(
        phone: phone.value,
        captcha: captcha.value,
        password: encryptedPwd,
      );

      if (res.ok) {
        FToastUtil.show('成功修改密码');
        Get.back();
      } else {
        FToastUtil.show(res.message ?? '修改密码失败');
      }
    } catch (e) {
      FToastUtil.show('修改密码失败');
    } finally {
      isLoading.value = false;
    }
  }

  String _encryptPassword(String pwd) {
    final bytes = utf8.encode(pwd);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}
