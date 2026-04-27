import 'package:cxq_merchant_flutter/app/modules/init/init_binding.dart';
import 'package:cxq_merchant_flutter/app/modules/upload_product/upload_product_binding.dart';
import 'package:cxq_merchant_flutter/app/modules/upload_product/upload_product_view.dart';
import 'package:cxq_merchant_flutter/app/modules/product_params/product_params_binding.dart';
import 'package:cxq_merchant_flutter/app/modules/product_params/product_params_view.dart';
import 'package:cxq_merchant_flutter/app/modules/product_attributes/product_attributes_binding.dart';
import 'package:cxq_merchant_flutter/app/modules/product_attributes/product_attributes_view.dart';
import 'package:cxq_merchant_flutter/app/modules/init/init_view.dart';
import 'package:cxq_merchant_flutter/app/modules/forgot_password/forgot_password_binding.dart';
import 'package:cxq_merchant_flutter/common/widget/user_agreement/user_agreement_widget.dart';
import 'package:cxq_merchant_flutter/app/modules/invite_code/invite_code_binding.dart';
import 'package:cxq_merchant_flutter/app/modules/invite_code/invite_code_view.dart';
import 'package:cxq_merchant_flutter/app/modules/upload_avatar_nickname/upload_avatar_nickname_binding.dart';
import 'package:cxq_merchant_flutter/app/modules/upload_avatar_nickname/upload_avatar_nickname_view.dart';
import 'package:cxq_merchant_flutter/app/modules/forgot_password/forgot_password_view.dart';
import 'package:cxq_merchant_flutter/app/modules/login/login_binding.dart';
import 'package:cxq_merchant_flutter/app/modules/login/login_view.dart';
import 'package:cxq_merchant_flutter/app/modules/main_home/main_home_binding.dart';
import 'package:cxq_merchant_flutter/app/modules/main_home/main_home_view.dart';
import 'package:cxq_merchant_flutter/app/modules/verify_code/verify_code_binding.dart';
import 'package:cxq_merchant_flutter/app/modules/verify_code/verify_code_view.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

// 路由配置
class AppPages {
  static const initial = Routes.uploadProduct;

  static final routes = [
    GetPage(
      name: Routes.init,
      page: () => const InitPage(),
      binding: InitBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.verifyCode,
      page: () => const VerifyCodePage(),
      binding: VerifyCodeBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.inviteCode,
      page: () => const InviteCodePage(),
      binding: InviteCodeBinding(),
    ),
    GetPage(
      name: Routes.uploadAvatarNickname,
      page: () => const UploadAvatarNicknamePage(),
      binding: UploadAvatarNicknameBinding(),
    ),
    GetPage(
      name: Routes.mainHome,
      page: () => const MainHomePage(),
      binding: MainHomeBinding(),
    ),
    GetPage(
      name: Routes.userServiceAgreement,
      page: () => const UserServiceAgreementPage(),
    ),
    GetPage(
      name: Routes.uploadProduct,
      page: () => const UploadProductPage(),
      binding: UploadProductBinding(),
    ),
    GetPage(
      name: Routes.productParams,
      page: () => const ProductParamsPage(),
      binding: ProductParamsBinding(),
    ),
    GetPage(
      name: Routes.productAttributes,
      page: () => const ProductAttributesPage(),
      binding: ProductAttributesBinding(),
    ),
  ];
}
