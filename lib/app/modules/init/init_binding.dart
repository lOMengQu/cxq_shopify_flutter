import 'package:get/get.dart';

import 'init_logic.dart';

class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InitLogic());
  }
}
