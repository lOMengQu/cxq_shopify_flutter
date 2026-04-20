import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/utils/toast.dart';
import '../z_entity/base_response.dart';
import 'api_client.dart';

typedef TokenExpiredPredicate = bool Function(BaseResponse<dynamic> resp);

class AsyncHandler {
  /// 建议所有接口通过它来包一层：
  /// - 失败时返回 BaseResponse.error（不为 null）
  /// - 发现 token 过期：跳登录并取消所有请求
  static Future<BaseResponse<T>> handle<T>({
    required Future<BaseResponse<T>> future,
    RxBool? loading,
    VoidCallback? onSuccess,
    Function(String)? onError,
    VoidCallback? onFinally,
    int retryCount = 0,
    TokenExpiredPredicate? isTokenExpired,
  }) async {
    loading?.value = true;
    try {
      int attempts = 0;
      while (true) {
        try {
          final resp = await future;

          if (!resp.ok) {
            if (resp.message != null && resp.message!.isNotEmpty) {
              showOkToast(resp.message!);
              debugPrint(
                  'Business error: code=${resp.code}, msg=${resp.message}');
            }
          } else {
            onSuccess?.call();
          }
          return resp;
        } on DioException catch (e) {
          if (attempts++ < retryCount) continue;
          final msg = e.message ?? '网络异常';
          showOkToast(msg);
          onError?.call(msg);
          return BaseResponse.errorResponse<T>(
            message: msg,
            code: e.response?.statusCode.toString(),
          );
        } catch (e, s) {
          final msg = e.toString().split("Exception: ").last;
          debugPrint('Caught error: $e');
          debugPrint('Stack trace: $s');
          onError?.call(msg);
          return BaseResponse.errorResponse<T>(message: msg);
        }
      }
    } finally {
      loading?.value = false;
      onFinally?.call();
    }
  }
}
