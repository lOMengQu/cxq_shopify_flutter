import 'package:get/get.dart';

import 'product_attributes_logic.dart';

class ProductAttributesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductAttributesLogic());
  }
}
