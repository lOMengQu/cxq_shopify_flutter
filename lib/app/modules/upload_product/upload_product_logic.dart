import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:cxq_merchant_flutter/api/service/goods_api.dart';
import 'package:cxq_merchant_flutter/common/utils/dialog/tip_dialog.dart';
import 'package:cxq_merchant_flutter/common/utils/toast.dart';

class UploadProductLogic extends GetxController {
  // ========== 商品图片（最多9张） ==========
  final productImages = <File>[].obs;
  final productImageUrls = <String>[].obs;
  static const int maxProductImages = 9;

  // ========== 商品基本信息 ==========
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();

  final productName = ''.obs;
  final productDesc = ''.obs;
  final productPrice = ''.obs;

  // ========== 商品参数 ==========
  final productParams = <Map<String, String>>[].obs;
  bool get isParamsFilled => productParams.isNotEmpty;

  // ========== 商品属性 ==========
  final productAttributesData = Rx<Map<String, dynamic>?>(null);
  bool get isAttributesFilled => productAttributesData.value != null;

  // ========== 商品服务 ==========
  final isGuaranteeAuthentic = false.obs; // 保证正品（必填，默认不勾选）
  final returnPolicyType = 0.obs; // 0:未选, 1:七天无理由, 2:不支持

  // ========== 经营类目 ==========
  final spuBcId = ''.obs; // 经营类目ID

  // ========== 运费模板 ==========
  final shippingTemplates = <String>['全国包邮'].obs;
  final selectedShippingTemplate = '全国包邮'.obs;
  final isShippingDropdownOpen = false.obs;
  final freightModelId = ''.obs; // 运费模板ID

  // ========== 商品详情图（最多20张） ==========
  final detailImages = <File>[].obs;
  final detailImageUrls = <String>[].obs;
  static const int maxDetailImages = 20;

  // ========== 加载状态 ==========
  final isSubmitting = false.obs;
  final isUploading = false.obs;

  // ========== 标记是否有改动 ==========
  final _hasChanges = false.obs;
  bool get hasChanges => _hasChanges.value;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(() {
      productName.value = nameController.text;
      _hasChanges.value = true;
    });
    descController.addListener(() {
      productDesc.value = descController.text;
      _hasChanges.value = true;
    });
    priceController.addListener(() {
      productPrice.value = priceController.text;
      _hasChanges.value = true;
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    super.onClose();
  }

  // ========== 相册路径中文化 ==========

  String _chinesePathName(AssetPathEntity path) => switch (path) {
        final p when p.isAll => '最近图片',
        final p when p.name.toLowerCase().contains('camera') => '相机',
        final p when p.name.toLowerCase().contains('weixin') => '微信',
        final p when p.name.toLowerCase().contains('qq') => 'QQ',
        final p when p.name.toLowerCase().contains('screenshots') => '截图',
        final p when p.name.toLowerCase().contains('download') => '下载',
        _ => path.name,
      };

  // ========== 商品图片操作 ==========

  Future<void> pickProductImages(BuildContext context) async {
    final remaining = maxProductImages - productImages.length;
    if (remaining <= 0) {
      FToastUtil.show('最多上传$maxProductImages张图片');
      return;
    }

    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: remaining,
        requestType: RequestType.image,
        pathNameBuilder: _chinesePathName,
      ),
    );

