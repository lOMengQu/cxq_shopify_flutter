import 'dart:io';

import 'package:cxq_merchant_flutter/common/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'invite_code_logic.dart';

class InviteCodePage extends GetView<InviteCodeLogic> {
  const InviteCodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                _buildAppBar(),
                SizedBox(height: 30.h),
                _buildTitle(),
                SizedBox(height: 40.h),
                _buildCodeInput(context),
                SizedBox(height: 30.h),
                _buildHintSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios,
              size: 20.w,
              color: textPrimary,
            ),
          ),
          if (!Platform.isIOS)
            Obx(() {
              if (controller.showSkipButton.value) {
                return GestureDetector(
                  onTap: controller.skip,
                  child: Text(
                    '跳过',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: textPrimary,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            })
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text.rich(
        TextSpan(
          text: '请输入',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          children: [
            TextSpan(
              text: '密钥',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        controller: controller.codeController,
        keyboardType: TextInputType.visiblePassword,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          LengthLimitingTextInputFormatter(6),
        ],
        autoFocus: true,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(8.r),
          fieldHeight: 50.h,
          fieldWidth: 45.w,
          activeFillColor: background,
          inactiveFillColor: background,
          selectedFillColor: background,
          activeColor: background,
          inactiveColor: background,
          selectedColor: primary,
        ),
        textStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        enableActiveFill: true,
        onChanged: controller.onCodeChanged,
        beforeTextPaste: (text) => true,
      ),
    );
  }

  Widget _buildHintSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: controller.toggleHint,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16.w,
                  color: textAssist,
                ),
                SizedBox(width: 4.w),
                Text(
                  '密钥',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: primary,
                  ),
                ),
                Text(
                  '是什么？',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (!controller.isHintExpanded.value) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(top: 12.h, left: 16.w, right: 30.w),
              child: Text.rich(
                TextSpan(
                  text: '密钥是为了保护伙伴们有一个更干净的社交氛围,如果你愿意加入我们,可以添加',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: textPrimary,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'chaoxingqiuxx',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: primary,
                      ),
                    ),
                    TextSpan(
                      text: '取得密钥。',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
