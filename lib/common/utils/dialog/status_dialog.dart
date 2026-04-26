import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constants/app_constants.dart';

void showStatusDialog({
  required Function(String) onConfirm,
  String? initialStatus,
}) {
  final controller = TextEditingController(text: initialStatus ?? '');
  final textLength = (initialStatus?.length ?? 0).obs;
  final hasChanged = false.obs;
  final initialText = initialStatus ?? '';

  controller.addListener(() {
    textLength.value = controller.text.length;
    hasChanged.value = controller.text != initialText;
  });

  Get.dialog(
    Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 32.w),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16.h),
            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Text(
                  '设置当前状态',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    maxLength: 40,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'citywalk中，找搭子',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: hintColor,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Obx(
                          () => Text(
                        '${textLength.value}/40',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: textAssist,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
                  () => GestureDetector(
                onTap: hasChanged.value
                    ? () {
                  Get.back();
                  onConfirm(controller.text);
                }
                    : null,
                child: Center(
                  child: Text(
                    '设置',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color:hasChanged.value?primary: textAssist,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
