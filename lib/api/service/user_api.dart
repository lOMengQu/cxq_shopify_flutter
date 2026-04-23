import '../z_entity/base_response.dart';
import '../z_entity/user/login_entity.dart';
import '../z_entity/user/image_code_entity.dart';
import '../http/api_client.dart';
import '../http/api_endpoints.dart';

/// 一键登录（运营商免密认证）
/// [token] 运营商返回的 token
/// [opToken] 运营商返回的 opToken
/// [operator] 运营商类型 CMCC/CUCC/CTCC
/// [userType] 用户类型，商家端固定传 2
Future<BaseResponse<LoginEntity>> postOneClickLogin({
  String? token,
  String? opToken,
  String? operator,
  int userType = 2,
}) {
  return ApiClient().post(
    ApiEndpoints.oneClickLogin,
    data: {
      "token": token,
      "opToken": opToken,
      "operator": operator,
      "userType": userType,
      "loginType": "2",
    }..removeWhere((key, value) => value == null),
    fromJsonT: (json) => LoginEntity.fromJson(json),
  );
}

/// 验证码登录/注册
/// [captcha] 验证码
/// [phoneNumber] 手机号
/// [userType] 用户类型，商家端固定传 2
Future<BaseResponse<LoginEntity>> postLoginOrRegisterByCaptcha({
  required String captcha,
  required String phoneNumber,
  int userType = 2,
}) {
  return ApiClient().post(
    ApiEndpoints.loginOrRegisterByCaptcha,
    data: {
      "captcha": captcha,
      "phoneNumber": phoneNumber,
      "userType": userType,
    },
    fromJsonT: (json) => LoginEntity.fromJson(json),
  );
}

/// 密码登录
/// [phoneNumber] 手机号
/// [password] 密码（需加密）
/// [userType] 用户类型，商家端固定传 2
Future<BaseResponse<LoginEntity>> postLoginByPassword({
  required String phoneNumber,
  required String password,
  int userType = 2,
}) {
  return ApiClient().post(
    ApiEndpoints.loginByPassword,
    data: {
      "phoneNumber": phoneNumber,
      "password": password,
      "userType": userType,
    },
    fromJsonT: (json) => LoginEntity.fromJson(json),
  );
}

/// 获取图片验证码
/// [phoneNumber] 手机号
Future<BaseResponse<ImageCodeEntity>> postGetVerifyImage({
  String? phoneNumber,
}) {
  return ApiClient().post(
    ApiEndpoints.getVerifyImage,
    data: {
      "phoneNumber": phoneNumber,
    }..removeWhere((key, value) => value == null),
    fromJsonT: (json) => ImageCodeEntity.fromJson(json),
  );
}

/// 重置密码
/// [phone] 手机号
/// [captcha] 短信验证码
/// [password] 新密码（MD5加密后）
Future<BaseResponse<void>> postResetPassword({
  required String phone,
  required String captcha,
  required String password,
}) {
  return ApiClient().post(
    ApiEndpoints.resetPassword,
    data: {
      "phone": phone,
      "captcha": captcha,
      "password": password,
    },
    fromJsonT: (json) => null,
  );
}

/// 邀请码校验
Future<BaseResponse<void>> postInvitationCodeVerify({
  required String invitationCode,
}) {
  return ApiClient().post(
    ApiEndpoints.invitation,
    data: {
      "invitationCode": invitationCode,
    },
    fromJsonT: (json) => null,
  );
}

/// 编辑用户信息（头像/昵称）
Future<BaseResponse<void>> postAccountUser(String userName, String avatar) {
  return ApiClient().post(
    ApiEndpoints.accountUser,
    data: {
      "nickname": userName,
      "avatar": avatar,
    },
    fromJsonT: (json) => null,
  );
}

/// 获取短信验证码
/// [phoneNumber] 手机号
/// [type] 验证码类型：1:注册, 2:登录, 3:修改密码
/// [oneKey] 图片验证码唯一Key
/// [imageCode] 用户输入的图片验证码
Future<BaseResponse<void>> postGetVerifyCode({
  required String phoneNumber,
  required int type,
  required String oneKey,
  required String imageCode,
}) {
  return ApiClient().post(
    ApiEndpoints.getVerifyCode,
    data: {
      "phoneNumber": phoneNumber,
      "type": type,
      "oneKey": oneKey,
      "imageCode": imageCode,
    },
    fromJsonT: (json) => null,
  );
}
