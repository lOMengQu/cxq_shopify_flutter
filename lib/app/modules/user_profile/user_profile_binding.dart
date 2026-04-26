import 'package:get/get.dart';

import 'user_profile_logic.dart';

class UserProfileBinding extends Bindings {
  @override
  void dependencies() {
    // final userId = Get.arguments?['userId'] ?? '';
    // // 如果已存在相同 tag 的控制器，先删除再创建新的
    // if (Get.isRegistered<UserProfileLogic>(tag: userId)) {
    //   Get.delete<UserProfileLogic>(tag: userId, force: true);
    // }
    // Get.put(UserProfileLogic(), tag: userId);
    Get.create<UserProfileLogic>(() => UserProfileLogic());

  }
}
