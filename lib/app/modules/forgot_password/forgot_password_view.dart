import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cxq_merchant_flutter/common/constants/app_constants.dart';

import 'forgot_password_logic.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotPasswordLogic>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset(
            "assets/login/back.png",
            width: double.infinity,
            height: 262.h,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20.w,
                      color: textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Text(
                          '忘记密码',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(height: 40.h),
                        _buildPhoneInput(controller),
                        SizedBox(height: 16.h),
                        _buildCaptchaInput(controller),
                        SizedBox(height: 16.h),
                        _buildPasswordInput(controller),
                        SizedBox(height: 16.h),
                        _buildConfirmPasswordInput(controller),
                        SizedBox(height: 40.h),
                        _buildSubmitButton(controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black26,
                  child: Center(
                    child: CircularProgressIndicator(color: primary),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(ForgotPasswordLogic controller) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              style: TextStyle(fontSize: 14.sp, color: textFiledColor),
              decoration: InputDecoration(
                hintText: '请输入手机号',
                hintStyle: TextStyle(fontSize: 14.sp, color: hintColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Obx(() => controller.phone.value.isNotEmpty
              ? GestureDetector(
                  onTap: controller.clearPhone,
                  child: Icon(Icons.cancel, size: 18.w, color: hintColor),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildCaptchaInput(ForgotPasswordLogic controller) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.captchaController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: TextStyle(fontSize: 14.sp, color: textFiledColor),
              decoration: InputDecoration(
                hintText: '请输入验证码',
                hintStyle: TextStyle(fontSize: 14.sp, color: hintColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Obx(() => controller.captcha.value.isNotEmpty
              ? GestureDetector(
                  onTap: controller.clearCaptcha,
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Icon(Icons.cancel, size: 18.w, color: hintColor),
                  ),
                )
              : const SizedBox.shrink()),
          Container(
            width: 1,
            height: 20.h,
            color: dividerColor2,
          ),
          SizedBox(width: 12.w),
          Obx(() => GestureDetector(
                onTap: controller.isCountingDown.value
                    ? null
                    : controller.onGetCaptchaTap,
                child: Text(
                  controller.isCountingDown.value
                      ? '重新获取${controller.countdown.value}s'
                      : '获取验证码',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: controller.isCountingDown.value
                        ? textAssist
                        : controller.phone.isEmpty &&
                                controller.phoneController.text.isEmpty
                            ? textAssist
                            : primary,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPasswordInput(ForgotPasswordLogic controller) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => TextField(
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(16),
                  ],
                  style: TextStyle(fontSize: 14.sp, color: textFiledColor),
                  decoration: InputDecoration(
                    hintText: '新密码（6-16位数字和字母）',
                    hintStyle: TextStyle(fontSize: 14.sp, color: hintColor),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                )),
          ),
          Obx(() => GestureDetector(
                onTap: controller.togglePasswordVisibility,
                child: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  size: 20.w,
                  color: hintColor,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordInput(ForgotPasswordLogic controller) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => TextField(
                  controller: controller.confirmPasswordController,
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(16),
                  ],
                  style: TextStyle(fontSize: 14.sp, color: textFiledColor),
                  decoration: InputDecoration(
                    hintText: '请再次输入密码',
                    hintStyle: TextStyle(fontSize: 14.sp, color: hintColor),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                )),
          ),
          Obx(() => GestureDetector(
                onTap: controller.toggleConfirmPasswordVisibility,
                child: Icon(
                  controller.isConfirmPasswordVisible.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  size: 20.w,
                  color: hintColor,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ForgotPasswordLogic controller) {
    return Obx(() {
      final isEnabled = controller.isFormValid;
      return GestureDetector(
        onTap: isEnabled ? controller.onSubmit : controller.validateAndSubmit,
        child: Container(
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            color: isEnabled ? primary : const Color(0xFFEEF1F5),
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Center(
            child: Text(
              '完成',
              style: TextStyle(
                fontSize: 16.sp,
                color: isEnabled ? Colors.white : textAssist,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    });
  }
}
