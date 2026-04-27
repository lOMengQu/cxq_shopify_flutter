import 'package:get/get.dart';

import 'upload_product_logic.dart';

class UploadProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UploadProductLogic());
  }
}
