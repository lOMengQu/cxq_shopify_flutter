import 'package:cxq_merchant_flutter/app/modules/main_home/main_home_binding.dart';
import 'package:cxq_merchant_flutter/app/modules/main_home/main_home_view.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

// 路由配置
class AppPages {
  static const initial = Routes.mainHome;

  static final routes = [
    GetPage(
      name: Routes.mainHome,
      page: () => const MainHomePage(),
      binding: MainHomeBinding(),
    ),
    // TODO: 在此添加更多路由
    // GetPage(
    //   name: Routes.login,
    //   page: () => const LoginPage(),
    //   binding: LoginBinding(),
    // ),
  ];
}
