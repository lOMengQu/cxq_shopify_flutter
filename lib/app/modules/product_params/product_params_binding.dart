import 'package:get/get.dart';

import 'product_params_logic.dart';

class ProductParamsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductParamsLogic());
  }
}
