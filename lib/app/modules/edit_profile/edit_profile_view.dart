import 'package:cached_network_image/cached_network_image.dart';
import 'package:city_pickers/city_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/constants/app_constants.dart';
import '../../../common/utils/dialog/tip_dialog.dart';
import '../../../common/utils/toast.dart';
import '../../../common/widget/app_bar_widget.dart';
import 'edit_profile_logic.dart';

class EditProfilePage extends GetView<EditProfileLogic> {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              AppBarWidget(
                backOnTap: _handleBack,
                title: '编辑资料',
                rightWidget: Obx(() {
                  final hasChanges = controller.hasChanges;
                  return GestureDetector(
                    onTap: hasChanges ? _handleSave : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      alignment: Alignment.center,
                      child: Text(
                        '保存',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: hasChanges ? primary : textAssist,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 30.h),
                      // 头像区域
                      _buildAvatarSection(context),
                      SizedBox(height: 40.h),
                      // 昵称区域
                      _buildNicknameSection(),
                      // 分割线
                      _buildDivider(),
                      // 城市区域
                      _buildCitySection(context),
                      // 分割线
                      // _buildDivider(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// 构建头像区域
  Widget _buildAvatarSection(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.pickAndUploadAvatar(context),
      child: Column(
        children: [
          Stack(
            children: [
              // 头像
              Obx(() {
                final avatarUrl = controller.avatar.value;
                return Container(
                  width: 90.w,
                  height: 90.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: background,
                  ),
                  child: ClipOval(
                    child: avatarUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 90.w,
                      height: 90.w,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          _buildDefaultAvatar(),
                    )
                        : _buildDefaultAvatar(),
                  ),
                );
              }),
              // 相机图标
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    child: Image.asset(
                        "assets/user/came.png"
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '点击更换头像',
            style: TextStyle(
              fontSize: 12.sp,
              color: textAssist,
            ),
          ),
        ],
      ),
    );
  }

  /// 默认头像
  Widget _buildDefaultAvatar() {
    return Container(
      width: 90.w,
      height: 90.w,
      color: background,
      child: Icon(
        Icons.person,
        size: 50.w,
        color: textAssist,
      ),
    );
  }

  /// 构建昵称区域
  Widget _buildNicknameSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          Text(
            '昵称',
            style: TextStyle(
              fontSize: 14.sp,
              color: textPrimary,
            ),
          ),
          SizedBox(width: 40.w),
          Expanded(
            child: TextField(
              controller: controller.nicknameController,
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
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: '请输入你的昵称',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: hintColor,
                ),
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建城市区域
  Widget _buildCitySection(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCityPicker(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Text(
              '城市',
              style: TextStyle(
                fontSize: 14.sp,
                color: textPrimary,
              ),
            ),
            Spacer(),
            Obx(() {
              final cityName = controller.city.value;
              return Text(
                cityName.isNotEmpty ? cityName : '请选择你所在的城市',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: cityName.isNotEmpty ? textPrimary : hintColor,
                ),
              );
            }),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right,
              size: 20.w,
              color: textAssist,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分割线
  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 1.h,
      color: dividerColor,
    );
  }

  /// 获取自定义城市数据（直辖市只显示市名，不显示城区/郊县）
  Map<String, dynamic> _getCustomCitiesData() {
    final data = Map<String, dynamic>.from(CityPickers.metaCities);
    // 直辖市：省级code -> 直辖市名称
    const municipalityMap = {
      '110000': {'110000': {'name': '北京市', 'alpha': 'b'}},
      '120000': {'120000': {'name': '天津市', 'alpha': 't'}},
      '310000': {'310000': {'name': '上海市', 'alpha': 's'}},
      '500000': {'500000': {'name': '重庆市', 'alpha': 'c'}},
      '810000': {'810000': {'name': '香港特别行政区', 'alpha': 'x'}},
      '820000': {'820000': {'name': '澳门特别行政区', 'alpha': 'a'}},
    };
    data.addAll(municipalityMap);
    return data;
  }

  /// 显示城市选择器
  Future<void> _showCityPicker(BuildContext context) async {
    final result = await CityPickers.showCityPicker(
      context: context,
      citiesData: _getCustomCitiesData(),
      cancelWidget: Text(
        '取消',
        style: TextStyle(
          fontSize: 14.sp,
          color: textAssist,
        ),
      ),
      confirmWidget: Text(
        '确定',
        style: TextStyle(
          fontSize: 14.sp,
          color: primary,
        ),
      ),
      height: 300.h,
      itemExtent: 40.h,
      showType: ShowType.pc,
      borderRadius: 16.r,
    );

    if (result != null) {
      // 直辖市/特别行政区只用省名，普通省份显示"省+市"全称
      const municipalities = ['北京市', '上海市', '天津市', '重庆市', '香港特别行政区', '澳门特别行政区'];
      final provinceName = result.provinceName ?? '';
      final isMunicipality = municipalities.contains(provinceName);
      final cityName = isMunicipality
          ? provinceName
          : '${result.provinceName ?? ''}${result.cityName ?? ''}';
      final cityId = result.cityId ?? result.provinceId ?? '';
      controller.updateCity(cityName, cityId);
    }
  }

  /// 处理返回
  void _handleBack() {
    if (controller.hasChanges) {
      showTipDialog(
        title: '是否保存更改',
        leftText: '不保存',
        rightText: '保存',
        onLeftTap: () {
          Get.back(); // 关闭弹窗
          Get.back(); // 返回上一页
        },
        onRightTap: () async {
          Get.back(); // 关闭弹窗
          final success = await controller.saveProfile();
          if (success) {
            Get.back(result: {'refresh': true});
          }
        },
      );
    } else {
      Get.back();
    }
  }

  /// 处理保存
  Future<void> _handleSave() async {
    final success = await controller.saveProfile();
    if (success) {
      Get.back(result: {'refresh': true});
    }
  }
}

/// 文本长度限制器：emoji 占 2 个字符，普通字符占 1 个
/// 当空间不足时拒绝输入并显示提示
class _GraphemeLengthLimitingTextInputFormatter extends TextInputFormatter {
  final int maxLength;

  _GraphemeLengthLimitingTextInputFormatter(this.maxLength);

  /// 计算文本长度：emoji 占 2 个字符，普通字符占 1 个
  int _calculateLength(String text) {
    int length = 0;
    for (final char in text.characters) {
      // emoji 通常长度 > 1 (UTF-16 代码单元)
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
    final oldLength = _calculateLength(oldValue.text);
    final newLength = _calculateLength(newValue.text);

    if (newLength <= maxLength) {
      return newValue;
    }

    // 超过限制，显示提示并拒绝输入
    showOkToast('最多输入$maxLength个字符');

    return oldValue;
  }
}
