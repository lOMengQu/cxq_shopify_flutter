import 'package:get/get.dart';

class MainHomeLogic extends GetxController {
  final count = 0.obs;

  void increment() => count.value++;
}
