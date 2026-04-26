import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../api/http/async_handler.dart';
import '../../../api/service/user_api.dart';
import '../../../common/constants/app_constants.dart';
import '../../../common/utils/service/user_service.dart';
import '../../../common/utils/sp_utils.dart';
import '../../../common/utils/toast.dart';
import '../../routes/app_pages.dart';
import 'real_name_auth_page.dart';
import 'help_center_page.dart';
import 'feedback_page.dart';
import 'block_user_list_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  void _onItemTap(String title) {
    // if (title == '版权保护') {
    //   Get.to(
    //         () =>
    //         WebViewPage(
    //           url: '${ApiEndpoints.serviceAgreementUrl}',
    //           title: title,
    //         ),
    //     transition: Transition.cupertino,
    //   );
    // } else
    if (title == '实名认证') {
      Get.to(() => const RealNameAuthPage());
    } else if (title == '创作者平台') {
      // Get.toNamed(AppRoutes.emotionEdit);
      // Get.to(() => const MusicianEntryPage());
    } else if (title == '意见反馈') {
      Get.to(() => const FeedbackPage());
    } else if (title == '帮助中心') {
      Get.to(() => const HelpCenterPage());
    } else if (title == '关于我们') {
      Get.to(() => const AboutPage());
    } else if (title == '黑名单') {
      Get.to(() => const BlockUserListPage());
    } else if (title == '账号与安全设置') {
      Get.to(() => const AccountSecurityPage());
    } else {
      Get.dialog(
        AlertDialog(
          title: Text(title),
          content: Text('点击了 $title，可在此处实现跳转到对应功能页面逻辑'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('设置',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 第一组：账号与安全相关
            _buildSettingGroup([
              _buildSettingItem('账号与安全设置'),
              _buildSettingItem('黑名单'),
            ]),
            const SizedBox(height: 16),
            // 第二组：认证与平台相关
            _buildSettingGroup([
              _buildSettingItem('实名认证'),
              // _buildSettingItem('创作者平台'),
            ]),
            const SizedBox(height: 16),
            // 第三组：反馈与关于相关
            _buildSettingGroup([
              _buildSettingItem('意见反馈'),
              _buildSettingItem('帮助中心'),
              _buildSettingItem('关于我们'),
              // _buildSettingItem('版权保护'),
            ]),
            const SizedBox(height: 32),
            // 退出当前账号按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60.r),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _showLogoutDialog,
                child: const Text('退出当前账号'),
              ),
            ),
          ],
        ),
      ),
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
  Widget _buildSettingItem(String title) {
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
      onTap: () => _onItemTap(title),
    );
  }

  /// 显示退出对话框
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        // 设置背景为白色
        title: Center(
          child: Text(
            '确定退出吗？',
            style: TextStyle(
              fontSize: 16, // 可以调整字体大小
              fontWeight: FontWeight.w600, // 可以调整字体粗细
              color: Color(0xFF333333), // 可以调整字体颜色
            ),
          ),
        ),
        // 标题居中
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        actions: [
          const Divider(height: 1, color: Colors.grey), // 上方分割线
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    '取消',
                    style: TextStyle(
                      fontSize: 16, // 可以调整字体大小
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666).withOpacity(0.9), // 可以调整字体颜色
                    ),
                  ),
                ),
              ),
              Container(
                height: 48.h, // 分割线高度
                width: 1.w, // 分割线宽度
                color: Colors.grey, // 分割线颜色
              ), // 中间分割线
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    await UserService.clearAll();
                    Get.back();
                    Get.offAllNamed(Routes.login);
                  },
                  child: Text(
                    '确定',
                    style: TextStyle(
                      fontSize: 16.sp, // 可以调整字体大小
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 账号与安全设置主页面
class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({Key? key}) : super(key: key);

  void _navigateToPage(String title) {
    if (title == '账号安全') {
      Get.to(() => const AccountSecuritySettingsPage());
    } else if (title == '青少年模式') {
      Get.to(() => const YouthModePage());
    } else {
      Get.dialog(
        AlertDialog(
          title: Text(title),
          content: Text('点击了 $title，可在此处实现功能'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('账号与安全设置',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSecurityGroup([
              _buildSecurityItemSingleTitle('账号安全'),
              _buildSecurityItemSingleTitle('青少年模式'),
            ]),
          ],
        ),
      ),
    );
  }

  /// 构建安全分组
  Widget _buildSecurityGroup(List<Widget> items) {
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

  /// 构建安全设置项（单标题）
  Widget _buildSecurityItemSingleTitle(String title) {
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
      onTap: () => _navigateToPage(title),
    );
  }
}

// 账号安全设置页面
class AccountSecuritySettingsPage extends StatefulWidget {
  const AccountSecuritySettingsPage({Key? key}) : super(key: key);

  @override
  State<AccountSecuritySettingsPage> createState() =>
      _AccountSecuritySettingsPageState();
}

class _AccountSecuritySettingsPageState
    extends State<AccountSecuritySettingsPage> {
  void _navigateToPage(String title) {
    if (title == '手机绑定') {
      Get.to(() => const PhoneBindingPage());
    } else if (title == '密码设置') {
      Get.to(() => const PasswordSettingPage());
    } else {
      Get.dialog(
        AlertDialog(
          title: Text(title),
          content: Text('点击了 $title，可在此处实现功能'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  var phone = "".obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('账号与安全',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSecurityGroup([
              Obx(() {
                return _buildSecurityItemWithSubTitle(
                    '手机绑定', '${phone.value}');
              }),
              _buildSecurityItemWithSubTitle('密码设置', ''),
            ]),
          ],
        ),
      ),
    );
  }

  /// 构建安全分组
  Widget _buildSecurityGroup(List<Widget> items) {
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

  /// 构建安全设置项（带副标题）
  Widget _buildSecurityItemWithSubTitle(String title, String subTitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          if (subTitle.isNotEmpty)
            Text(
              subTitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () => _navigateToPage(title),
    );
  }
}

// 隐私设置页面
class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({Key? key}) : super(key: key);

  void _navigateToPage(String title) {
    if (title == '青少年模式') {
      Get.to(() => const YouthModePage());
    } else {
      Get.dialog(
        AlertDialog(
          title: Text(title),
          content: Text('点击了 $title，可在此处实现功能'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('隐私设置',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSecurityGroup([
              _buildSecurityItemWithSubTitle('青少年模式', ''),
            ]),
          ],
        ),
      ),
    );
  }

  /// 构建安全分组
  Widget _buildSecurityGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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

  /// 构建安全设置项（带副标题）
  Widget _buildSecurityItemWithSubTitle(String title, String subTitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      subtitle: subTitle.isNotEmpty
          ? Text(
        subTitle,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () => _navigateToPage(title),
    );
  }
}

// 手机绑定页面
class PhoneBindingPage extends StatefulWidget {
  const PhoneBindingPage({Key? key}) : super(key: key);

  @override
  State<PhoneBindingPage> createState() => _PhoneBindingPageState();
}

class _PhoneBindingPageState extends State<PhoneBindingPage> {
  void _navigateToChangePhone() {
    Get.to(() => const ChangePhonePage());
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  var phone = "".obs;

  init() {
    phone.value = UserService.getPhone() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('手机绑定',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 148),
            // 手机绑定图片
            Center(
              child: Icon(
                Icons.phone_android,
                size: 80.w,
                color: primary,
              ),
            ),
            const SizedBox(height: 24),
            // 绑定的手机号信息
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    return Text(
                      '绑定的手机号：${phone.value}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 180),
            // 更换手机号按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35.r),
                    side: BorderSide(color: primary),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _navigateToChangePhone,
                child: const Text('更换手机号'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 更换手机号页面
class ChangePhonePage extends StatefulWidget {
  const ChangePhonePage({Key? key}) : super(key: key);

  @override
  State<ChangePhonePage> createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  final TextEditingController textEditingControllerPhone = TextEditingController();
  final TextEditingController textEditingControllerCaptcha = TextEditingController();

  int _countdown = 0;
  Timer? _timer;

  void _startCountdown() {
    setState(() {
      _countdown = 59;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('更换手机号',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // 更换手机号表单
            Container(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: textEditingControllerPhone,
                    maxLength: 11,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // ✅ 只允许输入数字
                    ],
                    decoration: InputDecoration(
                      hintText: '请输入新手机号',
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),

                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: textEditingControllerCaptcha,
                          decoration: InputDecoration(
                            hintText: '请输入验证码',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              side: BorderSide(color: primary),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: _countdown == 0
                              ? () async {
                            var phone = textEditingControllerPhone.text;
                            if (phone.isEmpty) {
                              FToastUtil.show("手机号不能为空");
                              return;
                            }
                            // TODO: 接入发送验证码API
                            FToastUtil.show("发送成功");
                            _startCountdown();
                          }
                              : null,
                          child: Text(
                            _countdown == 0 ? '获取验证码' : '$_countdown 秒',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  var phone = textEditingControllerPhone.text;
                  var captcha = textEditingControllerCaptcha.text;

                  if (phone.isEmpty || captcha.isEmpty) {
                    FToastUtil.show("账号或验证码不能为空");
                    return;
                  }
                  // TODO: 接入更换手机号API
                  FToastUtil.show("保存成功");
                  Get.back();
                },
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 密码设置页面
class PasswordSettingPage extends StatefulWidget {
  const PasswordSettingPage({Key? key}) : super(key: key);

  @override
  State<PasswordSettingPage> createState() => _PasswordSettingPageState();
}

class _PasswordSettingPageState extends State<PasswordSettingPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  var phoneNumber = "".obs;

var phoneTextEditingController =TextEditingController();
var newPhoneTextEditingController =TextEditingController();
var codeTextEditingController =TextEditingController();
  init() {
    phoneNumber.value = UserService.getPhone() ?? "";
  }

  int _countdown = 0;
  Timer? _timer;

  void _startCountdown() {
    setState(() {
      _countdown = 59;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('密码设置',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // 密码设置表单（显示手机号）
            Container(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Obx(() {
                    return Text(
                      phoneNumber.value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: codeTextEditingController,
                          decoration: InputDecoration(
                            hintText: '请输入验证码',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120.w,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              side: BorderSide(color: primary),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed:_countdown == 0? () async {
                            // TODO: 接入发送验证码API
                            FToastUtil.show("发送成功");
                            _startCountdown();
                          }:null,
                          child: Text(
                            _countdown == 0 ? '获取验证码' : '$_countdown 秒',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: phoneTextEditingController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '请输入密码',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons
                              .visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    obscureText: _obscureConfirmPassword,
                    controller: newPhoneTextEditingController,

                    decoration: InputDecoration(
                      hintText: '再次输入密码',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons
                              .visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 180),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35.r),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async{
                  final code = codeTextEditingController.text;
                  final pwd = phoneTextEditingController.text;
                  final pwd2 = newPhoneTextEditingController.text;
                  if (code.isEmpty || pwd.isEmpty || pwd2.isEmpty) {
                    FToastUtil.show("请填写完整信息");
                    return;
                  }
                  if (pwd != pwd2) {
                    FToastUtil.show("两次密码不一致");
                    return;
                  }
                  var baseResponse = await AsyncHandler.handle(future: postResetPassword(
                    phone: phoneNumber.value,
                    captcha: code,
                    password: pwd,
                  ));
                  if (baseResponse.ok) {
                    FToastUtil.show("保存成功");
                    Get.back();
                  }
                },
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YouthModePage extends StatefulWidget {
  const YouthModePage({Key? key}) : super(key: key);

  @override
  State<YouthModePage> createState() => _YouthModePageState();
}

class _YouthModePageState extends State<YouthModePage> {
  bool isYouthModeEnabled = false;
  bool _authing = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadYouthModeStatus();
  }

  Future<void> _loadYouthModeStatus() async {
    setState(() {
      isYouthModeEnabled = SPUtils.getBool('youth_mode_enabled') ?? false;
    });
  }

  Future<void> _saveYouthModeStatus(bool value) async {
    await SPUtils.setBool('youth_mode_enabled', value);
  }

  Future<bool> _authenticateToDisable() async {
    if (_authing) return false;
    _authing = true;
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: '关闭青少年模式需要系统验证',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return ok;
    } on PlatformException catch (e) {
      FToastUtil.show('请先在系统设置中设置锁屏密码或指纹，才可关闭青少年模式');
      return false;
    } catch (e) {
      FToastUtil.show('请先在系统设置中设置锁屏密码或指纹，才可关闭青少年模式');
      return false;
    } finally {
      _authing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('青少年模式',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // 修正后的容器装饰代码
            Container(
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
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '开启青少年模式',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Switch(
                    value: isYouthModeEnabled,
                    activeColor: primary,
                    onChanged: (value) async {
                      if (value) {
                        setState(() {
                          isYouthModeEnabled = true;
                        });
                        await _saveYouthModeStatus(true);
                        FToastUtil.show('已开启青少年模式');
                        return;
                      }

                      final ok = await _authenticateToDisable();
                      if (!ok) {
                        setState(() {
                          isYouthModeEnabled = true;
                        });
                        return;
                      }

                      setState(() {
                        isYouthModeEnabled = false;
                      });
                      await _saveYouthModeStatus(false);
                      FToastUtil.show('已关闭青少年模式');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 关于我们页面
class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = '${info.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '关于我们',
          style: TextStyle(
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
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Image.asset(
                'assets/logo.png',
                width: 88.w,
                height: 92.h,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text(
                '潮星球',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '当前版本 V$version',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Copyrightⓒ2024-2026',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '潮星球',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
