import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:cxq_merchant_flutter/api/service/file_api.dart';
import 'package:cxq_merchant_flutter/api/z_entity/file/oss_auth_entity.dart';

class OssUploadUtil {
  static OssAuthEntity? _credentials;
  static final Dio _dio = Dio();

  // OSS 配置
  static const String _bucket = 'shangbian';
  static const String _endpoint = 'oss-cn-hangzhou.aliyuncs.com';

  /// 获取 OSS 临时凭证
  static Future<bool> fetchCredentials() async {
    try {
      final response = await postFileUploadAuth(category: 1, fileType: 1);
      if (response.ok && response.data != null) {
        _credentials = response.data;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 检查凭证是否有效
  static bool _isCredentialsValid() {
    if (_credentials == null) return false;
    if (_credentials!.expiration == null) return false;

    try {
      final expTime = DateTime.parse(_credentials!.expiration!);
      return DateTime.now().toUtc().isBefore(expTime.subtract(Duration(minutes: 5)));
    } catch (e) {
      return false;
    }
  }

  /// 确保凭证有效
  static Future<bool> _ensureCredentials() async {
    if (_isCredentialsValid()) return true;
    return await fetchCredentials();
  }

  /// 使用指定时间戳上传文件
  static Future<String?> uploadFileWithTimestamp(File file, int timestamp, String type) async {
    if (!await _ensureCredentials()) {
      return null;
    }

    try {
      final ext = file.path.split('.').last.toLowerCase();
      final fileName = '${timestamp}_$type.$ext';
      final objectKey = 'ugc/img/$fileName';

      final bytes = await file.readAsBytes();
      final contentType = _getContentType(file.path);

      final date = HttpDate.format(DateTime.now().toUtc());
      final canonicalizedResource = '/$_bucket/$objectKey';
      final canonicalizedOSSHeaders = 'x-oss-security-token:${_credentials!.securityToken}';

      final stringToSign = 'PUT\n\n$contentType\n$date\n$canonicalizedOSSHeaders\n$canonicalizedResource';

      final hmacSha1 = Hmac(sha1, utf8.encode(_credentials!.accessKeySecret!));
      final signature = base64.encode(hmacSha1.convert(utf8.encode(stringToSign)).bytes);

      final authorization = 'OSS ${_credentials!.accessKeyId}:$signature';

      final url = 'https://$_bucket.$_endpoint/$objectKey';

      final response = await _dio.put(
        url,
        data: bytes,
        options: Options(
          headers: {
            'Authorization': authorization,
            'Date': date,
            'Content-Type': contentType,
            'x-oss-security-token': _credentials!.securityToken,
          },
          contentType: contentType,
          responseType: ResponseType.plain,
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode == 200) {
        return url;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// 获取文件 Content-Type
  static String _getContentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
      case 'heif':
        return 'image/heic';
      default:
        return 'application/octet-stream';
    }
  }
}
