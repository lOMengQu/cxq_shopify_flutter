import 'package:cached_network_image/cached_network_image.dart';
import 'package:cxq_merchant_flutter/common/constants/app_constants.dart';
import 'package:cxq_merchant_flutter/common/utils/platform_util.dart';
import 'package:cxq_merchant_flutter/common/utils/toast.dart';
import 'package:cxq_merchant_flutter/common/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'upload_avatar_nickname_logic.dart';

class UploadAvatarNicknamePage extends GetView<UploadAvatarNicknameLogic> {
  const UploadAvatarNicknamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Image.asset(
            "assets/login/back.png",
            width: double.infinity,
            height: 262.h,
            fit: BoxFit.cover,
          ),
          Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).viewPadding.top),
                  _buildAppBar(),
                  Column(
                    children: [
                      SizedBox(height: 40.h),
                      SizedBox(height: 60.h),
                      _buildAvatarSection(context),
                      SizedBox(height: 50.h),
                      _buildNicknameInput(),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 80.h + PlatformUtil.getBottomPadding(context),
                left: 0,
                right: 0,
                child: _buildSubmitButton(),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios,
              size: 20.w,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.pickAndUploadAvatar(context),
      child: Obx(() {
        final avatarUrl = controller.avatar.value;
        return Container(
          width: 140.w,
          height: 140.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: primary.withValues(alpha: 0.5),
              width: 4.w,
            ),
          ),
          child: ClipOval(
            child: avatarUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl,
                    width: 140.w,
                    height: 140.w,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        _buildAvatarPlaceholder(),
                  )
                : _buildAvatarPlaceholder(),
          ),
        );
      }),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 140.w,
      height: 140.w,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/login/came.png",
            width: 52.w,
            height: 53.w,
          ),
          SizedBox(height: 8.h),
          Text(
            '上传头像',
            style: TextStyle(
              fontSize: 14.sp,
              color: textAssist,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Obx(() => TextField(
              controller: controller.nicknameController,
              focusNode: controller.nicknameFocusNode,
              onChanged: controller.updateNickname,
              maxLines: 1,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\n')),
                _GraphemeLengthLimitingTextInputFormatter(10),
              ],
              style: TextStyle(
                fontSize: 14.sp,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: controller.isFocused.value ? '' : '请输入昵称',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: textAssist,
                ),
                border: InputBorder.none,
                counterText: '',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              ),
            )),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: Obx(() => ThemeButton(
              radius: 25,
              enabled: controller.isFormValid,
              onTap: controller.submit,
              child: Text(
                '进入潮星球',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: controller.isFormValid ? Colors.white : textAssist,
                ),
              ),
            )),
      ),
    );
  }
}

class _GraphemeLengthLimitingTextInputFormatter extends TextInputFormatter {
  final int maxLength;

  _GraphemeLengthLimitingTextInputFormatter(this.maxLength);

  int _calculateLength(String text) {
    int length = 0;
    for (final char in text.characters) {
      if (char.length > 1) {
        length += 2;
      } else {
        length += 1;
      }
    }
    return length;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newLength = _calculateLength(newValue.text);

    if (newLength <= maxLength) {
      return newValue;
    }

    showOkToast('最多输入$maxLength个字符');

    return oldValue;
  }
}
