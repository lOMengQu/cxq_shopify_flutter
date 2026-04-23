/// 商家端登录响应实体
/// 接口返回的 data 直接就是用户信息字段
class LoginEntity {
  int? jumpPage;
  int? metaDataState;
  String? phoneNumber;
  String? avatar;
  String? nickName;
  String? token;
  int? userType;
  String? userId;
  String? shopId;
  int? sellerFirstLoginStep;

  LoginEntity({
    this.jumpPage,
    this.metaDataState,
    this.phoneNumber,
    this.avatar,
    this.nickName,
    this.token,
    this.userType,
    this.userId,
    this.shopId,
    this.sellerFirstLoginStep,
  });

  factory LoginEntity.fromJson(Map<String, dynamic> json) {
    return LoginEntity(
      jumpPage: json['jumpPage'] as int?,
      metaDataState: json['metaDataState'] as int?,
      phoneNumber: json['phoneNumber']?.toString(),
      avatar: json['avatar']?.toString() ?? "",
      nickName: json['nickname']?.toString() ?? "",
      token: json['token']?.toString(),
      userType: json['userType'] as int?,
      userId: json['userId']?.toString(),
      shopId: json['shopId']?.toString(),
      sellerFirstLoginStep: json['sellerFirstLoginStep'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jumpPage': jumpPage,
      'metaDataState': metaDataState,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'nickname': nickName,
      'token': token,
      'userType': userType,
      'userId': userId,
      'shopId': shopId,
      'sellerFirstLoginStep': sellerFirstLoginStep,
    };
  }
}
