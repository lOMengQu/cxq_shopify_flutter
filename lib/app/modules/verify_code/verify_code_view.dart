import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:cxq_merchant_flutter/common/constants/app_constants.dart';

import 'verify_code_logic.dart';

class VerifyCodePage extends StatelessWidget {
  const VerifyCodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VerifyCodeLogic>();

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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Text(
                        '请填写验证码',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '已将验证码发送至 ${controller.formattedPhone}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: textAssist,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: controller.codeController,
                        keyboardType: TextInputType.number,
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
                      SizedBox(height: 16.h),
                      Obx(() => GestureDetector(
                        onTap: controller.onResendTap,
                        child: Text(
                          controller.isCountingDown.value
                              ? '重新获取验证码 ${controller.countdown.value}s'
                              : '重新获取验证码',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: controller.isCountingDown.value
                                ? textAssist
                                : primary,
                          ),
                        ),
                      )),
                    ],
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
}
