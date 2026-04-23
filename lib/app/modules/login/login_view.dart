import 'package:cxq_merchant_flutter/common/utils/platform_util.dart';
import 'package:cxq_merchant_flutter/common/constants/app_constants.dart';
import 'package:cxq_merchant_flutter/common/widget/button_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'login_logic.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginLogic controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LoginLogic>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: Get.width,
        height: Get.height,
        color: Colors.white,
        child: Stack(
          children: [
            Image.asset(
              "assets/login/back.png",
              width: double.infinity,
              height: 262.h,
              fit: BoxFit.cover,
            ),
            Positioned(
              height: MediaQuery.of(context).viewPadding.top + 80.h,
              child: GestureDetector(
                  onTap: () {
                    controller.oneClickLoginVerify();
                  },
                  child: Image.asset(
                    "assets/public/back.png",
                    width: 44.w,
                    height: 44.w,
                  )),
            ),
            Positioned(
              top: 180.h,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.asset(
                      "assets/logo.png",
                      width: 76.w,
                      height: 76.w,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    "登录/注册",
                    style: TextStyle(
                        fontSize: 24.sp,
                        color: textPrimary,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 36.h),
                  Obx(() => controller.isPasswordLoginMode.value
                      ? _buildPasswordLoginWidget(controller)
                      : _buildVerifyCodeLoginWidget(controller))
                ],
              ),
            ),
            Positioned(
                bottom: PlatformUtil.getBottomPadding(context) + 30.h,
                left: 30.w,
                right: 30.w,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: controller.toggleAgreement,
                      child: Obx(() => Image.asset(
                            controller.isAgreementChecked.value
                                ? "assets/login/checkbox_circle_checked.png"
                                : "assets/login/checkbox_circle.png",
                            width: 16.w,
                            height: 16.w,
                          )),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: '感谢您对潮星球商家端的信任，请认真阅读',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: textAssist,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: '《用户协议》',
                              style: TextStyle(
                                color: primary,
                                fontSize: 12.sp,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: '、'),
                            TextSpan(
                              text: '《隐私协议》',
                              style: TextStyle(
                                color: primary,
                                fontSize: 12.sp,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyCodeLoginWidget(LoginLogic controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 46.h,
            decoration: BoxDecoration(
                color: Color(0XFFF5F7F9),
                borderRadius: BorderRadius.circular(60.r)),
            child: Row(
              children: [
                SizedBox(width: 20.w),
                Image.asset(
                  "assets/login/user.png",
                  width: 28.w,
                  height: 28.w,
                ),
                SizedBox(width: 8.w),
                Container(
                  height: 14.h,
                  width: 1.w,
                  color: Color(0XFF999999),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(() => TextField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: textFiledColor,
                        ),
                        decoration: InputDecoration(
                          hintText: '请输入手机号',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: textAssist,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          suffixIcon: controller.phone.value.isNotEmpty
                              ? GestureDetector(
                                  onTap: controller.clearPhone,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 16.w),
                                    child: Icon(
                                      Icons.cancel,
                                      size: 18.w,
                                      color: hintColor,
                                    ),
                                  ),
                                )
                              : null,
                          suffixIconConstraints: BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: Obx(() => ThemeButton(
                  radius: 60,
                  enabled: controller.isPhoneValid,
                  onTap: controller.onGetVerifyCodeTap,
                  child: Text(
                    '获取验证码',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color:
                          controller.isPhoneValid ? Colors.white : textAssist,
                    ),
                  ),
                )),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: controller.switchToPasswordLogin,
            child: Text(
              '密码登录',
              style: TextStyle(
                fontSize: 14.sp,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordLoginWidget(LoginLogic controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 46.h,
            decoration: BoxDecoration(
                color: Color(0XFFF5F7F9),
                borderRadius: BorderRadius.circular(60.r)),
            child: Row(
              children: [
                SizedBox(width: 20.w),
                Image.asset(
                  "assets/login/user.png",
                  width: 28.w,
                  height: 28.w,
                ),
                SizedBox(width: 8.w),
                Container(
                  height: 14.h,
                  width: 1.w,
                  color: Color(0XFF999999),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(() => TextField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: textFiledColor,
                        ),
                        decoration: InputDecoration(
                          hintText: '请输入手机号',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: textAssist,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          suffixIcon: controller.phone.value.isNotEmpty
                              ? GestureDetector(
                                  onTap: controller.clearPhone,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 16.w),
                                    child: Icon(
                                      Icons.cancel,
                                      size: 18.w,
                                      color: hintColor,
                                    ),
                                  ),
                                )
                              : null,
                          suffixIconConstraints: BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            height: 46.h,
            decoration: BoxDecoration(
                color: Color(0XFFF5F7F9),
                borderRadius: BorderRadius.circular(60.r)),
            child: Row(
              children: [
                SizedBox(width: 20.w),
                Image.asset(
                  "assets/login/lock.png",
                  width: 28.w,
                  height: 28.w,
                ),
                SizedBox(width: 8.w),
                Container(
                  height: 14.h,
                  width: 1.w,
                  color: Color(0XFF999999),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(() => TextField(
                        controller: controller.passwordController,
                        obscureText: !controller.isPasswordVisible.value,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(16),
                        ],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: textFiledColor,
                        ),
                        decoration: InputDecoration(
                          hintText: '请输入密码',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: textAssist,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )),
                ),
                Obx(() => GestureDetector(
                      onTap: controller.togglePasswordVisibility,
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20.w,
                          color: hintColor,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: Obx(() => ThemeButton(
                  radius: 60,
                  enabled: controller.isPasswordLoginValid,
                  onTap: controller.onPasswordLogin,
                  child: Text(
                    '立即登录',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: controller.isPasswordLoginValid
                          ? Colors.white
                          : textAssist,
                    ),
                  ),
                )),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: controller.switchToVerifyCodeLogin,
                child: Text(
                  '验证码登录',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: textPrimary,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Container(
                  width: 1,
                  height: 12.h,
                  color: dividerColor2,
                ),
              ),
              GestureDetector(
                onTap: controller.goToForgotPassword,
                child: Text(
                  '找回密码',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
