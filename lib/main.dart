/// 应用入口文件
///
/// 功能说明：
/// - 配置屏幕适配（ScreenUtil）
/// - 配置全局主题（ThemeData）
/// - 配置路由管理（GetX）
/// - 配置全局 Loading 和 Toast
/// - 配置国际化支持
import 'dart:async';

import 'package:cxq_merchant_flutter/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import 'app/routes/app_pages.dart';
import 'common/constants/app_constants.dart';
import 'common/utils/loading_util.dart';

/// 应用入口函数
void main() {
  runZonedGuarded(
    () async {
      // 步骤 1：初始化全局配置（包含 WidgetsFlutterBinding.ensureInitialized）
      await Global.init();

      // 步骤 2：启用 Android 全面屏模式
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // 步骤 3：锁定竖屏方向
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // 步骤 4：启动应用
      runApp(const MyApp());
    },
    (error, stack) {
      debugPrint('Zone error: $error\n$stack');
    },
  );
}

/// 应用根组件
///
/// 负责初始化：
/// - 屏幕适配配置
/// - 全局主题样式
/// - 路由配置
/// - 国际化配置
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 屏幕适配初始化
    return ScreenUtilInit(
      splitScreenMode: true,
      minTextAdapt: true,
      designSize: const Size(SCREEN_WIDTH, SCREEN_HEIGHT),
      builder: (context, child) {
        return GetMaterialApp(
          title: "潮星球商家端",
          // 初始化 EasyLoading 和 Toast
          builder: EasyLoading.init(builder: (context, child) {
            configEasyLoading();
            // 统一的键盘收起逻辑
            void dismissKeyboardIfNeeded() {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.unfocus();
              }
            }

            return OKToast(
              movingOnWindowChange: false,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: dismissKeyboardIfNeeded,
                child: child!,
              ),
            );
          }),
          navigatorKey: globalKey,
          themeMode: ThemeMode.light,
          // ========== 全局主题配置 ==========
          theme: ThemeData(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            primaryColor: primary,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: primary,
              error: accentOrange,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.r)),
              ),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: primary,
              selectionColor: primary.withOpacity(0.4),
              selectionHandleColor: primary,
            ),
            cupertinoOverrideTheme: const CupertinoThemeData(
              primaryColor: primary,
            ),
          ),
          // ========== 国际化配置 ==========
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CN'),
          ],
          locale: const Locale('zh', 'CN'),
          // ========== 其他配置 ==========
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 600),
          getPages: AppPages.routes,
          initialRoute: AppPages.initial,
        );
      },
    );
  }
}
