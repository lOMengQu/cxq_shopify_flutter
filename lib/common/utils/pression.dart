import 'dart:io';
import 'package:cxq_merchant_flutter/common/utils/sp_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import "package:get/get.dart";

/// 权限类型枚举
enum PermissionType {
  photos,      // 相册
  camera,      // 相机
  microphone,  // 麦克风
  storage,     // 存储
  audio,       // 音频
  videos,      // 视频
}

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
void showPermissionSnackbarPersistent(
    {Color backColor = Colors.black54,
      String context =
      "为帮助你发布作品，应用需获取相册和录音权限。我们承诺仅在你使用发布功能时使用这些权限，不会收集或上传无关内容。"}) {
  Get.snackbar(
    "提示",
    context,
    snackPosition: SnackPosition.TOP,
    backgroundColor: backColor,
    colorText: Colors.white,
    margin: EdgeInsets.all(10),
    borderRadius: 8,
    duration: Duration(days: 1),
    // ❗ 不自动消失
    isDismissible: false, // ❗ 禁止手势关闭
  );
}

Future<bool> requestAudioVideoPermissions() async {
  // return true;
  if (Platform.isAndroid) {
    final info = await DeviceInfoPlugin().androidInfo;
    final release = info.version.release;
    if (release.contains("11") || release.contains("12")) {
      bool audioGranted = await Permission.microphone.isGranted;
      bool videoGranted = await Permission.storage.isGranted;
      bool manageExternalStorage =
      await Permission.manageExternalStorage.isGranted;

      if (audioGranted && videoGranted && manageExternalStorage) {
        await SPUtils.setBool("permission", true);

        return true;
      }

      List<Permission> toRequest = [];
      if (!audioGranted) {
        toRequest.add(Permission.microphone);
      }
      if (!videoGranted) {
        toRequest.add(Permission.storage);
      }
      if (!manageExternalStorage) {
        toRequest.add(Permission.manageExternalStorage);
      }
      showPermissionSnackbarPersistent();
      await Future.delayed(Duration(milliseconds: 500));
      Map<Permission, PermissionStatus> statuses = await toRequest.request();
      Get.closeCurrentSnackbar();

      bool audioOk =
          audioGranted || (statuses[Permission.microphone]?.isGranted == true);
      bool videoOk =
          videoGranted || (statuses[Permission.storage]?.isGranted == true);
      bool manageOK = manageExternalStorage ||
          (statuses[Permission.manageExternalStorage]?.isGranted == true);

      return audioOk && videoOk && manageOK;
    } else {
      bool audioGranted = await Permission.audio.isGranted;
      bool videoGranted = await Permission.videos.isGranted;
      // bool manageExternalStorage =
      //     await Permission.manageExternalStorage.isGranted;
// 是否有限授权
      bool audioLimited = await Permission.audio.isLimited;
      bool videoLimited = await Permission.videos.isLimited;
      if ((audioGranted || audioLimited) &&
          (videoGranted || videoLimited)
      // &&
      // manageExternalStorage
      ) {
        return true;
      }

      // 创建一个权限列表，按需添加需要申请的权限
      List<Permission> toRequest = [];
      if (!audioGranted) {
        toRequest.add(Permission.audio);
      }
      if (!videoGranted) {
        toRequest.add(Permission.videos);
      }

      showPermissionSnackbarPersistent();
      await Future.delayed(Duration(milliseconds: 500));
      // 申请对应的权限
      Map<Permission, PermissionStatus> statuses = await toRequest.request();
      Get.closeCurrentSnackbar();


      // 判断申请结果，如果之前没授权的都申请成功才返回true
      bool audioOk =
          audioGranted || (statuses[Permission.audio]?.isGranted == true);
      bool videoOk =
          videoGranted || (statuses[Permission.videos]?.isGranted == true);

      return audioOk && videoOk;
      // && manageOK;
    }
  } else if (Platform.isIOS) {
    PermissionStatus photoStatus = await Permission.photos.status;
    if (photoStatus.isDenied || photoStatus.isLimited) {
      photoStatus = await Permission.photos.request();
      if (photoStatus.isPermanentlyDenied) {
        // 权限被永久拒绝，打开设置页面
        // openAppSettings();
        return false;
      }
      if (photoStatus.isLimited||photoStatus.isGranted) {
        return true;
        // 用户只允许有限访问，可提示去设置开启全部权限
        // openAppSettings();
      }
    }



    return (photoStatus.isGranted || photoStatus.isLimited);
    // &&
    // micStatus.isGranted;
  }
  return false;
}

