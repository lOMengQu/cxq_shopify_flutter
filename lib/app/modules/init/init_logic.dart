import 'package:cxq_merchant_flutter/api/http/api_endpoints.dart';
import 'package:cxq_merchant_flutter/common/constants/app_constants.dart';
import 'package:cxq_merchant_flutter/common/utils/sp_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flyverify_plugin/flyverify.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';

class InitLogic extends GetxController {
  final isAgreed = false.obs;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() async {
      try {
        await Flyverify.registerSDK(
            appKey: '36e80cba497b5',
            appSecret: '38a2fbb4d088759547f465bc767e594b');
        await Flyverify.submitPrivacyGrantResult(true, null);
        await Flyverify.enableDebug();
      } catch (e) {
        // ignore init failure, will fallback at login time
      }
    });
  }

  init() async {
    var isUserAgreement = SPUtils.getBool("userAgreement") ?? false;
    if (!isUserAgreement) {
      initDialog();
    } else {
      Get.offNamed(Routes.login);
    }
  }

  initDialog() {
    Get.dialog(
      Center(
        child: Container(
          width: 240.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                child: Column(
                  children: [
                    Text(
                      '潮星球商家端服务声明',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text.rich(
                      TextSpan(
                        text:
                            '感谢您信任并使用潮星球商家端APP。依据最新法律要求，我们整理了用户协议、隐私政策，并根据您使用服务的具体功能对您的信息进行收集使用和共享。希望您仔细阅读',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: textPrimary,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: '《用户服务协议》',
                            style: TextStyle(
                              color: primary,
                              fontSize: 14.sp,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed(Routes.userServiceAgreement,
                                    arguments: {
                                      "agreement":
                                          ApiEndpoints.userAgreementUrl
                                    });
                              },
                          ),
                          const TextSpan(text: '和'),
                          TextSpan(
                            text: '《隐私政策》',
                            style: TextStyle(
                              color: primary,
                              fontSize: 14.sp,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed(Routes.userServiceAgreement,
                                    arguments: {
                                      "agreement":
                                          ApiEndpoints.privacyPolicyUrl
                                    });
                              },
                          ),
                          const TextSpan(
                              text: '了解详细信息，如您【同意】，可点击同意开始接受我们的服务。'),
                        ],
                      ),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 0.5.h,
                color: Colors.grey.shade300,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        SystemNavigator.pop();
                      },
                      child: Container(
                        height: 50.h,
                        child: Center(
                            child: Text(
                          "不同意",
                          style:
                              TextStyle(fontSize: 16.sp, color: textAssist),
                        )),
                      ),
                    ),
                  ),
                  Container(
                    height: 50.h,
                    width: 0.5.h,
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        Get.back();
                        await Future.delayed(
                            const Duration(milliseconds: 300));
                        isAgreed.value = true;
                      },
                      child: Container(
                        height: 50.h,
                        child: Center(
                            child: Text(
                          "同意",
                          style:
                              TextStyle(fontSize: 16.sp, color: primary),
                        )),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onReady() {
    super.onReady();
    init();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
