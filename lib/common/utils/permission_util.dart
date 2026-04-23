import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import "package:get/get.dart";

/// 检查是否已有相册/存储权限（不触发权限请求弹窗）
Future<bool> hasPhotoPermission() async {
  if (Platform.isAndroid) {
    final info = await DeviceInfoPlugin().androidInfo;
    final sdkInt = info.version.sdkInt;
    if (sdkInt >= 33) {
      return await Permission.photos.isGranted ||
          await Permission.photos.isLimited;
    } else {
      return await Permission.storage.isGranted;
    }
  } else if (Platform.isIOS) {
    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }
  return false;
}

/// 显示权限提示的 Snackbar
void showPermissionSnackbarPersistent({
  Color backColor = Colors.black54,
  String context =
      "为帮助你上传头像，应用需获取相册权限。我们承诺仅在你使用上传功能时使用该权限，不会收集或上传无关内容。",
}) {
  Get.snackbar(
    "提示",
    context,
    snackPosition: SnackPosition.TOP,
    backgroundColor: backColor,
    colorText: Colors.white,
    margin: EdgeInsets.all(10),
    borderRadius: 8,
    duration: Duration(days: 1),
    isDismissible: false,
  );
}
