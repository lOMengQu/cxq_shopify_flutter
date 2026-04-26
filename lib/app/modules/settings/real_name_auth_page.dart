import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'help_center_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RealNameAuthPage extends StatefulWidget {
  const RealNameAuthPage({Key? key}) : super(key: key);

  @override
  State<RealNameAuthPage> createState() => _RealNameAuthPageState();
}

class _RealNameAuthPageState extends State<RealNameAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  bool _isAgreed = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _idCardController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _idCardController.removeListener(_validateForm);
    _nameController.dispose();
    _idCardController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {}); // Trigger rebuild to update button state
  }

  void _launchAgreementUrl() {
    const url = "http://api.wxpmusic.cn/danceline/agreement/user_service_agreement/";
    const title = '认证协议';
    Get.to(
          () => WebViewPage(url: url, title: title),
      transition: Transition.cupertino,
    );
  }

  void _handleNextStep() async {
    if ((_nameController.text.isNotEmpty &&
        _idCardController.text.length == 18)) {
      if (_isAgreed) {
        // Submit logic here
        debugPrint("姓名: ${_nameController.text}");
        debugPrint("身份证号: ${_idCardController.text}");

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("认证信息提交成功"))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("请勾选同意下方协议"))
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("请填写完整信息"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFormValid = _nameController.text.isNotEmpty &&
        _idCardController.text.length == 18;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '实名认证',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '根据国家互联网用户实名制相关要求，为了保障您的账号资产安全，请尽快完成实名认证哦。',
                style: TextStyle(
                  color: const Color(0xFF666666),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 16.h),

              // Name and ID Card Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFECECEC), width: 1.w),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: '请输入真实姓名',
                        hintStyle: TextStyle(
                          color: const Color(0xFF999999),
                          fontSize: 16.sp,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      height: 1.h,
                      color: const Color(0xFFECECEC),
                      margin: EdgeInsets.symmetric(horizontal: 12.w),
                    ),
                    TextFormField(
                      controller: _idCardController,
                      maxLength: 18,
                      decoration: InputDecoration(
                        hintText: '请输入身份证号',
                        hintStyle: TextStyle(
                          color: const Color(0xFF999999),
                          fontSize: 16.sp,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 380.h),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isFormValid ? _handleNextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFormValid
                        ? const Color(0xFFCD1CE3)
                        : const Color(0xFFECECEC),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    '下一步',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Agreement Checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: _isAgreed,
                    onChanged: (value) {
                      setState(() {
                        _isAgreed = value ?? false;
                      });
                    },
                    activeColor: const Color.fromRGBO(214, 35, 160, 1),
                  ),
                  Text(
                    '阅读并同意',
                    style: TextStyle(
                      color: const Color(0xFF666666),
                      fontSize: 12.sp,
                    ),
                  ),
                  GestureDetector(
                    onTap: _launchAgreementUrl,
                    child: Text(
                      '认证协议',
                      style: TextStyle(
                        color: const Color(0xFF333333),
                        fontSize: 12.sp,
                        // decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}