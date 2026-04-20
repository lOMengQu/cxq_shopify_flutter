import 'package:cxq_merchant_flutter/api/http/env_config.dart';

class ApiEndpoints {
  /// HTTP 基础地址，跟随 EnvConfig.currentEnv 自动切换
  static String get baseUrl => EnvConfig.httpBaseUrl;

  // ========== 在这里添加接口路径 ==========
  // static const String login = '/account/login/';
}
