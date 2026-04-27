import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:cxq_merchant_flutter/common/utils/dialog/tip_dialog.dart';
import 'package:cxq_merchant_flutter/common/utils/toast.dart';

// ========== 数据模型 ==========

class AttributeGroup {
  static int _idCounter = 0;
  final int id;
  final TextEditingController nameController;
  final FocusNode nameFocus;
  final values = <AttributeValue>[].obs;
  final hasError = false.obs;

  AttributeGroup({String? name})
      : id = _idCounter++,
        nameController = TextEditingController(text: name ?? ''),
        nameFocus = FocusNode();

  String get name => nameController.text.trim();
  bool get isEmpty => name.isEmpty;

  void dispose() {
    nameController.dispose();
    nameFocus.dispose();
    for (var v in values) {
      v.dispose();
    }
  }
}

class AttributeValue {
  static int _idCounter = 0;
  final int id;
  final TextEditingController controller;
  final FocusNode focusNode;
  final hasError = false.obs;

  AttributeValue({String? text})
      : id = _idCounter++,
        controller = TextEditingController(text: text ?? ''),
        focusNode = FocusNode();

  String get text => controller.text.trim();
  bool get isEmpty => text.isEmpty;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class SkuRowData {
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final limitCtrl = TextEditingController();
  final hasError = false.obs;

  SkuRowData({String? price, String? stock, String? limit}) {
    if (price != null) priceCtrl.text = price;
    if (stock != null) stockCtrl.text = stock;
    if (limit != null) limitCtrl.text = limit;
  }

  bool get isComplete =>
      priceCtrl.text.trim().isNotEmpty &&
      stockCtrl.text.trim().isNotEmpty &&
      limitCtrl.text.trim().isNotEmpty;

  void dispose() {
    priceCtrl.dispose();
    stockCtrl.dispose();
    limitCtrl.dispose();
  }
}

// ========== Controller ==========

class ProductAttributesLogic extends GetxController {
  final attributeGroups = <AttributeGroup>[].obs;
  final skuImages = <String, File>{}.obs;
  final skuRows = <String, SkuRowData>{}.obs;

  final selectedFirstAttrIndex = 0.obs;
  final isBatchEditMode = false.obs;
  final selectedSkuKeys = <String>{}.obs;
  final _hasChanges = false.obs;

  bool get hasChanges => _hasChanges.value;

  String _chinesePathName(AssetPathEntity path) => switch (path) {
        final p when p.isAll => '最近图片',
        final p when p.name.toLowerCase().contains('camera') => '相机',
        final p when p.name.toLowerCase().contains('weixin') => '微信',
        final p when p.name.toLowerCase().contains('qq') => 'QQ',
        final p when p.name.toLowerCase().contains('screenshots') => '截图',
        final p when p.name.toLowerCase().contains('download') => '下载',
        _ => path.name,
      };

  @override
  void onInit() {
    super.onInit();
    final data = Get.arguments as Map<String, dynamic>?;
    if (data != null) _loadExistingData(data);
  }

  void _loadExistingData(Map<String, dynamic> data) {
    final attrs = data['attributes'] as List?;
    if (attrs != null) {
      for (var attr in attrs) {
        final group = AttributeGroup(name: attr['name'] as String);
        final vals = attr['values'] as List<String>;
        for (var v in vals) {
          group.values.add(AttributeValue(text: v));
        }
        attributeGroups.add(group);
      }
    }
    final existingSku = data['skuData'] as Map<String, Map<String, String>>?;
    if (existingSku != null) {
      for (var entry in existingSku.entries) {
        skuRows[entry.key] = SkuRowData(
          price: entry.value['price'],
          stock: entry.value['stock'],
          limit: entry.value['limit'],
        );
      }
    }
    _refreshSkuRows();
  }

  // ========== 属性名操作 ==========

