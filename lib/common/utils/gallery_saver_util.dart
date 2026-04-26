import 'dart:io';

import 'package:cxq_merchant_flutter/common/utils/pression.dart';
import 'package:cxq_merchant_flutter/common/utils/toast.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

// 你项目里的：
// import 'xxx/permission/permission.dart'; // requestPermissions / PermissionType
// import 'xxx/toast/toast.dart';           // showOkToast

/// 相册保存工具
class GallerySaverUtil {
  GallerySaverUtil._(); // 禁止实例化

  /// 保存网络图片到相册
  ///
  /// [imageUrl] 网络图片地址
  /// [filePrefix] 临时文件名前缀
  /// [toastOnSuccess] 是否提示“保存成功”
  /// [toastOnFail] 是否提示“保存失败”
  static Future<bool> saveNetworkImageToGallery(
      String imageUrl, {
        String filePrefix = 'image',
        bool toastOnSuccess = true,
        bool toastOnFail = true,
      }) async {
    File? tempFile;
    try {
      final hasPermission = await _requestPhotoPermission();
      if (!hasPermission) {
        showOkToast('请授予相册权限');
        return false;
      }

      // 下载图片（二进制）
      final resp = await Dio().get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = resp.data;
      if (bytes == null || bytes.isEmpty) {
        if (toastOnFail) showOkToast('保存失败');
        return false;
      }

      // 写入临时文件
      final tempDir = await getTemporaryDirectory();
      final fileName =
          '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);

      // 保存到相册
      await Gal.putImage(tempFile.path);

      if (toastOnSuccess) showOkToast('保存成功');
      return true;
    } catch (_) {
      if (toastOnFail) showOkToast('保存失败');
      return false;
    } finally {
      // 删除临时文件
      try {
        if (tempFile != null && await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}
    }
  }

  /// 请求相册权限（沿用你项目现有封装）
  static Future<bool> _requestPhotoPermission() async {
    return await requestPermissions(
      permissionTypes: [PermissionType.photos],
      showSnackbar: true,
    );
  }
}
