import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class ContactCustomerServicePage extends StatelessWidget {
  const ContactCustomerServicePage({Key? key}) : super(key: key);

  // 复制到剪贴板并提示
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      Get.snackbar(
        '提示',
        '已复制',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey.shade800,
        colorText: Colors.white,
      );
    });
  }

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
          '联系客服',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 客服微信 & 复制按钮
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text(
                  '客服微信: chaoxingqiuxx',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold, // 加粗文字
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () => _copyToClipboard('chaoxingqiuxx'),
                  child: const Text(
                    '复制',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF793DF9),
                    ),
                  ),
                ),
              ),
              // 分割线
              const Divider(height: 1, indent: 16, endIndent: 16),
              // 客服工作时间
              Padding(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '客服工作时间: 工作日10:00-18:00',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold, // 加粗文字
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}