import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserServiceAgreementPage extends StatefulWidget {
  const UserServiceAgreementPage({super.key});

  @override
  State<UserServiceAgreementPage> createState() =>
      _UserServiceAgreementPageState();
}

class _UserServiceAgreementPageState extends State<UserServiceAgreementPage> {
  late final WebViewController controller;
  late final String agreementUrl;
  late final String pageTitle;

  @override
  void initState() {
    super.initState();

    final arguments = Get.arguments ?? {};
    agreementUrl = arguments['agreement'] ?? '';
    pageTitle = arguments['title'] ?? '协议';

    debugPrint(
        '🔍 UserServiceAgreementPage - agreementUrl: $agreementUrl, pageTitle: $pageTitle');

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) => debugPrint('🔍 页面开始加载: $url'),
          onPageFinished: (String url) => debugPrint('🔍 页面加载完成: $url'),
          onWebResourceError: (WebResourceError error) => debugPrint(
              '🔍 页面加载错误: ${error.description}, code: ${error.errorCode}'),
        ),
      )
      ..loadRequest(Uri.parse(agreementUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
        ),
        centerTitle: true,
        title: Text(
          pageTitle,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: WebViewWidget(
          controller: controller,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer()),
          },
        ),
      ),
    );
  }
}
