import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../api/http/api_endpoints.dart';
import 'contact_customer_service_page.dart';
import 'account_cancellation_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '帮助中心',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 构建帮助中心的设置组
            _buildSettingGroup([
              _buildSettingItem('服务协议', () => _onMenuItemTap('服务协议')),
              _buildSettingItem('隐私政策', () => _onMenuItemTap('隐私政策')),
              _buildSettingItem('联系客服', () => Get.to(const ContactCustomerServicePage())),
              _buildSettingItem('注销账号', () => Get.to(const AccountCancellationPage())),
            ]),
          ],
        ),
      ),
    );
  }

  // 处理菜单项点击
  void _onMenuItemTap(String title) {
    if (title == '服务协议') {
      _openWebView(
        url: ApiEndpoints.serviceAgreementUrl,
        title: title,
      );
    } else if (title == '隐私政策') {
      _openWebView(
        url: ApiEndpoints.privacyPolicyUrl,
        title: title,
      );
    }
  }

  // 打开WebView页面
  void _openWebView({required String url, required String title}) {
    Get.to(
          () => WebViewPage(url: url, title: title),
      transition: Transition.cupertino,
    );
  }

  /// 构建一组设置项
  Widget _buildSettingGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          return Column(
            children: [
              items[index],
              if (index != items.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }

  /// 构建单个设置项
  Widget _buildSettingItem(String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

// WebView页面（可复用）
class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  var loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              loadingProgress = progress;
            });
          },
          onNavigationRequest: (request) {
            if (request.url.startsWith('http') || request.url.startsWith('https')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
          onPageStarted: (url) {},
          onPageFinished: (url) {
            setState(() {
              loadingProgress = 100;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
        headers: {'X-Requested-With': 'XMLHttpRequest'},
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (loadingProgress < 100)
            LinearProgressIndicator(
              value: loadingProgress / 100,
              backgroundColor: Colors.transparent,
              minHeight: 2,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }
}