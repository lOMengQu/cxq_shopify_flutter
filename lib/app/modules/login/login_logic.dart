import 'dart:convert';
import 'dart:typed_data';
import 'package:cxq_merchant_flutter/api/http/async_handler.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'package:cxq_merchant_flutter/api/service/user_api.dart';
import 'package:cxq_merchant_flutter/common/utils/toast.dart';
import 'package:cxq_merchant_flutter/common/constants/app_constants.dart';
import 'package:cxq_merchant_flutter/common/utils/login_route_helper.dart';
import 'package:cxq_merchant_flutter/app/routes/app_pages.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flyverify_plugin/flyverify.dart';
import 'package:flyverify_plugin/flyverify_UIConfig.dart';

import '../../../api/http/api_endpoints.dart';
import '../../../api/http/env_config.dart';

class LoginLogic extends GetxController {
  static const String _userAgreementUrl =
      'http://apitest.wxpmusic.cn/danceline/agreement/user_service_agreement/';
  static const String _privacyUrl =
      'http://apitest.wxpmusic.cn/danceline/agreement/privacy/';
  static const String _themeColor = '#793DF9';

  final isLoading = false.obs;

  final phoneController = TextEditingController();
  final phone = ''.obs;
  final isAgreementChecked = false.obs;

  final captchaController = TextEditingController();
  final captchaInput = ''.obs;
  final imageCodeBase64 = ''.obs;
  final oneKey = ''.obs;
  final isCaptchaLoading = false.obs;

  // 密码登录相关
  final isPasswordLoginMode = false.obs;
  final passwordController = TextEditingController();
  final password = ''.obs;
  final isPasswordVisible = false.obs;

  bool get isPhoneValid => phone.value.length == 11;

  bool get isPasswordLoginValid => isPhoneValid && password.value.isNotEmpty;

