import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constants/app_constants.dart';

void showTipDialog({
  required String title,
  required String leftText,
  required String rightText,
  required VoidCallback onLeftTap,
  required VoidCallback onRightTap,
  Color? leftTextColor,
  Color? rightTextColor,
  bool barrierDismissible = false,
}) {
  Get.dialog(
    Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 40.w),
        width: 260.w,
        height: 120.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 1.h,
              color: dividerColor,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onLeftTap,
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                        child: Text(
                          leftText,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: leftTextColor ?? textAssist,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1.h,
                    height: double.infinity,
                    color: dividerColor,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: onRightTap,
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                        child: Text(
                          rightText,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: rightTextColor ?? primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ),
    barrierDismissible: barrierDismissible,
  );
}
