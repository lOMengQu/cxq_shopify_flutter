import 'package:cxq_merchant_flutter/common/utils/sp_utils.dart';
import 'package:flutter/cupertino.dart';

class Global {
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SPUtils.init();
  }
}
