import 'package:cxq_merchant_flutter/api/http/env_config.dart';

class ApiEndpoints {
  /// HTTP 基础地址，跟随 EnvConfig.currentEnv 自动切换
  static String get baseUrl => EnvConfig.httpBaseUrl;

  /// 隐私政策
  static String privacyPolicyUrl = '$baseUrl/share/page5/';

  /// 用户协议
  static String userAgreementUrl = '$baseUrl/share/page6/';

  // ========== 登录注册相关 ==========
  /// 验证码登录/注册
  static const String loginOrRegisterByCaptcha =
      '/chaoxingqiu/account/login_or_register_by_captcha_v_5_1_0/';

  /// 密码登录
  static const String loginByPassword =
      '/chaoxingqiu/account/login_by_password_v_5_1_0/';

  /// 获取图片验证码
  static const String getVerifyImage =
      '/chaoxingqiu/account/get_verify_image_v_5_1_0/';

  /// 获取短信验证码
  static const String getVerifyCode =
      '/chaoxingqiu/account/get_verify_code_in_user_v_5_0_1/';

  /// 一键登录（运营商免密认证）
  static const String oneClickLogin =
      '/chaoxingqiu/account/login_or_register_by_captcha_v_5_1_0/';

  /// 重置密码
  static const String resetPassword =
      '/chaoxingqiu/account/password/';

  /// 邀请码校验
  static const String invitation =
      '/chaoxingqiu/account/invitation/';

  /// 编辑用户信息（头像/昵称）
  static const String accountUser =
      '/chaoxingqiu/account/user/';

  /// 文件上传凭证
  static const String fileUploadAuth =
      '/chaoxingqiu/file/uploads/auth/info/';
}
