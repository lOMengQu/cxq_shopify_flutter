import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:cxq_merchant_flutter/common/constants/app_constants.dart';
import 'package:cxq_merchant_flutter/common/utils/toast.dart';
import 'package:cxq_merchant_flutter/common/widget/app_bar_widget.dart';

import 'product_attributes_logic.dart';

class ProductAttributesPage extends StatelessWidget {
  const ProductAttributesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProductAttributesLogic>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppBarWidget(
              backOnTap: c.onBackPressed,
              title: '商品属性',
              rightWidget: GestureDetector(
                onTap: c.onComplete,
                child: Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Text('完成',
                      style: TextStyle(fontSize: 14.sp, color: primary)),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: background,
              child: Obx(() => _buildContent(context, c)),
            ),
          ),
          // 批量编辑底部栏
          Obx(() => c.isBatchEditMode.value && c.hasValidSkuCombinations
              ? _buildBatchEditBar(context, c)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductAttributesLogic c) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          // 说明
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14.sp, color: textAssist),
              children: [
                const TextSpan(text: '说明：'),
                TextSpan(
                  text: '商品SPU属性，如(属性名：颜色 属性值：红色）',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // 举例缩略图
          _buildExampleThumbnail(context),
          SizedBox(height: 20.h),
          // ========== 属性名 ==========
          _buildAttrNamesSection(c),
          SizedBox(height: 16.h),
          // ========== 各属性值 ==========
          ...List.generate(c.attributeGroups.length, (i) {
            final group = c.attributeGroups[i];
            if (group.isEmpty) return const SizedBox.shrink();
            return _buildAttrValuesSection(c, i);
          }),
          // ========== 现价/库存/限购 ==========
          if (c.hasValidSkuCombinations) ...[
            Divider(color: dividerColor),
            SizedBox(height: 12.h),
            _buildSkuSection(context, c),
          ],
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // ========== 举例缩略图 ==========

  Widget _buildExampleThumbnail(BuildContext context) {
    const exampleImage = 'assets/product/img.png';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('举例：', style: TextStyle(fontSize: 14.sp, color: textAssist)),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () {
            Get.dialog(
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.asset(exampleImage,
                            width: double.infinity, fit: BoxFit.fitWidth),
                      ),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text('关闭',
                            style:
                                TextStyle(fontSize: 14.sp, color: primary)),
                      ),
                    ],
                  ),
                ),
              ),
              barrierDismissible: true,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.asset(exampleImage,
                width: 120.w, height: 80.h, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  // ========== 属性名区域 ==========

  Widget _buildAttrNamesSection(ProductAttributesLogic c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('属性名：',
                style: TextStyle(fontSize: 14.sp, color: textPrimary)),
            SizedBox(width: 8.w),
            _buildAddButton('+ 自定义属性名', c.addAttributeName),
          ],
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: List.generate(c.attributeGroups.length, (i) {
            return _buildAttrNameChip(c, i);
          }),
        ),
      ],
    );
  }

  Widget _buildAttrNameChip(ProductAttributesLogic c, int index) {
    final group = c.attributeGroups[index];
    return Obx(() {
      final isError = group.hasError.value;
      final borderColor = isError ? Colors.red : primary;

      return Container(
        constraints: BoxConstraints(minWidth: 90.w),
        padding: EdgeInsets.only(left: 24.w, right: 8.w, top: 6.h, bottom: 6.h),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red.withValues(alpha: 0.06)
              : const Color(0xFF793DF9).withValues(alpha: 0.1),
          border: Border.all(color: borderColor, width: 1.2),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: IntrinsicWidth(
                child: TextField(
                  controller: group.nameController,
                  focusNode: group.nameFocus,
                  maxLength: 15,
                  textAlign: TextAlign.center,
                  inputFormatters: [LengthLimitingTextInputFormatter(15)],
                  decoration: InputDecoration(
                    hintText: '属性名',
                    hintStyle: TextStyle(fontSize: 13.sp, color: primary.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    constraints: BoxConstraints(maxWidth: 100.w),
                  ),
                  style: TextStyle(fontSize: 13.sp, color: primary),
                  onSubmitted: (_) => c.onAttributeNameSubmitted(index),
                  onEditingComplete: () => c.onAttributeNameSubmitted(index),
                ),
              ),
            ),
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: () => c.removeAttributeName(index),
              child: Icon(Icons.close, size: 18.w, color: borderColor),
            ),
          ],
        ),
      );
    });
  }

  // ========== 属性值区域 ==========

  Widget _buildAttrValuesSection(ProductAttributesLogic c, int groupIndex) {
    final group = c.attributeGroups[groupIndex];
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: dividerColor),
          SizedBox(height: 10.h),
          Row(
            children: [
              Text('${group.name}–属性值：',
                  style: TextStyle(fontSize: 14.sp, color: textPrimary)),
              SizedBox(width: 8.w),
              _buildAddButton(
                  '+ 自定义属性值', () => c.addAttributeValue(groupIndex)),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(group.values.length, (vi) {
              return _buildAttrValueChip(c, groupIndex, vi);
            }),
          ),
          SizedBox(height: 16.h),
        ],
      );
    });
  }

  Widget _buildAttrValueChip(
      ProductAttributesLogic c, int groupIndex, int valueIndex) {
    final val = c.attributeGroups[groupIndex].values[valueIndex];
    return Obx(() {
      final isError = val.hasError.value;
      final borderColor = isError ? Colors.red : primary;

      return Container(
        constraints: BoxConstraints(minWidth: 90.w),
        padding: EdgeInsets.only(left: 24.w, right: 8.w, top: 8.h, bottom: 8.h),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red.withValues(alpha: 0.06)
              : const Color(0xFF793DF9).withValues(alpha: 0.1),
          border: Border.all(color: borderColor, width: 1.2),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: IntrinsicWidth(
                child: TextField(
                  controller: val.controller,
                  focusNode: val.focusNode,
                  maxLength: 15,
                  textAlign: TextAlign.center,
                  inputFormatters: [LengthLimitingTextInputFormatter(15)],
                  decoration: InputDecoration(
                    hintText: '属性值',
                    hintStyle: TextStyle(fontSize: 13.sp, color: primary.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    constraints: BoxConstraints(maxWidth: 100.w),
                  ),
                  style: TextStyle(fontSize: 13.sp, color: primary),
                  onSubmitted: (_) =>
                      c.onAttributeValueSubmitted(groupIndex, valueIndex),
                  onEditingComplete: () =>
                      c.onAttributeValueSubmitted(groupIndex, valueIndex),
                ),
              ),
            ),
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: () => c.removeAttributeValue(groupIndex, valueIndex),
              child: Icon(Icons.close, size: 18.w, color: borderColor),
            ),
          ],
        ),
      );
    });
  }

  // ========== 现价/库存/限购 区域 ==========

  Widget _buildSkuSection(BuildContext context, ProductAttributesLogic c) {
    final firstVals = c.attributeGroups.isNotEmpty
        ? c.attributeGroups.first.values
            .where((v) => v.text.isNotEmpty)
            .map((v) => v.text)
            .toList()
        : <String>[];

    if (firstVals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行 + 批量编辑按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('现价/库存/限购：',
                style: TextStyle(fontSize: 14.sp, color: textPrimary)),
            GestureDetector(
              onTap: c.toggleBatchEditMode,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Obx(() => Text(
                      c.isBatchEditMode.value ? '取消编辑' : '批量编辑',
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    )),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // 第一属性值标签页
        Obx(() {
          final idx = c.selectedFirstAttrIndex.value;
          return Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(firstVals.length, (i) {
              final isSelected = i == idx;
              return GestureDetector(
                onTap: () => c.selectedFirstAttrIndex.value = i,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primary
                        : const Color(0xFF793DF9).withValues(alpha: 0.1),
                    border: Border.all(
                        color: primary ),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Text(
                    firstVals[i],
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isSelected ? Colors.white : primary,
                    ),
                  ),
                ),
              );
            }),
          );
        }),
        SizedBox(height: 12.h),
        // 当前tab内容
        Obx(() {
          final idx = c.selectedFirstAttrIndex.value;
          if (idx >= firstVals.length) return const SizedBox.shrink();
          final currentFirstVal = firstVals[idx];
          return _buildSkuTabContent(context, c, currentFirstVal);
        }),
      ],
    );
  }

  Widget _buildSkuTabContent(
      BuildContext context, ProductAttributesLogic c, String firstVal) {
    final skuKeys = c.getSkuKeysForTab(firstVal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SKU 图片
        _buildSkuImageUpload(context, c, firstVal),
        SizedBox(height: 12.h),
        // SKU 行
        ...skuKeys.map((key) => _buildSkuRow(c, key)),
      ],
    );
  }

  Widget _buildSkuImageUpload(
      BuildContext context, ProductAttributesLogic c, String firstVal) {
    return Obx(() {
      final file = c.skuImages[firstVal];
      return GestureDetector(
        onTap: () => c.pickSkuImage(context, firstVal),
        child: Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: dividerColor),
          ),
          child: file != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.file(file,
                      width: 80.w, height: 80.w, fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        size: 28.w, color: textAssist),
                    SizedBox(height: 4.h),
                    Text('上传sku图',
                        style:
                            TextStyle(fontSize: 10.sp, color: textAssist)),
                  ],
                ),
        ),
      );
    });
  }

  Widget _buildSkuRow(ProductAttributesLogic c, String key) {
    final label = c.getSkuRowLabel(key);
    final row = c.skuRows[key];
    if (row == null) return const SizedBox.shrink();

    return Obx(() {
      final isBatch = c.isBatchEditMode.value;
      final isSelected = c.selectedSkuKeys.contains(key);
      final isError = row.hasError.value;

      return Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label.isNotEmpty)
              Row(
                children: [
                  if (isBatch)
                    GestureDetector(
                      onTap: () => c.toggleSkuSelection(key),
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 20.w,
                          color: isSelected ? primary : textAssist,
                        ),
                      ),
                    ),
                  Text('$label：',
                      style: TextStyle(fontSize: 13.sp, color: textPrimary)),
                ],
              ),
            if (label.isNotEmpty) SizedBox(height: 6.h),
            if (label.isEmpty && isBatch)
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: GestureDetector(
                  onTap: () => c.toggleSkuSelection(key),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20.w,
                    color: isSelected ? primary : textAssist,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: _buildSkuInput(
                    ctrl: row.priceCtrl,
                    hint: '输入现价',
                    isError: isError,
                    keyboard: const TextInputType.numberWithOptions(
                        decimal: true),
                    formatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    onEditingComplete: () => c.formatPrice(row.priceCtrl),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildSkuInput(
                    ctrl: row.stockCtrl,
                    hint: '输入库存数量',
                    isError: isError,
                    keyboard: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    onEditingComplete: () =>
                        c.validateInteger(row.stockCtrl),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildSkuInput(
                    ctrl: row.limitCtrl,
                    hint: '输入限购数量',
                    isError: isError,
                    keyboard: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    onEditingComplete: () =>
                        c.validateInteger(row.limitCtrl),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSkuInput({
    required TextEditingController ctrl,
    required String hint,
    required bool isError,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    VoidCallback? onEditingComplete,
  }) {
    return Container(
      height: 36.h,
      decoration: BoxDecoration(
        border:
            Border.all(color: isError ? Colors.red : Color(0XFFD8D8D8), width: 1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        textAlign: TextAlign.center,
        inputFormatters: formatters,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 11.sp, color: textAssist),
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        ),
        style: TextStyle(fontSize: 12.sp, color: textPrimary),
      ),
    );
  }

  // ========== 批量编辑底部栏 ==========

  Widget _buildBatchEditBar(BuildContext context, ProductAttributesLogic c) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 10.h,
        bottom: MediaQuery.of(context).padding.bottom + 10.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 全选
          GestureDetector(
            onTap: c.selectAllSkus,
            child: Obx(() {
              final allKeys = c.getAllSkuKeys();
              final allSelected =
                  allKeys.isNotEmpty &&
                  c.selectedSkuKeys.length == allKeys.length;
              return Row(
                children: [
                  Icon(
                    allSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20.w,
                    color: allSelected ? primary : textAssist,
                  ),
                  SizedBox(width: 4.w),
                  Text('全选',
                      style:
                          TextStyle(fontSize: 13.sp, color: textPrimary)),
                ],
              );
            }),
          ),
          SizedBox(width: 12.w),
          // 设置现价/库存/限购
          Expanded(
            child: GestureDetector(
              onTap: () => _showBatchSetDialog(context, c),
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Text('设置现价/库存/限购',
                      style: TextStyle(
                          fontSize: 13.sp, color: Colors.white)),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // 完成
          GestureDetector(
            onTap: c.toggleBatchEditMode,
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(
                child: Text('完成',
                    style: TextStyle(
                        fontSize: 13.sp, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== 批量设置弹窗 ==========

  void _showBatchSetDialog(BuildContext context, ProductAttributesLogic c) {
    if (c.selectedSkuKeys.isEmpty) {
      FToastUtil.show('请先选择属性项');
      return;
    }

    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final limitCtrl = TextEditingController();
    final allFilled = false.obs;

    void checkFilled() {
      allFilled.value = priceCtrl.text.trim().isNotEmpty &&
          stockCtrl.text.trim().isNotEmpty &&
          limitCtrl.text.trim().isNotEmpty;
    }

    priceCtrl.addListener(checkFilled);
    stockCtrl.addListener(checkFilled);
    limitCtrl.addListener(checkFilled);

    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 280.w,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text('设置现价/库存/限购',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: textPrimary)),
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child:
                            Icon(Icons.close, size: 20.w, color: textAssist),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Divider(height: 1, color: dividerColor),
                _buildDialogRow('现价：', '请输入现价', priceCtrl,
                    TextInputType.numberWithOptions(decimal: true)),
                Divider(height: 1, color: dividerColor),
                _buildDialogRow('库存数量：', '请输入库存数量', stockCtrl,
                    TextInputType.number),
                Divider(height: 1, color: dividerColor),
                _buildDialogRow('限购数量：', '请输入限购数量', limitCtrl,
                    TextInputType.number),
                SizedBox(height: 20.h),
                // 按钮
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          height: 40.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: dividerColor),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Center(
                            child: Text('取消',
                                style: TextStyle(
                                    fontSize: 14.sp, color: textAssist)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(() {
                        final enabled = allFilled.value;
                        return GestureDetector(
                          onTap: enabled
                              ? () {
                                  final price = priceCtrl.text.trim();
                                  final stock = stockCtrl.text.trim();
                                  final limit = limitCtrl.text.trim();
                                  final v = double.tryParse(price);
                                  if (v == null) {
                                    FToastUtil.show('仅能输入数字');
                                    return;
                                  }
                                  if (int.tryParse(stock) == null) {
                                    FToastUtil.show('库存仅能输入整数');
                                    return;
                                  }
                                  if (int.tryParse(limit) == null) {
                                    FToastUtil.show('限购仅能输入整数');
                                    return;
                                  }
                                  c.batchSetValues(
                                      v.toStringAsFixed(2), stock, limit);
                                  Get.back();
                                }
                              : null,
                          child: Container(
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: enabled
                                  ? primary
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Center(
                              child: Text('确定',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white)),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildDialogRow(String label, String hint,
      TextEditingController ctrl, TextInputType keyboard) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(fontSize: 14.sp, color: textPrimary)),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: keyboard,
              textAlign: TextAlign.right,
              inputFormatters: keyboard == TextInputType.number
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'))
                    ],
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 14.sp, color: textAssist),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 14.sp, color: textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // ========== 通用组件 ==========

  Widget _buildAddButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(text,
            style: TextStyle(fontSize: 13.sp, color: Colors.white)),
      ),
    );
  }
}
