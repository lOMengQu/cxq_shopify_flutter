import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cxq_merchant_flutter/api/http/async_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cxq_merchant_flutter/api/service/user_api.dart';
import 'package:cxq_merchant_flutter/common/utils/toast.dart';
import 'package:cxq_merchant_flutter/common/constants/app_constants.dart';
import 'package:cxq_merchant_flutter/common/utils/login_route_helper.dart';

class VerifyCodeLogic extends GetxController {
  late String phone;
  late String oneKey;
  
  late TextEditingController codeController;
  final verifyCode = ''.obs;
  final isLoading = false.obs;
  
  final countdown = 60.obs;
  final isCountingDown = true.obs;
  Timer? _timer;
  
  late TextEditingController captchaController;
  final captchaInput = ''.obs;
  final imageCodeBase64 = ''.obs;
  final captchaOneKey = ''.obs;
  final isCaptchaLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    codeController = TextEditingController();
    captchaController = TextEditingController();
    final args = Get.arguments as Map<String, dynamic>?;
    phone = args?['phone'] ?? '';
    oneKey = args?['oneKey'] ?? '';
    startCountdown();
  }

  @override
  void onClose() {
    _timer?.cancel();
    codeController.dispose();
    captchaController.dispose();
    super.onClose();
  }

  String get formattedPhone {
    if (phone.length == 11) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 7)} ${phone.substring(7)}';
    }
    return phone;
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

  void onCodeChanged(String code) {
    verifyCode.value = code;
    if (code.length == 6) {
      submitVerifyCode();
    }
  }

  Future<void> submitVerifyCode() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final res = await AsyncHandler.handle(
          future: postLoginOrRegisterByCaptcha(
        phoneNumber: phone,
        captcha: verifyCode.value,
        userType: 2,
      ));

      if (res.ok && res.data != null) {
        await LoginRouteHelper.handleLoginSuccess(res.data!);
      } else if (res.code == '4002') {
        FToastUtil.show('验证码已失效');
        codeController.clear();
      } else {
        FToastUtil.show(res.message ?? '登录失败');
        codeController.clear();
      }
    } catch (e) {
      FToastUtil.show('验证码错误');
      codeController.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void onResendTap() {
    if (isCountingDown.value) return;
    showCaptchaDialog();
  }

  Future<void> fetchImageCode() async {
    if (isCaptchaLoading.value) return;
    isCaptchaLoading.value = true;

    try {
      final res = await postGetVerifyImage(phoneNumber: phone);
      if (res.data != null) {
        imageCodeBase64.value = res.data!.image ?? '';
        captchaOneKey.value = res.data!.oneKey ?? '';
      }
    } catch (e) {
      FToastUtil.show('获取验证码失败');
    } finally {
      isCaptchaLoading.value = false;
    }
  }

  void showCaptchaDialog() {
    captchaController.clear();
    captchaInput.value = '';
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
                    ? Container(
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
                        : Container(
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
                          controller: captchaController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 14.sp, color: textFiledColor),
                          onChanged: (value) => captchaInput.value = value,
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
                GestureDetector(
                  onTap: onCaptchaConfirm,
                  child: Container(
                    width: 110.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Center(
                      child: Text(
                        '确定',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
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

  Future<void> onCaptchaConfirm() async {
    if (captchaInput.value.isEmpty) {
      FToastUtil.show('请输入验证码');
      return;
    }
    
    if (isCaptchaLoading.value) return;
    isCaptchaLoading.value = true;
    
    try {
      final res = await postGetVerifyCode(
        phoneNumber: phone,
        type: 2,
        oneKey: captchaOneKey.value,
        imageCode: captchaInput.value,
      );
      
      if (res.ok) {
        Get.back();
        oneKey = captchaOneKey.value;
        startCountdown();
        FToastUtil.show('验证码已发送');
      } else {
        FToastUtil.show(res.message ?? '验证码错误');
        captchaController.clear();
        captchaInput.value = '';
        fetchImageCode();
      }
    } catch (e) {
      FToastUtil.show('请求失败，请重试');
      captchaController.clear();
      captchaInput.value = '';
      fetchImageCode();
    } finally {
      isCaptchaLoading.value = false;
    }
  }
}
