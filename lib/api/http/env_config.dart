/// 环境枚举
enum Env { test, official }

/// 统一环境配置，一处切换，HTTP / WS 地址全部跟随
class EnvConfig {
  EnvConfig._();
  // ============ 在这里切换环境 ============
  static Env currentEnv = Env.test;
  // =======================================

  // ---------- HTTP ----------
  static const _httpUrlMap = {
    Env.test: 'http://businesstestapi.chaoxingqiu.cn',
    Env.official: 'https://businessapi.chaoxingqiu.cn',
  };

  static String get httpBaseUrl => _httpUrlMap[currentEnv]!;

  // ---------- WebSocket ----------
  static const _wsUrlMap = {
    Env.test: 'wss://apptest.chaoxingqiu.cn',
    Env.official: 'wss://app.chaoxingqiu.cn',
  };

  static String get wsBaseUrl => _wsUrlMap[currentEnv]!;

  /// WS host（用于构建 Uri）
  static String get wsHost {
    switch (currentEnv) {
      case Env.test:
        return 'apptest.chaoxingqiu.cn';
      case Env.official:
        return 'app.chaoxingqiu.cn';
    }
  }

  // ---------- 便捷方法 ----------
  static bool get isTest => currentEnv == Env.test;
  static bool get isOfficial => currentEnv == Env.official;

  /// 切换环境（如果需要运行时动态切换）
  static void switchEnv(Env env) {
    currentEnv = env;
  }
}