  bool get isPhoneFormatValid {
    if (phone.value.length != 11) return false;
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone.value);
  }

  var captchaString = "".obs;

  @override
  void onInit() {
    super.onInit();
    initVerify();
    phoneController.addListener(() {
      phone.value = phoneController.text;
    });
    passwordController.addListener(() {
      password.value = passwordController.text;
    });
    captchaController.addListener(() {
      captchaString.value = captchaController.text;
    });
  }

  @override
  void onClose() {
    phoneController.dispose();
    captchaController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void clearPhone() {
    phoneController.clear();
    phone.value = '';
  }

  void toggleAgreement() {
    isAgreementChecked.value = !isAgreementChecked.value;
  }

  void onGetVerifyCodeTap() {
    if (!isPhoneValid) return;

    if (!isPhoneFormatValid) {
      FToastUtil.show('手机号格式错误');
      return;
    }

    if (!isAgreementChecked.value) {
      showAgreementDialog();
      return;
    }

    showCaptchaDialog();
  }

  void showAgreementDialog({VoidCallback? onAgree}) {
    Get.dialog(
      Center(
        child: Container(
          width: 300.w,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '潮星球商家端服务声明',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 20.h),
              Text.rich(
                TextSpan(
                  text: '请阅读并同意',
                  style: TextStyle(fontSize: 14.sp, color: textPrimary),
                  children: [
                    TextSpan(
                      text: '《用户协议》',
                      style: TextStyle(color: primary),
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                    const TextSpan(text: '、'),
                    TextSpan(
                      text: '《隐私协议》',
                      style: TextStyle(color: primary),
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28.h),
              GestureDetector(
                onTap: () {
                  isAgreementChecked.value = true;
                  Get.back();
                  if (onAgree != null) {
                    onAgree();
                  } else {
                    showCaptchaDialog();
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Center(
                    child: Text(
                      '同意并继续',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black54,
    );
  }

  Future<void> fetchImageCode() async {
    if (isCaptchaLoading.value) return;
    isCaptchaLoading.value = true;

    try {
      final res = await postGetVerifyImage(phoneNumber: phone.value);
      if (res.data != null) {
        imageCodeBase64.value = res.data!.image ?? '';
        oneKey.value = res.data!.oneKey ?? '';
      }
    } catch (e) {
      FToastUtil.show('获取验证码失败');
    } finally {
      isCaptchaLoading.value = false;
    }
  }

  void showCaptchaDialog() {
    captchaController.clear();
    captchaInput.value = '';
    fetchImageCode();

    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300.w,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '输入图片信息获取验证码',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 20.h),
                Obx(() => isCaptchaLoading.value
                    ? Container(
                        height: 60.h,
                        child: Center(
                          child: CircularProgressIndicator(color: primary),
                        ),
                      )
                    : imageCodeBase64.value.isNotEmpty
                        ? Image.memory(
                            _decodeBase64Image(imageCodeBase64.value),
                            height: 60.h,
                            fit: BoxFit.contain,
                          )
                        : Container(
                            height: 60.h,
                            child: Center(
                              child: Text('加载失败',
                                  style: TextStyle(color: textAssist)),
                            ),
                          )),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: dividerColor2, width: 1),
                          ),
                        ),
                        child: TextField(
                          controller: captchaController,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(fontSize: 14.sp, color: textFiledColor),
                          onChanged: (value) => captchaInput.value = value,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: InputDecoration(
                            hintText: '请输入验证码',
                            hintStyle:
                                TextStyle(fontSize: 14.sp, color: hintColor),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    GestureDetector(
                      onTap: fetchImageCode,
                      child: Text(
                        '换一换',
                        style: TextStyle(fontSize: 14.sp, color: textAssist),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),
                Obx(() {
                  var isEmpty = captchaString.isEmpty;
                  return GestureDetector(
                      onTap: isEmpty ? null : onCaptchaConfirm,
                      child: Container(
                        width: 110.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: isEmpty ? Color(0XFFEEF1F5) : primary,
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        child: Center(
                          child: Text(
                            '确定',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: isEmpty ? textAssist : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ));
                }),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.black54,
    );
  }

  Uint8List _decodeBase64Image(String base64String) {
    String base64Data = base64String;
    if (base64String.contains(',')) {
      base64Data = base64String.split(',').last;
    }
    return base64Decode(base64Data);
  }

  Future<void> onCaptchaConfirm() async {
    if (captchaInput.value.isEmpty) {
      FToastUtil.show('请输入验证码');
      return;
    }

    if (isCaptchaLoading.value) return;
    isCaptchaLoading.value = true;

    // 测试环境跳过发送验证码，直接进入验证码页面
    if (EnvConfig.isTest) {
      isCaptchaLoading.value = false;
      Get.back();
      Get.toNamed(Routes.verifyCode, arguments: {
        'phone': phone.value,
        'oneKey': '',
      });
      return;
    }
    try {
      final res = await AsyncHandler.handle(
          future: postGetVerifyCode(
        phoneNumber: phone.value,
        type: 2,
        oneKey: oneKey.value,
        imageCode: captchaInput.value,
      ));

      if (res.ok) {
        showOkToast("验证码发送成功");
        Get.back();
        Get.toNamed(Routes.verifyCode, arguments: {
          'phone': phone.value,
          'oneKey': oneKey.value,
        });
      } else {
        FToastUtil.show(res.message ?? '验证码错误');
        captchaController.clear();
        captchaInput.value = '';
        fetchImageCode();
      }
    } catch (e) {
      FToastUtil.show('请求失败，请重试');
      captchaController.clear();
      captchaInput.value = '';
      fetchImageCode();
    } finally {
      isCaptchaLoading.value = false;
    }
  }

  void switchToPasswordLogin() {
    isPasswordLoginMode.value = true;
  }

  void switchToVerifyCodeLogin() {
    isPasswordLoginMode.value = false;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void clearPassword() {
    passwordController.clear();
  }

  void goToForgotPassword() {
    Get.toNamed(Routes.forgotPassword, arguments: {"phone": phone.value});
  }

  String _encryptPassword(String pwd) {
    final bytes = utf8.encode(pwd);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  Future<void> onPasswordLogin() async {
    if (!isPasswordLoginValid) return;

    if (!isPhoneFormatValid) {
      FToastUtil.show('手机号格式错误');
      return;
    }

    if (!isAgreementChecked.value) {
      showAgreementDialog(onAgree: () {
        _doPasswordLogin();
      });
      return;
    }

    _doPasswordLogin();
  }

  Future<void> _doPasswordLogin() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final encryptedPwd = _encryptPassword(password.value);
      final res = await AsyncHandler.handle(
          future: postLoginByPassword(
        phoneNumber: phone.value,
        password: encryptedPwd,
      ));

      if (res.ok && res.data != null) {
        await LoginRouteHelper.handleLoginSuccess(res.data!);
      } else {
        FToastUtil.show(res.message ?? '登录失败');
      }
    } catch (e) {
      FToastUtil.show('登录失败');
    } finally {
      isLoading.value = false;
    }
  }

  // ========== 一键登录相关 ==========

  Future<void> initVerify() async {
    try {
      Flyverify.submitPrivacyGrantResult(true, null);
      _preVerify();
    } catch (e) {
      debugPrint('[Flyverify] initVerify error: $e');
    }
  }

  Future<void> oneClickLoginVerify() async {
    try {
      Flyverify.submitPrivacyGrantResult(true, null);
      Flyverify.preVerify(
        result: (Map<dynamic, dynamic>? ret, Map<dynamic, dynamic>? err) {
          if (err != null) {
            Get.back();
            return;
          }
          _showAuthPage();
        },
      );
    } catch (e) {
      debugPrint('[Flyverify] oneClickLoginVerify error: $e');
    }
  }

  void _preVerify() {
    try {
      Flyverify.preVerify(
        result: (Map<dynamic, dynamic>? ret, Map<dynamic, dynamic>? err) {
          if (err != null) {
            FToastUtil.show('一键登录预取号失败');
            return;
          }
          _showAuthPage();
        },
      );
    } catch (e) {
      debugPrint('[Flyverify] preVerify error: $e');
    }
  }

  void _showAuthPage() {
    final config = _buildUIConfig();
    Flyverify.autoFinishOAuthPage(flag: true);
    Flyverify.verify(
      config,
      _onAuthPageResult,
      _onAuthCanceled,
      _onIOSLoginResult,
      _onCustomControlClick,
      _onAndroidEvent,
    );
  }

  FlyVerifyUIConfig _buildUIConfig() {
    final config = FlyVerifyUIConfig();
    _configIOS(config);
    _configAndroid(config);
    return config;
  }

  void _configIOS(FlyVerifyUIConfig config) {
    config.iOSConfig?.logoImageName = 'assets/logo.png';
    config.iOSConfig?.loginBtnBgColor = _themeColor;
    config.iOSConfig?.loginBtnCornerRadius = 6;
    config.iOSConfig?.shouldAutorotate = false;
    config.iOSConfig?.supportedInterfaceOrientations =
        iOSInterfaceOrientationMask.portrait;
    config.iOSConfig?.preferredInterfaceOrientationForPresentation =
        iOSInterfaceOrientation.portrait;
    config.iOSConfig?.uncheckedImgName = 'assets/login/checkbox_circle.png';
    config.iOSConfig?.checkedImgName = 'assets/login/checkbox_circle_checked.png';
    config.iOSConfig?.manualDismiss = false;

    config.iOSConfig?.portraitLayouts ??= FlyVerifyUIConfigIOSCustomLayouts();
    config.iOSConfig?.portraitLayouts?.checkBoxLayout ??=
        FlyVerifyUIConfigIOSPrivacyCheckBoxLayout();
    config.iOSConfig?.portraitLayouts?.checkBoxLayout?.layoutWidth = 18;
    config.iOSConfig?.portraitLayouts?.checkBoxLayout?.layoutHeight = 18;
    config.iOSConfig?.portraitLayouts?.checkBoxLayout
        ?.layoutRightSpaceToPrivacyLeft = 0;
    config.iOSConfig?.portraitLayouts?.checkBoxLayout?.layoutCenterY = -8;

    config.iOSConfig?.privacySettings = [
      FlyVerifyUIConfigIOSPrivacyText()..text = '登录即同意',
      FlyVerifyUIConfigIOSPrivacyText()
        ..isOperatorPlaceHolder = true
        ..textColor = _themeColor,
      FlyVerifyUIConfigIOSPrivacyText()..text = '、',
      FlyVerifyUIConfigIOSPrivacyText()
        ..text = '用户协议'
        ..textColor = _themeColor
        ..textLinkString = ApiEndpoints.userAgreementUrl
        ..webTitleText = '用户协议',
      FlyVerifyUIConfigIOSPrivacyText()..text = '和',
      FlyVerifyUIConfigIOSPrivacyText()
        ..text = '隐私协议'
        ..textColor = _themeColor
        ..textLinkString = ApiEndpoints.privacyPolicyUrl
        ..webTitleText = '隐私协议',
      FlyVerifyUIConfigIOSPrivacyText()..text = '并授权潮星球使用认证服务',
    ];
  }

  void _configAndroid(FlyVerifyUIConfig config) {
    config.androidPortraitConfig ??= FlyVerifyUIConfigAndroid();
    final android = config.androidPortraitConfig!;

    android.backgroundImgPath = 'login/back.png';
    android.immersiveTheme = true;
    android.immersiveStatusTextColorBlack = true;

    android.logoImgPath = 'assets/logo.png';

    android.checkboxHidden = false;
    android.checkboxDefaultState = false;
    android.checkboxWidth = 18;
    android.checkboxHeight = 18;
    android.uncheckedImgName = "login/checkbox_circle.png";
    android.checkedImgName = "login/checkbox_circle_checked.png";

    android.loginBtnHidden = false;
    android.loginBtnWidth = 280;
    android.loginBtnHeight = 45;
    android.loginBtnTextSize = 16;
    android.loginImgNormalName = '#793DF9';
    android.loginImgPressedName = '#793DF9';

    android.agreementTextStartString = '登录即同意';
    android.agreementTextAndString1 = 'wxp_flyverify_agreement_and1';
    android.agreementTextAndString2 = 'wxp_flyverify_agreement_and2';
    android.agreementTextAndString3 = '';
    android.agreementTextEndString = '并授权潮星球使用认证服务';

    android.cusAgreementNameText1 = 'wxp_flyverify_user_agreement';
    android.cusAgreementUrl1 = _userAgreementUrl;
    android.cusAgreementNameText2 = 'wxp_flyverify_privacy_agreement';
    android.cusAgreementUrl2 = _privacyUrl;
  }

  void _onAuthPageResult(
      Map<dynamic, dynamic>? ret, Map<dynamic, dynamic>? err) {
    if (err != null) {
      FToastUtil.show('拉起一键登录授权页失败');
    }
  }

  void _onAuthCanceled(Map<dynamic, dynamic>? ret, Map<dynamic, dynamic>? err) {}

  Future<void> _onIOSLoginResult(
      Map<dynamic, dynamic>? ret, Map<dynamic, dynamic>? err) async {
    if (ret != null && err == null) {
      await _handleOneClickLoginResult(ret);
    } else if (err != null) {
      FToastUtil.show(err.toString());
    } else {
      FToastUtil.show('登录验证失败');
    }
  }

  void _onCustomControlClick(
      Map<dynamic, dynamic>? ret, Map<dynamic, dynamic>? err) {}

  Future<void> _onAndroidEvent(
      Map<dynamic, dynamic>? ret, Map<dynamic, dynamic>? err) async {
    if (ret != null && err == null) {
      final resultStr = ret['ret']?.toString() ?? '';
      if (resultStr.isEmpty) return;
      if (resultStr.contains('onOtherLogin')) return;
      if (resultStr.contains('onUserCanceled')) return;
      await _handleOneClickLoginResult(ret);
    } else if (err != null) {
      FToastUtil.show('取号失败');
    }
  }

  Future<void> _handleOneClickLoginResult(Map<dynamic, dynamic> ret) async {
    final credentials = _parseCredentials(ret);
    if (credentials == null) {
      FToastUtil.show('登录验证失败');
      return;
    }

    await _performOneClickLogin(
      token: credentials['token']!,
      opToken: credentials['opToken']!,
      operatorType: credentials['operatorType']!,
    );
  }

  Map<String, String>? _parseCredentials(Map<dynamic, dynamic> ret) {
    final payload = ret['ret'] ?? ret;
    final map = Map<String, dynamic>.from((payload ?? {}) as Map);

    final token = (map['token'] ?? map['loginToken'] ?? '').toString();
    final opToken = (map['opToken'] ?? '').toString();
    var operatorType =
        (map['operator'] ?? map['operatorType'] ?? '').toString();

    operatorType = _normalizeOperatorType(operatorType);

    if (token.isEmpty || opToken.isEmpty || operatorType.isEmpty) {
      return null;
    }

    return {
      'token': token,
      'opToken': opToken,
      'operatorType': operatorType,
    };
  }

  String _normalizeOperatorType(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('移动') || lower.contains('cmcc') || lower == 'cm') {
      return 'CMCC';
    }
    if (lower.contains('联通') || lower.contains('cucc') || lower == 'cu') {
      return 'CUCC';
    }
    if (lower.contains('电信') || lower.contains('ctcc') || lower == 'ct') {
      return 'CTCC';
    }
    return raw;
  }

  Future<void> _performOneClickLogin({
    required String token,
    required String opToken,
    required String operatorType,
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final res = await postOneClickLogin(
        token: token,
        opToken: opToken,
        operator: operatorType,
      );

      if (res.ok && res.data != null) {
        await LoginRouteHelper.handleLoginSuccess(res.data!);
      } else {
        FToastUtil.show(res.message ?? '登录失败');
      }
    } catch (e) {
      FToastUtil.show('登录失败');
    } finally {
      isLoading.value = false;
    }
  }
}
