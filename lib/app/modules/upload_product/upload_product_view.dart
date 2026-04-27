import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:cxq_merchant_flutter/common/constants/app_constants.dart';
import 'package:cxq_merchant_flutter/common/widget/app_bar_widget.dart';
import 'package:cxq_merchant_flutter/common/widget/button_widget.dart';
import 'package:cxq_merchant_flutter/app/routes/app_pages.dart';
import 'upload_product_logic.dart';

class UploadProductPage extends StatelessWidget {
  const UploadProductPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UploadProductLogic>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: background,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppBarWidget(
              backOnTap: controller.onBackPressed,
              title: '上传商品',
              rightWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: controller.onSaveDraft,
                    child: Text(
                      '暂存',
                      style: TextStyle(fontSize: 14.sp, color: primary),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  GestureDetector(
                    onTap: controller.onPreview,
                    child: Text(
                      '预览',
                      style: TextStyle(fontSize: 14.sp, color: primary),
                    ),
                  ),
                  SizedBox(width: 16.w),
                ],
              ),
            ),
          ),

          // ========== 可滚动内容区 ==========
          Expanded(
            child: Container(
              color: background,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildProductImagesSection(context, controller),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildBasicInfoSection(controller),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildParamsSection(controller),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildServicesSection(controller),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildShippingSection(controller),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildDetailImagesSection(context, controller),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),

          // ========== 底部提交按钮（固定，不受键盘影响） ==========
          _buildSubmitButton(controller),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  // ================================================================
  // 商品图片区域
  // ================================================================
  Widget _buildProductImagesSection(
      BuildContext context, UploadProductLogic controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() {
            final images = controller.productImages;
            final showAddBtn =
                images.length < UploadProductLogic.maxProductImages;

            // 没有图片时，上传按钮居中
            if (images.isEmpty) {
              return _buildImagePickerButton(
                onTap: () => controller.pickProductImages(context),
                label: '上传商品图片',
              );
            }

            return SizedBox(
              height: 90.w,
              child: Row(
                children: [
                  if (showAddBtn)
                    Padding(
                      padding: EdgeInsets.only(left: 16.w, right: 8.w),
                      child: _buildImagePickerButton(
                        onTap: () => controller.pickProductImages(context),
                        label: '上传商品图片',
                      ),
                    ),
                  Expanded(
                    child: ReorderableListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(
                        left: showAddBtn ? 0 : 16.w,
                        right: 16.w,
                      ),
                      buildDefaultDragHandles: false,
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            final scale =
                                Tween<double>(begin: 1.0, end: 1.08)
                                    .animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    ))
                                    .value;
                            return Transform.scale(
                              scale: scale,
                              child: Material(
                                color: Colors.transparent,
                                elevation: 6,
                                shadowColor: Colors.black26,
                                borderRadius: BorderRadius.circular(8.r),
                                child: child,
                              ),
                            );
                          },
                          child: child,
                        );
                      },
                      itemCount: images.length,
                      onReorder: controller.reorderProductImages,
                      itemBuilder: (_, index) {
                        return Padding(
                          key: ValueKey('product_img_$index'),
                          padding: EdgeInsets.only(
                            right: index < images.length - 1 ? 8.w : 0,
                          ),
                          child: ReorderableDelayedDragStartListener(
                            index: index,
                            child: _buildImageItem(
                              file: images[index],
                              index: index,
                              onRemove: () =>
                                  controller.removeProductImage(index),
                              isCover: index == 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 8.h),
          Text(
            '图片大小不超过3MB，可拖动调整位置，最多上传9张',
            style: TextStyle(fontSize: 12.sp, color: textAssist),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 商品基本信息
  // ================================================================
  Widget _buildBasicInfoSection(UploadProductLogic controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品基本信息',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInputRow(
            label: '商品名称：',
            controller: controller.nameController,
            hint: '请输入商品名称',
            maxLength: 30,
            required: true,
          ),
          Divider(height: 1, color: dividerColor),
          _buildInputRow(
            label: '商品简介：',
            controller: controller.descController,
            hint: '请输入商品简介',
            maxLength: 200,
          ),
          Divider(height: 1, color: dividerColor),
          _buildInputRow(
            label: '商品吊牌价：',
            controller: controller.priceController,
            hint: '请输入商品吊牌价',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onEditingComplete: controller.formatPrice,
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow({
    required String label,
    required TextEditingController controller,
    required String hint,
    int? maxLength,
    bool required = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onEditingComplete,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: textPrimary),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: [
                if (maxLength != null)
                  LengthLimitingTextInputFormatter(maxLength),
                if (inputFormatters != null) ...inputFormatters,
              ],
              onEditingComplete: onEditingComplete,
              style: TextStyle(fontSize: 14.sp, color: textFiledColor),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 14.sp, color: hintColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 商品参数 + 商品属性
  // ================================================================
  Widget _buildParamsSection(UploadProductLogic controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品参数
          Obx(() => _buildNavigationRow(
                title: '商品参数',
                isFilled: controller.isParamsFilled,
                description: controller.isParamsFilled
                    ? controller.productParams
                        .map((p) => '${p.keys.first}：${p.values.first}')
                        .join('  ')
                    : '说明：商品参数，如（材质：羊毛；适用人群：12岁以上等介绍描述）',
                onTap: () async {
                  final result = await Get.toNamed(
                    Routes.productParams,
                    arguments: controller.productParams.toList(),
                  );
                  if (result != null && result is List<Map<String, String>>) {
                    controller.productParams.value = result;
                  }
                },
              )),
          SizedBox(height: 12.h),
          Divider(height: 1, color: dividerColor),
          SizedBox(height: 12.h),
          // 商品属性
          Obx(() {
            final data = controller.productAttributesData.value;
            final attrs = data?['attributes'] as List?;
            final desc = (attrs != null && attrs.isNotEmpty)
                ? '属性类型：${attrs.map((a) => a['name']).join('  ')}'
                : '说明：商品SPU属性，如（属性名：颜色 属性值：红色 ）';
            return _buildNavigationRow(
              title: '商品属性',
              isFilled: controller.isAttributesFilled,
              required: true,
              description: desc,
              onTap: () async {
                final result = await Get.toNamed(
                  Routes.productAttributes,
                  arguments: data,
                );
                if (result != null && result is Map<String, dynamic>) {
                  controller.productAttributesData.value = result;
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavigationRow({
    required String title,
    required bool isFilled,
    required String description,
    required VoidCallback onTap,
    bool required = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                isFilled ? '已填写' : '未填写',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isFilled ? textPrimary : textAssist,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right,
                size: 18.w,
                color: textAssist,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            description,
            style: TextStyle(fontSize: 12.sp, color: textAssist),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 商品服务
  // ================================================================
  Widget _buildServicesSection(UploadProductLogic controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品服务',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '说明：基础服务可多选，互斥的基础服务不能多选',
            style: TextStyle(fontSize: 12.sp, color: textAssist),
          ),
          SizedBox(height: 12.h),
          // 保证正品（必填，用户手动勾选）
          Obx(() => _buildCheckItem(
                label: '保证正品',
                checked: controller.isGuaranteeAuthentic.value,
                onTap: () {
                  controller.isGuaranteeAuthentic.value =
                      !controller.isGuaranteeAuthentic.value;
                },
              )),
          SizedBox(height: 12.h),
          Row(
            children: [
              Obx(() => _buildRadioItem(
                    label: '7天无理由退货',
                    selected: controller.returnPolicyType.value == 1,
                    onTap: () => controller.toggleReturnPolicy(1),
                  )),
              SizedBox(width: 16.w),
              Expanded(
                child: Obx(() => _buildRadioItem(
                      label: '不支持7天无理由退换(消耗类商品，如点卡)',
                      selected: controller.returnPolicyType.value == 2,
                      onTap: () => controller.toggleReturnPolicy(2),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem({
    required String label,
    required bool checked,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18.w,
            color: checked ? primary : textAssist,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioItem({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            size: 18.w,
            color: selected ? primary : textAssist,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: textPrimary),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 运费模板设置
  // ================================================================
  Widget _buildShippingSection(UploadProductLogic controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '运费模板设置',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() => GestureDetector(
                onTap: controller.toggleShippingDropdown,
                child: Container(
                  width: double.infinity,
                  height: 44.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: dividerColor),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.selectedShippingTemplate.value,
                          style:
                              TextStyle(fontSize: 14.sp, color: textPrimary),
                        ),
                      ),
                      Icon(
                        controller.isShippingDropdownOpen.value
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 22.w,
                        color: textAssist,
                      ),
                    ],
                  ),
                ),
              )),
          Obx(() {
            if (!controller.isShippingDropdownOpen.value) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: EdgeInsets.only(top: 4.h),
              decoration: BoxDecoration(
                border: Border.all(color: dividerColor),
                borderRadius: BorderRadius.circular(8.r),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  ...controller.shippingTemplates.map((t) => GestureDetector(
                        onTap: () => controller.selectShippingTemplate(t),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 12.h),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: t == controller.selectedShippingTemplate.value
                                  ? primary
                                  : textPrimary,
                            ),
                          ),
                        ),
                      )),
                  GestureDetector(
                    onTap: () {
                      // TODO: 跳转新建运费模板页
                      controller.isShippingDropdownOpen.value = false;
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 12.h),
                      child: Text(
                        '+ 新建运费模板',
                        style: TextStyle(fontSize: 14.sp, color: primary),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ================================================================
  // 商品详情图
  // ================================================================
  Widget _buildDetailImagesSection(
      BuildContext context, UploadProductLogic controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品详情图',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '说明：图片大小不超过3MB，可拖动调整位置，最多上传20张。推荐使用商品白底图，避免过多颜色渲染影响商品展示',
            style: TextStyle(fontSize: 12.sp, color: textAssist),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final images = controller.detailImages;
            final showAddBtn =
                images.length < UploadProductLogic.maxDetailImages;

            return Column(
              children: [
                // 上传按钮固定在顶部居中
                if (showAddBtn)
                  Center(
                    child: _buildImagePickerButton(
                      onTap: () => controller.pickDetailImages(context),
                      label: '上传商品详情图',
                    ),
                  ),
                if (showAddBtn && images.isNotEmpty) SizedBox(height: 12.h),
                // 竖向大图列表，长按拖动排序
                if (images.isNotEmpty)
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          final scale =
                              Tween<double>(begin: 1.0, end: 1.03)
                                  .animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  ))
                                  .value;
                          return Transform.scale(
                            scale: scale,
                            child: Material(
                              color: Colors.transparent,
                              elevation: 4,
                              shadowColor: Colors.black26,
                              borderRadius: BorderRadius.circular(8.r),
                              child: child,
                            ),
                          );
                        },
                        child: child,
                      );
                    },
                    itemCount: images.length,
                    onReorder: controller.reorderDetailImages,
                    itemBuilder: (_, index) {
                      return Padding(
                        key: ValueKey('detail_img_$index'),
                        padding: EdgeInsets.only(
                          bottom: index < images.length - 1 ? 12.h : 0,
                        ),
                        child: ReorderableDelayedDragStartListener(
                          index: index,
                          child: _buildDetailImageItem(
                            file: images[index],
                            onRemove: () =>
                                controller.removeDetailImage(index),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ================================================================
  // 底部提交按钮
  // ================================================================
  Widget _buildSubmitButton(UploadProductLogic controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 46.h,
        child: Obx(() => ThemeButton(
              radius: 60,
              enabled: !controller.isSubmitting.value,
              onTap: controller.onSubmitReview,
              child: Text(
                '提交审核',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
            )),
      ),
    );
  }

  // ================================================================
  // 公共组件
  // ================================================================

  Widget _buildImagePickerButton({
    required VoidCallback onTap,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90.w,
        height: 90.w,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 32.w, color: textAssist),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: textAssist),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildImageItem({
    required File file,
    required int index,
    required VoidCallback onRemove,
    bool isCover = false,
  }) {
    return SizedBox(
      width: 90.w,
      height: 90.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.file(
              file,
              width: 90.w,
              height: 90.w,
              fit: BoxFit.cover,
            ),
          ),
          if (isCover)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    bottomRight: Radius.circular(8.r),
                  ),
                ),
                child: Text(
                  '封面',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 4.w,
            right: 4.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 14.w,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailImageItem({
    required File file,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.file(
            file,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        Positioned(
          top: 8.w,
          right: 8.w,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16.w,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
