import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cxq_merchant_flutter/common/utils/sp_utils.dart';
import 'package:cxq_merchant_flutter/app/routes/app_pages.dart';
import 'package:cxq_merchant_flutter/common/utils/toast.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:mutex/mutex.dart';
import '../z_entity/base_response.dart';
import 'api_endpoints.dart';
import 'package:get/get.dart';

class ApiClient {
  ApiClient._internal() {
    _createDio(ApiEndpoints.baseUrl);
  }

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late Dio _dio;
  CancelToken _globalCancelToken = CancelToken();

  void _createDio(String baseUrl) {
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Content-Type': 'application/json'},
      responseType: ResponseType.json,
      validateStatus: (status) {
        if (status == null) return false;
        if (status == 422) return true;
        return status >= 200 && status < 300;
      },
    );

    _dio = Dio(options);

    _dio.interceptors.addAll([
      _HeaderInterceptor(),
      _LoggingInterceptor(),
      _TokenExpiredInterceptor(),
      _ErrorTextInterceptor(),
    ]);
  }

  /// 取消当前所有请求，并重置全局 CancelToken
  void cancelAll([String reason = 'Cancel by global signal']) {
    try {
      _globalCancelToken.cancel(reason);
    } finally {
      _globalCancelToken = CancelToken();
    }
  }

  // --- 对外暴露的请求方法 ---

  Future<BaseResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic)? fromJsonT,
    Map<String, String>? headers,
  }) =>
      _request<T>(
        method: 'GET',
        path: path,
        query: query,
        headers: headers,
        fromJsonT: fromJsonT,
      );

  Future<BaseResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJsonT,
    Map<String, String>? headers,
    bool isFileUpload = false,
    ProgressCallback? onSendProgress,
  }) =>
      _request<T>(
        method: 'POST',
        path: path,
        data: data,
        headers: headers,
        fromJsonT: fromJsonT,
        isFileUpload: isFileUpload,
        onSendProgress: onSendProgress,
      );

  Future<BaseResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJsonT,
    Map<String, String>? headers,
  }) =>
      _request<T>(
        method: 'PUT',
        path: path,
        data: data,
        headers: headers,
        fromJsonT: fromJsonT,
      );

  Future<BaseResponse<T>> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJsonT,
    Map<String, String>? headers,
  }) =>
      _request<T>(
        method: 'PATCH',
        path: path,
        data: data,
        headers: headers,
        fromJsonT: fromJsonT,
      );

  Future<BaseResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? query,
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? fromJsonT,
  }) =>
      _request<T>(
        method: 'DELETE',
        path: path,
        query: query,
        data: data,
        headers: headers,
        fromJsonT: fromJsonT,
      );

  // --- 统一底层请求 ---

  Future<BaseResponse<T>> _request<T>({
    required String method,
    required String path,
    Map<String, dynamic>? query,
    dynamic data,
    Map<String, String>? headers,
    T Function(dynamic)? fromJsonT,
    bool isFileUpload = false,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final options = Options(
        method: method,
        headers: headers,
        sendTimeout: isFileUpload ? Duration.zero : null,
        receiveTimeout: isFileUpload ? Duration.zero : null,
      );

      final res = await _dio.request<dynamic>(
        path,
        queryParameters: query,
        data: data,
        options: options,
        cancelToken: _globalCancelToken,
        onSendProgress: onSendProgress,
      );

      final map = (res.data is Map<String, dynamic> ||
              res.data is List<dynamic>)
          ? res.data
          : jsonDecode(jsonEncode(res.data));

      final parsed = BaseResponse<T>.fromJson(
        map,
        fromJsonT: fromJsonT,
      );

      return parsed;
    } on DioException catch (e) {
      return BaseResponse.errorResponse<T>(
        message: _formatDioError(e),
        code: e.response?.statusCode.toString(),
      );
    } catch (e) {
      return BaseResponse.errorResponse<T>(message: e.toString());
    }
  }
}

// ───────────────── Interceptors ─────────────────

class _HeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = SPUtils.getString("token");
    if (token != null && token.isNotEmpty) {
      options.headers['token'] = token;
    }
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('🚀 ${options.method} ${options.uri}');
    debugPrint('headers: ${options.headers}');
    debugPrint('data: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(dio.Response response, ResponseInterceptorHandler handler) {
    debugPrint('✅ ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('resp: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ ${err.requestOptions.method} ${err.requestOptions.uri}');
    debugPrint('💥 ${err.message}');
    handler.next(err);
  }
}

/// 处理 401 token 过期：跳转登录页并清除用户数据
class _TokenExpiredInterceptor extends Interceptor {
  static bool _isHandling = false;
  static final _mutex = Mutex();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    if (statusCode == 401) {
      await _handleTokenExpired();
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          error: '登录状态已过期，请重新登录',
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }
    handler.next(err);
  }

  Future<void> _handleTokenExpired() async {
    await _mutex.protect(() async {
      if (_isHandling) return;
      _isHandling = true;

      try {
        ApiClient().cancelAll('Token expired');
        showOkToast('登录状态已过期，请重新登录');
        Get.offAllNamed(Routes.login);
      } finally {
        Future.delayed(const Duration(seconds: 2), () {
          _isHandling = false;
        });
      }
    });
  }
}

class _ErrorTextInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final msg = _formatDioError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: msg,
        type: err.type,
      ),
    );
  }
}

String _formatDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
      return '网络连接超时，请稍后重试';
    case DioExceptionType.badResponse:
      return '服务端错误，状态码：${e.response?.statusCode}';
    case DioExceptionType.cancel:
      return '请求已取消';
    case DioExceptionType.unknown:
      return '未知错误：${e.message}';
    default:
      return e.message ?? '网络错误';
  }
}
