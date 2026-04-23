import 'package:cxq_merchant_flutter/api/z_entity/user/login_entity.dart';
import 'package:cxq_merchant_flutter/app/routes/app_pages.dart';
import 'package:cxq_merchant_flutter/common/utils/service/user_service.dart';
import 'package:cxq_merchant_flutter/common/utils/toast.dart';
import 'package:get/get.dart';

/// 登录成功后根据 jumpPage 分发路由
class LoginRouteHelper {
  /// 处理登录成功后的路由跳转
  /// jumpPage: 1 → 密钥页面 → 上传头像 → 主页
  /// jumpPage: 5 (设置头像) / 6 (设置昵称) → 上传头像页面
  /// jumpPage: 8 (不跳转) / 7 → 主页
  static Future<void> handleLoginSuccess(LoginEntity loginData) async {
    // 先保存用户数据
    if (loginData.token != null && loginData.userId != null) {
      await UserService.saveUserData(
        token: loginData.token!,
        userId: loginData.userId!,
        avatar: loginData.avatar,
        nickName: loginData.nickName,
        phone: loginData.phoneNumber,
      );
      if (loginData.shopId != null && loginData.shopId!.isNotEmpty) {
        await UserService.saveShopId(loginData.shopId!);
      }
    }

    showOkToast('登录成功');

    final jumpPage = loginData.jumpPage ?? 8;

    switch (jumpPage) {
      case 1:
        // 进入密钥页面
        Get.offAllNamed(Routes.inviteCode);
        break;
      case 5:
      case 6:
        // 设置头像 / 设置昵称 → 上传头像页面
        Get.offAllNamed(Routes.uploadAvatarNickname);
        break;
      default:
        // 7、8 及其他 → 主页
        Get.offAllNamed(Routes.mainHome);
        break;
    }
  }
}
