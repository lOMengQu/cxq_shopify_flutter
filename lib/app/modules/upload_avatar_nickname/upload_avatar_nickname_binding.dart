import 'package:get/get.dart';

import 'upload_avatar_nickname_logic.dart';

class UploadAvatarNicknameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UploadAvatarNicknameLogic>(() => UploadAvatarNicknameLogic());
  }
}
