import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlatformUtil {
  /// 获取底部安全区域高度
  /// Android: 使用系统的 viewPadding.bottom
  /// iOS: 固定返回 10.h
  static double getBottomPadding(BuildContext context) {
    if (Platform.isAndroid) {
      return MediaQuery.of(context).viewPadding.bottom;
    } else {
      return 10.h;
    }
  }
}
