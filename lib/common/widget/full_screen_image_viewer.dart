import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../api/service/user_api.dart';
import '../utils/gallery_saver_util.dart';
import '../utils/loading_util.dart';
import '../utils/oss_upload_util.dart';
import '../utils/permission_util.dart';
import '../utils/service/user_service.dart';
import '../utils/toast.dart';

/// 全屏图片查看器，支持缩放、平移等手势操作
class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;
  final String userId;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag, required this.userId,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  bool _isUploading = false;
  var currentAvatar = "".obs;

  /// 选择并上传头像
  Future<void> _pickAndUploadAvatar() async {
    if (_isUploading) return;

    try {
      // 请求相册权限
      final bool alreadyGranted = await hasPhotoPermission();
      if (!alreadyGranted) {
        showPermissionSnackbarPersistent(
          context: '为便于您更换头像，我们需要申请访问您的相册/存储权限。\n我们仅在您主动选择上传头像时使用该权限，不会收集、存储或上传与头像无关的任何内容。\n请放心授权。',
        );
        await Future.delayed(const Duration(milliseconds: 500));
      }
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!alreadyGranted) {
        Get.closeCurrentSnackbar();
      }
      if (!ps.hasAccess) {
        FToastUtil.show("请授予相册访问权限");
        return;
      }

      final context = this.context;
      if (!mounted) return;

      // 打开相册选择单张图片
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          requestType: RequestType.image,
          selectedAssets: const <AssetEntity>[],
          pathNameBuilder: (AssetPathEntity path) =>
          switch (path) {
            final p when p.isAll => '最近图片',
            final p when p.name.toLowerCase().contains('camera') => '相机',
            final p when p.name.toLowerCase().contains('weixin') => '微信',
            final p when p.name.toLowerCase().contains('qq') => 'QQ',
            final p when p.name.toLowerCase().contains('screenshots') => '截图',
            _ => path.name,
          },
        ),
      );

      if (result == null || result.isEmpty) return;

      setState(() {
        _isUploading = true;
      });

      LoadingUtil.show();

      // 获取文件
      final asset = result.first;
      final File? file = await asset.file;
      if (file == null) {
        FToastUtil.show("获取图片失败");
        return;
      }

      // 上传到 OSS
      final timestamp = DateTime
          .now()
          .millisecondsSinceEpoch;
      final String? avatarUrl = await OssUploadUtil.uploadFileWithTimestamp(
        file,
        timestamp,
        'img',
      );

      if (avatarUrl == null) {
        FToastUtil.show("图片上传失败");
        return;
      }

      // 调用接口更新头像
      final response = await postUserEdit(avatar: avatarUrl);
      if (response.ok) {
        currentAvatar.value = avatarUrl;
        UserService.saveAvatar(avatarUrl);
        FToastUtil.show("头像更换成功");
        // 返回并触发刷新
      }
    } catch (e) {
      FToastUtil.show("更换头像失败: $e");
    } finally {
      LoadingUtil.dismiss();
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
  _goBack(){
    if(currentAvatar.value.isEmpty){
      Get.back();
    }else{
      Get.back(result: {'refresh': true});
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _goBack,
          child: Stack(
            children: [
              // 图片查看器
              Center(
                  child: Obx(() {
                    var isEmptyCurrentAvatar = currentAvatar.value.isEmpty;
                    return PhotoView(
                      imageProvider:
                      CachedNetworkImageProvider(isEmptyCurrentAvatar?widget.imageUrl:currentAvatar.value),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      initialScale: PhotoViewComputedScale.contained,
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      loadingBuilder: (context, event) =>
                          Center(
                            child: CircularProgressIndicator(
                              value: event == null
                                  ? 0
                                  : event.cumulativeBytesLoaded /
                                  (event.expectedTotalBytes ?? 1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          ),
                      errorBuilder: (context, error, stackTrace) =>
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.white54,
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  '图片加载失败',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    );
                  })

              ),
              // 关闭按钮
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: _goBack,
                  ),
                ),
              ),
              Positioned(
                  bottom: 60.h,
                  left: 55.w,
                  right: 55.w,
                  child: Column(
                    children: [
                      if(UserService.isCurrentUser(widget.userId))
                        GestureDetector(
                          onTap: _pickAndUploadAvatar,
                          child: Container(
                            width: double.infinity,
                            height: 40.h,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.15),
                                borderRadius: BorderRadius.circular(60.r)),
                            child: Center(
                              child: Text(
                                "更换头像",
                                style:
                                TextStyle(fontSize: 16.sp, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 16.h,),
                      GestureDetector(
                        onTap: () async {
                          await GallerySaverUtil.saveNetworkImageToGallery(
                              widget.imageUrl);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 40.h,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.15),
                              borderRadius: BorderRadius.circular(60.r)),
                          child: Center(
                            child: Text(
                              "保存头像",
                              style:
                              TextStyle(fontSize: 16.sp, color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