  void addAttributeName() {
    for (var group in attributeGroups) {
      if (group.isEmpty) {
        group.hasError.value = true;
        group.nameFocus.requestFocus();
        FToastUtil.show('请输入属性名');
        return;
      }
    }
    final group = AttributeGroup();
    attributeGroups.add(group);
    _hasChanges.value = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      group.nameFocus.requestFocus();
    });
  }

  void removeAttributeName(int index) {
    if (index < 0 || index >= attributeGroups.length) return;
    attributeGroups[index].dispose();
    attributeGroups.removeAt(index);
    _hasChanges.value = true;
    _refreshSkuRows();
    if (selectedFirstAttrIndex.value >= _getFirstAttrValues().length) {
      selectedFirstAttrIndex.value = 0;
    }
  }

  void onAttributeNameSubmitted(int index) {
    final group = attributeGroups[index];
    if (group.name.isNotEmpty) {
      group.hasError.value = false;
      if (group.values.isEmpty) {
        final val = AttributeValue();
        group.values.add(val);
        Future.delayed(const Duration(milliseconds: 100), () {
          val.focusNode.requestFocus();
        });
      }
      _hasChanges.value = true;
      attributeGroups.refresh();
      _refreshSkuRows();
    }
  }

  // ========== 属性值操作 ==========

  void addAttributeValue(int groupIndex) {
    final group = attributeGroups[groupIndex];
    for (var val in group.values) {
      if (val.isEmpty) {
        val.hasError.value = true;
        val.focusNode.requestFocus();
        FToastUtil.show('请输入属性值');
        return;
      }
    }
    final newVal = AttributeValue();
    group.values.add(newVal);
    _hasChanges.value = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      newVal.focusNode.requestFocus();
    });
  }

  void removeAttributeValue(int groupIndex, int valueIndex) {
    final group = attributeGroups[groupIndex];
    if (valueIndex < 0 || valueIndex >= group.values.length) return;
    group.values[valueIndex].dispose();
    group.values.removeAt(valueIndex);
    _hasChanges.value = true;
    _refreshSkuRows();
  }

  void onAttributeValueSubmitted(int groupIndex, int valueIndex) {
    final val = attributeGroups[groupIndex].values[valueIndex];
    if (val.text.isNotEmpty) {
      val.hasError.value = false;
      _hasChanges.value = true;
      attributeGroups.refresh();
      _refreshSkuRows();
    }
  }

  // ========== SKU 组合计算 ==========

  List<String> _getFirstAttrValues() {
    if (attributeGroups.isEmpty) return [];
    return attributeGroups.first.values
        .where((v) => v.text.isNotEmpty)
        .map((v) => v.text)
        .toList();
  }

  List<List<String>> _getRemainingAttrValues() {
    if (attributeGroups.length <= 1) return [];
    return attributeGroups
        .skip(1)
        .where((g) => g.name.isNotEmpty)
        .map((g) =>
            g.values.where((v) => v.text.isNotEmpty).map((v) => v.text).toList())
        .where((list) => list.isNotEmpty)
        .toList();
  }

  List<String> _cartesianProduct(List<List<String>> lists) {
    if (lists.isEmpty) return [''];
    List<String> result = [''];
    for (var list in lists) {
      final newResult = <String>[];
      for (var existing in result) {
        for (var item in list) {
          newResult.add(existing.isEmpty ? item : '$existing/$item');
        }
      }
      result = newResult;
    }
    return result;
  }

  List<String> getSkuKeysForTab(String firstVal) {
    final remaining = _getRemainingAttrValues();
    final combos = _cartesianProduct(remaining);
    if (combos.length == 1 && combos.first.isEmpty) return [firstVal];
    return combos.map((c) => '$firstVal/$c').toList();
  }

  List<String> getAllSkuKeys() {
    final firstVals = _getFirstAttrValues();
    if (firstVals.isEmpty) return [];
    final all = <String>[];
    for (var fv in firstVals) {
      all.addAll(getSkuKeysForTab(fv));
    }
    return all;
  }

  bool get hasValidSkuCombinations {
    final first = attributeGroups.firstOrNull;
    if (first == null || first.isEmpty) return false;
    return first.values.any((v) => v.text.isNotEmpty);
  }

  String getSkuRowLabel(String key) {
    final parts = key.split('/');
    if (parts.length <= 1) return '';
    return parts.sublist(1).join('/');
  }

  void _refreshSkuRows() {
    final allKeys = getAllSkuKeys();
    final keysToRemove =
        skuRows.keys.where((k) => !allKeys.contains(k)).toList();
    for (var k in keysToRemove) {
      skuRows[k]?.dispose();
      skuRows.remove(k);
    }
    for (var k in allKeys) {
      skuRows.putIfAbsent(k, () => SkuRowData());
    }
    final firstVals = _getFirstAttrValues().toSet();
    final imgToRemove =
        skuImages.keys.where((k) => !firstVals.contains(k)).toList();
    for (var k in imgToRemove) {
      skuImages.remove(k);
    }
  }

  // ========== SKU 图片 ==========

  Future<void> pickSkuImage(
      BuildContext context, String firstAttrValue) async {
    final result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 1,
        requestType: RequestType.image,
        pathNameBuilder: _chinesePathName,
      ),
    );
    if (result != null && result.isNotEmpty) {
      final file = await result.first.file;
      if (file != null) {
        skuImages[firstAttrValue] = file;
        _hasChanges.value = true;
      }
    }
  }

  // ========== 批量编辑 ==========

  void toggleBatchEditMode() {
    isBatchEditMode.value = !isBatchEditMode.value;
    if (!isBatchEditMode.value) selectedSkuKeys.clear();
  }

  void toggleSkuSelection(String key) {
    if (selectedSkuKeys.contains(key)) {
      selectedSkuKeys.remove(key);
    } else {
      selectedSkuKeys.add(key);
    }
  }

  void selectAllSkus() {
    final allKeys = getAllSkuKeys();
    if (selectedSkuKeys.length == allKeys.length) {
      selectedSkuKeys.clear();
    } else {
      selectedSkuKeys
        ..clear()
        ..addAll(allKeys);
    }
  }

  void batchSetValues(String price, String stock, String limit) {
    for (var key in selectedSkuKeys) {
      final row = skuRows[key];
      if (row != null) {
        if (price.isNotEmpty) row.priceCtrl.text = price;
        if (stock.isNotEmpty) row.stockCtrl.text = stock;
        if (limit.isNotEmpty) row.limitCtrl.text = limit;
      }
    }
    _hasChanges.value = true;
  }

  // ========== 输入校验 ==========

  void formatPrice(TextEditingController ctrl) {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    final value = double.tryParse(text);
    if (value == null) {
      FToastUtil.show('仅能输入数字');
      ctrl.clear();
      return;
    }
    ctrl.text = value.toStringAsFixed(2);
  }

  void validateInteger(TextEditingController ctrl) {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    if (int.tryParse(text) == null) {
      FToastUtil.show('仅能输入数字');
      ctrl.clear();
    }
  }

  // ========== 完成 ==========

  void onComplete() {
    final validGroups =
        attributeGroups.where((g) => g.name.isNotEmpty).toList();

    if (validGroups.isEmpty) {
      Get.back(result: null);
      return;
    }

    bool hasIncomplete = false;
    for (var group in validGroups) {
      final validValues = group.values.where((v) => v.text.isNotEmpty).toList();
      if (validValues.isEmpty) {
        group.hasError.value = true;
        hasIncomplete = true;
      }
    }

    final allKeys = getAllSkuKeys();
    for (var key in allKeys) {
      final row = skuRows[key];
      if (row != null && !row.isComplete) {
        row.hasError.value = true;
        hasIncomplete = true;
      }
    }

    if (hasIncomplete) {
      FToastUtil.show('请完成参数填写');
      return;
    }

    final attributes = validGroups
        .map((g) => {
              'name': g.name,
              'values': g.values
                  .where((v) => v.text.isNotEmpty)
                  .map((v) => v.text)
                  .toList(),
            })
        .toList();

    final skuDataResult = <String, Map<String, String>>{};
    for (var entry in skuRows.entries) {
      skuDataResult[entry.key] = {
        'price': entry.value.priceCtrl.text.trim(),
        'stock': entry.value.stockCtrl.text.trim(),
        'limit': entry.value.limitCtrl.text.trim(),
      };
    }

    Get.back(result: {'attributes': attributes, 'skuData': skuDataResult});
    FToastUtil.show('保存成功');
  }

  // ========== 返回 ==========

  void onBackPressed() {
    if (!hasChanges) {
      Get.back();
      return;
    }
    showTipDialog(
      title: '是否保存更改？',
      leftText: '不保存',
      rightText: '保存',
      onLeftTap: () {
        Get.back();
        Get.back();
      },
      onRightTap: () {
        Get.back();
        onComplete();
      },
    );
  }

  @override
  void onClose() {
    for (var g in attributeGroups) {
      g.dispose();
    }
    for (var r in skuRows.values) {
      r.dispose();
    }
    super.onClose();
  }
}
