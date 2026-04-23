import 'package:cxq_merchant_flutter/common/utils/sp_utils.dart';

/// Token 管理服务
class UserService {
  static const String _tokenKey = 'token';
  static const String _userIdKey = 'user_id';
  static const String _avatarKey = 'user_avatar';
  static const String _nicknameKey = 'user_nickname';
  static const String _phoneKey = 'user_phone';
  static const String _shopIdKey = 'shop_id';
  static const String _registrationInProgressKey = 'registration_in_progress';

  /// 保存 token
  static Future<void> saveToken(String token) async {
    await SPUtils.setString(_tokenKey, token);
  }

  /// 获取 token
  static String? getToken() {
    return SPUtils.getString(_tokenKey);
  }

  /// 清除 token
  static Future<void> clearToken() async {
    await SPUtils.remove(_tokenKey);
  }

  /// 检查是否有 token
  static bool hasToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  /// 保存用户ID
  static Future<void> saveUserId(String userId) async {
    await SPUtils.setString(_userIdKey, userId);
  }

  /// 获取用户ID
  static String? getUserId() {
    return SPUtils.getString(_userIdKey);
  }

  /// 保存用户头像
  static Future<void> saveAvatar(String avatar) async {
    await SPUtils.setString(_avatarKey, avatar);
  }

  /// 获取用户头像
  static String? getAvatar() {
    return SPUtils.getString(_avatarKey);
  }

  /// 保存用户昵称
  static Future<void> saveNickname(String nickname) async {
    await SPUtils.setString(_nicknameKey, nickname);
  }

  /// 获取用户昵称
  static String? getNickname() {
    return SPUtils.getString(_nicknameKey);
  }

  /// 保存手机号
  static Future<void> savePhone(String phone) async {
    await SPUtils.setString(_phoneKey, phone);
  }

  /// 获取手机号
  static String? getPhone() {
    return SPUtils.getString(_phoneKey);
  }

  static bool isCurrentUser(String? userId) {
    if (userId == null || userId.isEmpty) {
      return false;
    }
    final currentUserId = UserService.getUserId();
    return currentUserId != null && currentUserId == userId;
  }

  /// 清除用户ID
  static Future<void> clearUserId() async {
    await SPUtils.remove(_userIdKey);
  }

  /// 判断是否已登录
  static bool isLoggedIn() {
    return UserService.hasToken() && UserService.getUserId() != null;
  }

  /// 一键保存用户登录数据
  static Future<void> saveUserData({
    required String token,
    required String userId,
    String? avatar,
    String? nickName,
    String? phone,
  }) async {
    await saveToken(token);
    await saveUserId(userId);
    if (avatar != null && avatar.isNotEmpty) {
      await saveAvatar(avatar);
    }
    if (nickName != null && nickName.isNotEmpty) {
      await saveNickname(nickName);
    }
    if (phone != null && phone.isNotEmpty) {
      await savePhone(phone);
    }
  }

  /// 保存店铺ID
  static Future<void> saveShopId(String shopId) async {
    await SPUtils.setString(_shopIdKey, shopId);
  }

  /// 获取店铺ID
  static String? getShopId() {
    return SPUtils.getString(_shopIdKey);
  }

  /// 清除所有用户信息（token 和 userId）
  static Future<void> clearAll() async {
    await clearToken();
    await clearUserId();
    await SPUtils.remove(_avatarKey);
    await SPUtils.remove(_nicknameKey);
    await SPUtils.remove(_phoneKey);
    await SPUtils.remove(_shopIdKey);
    await clearRegistrationInProgress();
  }

  /// 标记注册流程进行中
  static Future<void> setRegistrationInProgress() async {
    await SPUtils.setBool(_registrationInProgressKey, true);
  }

  /// 清除注册流程标记（注册完成时调用）
  static Future<void> clearRegistrationInProgress() async {
    await SPUtils.remove(_registrationInProgressKey);
  }

  /// 检查是否有未完成的注册流程
  static bool isRegistrationInProgress() {
    return SPUtils.getBool(_registrationInProgressKey) ?? false;
  }

  /// 检查并清理未完成的注册（app 启动时调用）
  static Future<void> checkAndClearIncompleteRegistration() async {
    if (isRegistrationInProgress()) {
      await clearAll();
    }
  }
}
