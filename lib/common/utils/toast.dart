import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FToastUtil {
  static void show(String message, {Color color = Colors.black87}) {
    showOkToast(message, color: color);
  }
}

void showOkToast(String message, {Color color = Colors.black87}) {
  var w = Container(
    padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 12.0.h),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5.r),
      color: color,
    ),
    child: Text(message, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
  );
  showToastWidget(w, position: ToastPosition.center, dismissOtherToast: true);
}
