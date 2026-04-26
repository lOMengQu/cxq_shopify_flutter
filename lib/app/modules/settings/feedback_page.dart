import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../common/constants/app_constants.dart';
import '../../../common/utils/permission_util.dart';
import '../../../common/utils/toast.dart';
import 'feedback_history_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _feedbackDescriptionController = TextEditingController();
  final _contactInfoController = TextEditingController();
  int _selectedCategory = 0; // 0 means not selected
  List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;

  final Map<int, String> _categories = {
    1: '账号问题',
    2: '播放问题',
    3: '上传问题',
    4: '审核问题',
    5: '交易问题',
    6: '其他问题'
  };

  @override
  void initState() {
    super.initState();
    _feedbackDescriptionController.addListener(_updateCounter);
    _contactInfoController.addListener(_updateContactCounter);
  }

  @override
  void dispose() {
    _feedbackDescriptionController.removeListener(_updateCounter);
    _feedbackDescriptionController.dispose();
    _contactInfoController.removeListener(_updateContactCounter);
    _contactInfoController.dispose();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    super.dispose();
  }

  void _updateCounter() {
    setState(() {}); // Trigger rebuild to update counter
  }

  void _updateContactCounter() {
    setState(() {});
  }

  Future getImageWithAlbumAndPermission(BuildContext context) async {
    final bool alreadyGranted = await hasPhotoPermission();
    if (!alreadyGranted) {
      showPermissionSnackbarPersistent(
        context: '为便于您上传反馈截图，我们需要申请访问您的相册/存储权限。\n我们仅在您主动选择上传截图时使用该权限，不会收集、存储或上传与反馈无关的任何内容。\n请放心授权。',
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!alreadyGranted) {
      Get.closeCurrentSnackbar();
    }
    if (ps.isAuth) {
      // 已获取到权限
      getImageWithAlbum(context);
    } else if (ps.hasAccess) {
      // 已获取到权限
      // iOS Android 目（哪怕只是有限的访问权限）。前都已经有了部分权限的概念。
      // if (Platform.isIOS) {
      //   await PhotoManager.presentLimited();
      // } else {
      // 已获取到权限（哪怕只是有限的访问权限）。
      // iOS Android 目前都已经有了部分权限的概念。
      getImageWithAlbum(context);
      // }
    } else {
      // 权限受限制（iOS）或者被拒绝，使用 `==` 能够更准确的判断是受限还是拒绝。
      // 你可以使用 `PhotoManager.openSetting()` 打开系统设置页面进行进一步的逻辑定制。
      PhotoManager.openSetting();
    }
  }

  Future getImageWithAlbum(BuildContext context) async {
    // final pickFile = await imagePicker.pickImage(source: ImageSource.gallery);
    var list = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: _selectedImages.length == 0
            ? 3
            : _selectedImages.length == 1
                ? 2
                : _selectedImages.length == 2
                    ? 1
                    : 0,
        requestType: RequestType.image,
        pathNameBuilder: (AssetPathEntity path) => switch (path) {
          final p when p.isAll => '最近图片',
          // 你也可以将类似的逻辑应用在其他常见的相册上。
          final p when p.name.toLowerCase().contains('camera') => '相机',
          final p when p.name.toLowerCase().contains('weixin') => '微信',
          final p when p.name.toLowerCase().contains('qq') => 'QQ',
          final p when p.name.toLowerCase().contains('screenshots') => '截图',
          _ => path.name,
        },
      ),
    );
    if (list != null) {
      EasyLoading.show(status: "上传中...");
      for (var file in list) {
        var currentFile = await file.file;
        // var compressFile = await imageCompressAndGetFile(currentFile!);
        _selectedImages.add(currentFile!);
      }
      EasyLoading.dismiss();
      EasyLoading.showSuccess("上传成功");
      setState(() {});
    }
  }

  // Future<void> _pickImages() async {
  //   try {
  //     final images = await _imagePicker.pickMultiImage(
  //       maxWidth: 1200,
  //       maxHeight: 1200,
  //       imageQuality: 85,
  //     );
  //
  //     if (images != null && images.isNotEmpty) {
  //       setState(() {
  //         final remainingSlots = 3 - _selectedImages.length;
  //         if (remainingSlots > 0) {
  //           _selectedImages.addAll(images.take(remainingSlots));
  //         }
  //         if (images.length > remainingSlots) {
  //           _showToast('最多只能上传3张图片');
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     Get.snackbar('错误', '图片选择失败: ${e.toString()}');
  //   }
  // }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _navigateToFeedbackHistory() {
    Get.to(const FeedbackHistoryPage());
  }

  void _resetForm() {
    _feedbackDescriptionController.clear();
    _contactInfoController.clear();
    setState(() {
      _selectedImages.clear();
      _selectedCategory = 0;
    });
  }

  void _showToast(String message) {
    FToastUtil.show(message);
  }

  void _showShortFeedbackSnackBar() {
    _showToast('请输入至少15字的反馈内容');
  }

  Future<void> _submitFeedback() async {
    final feedbackText = _feedbackDescriptionController.text.trim();
    final contactInfo = _contactInfoController.text.trim();

    if (feedbackText.isEmpty) {
      _showToast('请输入反馈内容');
      return;
    }

    if (contactInfo.isEmpty) {
      _showToast('请输入联系方式');
      return;
    }

    if (contactInfo.length > 50) {
      _showToast('联系方式最多50个字符');
      return;
    }

    if (_selectedCategory == 0) {
      _showToast('请选择反馈类型');
      return;
    }

    if (feedbackText.length < 15) {
      _showShortFeedbackSnackBar();
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final imageFiles =
          _selectedImages.map((xfile) => File(xfile.path)).toList();
      // TODO: 接入反馈提交API
      await Future.delayed(const Duration(milliseconds: 500));

      _showToast('反馈提交成功！');
      _resetForm();
    } catch (e) {
      _showToast('提交失败: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
        title: Text(
          '意见反馈',
          style: TextStyle(color: Colors.black, fontSize: 18.sp),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _navigateToFeedbackHistory,
            child: Text(
              '反馈历史',
              style: TextStyle(color: Colors.black, fontSize: 16.sp),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 问题类型选择
                Text(
                  '问题类型',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                SizedBox(height: 8.h),
                _buildCategoryTags(),
                SizedBox(height: 24.h),

                // 反馈描述
                Text(
                  '反馈描述',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _feedbackDescriptionController,
                  maxLines: 8,
                  inputFormatters: [],
                  decoration: InputDecoration(
                    hintText: '潮星球的每一个进步，都离不开你的意见和建议。',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    counterText:
                        '${_feedbackDescriptionController.text.length}/1000',
                    counterStyle: TextStyle(
                      color: _feedbackDescriptionController.text.length >= 1000
                          ? Colors.grey
                          : Colors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                  onChanged: (value) {
                    bool shouldShowToast = false;

                    // 检查字数限制
                    if (value.length > 1000) {
                      shouldShowToast = true;
                      // 截断超出部分
                      _feedbackDescriptionController.text =
                          value.substring(0, 1000);
                      _feedbackDescriptionController.selection =
                          TextSelection.collapsed(
                        offset: _feedbackDescriptionController.text.length,
                      );
                    }

                    // 显示字数超出提示
                    if (shouldShowToast) {
                      // _showToast('最多可输入1000个字符');
                      FToastUtil.show("最多可输入1000个字符");
                    }

                    _updateCounter();
                  },
                ),

                _buildImageUploadSection(),

                SizedBox(height: 8.h),

                // 联系方式
                Text(
                  '联系方式',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _contactInfoController,
                  maxLines: 4,
                  inputFormatters: [
                    // LengthLimitingTextInputFormatter(50),
                  ],
                  decoration: InputDecoration(
                    hintText: '请输入您的手机/QQ/微信/邮箱',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide:
                          BorderSide(color: primary, width: 1),
                    ),
                    counterText: '${_contactInfoController.text.length}/50',
                    counterStyle: TextStyle(
                      color: _contactInfoController.text.length >= 50
                          ? Colors.grey
                          : Colors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                  onChanged: (value) {
                    bool shouldShowToast = false;
                    // 检查字数限制
                    if (value.length >= 50) {
                      shouldShowToast = true;
                      // 截断超出部分
                      _contactInfoController.text = value.substring(0, 50);
                      _contactInfoController.selection =
                          TextSelection.collapsed(
                        offset: _contactInfoController.text.length,
                      );
                    }
                    // 显示字数超出提示
                    if (shouldShowToast) {
                      // _showToast('联系方式最多50个字符');
                      FToastUtil.show("联系方式最多50个字符");
                    }
                    _updateContactCounter();
                  },
                ),

                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.r),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            '提交反馈',
                            style:
                                TextStyle(fontSize: 16.sp, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSubmitting)
            const ModalBarrier(
              dismissible: false,
              color: Colors.black12,
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTags() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 8.h,
      children: _categories.entries.map((entry) {
        final isSelected = entry.key == _selectedCategory;
        return InputChip(
          label: Text(entry.value, style: TextStyle(fontSize: 14.sp)),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedCategory = entry.key),
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFFF0E6FF),
          labelStyle: TextStyle(
            color: isSelected ? primary : Colors.grey,
            fontSize: 14.sp,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          selectedShadowColor: Colors.transparent,
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            ..._selectedImages.asMap().entries.map((entry) {
              final index = entry.key;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(
                      File(entry.value.path),
                      width: 80.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4.h,
                    right: 4.w,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (_selectedImages.length < 3)
              GestureDetector(
                onTap: () async {
                  await getImageWithAlbumAndPermission(context);
                },
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300, width: 1.w),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.grey, size: 48.sp),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
