import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/constants/app_constants.dart';
import 'main_home_logic.dart';

class MainHomePage extends StatelessWidget {
  const MainHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<MainHomeLogic>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '潮星球商家端',
          style: TextStyle(fontSize: 18.sp, color: textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '欢迎使用潮星球商家端',
              style: TextStyle(fontSize: 20.sp, color: textPrimary),
            ),
            SizedBox(height: 20.h),
            Obx(() => Text(
                  '${logic.count}',
                  style: TextStyle(fontSize: 36.sp, color: primary),
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: logic.increment,
        backgroundColor: primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
