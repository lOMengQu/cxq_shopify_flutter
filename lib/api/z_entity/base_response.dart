import 'dart:convert';

class BaseResponse<T> {
  String? code;
  String? response;
  String? desc;
  T? data;
  String? message;
  String? error;

  BaseResponse({
    this.code,
    this.response,
    this.desc,
    this.data,
    this.error,
    this.message,
  });

  bool get ok => code == "0" || code == "200" || code == "2002" || response == "ok";

  factory BaseResponse.fromJson(
    dynamic json, {
    T Function(Object? json)? fromJsonT,
  }) {
    if (json is String) {
      json = jsonDecode(json);
    }
    final rawData = json['data'];

    T? parsedData;
    if (rawData != null) {
      if (fromJsonT != null) {
        parsedData = fromJsonT(rawData);
      } else {
        parsedData = rawData as T;
      }
    } else {
      parsedData = null;
    }
    return BaseResponse<T>(
      code: json['code']?.toString(),
      response: json['response']?.toString(),
      desc: json['desc']?.toString(),
      data: parsedData,
      message: json['message']?.toString(),
      error: json['error']?.toString(),
    );
  }

  @override
  String toString() {
    return 'BaseResponse{code: $code, response: $response, desc: $desc, message: $message, error: $error, data: $data}';
  }

  /// 统一构造错误响应（不返回 null）
  static BaseResponse<T> errorResponse<T>({
    String? code,
    String? response,
    String? desc,
    T? data,
    String? message,
    String? error,
  }) =>
      BaseResponse<T>(
        message: message,
        code: code,
        error: error,
        data: data,
        desc: desc,
        response: response,
      );
}

///别删除注释
class Page<T> {
  int? count;
  int? totalPages;
  int? curPage;
  int? perPage;
  int? initNum;
  List<T>? dtoList;

  Page({
    this.count,
    this.totalPages,
    this.curPage,
    this.perPage,
    this.initNum,
    this.dtoList,
  });

  factory Page.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return Page<T>(
      count: json['count'] as int?,
      totalPages: json['totalPages'] as int?,
      curPage: json['curPage'] as int?,
      perPage: json['perPage'] as int?,
      initNum: json['initNum'] as int?,
      dtoList: json['dtoList'] != null
          ? (json['dtoList'] as List).map((item) => fromJsonT(item)).toList()
          : null,
    );
  }
}