/// 通用权限请求方法
/// [permissionTypes] 需要请求的权限类型列表，默认为空表示请求所有权限
/// [showSnackbar] 是否显示权限提示 Snackbar，默认 true
Future<bool> requestPermissions({
  List<PermissionType>? permissionTypes,
  bool showSnackbar = true,
}) async {
  // 如果没有指定权限类型，则请求所有权限（调用原有方法）
  if (permissionTypes == null || permissionTypes.isEmpty) {
    return requestAudioVideoPermissions();
  }

  List<Permission> toRequest = [];

  if (Platform.isAndroid) {
    final info = await DeviceInfoPlugin().androidInfo;
    final sdkInt = info.version.sdkInt;

    for (var type in permissionTypes) {
      switch (type) {
        case PermissionType.photos:
        // Android 13+ 使用 photos 权限，低版本使用 storage
          if (sdkInt >= 33) {
            if (!await Permission.photos.isGranted) {
              toRequest.add(Permission.photos);
            }
          } else {
            if (!await Permission.storage.isGranted) {
              toRequest.add(Permission.storage);
            }
          }
          break;
        case PermissionType.camera:
          if (!await Permission.camera.isGranted) {
            toRequest.add(Permission.camera);
          }
          break;
        case PermissionType.microphone:
          if (!await Permission.microphone.isGranted) {
            toRequest.add(Permission.microphone);
          }
          break;
        case PermissionType.storage:
          if (!await Permission.storage.isGranted) {
            toRequest.add(Permission.storage);
          }
          break;
        case PermissionType.audio:
          if (sdkInt >= 33) {
            if (!await Permission.audio.isGranted) {
              toRequest.add(Permission.audio);
            }
          }
          break;
        case PermissionType.videos:
          if (sdkInt >= 33) {
            if (!await Permission.videos.isGranted) {
              toRequest.add(Permission.videos);
            }
          }
          break;
      }
    }

    if (toRequest.isEmpty) {
      return true;
    }

    if (showSnackbar) {
      showPermissionSnackbarPersistent(
        context: _getPermissionHintText(permissionTypes),
      );
      await Future.delayed(Duration(milliseconds: 500));
    }

    Map<Permission, PermissionStatus> statuses = await toRequest.request();

    if (showSnackbar) {
      Get.closeCurrentSnackbar();
    }

    // 检查所有请求的权限是否都已授权
    for (var permission in toRequest) {
      if (statuses[permission]?.isGranted != true &&
          statuses[permission]?.isLimited != true) {
        return false;
      }
    }
    return true;

  } else if (Platform.isIOS) {
    for (var type in permissionTypes) {
      Permission? permission;
      switch (type) {
        case PermissionType.photos:
          permission = Permission.photos;
          break;
        case PermissionType.camera:
          permission = Permission.camera;
          break;
        case PermissionType.microphone:
          permission = Permission.microphone;
          break;
        case PermissionType.storage:
        case PermissionType.audio:
        case PermissionType.videos:
        // iOS 不需要这些权限
          continue;
      }

      if (permission != null) {
        PermissionStatus status = await permission.status;
        // 已授权或有限授权，跳过
        if (status.isGranted || status.isLimited) {
          continue;
        }
        // 未授权，发起请求
        status = await permission.request();
        if (status.isPermanentlyDenied) {
          // 权限被永久拒绝
          // openAppSettings();
          return false;
        }
        if (!status.isGranted && !status.isLimited) {
          return false;
        }
      }
    }
    return true;
  }

  return false;
}

/// 获取权限提示文本
String _getPermissionHintText(List<PermissionType> types) {
  List<String> names = [];
  for (var type in types) {
    switch (type) {
      case PermissionType.photos:
        names.add('相册');
        break;
      case PermissionType.camera:
        names.add('相机');
        break;
      case PermissionType.microphone:
        names.add('麦克风');
        break;
      case PermissionType.storage:
        names.add('存储');
        break;
      case PermissionType.audio:
        names.add('音频');
        break;
      case PermissionType.videos:
        names.add('视频');
        break;
    }
  }
  return '为帮助你使用此功能，应用需获取${names.join('、')}权限。';
}