    if (result != null && result.isNotEmpty) {
      for (var asset in result) {
        final file = await asset.file;
        if (file != null) {
          // 校验图片大小 <= 3MB
          final fileSize = await file.length();
          if (fileSize > 3 * 1024 * 1024) {
            FToastUtil.show('图片大小不能超过3MB');
            continue;
          }
          productImages.add(file);
        }
      }
      _hasChanges.value = true;
    }
  }

  void removeProductImage(int index) {
    if (index >= 0 && index < productImages.length) {
      productImages.removeAt(index);
      if (index < productImageUrls.length) {
        productImageUrls.removeAt(index);
      }
      _hasChanges.value = true;
    }
  }

  void reorderProductImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = productImages.removeAt(oldIndex);
    productImages.insert(newIndex, item);
    if (oldIndex < productImageUrls.length && newIndex < productImageUrls.length) {
      final url = productImageUrls.removeAt(oldIndex);
      productImageUrls.insert(newIndex, url);
    }
    _hasChanges.value = true;
  }

  // ========== 商品详情图操作 ==========

  Future<void> pickDetailImages(BuildContext context) async {
    final remaining = maxDetailImages - detailImages.length;
    if (remaining <= 0) {
      FToastUtil.show('最多上传$maxDetailImages张图片');
      return;
    }

    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: remaining,
        requestType: RequestType.image,
        pathNameBuilder: _chinesePathName,
      ),
    );

    if (result != null && result.isNotEmpty) {
      for (var asset in result) {
        final file = await asset.file;
        if (file != null) {
          final fileSize = await file.length();
          if (fileSize > 3 * 1024 * 1024) {
            FToastUtil.show('图片大小不能超过3MB');
            continue;
          }
          detailImages.add(file);
        }
      }
      _hasChanges.value = true;
    }
  }

  void removeDetailImage(int index) {
    if (index >= 0 && index < detailImages.length) {
      detailImages.removeAt(index);
      if (index < detailImageUrls.length) {
        detailImageUrls.removeAt(index);
      }
      _hasChanges.value = true;
    }
  }

  void reorderDetailImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = detailImages.removeAt(oldIndex);
    detailImages.insert(newIndex, item);
    if (oldIndex < detailImageUrls.length && newIndex < detailImageUrls.length) {
      final url = detailImageUrls.removeAt(oldIndex);
      detailImageUrls.insert(newIndex, url);
    }
    _hasChanges.value = true;
  }

  // ========== 商品服务 ==========

  void toggleReturnPolicy(int type) {
    if (returnPolicyType.value == type) {
      returnPolicyType.value = 0;
    } else {
      returnPolicyType.value = type;
    }
    _hasChanges.value = true;
  }

  // ========== 运费模板 ==========

  void selectShippingTemplate(String template) {
    selectedShippingTemplate.value = template;
    isShippingDropdownOpen.value = false;
    _hasChanges.value = true;
  }

  void toggleShippingDropdown() {
    isShippingDropdownOpen.value = !isShippingDropdownOpen.value;
  }

  // ========== 吊牌价格式化 ==========

  void formatPrice() {
    final text = priceController.text.trim();
    if (text.isEmpty) return;

    final value = double.tryParse(text);
    if (value == null) {
      FToastUtil.show('仅能输入数字');
      priceController.clear();
      return;
    }
    priceController.text = value.toStringAsFixed(2);
    priceController.selection = TextSelection.fromPosition(
      TextPosition(offset: priceController.text.length),
    );
  }

  // ========== 返回按钮逻辑 ==========

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
        onSaveDraft();
        Get.back();
      },
    );
  }

  // ========== 暂存 ==========

  void onSaveDraft() {
    // TODO: 调用保存草稿接口
    FToastUtil.show('保存成功');
  }

  // ========== 预览 ==========

  void onPreview() {
    // TODO: 跳转商品详情预览页
    FToastUtil.show('预览功能开发中');
  }

  // ========== 必填项校验 ==========

  String? _checkRequiredFields() {
    if (productImages.isEmpty) return '上传商品图片';
    if (productName.value.trim().isEmpty) return '商品名称';
    if (!isAttributesFilled) return '商品属性';
    if (!isGuaranteeAuthentic.value) return '保证正品';
    return null;
  }

  bool get isAllRequiredFilled => _checkRequiredFields() == null;

  // ========== 提交审核 ==========

  void onSubmitReview() {
    final missingField = _checkRequiredFields();
    if (missingField != null) {
      FToastUtil.show('还未填写$missingField');
      return;
    }

    showTipDialog(
      title: '确认提交？',
      leftText: '取消',
      rightText: '确认',
      onLeftTap: () => Get.back(),
      onRightTap: () {
        Get.back();
        _doSubmit();
      },
    );
  }

  Future<void> _doSubmit() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    try {
      // 1. 组装主图列表
      final imageList = productImageUrls
          .map((url) => {"image": url, "width": 0, "height": 0})
          .toList();

      // 2. 组装详情图列表
      final detailImageList = detailImageUrls
          .map((url) => {"image": url, "width": 0, "height": 0})
          .toList();

      // 3. 组装商品参数
      final parameterList = productParams
          .map((p) => {"name": p['name'], "description": p['value']})
          .toList();

      // 4. 组装商品服务
      final spuServer = <int>[];
      if (isGuaranteeAuthentic.value) spuServer.add(1);
      if (returnPolicyType.value == 1) {
        spuServer.add(4); // 7天无理由退换
      } else if (returnPolicyType.value == 2) {
        spuServer.add(5); // 不支持7天无理由退换
      }

      // 5. 组装 SKU 属性数据
      final skuAttributeDto = _buildSkuAttributeDto();

      // 6. 组装 spuData
      final spuData = <String, dynamic>{
        "name": productName.value.trim(),
        "description": productDesc.value.trim(),
        "spuBcId": spuBcId.value,
        "freightModelId": freightModelId.value,
        "showPrice": productPrice.value.trim(),
        "spuServer": spuServer,
        "imageList": imageList,
        "detailImageList": detailImageList,
        "parameterList": parameterList,
        "skuAttributeDto": skuAttributeDto,
      };

      final response = await postSpuAddUpdate(spuData: spuData);
      if (response.ok) {
        FToastUtil.show('已提交审核');
        Get.back();
      } else {
        FToastUtil.show(response.message ?? '提交失败，请重试');
      }
    } catch (e) {
      FToastUtil.show('提交失败，请重试');
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 组装 skuAttributeDto 结构
  Map<String, dynamic> _buildSkuAttributeDto() {
    final attrData = productAttributesData.value;
    if (attrData == null) return {};

    final attributes = attrData['attributes'] as List? ?? [];
    final skuList = attrData['skuList'] as List? ?? [];
    final skuImages = attrData['skuImages'] as Map? ?? {};

    // 最多三组属性，分别对应 getFirstAttribute / getSecondAttribute / getThirdAttribute
    final attrKeys = ['getFirstAttribute', 'getSecondAttribute', 'getThirdAttribute'];
    final result = <String, dynamic>{};

    for (int i = 0; i < attrKeys.length; i++) {
      if (i < attributes.length) {
        final group = attributes[i] as Map<String, dynamic>;
        final name = group['name'] as String? ?? '';
        final values = group['values'] as List? ?? [];
        result[attrKeys[i]] = values
            .map((v) => {"name": name, "value": v.toString()})
            .toList();
      } else {
        result[attrKeys[i]] = [];
      }
    }

    // 组装 skuDtoList
    final skuDtoList = <Map<String, dynamic>>[];
    for (final sku in skuList) {
      final skuMap = sku as Map<String, dynamic>;
      final key = skuMap['key'] as String? ?? '';
      // 取第一属性值作为图片key
      final firstVal = key.split('-').isNotEmpty ? key.split('-').first : '';
      final imageUrl = skuImages[firstVal] ?? '';

      skuDtoList.add({
        "price": skuMap['price'] ?? '0.00',
        "stockCount": int.tryParse(skuMap['stock']?.toString() ?? '0') ?? 0,
        "limitCount": int.tryParse(skuMap['limit']?.toString() ?? '0') ?? 0,
        "image": imageUrl,
      });
    }
    result['skuDtoList'] = skuDtoList;

    return result;
  }
}
