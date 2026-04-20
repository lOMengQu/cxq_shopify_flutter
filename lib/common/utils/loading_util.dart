import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// EasyLoading 配置
void configEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class LoadingUtil {
  static void show({String? status}) {
    EasyLoading.show(status: status);
  }

  static void dismiss() {
    EasyLoading.dismiss();
  }

  static void showSuccess(String status) {
    EasyLoading.showSuccess(status);
  }

  static void showError(String status) {
    EasyLoading.showError(status);
  }
}
