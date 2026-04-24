import 'package:cxq_merchant_flutter/app/routes/app_pages.dart';
import 'package:cxq_merchant_flutter/common/utils/sp_utils.dart';
import 'package:cxq_merchant_flutter/common/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'init_logic.dart';

class InitPage extends GetWidget<InitLogic> {
  const InitPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 140.h,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
                  child: Image.asset(
                    "assets/init.png",
                    width: double.infinity,
                    height: 215.h,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 70.h,
                child: Column(
                  children: [
                    Obx(() => AnimatedPadding(
                          padding: EdgeInsets.only(
                            bottom: controller.isAgreed.value ? 30.h : 0.h,
                          ),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                  horizontal: 16.w),
                              child: Image.asset(
                                "assets/init2.png",
                                width: 118.w,
                                height: 38.h,
                              ),
                            ),
                          ),
                        )),
                    Obx(() => controller.isAgreed.value
                        ? AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                            child: AnimatedScale(
                              scale: 1.0,
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutBack,
                              child: Column(
                                children: [
                                  Container(
                                      margin: EdgeInsetsGeometry.symmetric(
                                          horizontal: 32.w),
                                      height: 46.h,
                                      child: ThemeButton(
                                          child: Text(
                                            "欢迎登陆",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.sp),
                                          ),
                                          radius: 60.r,
                                          onTap: () {
                                            SPUtils.setBool(
                                                "userAgreement", true);
                                            Get.toNamed(Routes.login);
                                          }))
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink())
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
