import 'package:get/get.dart';
import 'main_home_logic.dart';

class MainHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainHomeLogic>(() => MainHomeLogic());
  }
}
