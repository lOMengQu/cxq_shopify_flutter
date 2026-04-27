import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cxq_merchant_flutter/common/utils/dialog/tip_dialog.dart';
import 'package:cxq_merchant_flutter/common/utils/toast.dart';

class ProductParamsLogic extends GetxController {
  // 参数列表，每项包含 nameController 和 descController
  final params = <Map<String, TextEditingController>>[].obs;

  // 是否有新增/修改内容
  final _hasChanges = false.obs;
  bool get hasChanges => _hasChanges.value;

  // 接收上一页传来的已有参数
  @override
  void onInit() {
    super.onInit();
    final List<Map<String, String>>? existingParams = Get.arguments;
    if (existingParams != null && existingParams.isNotEmpty) {
      for (var item in existingParams) {
        final nameCtrl = TextEditingController(text: item.keys.first);
        final descCtrl = TextEditingController(text: item.values.first);
        _addListeners(nameCtrl, descCtrl);
        params.add({'name': nameCtrl, 'desc': descCtrl});
      }
    }
  }

  void _addListeners(
      TextEditingController nameCtrl, TextEditingController descCtrl) {
    nameCtrl.addListener(() => _hasChanges.value = true);
    descCtrl.addListener(() => _hasChanges.value = true);
  }

  // ========== 新增参数 ==========

  void addParam() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    _addListeners(nameCtrl, descCtrl);
    params.add({'name': nameCtrl, 'desc': descCtrl});
    _hasChanges.value = true;
  }

  // ========== 删除参数 ==========

  void removeParam(int index) {
    if (index >= 0 && index < params.length) {
      params[index]['name']?.dispose();
      params[index]['desc']?.dispose();
      params.removeAt(index);
      _hasChanges.value = true;
    }
  }

  // ========== 完成按钮 ==========

  void onComplete() {
    // 仅保存名称和介绍都填写了的参数
    final validParams = <Map<String, String>>[];
    for (var item in params) {
      final name = item['name']?.text.trim() ?? '';
      final desc = item['desc']?.text.trim() ?? '';
      if (name.isNotEmpty && desc.isNotEmpty) {
        validParams.add({name: desc});
      }
    }
    Get.back(result: validParams);
    FToastUtil.show('保存成功');
  }

  // ========== 返回按钮 ==========

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
        Get.back(); // 关闭弹窗
        Get.back(); // 返回上一页
      },
      onRightTap: () {
        Get.back(); // 关闭弹窗
        onComplete();
      },
    );
  }

  @override
  void onClose() {
    for (var item in params) {
      item['name']?.dispose();
      item['desc']?.dispose();
    }
    super.onClose();
  }
}
