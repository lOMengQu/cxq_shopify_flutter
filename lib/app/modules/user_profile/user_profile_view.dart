import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


import '../../../api/z_entity/user/user_homepage_entity.dart';
import '../../../common/constants/app_constants.dart';
import '../../../common/utils/app_image_cache_manager.dart';
import '../../../common/utils/dialog/more_menu_dialog.dart';
import '../../../common/utils/dialog/status_dialog.dart';
import '../../../common/utils/dialog/tip_dialog.dart';
import '../../../common/utils/service/user_service.dart';

import '../../../common/widget/full_screen_image_viewer.dart';
import '../../../common/widget/smart_refresher/smart_footer_components.dart';
import '../../../common/widget/smart_refresher/smart_header_components.dart';
import '../../routes/app_pages.dart';
import '../settings/settings_page.dart';
import 'user_profile_logic.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late UserProfileLogic controller;
  final PageController _pageController = PageController();
  final GlobalKey _moreButtonKey = GlobalKey();
  final GlobalKey _headerMoreButtonKey = GlobalKey();

  Worker? _openStatusWorker;
  bool _hasOpenedStatusDialog = false;
  int _brandTabIndex = 0;
  final List<Map<String, String>> _brandGoodsMockList = const [
    {'productId': 'commodity_demo_001', 'title': '十三余 气质华丽国风长款', 'price': '759'},
    {'productId': 'commodity_demo_002', 'title': '十三余 牛仔马甲条纹长袖', 'price': '779'},
    {'productId': 'commodity_demo_003', 'title': '十三余 新中式刺绣连衣裙', 'price': '699'},
    {'productId': 'commodity_demo_001', 'title': '十三余 复古拼接半身长裙', 'price': '829'},
    {'productId': 'commodity_demo_002', 'title': '十三余 国风小香风上衣', 'price': '599'},
    {'productId': 'commodity_demo_003', 'title': '十三余 提花宽松阔腿长裤', 'price': '639'},
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<UserProfileLogic>();

    final args = Get.arguments;
    final shouldOpen = args is Map && args['openStatusDialog'] == true;
    if (shouldOpen) {
      _openStatusWorker = ever<UserBaseInfo?>(controller.userInfo, (userInfo) {
        if (_hasOpenedStatusDialog) return;
        if (userInfo == null) return;
        if (!controller.isCurrentUser) return;
        _hasOpenedStatusDialog = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showStatusDialog(
            initialStatus: userInfo.description,
            onConfirm: (description) {
              controller.setUserStatus(description);
            },
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _openStatusWorker?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SmartRefresher(
            controller: controller.refreshController,
            enablePullDown: true,
            enablePullUp: false,
            header: SmartHeaderComponents(),
            footer: SmartFooterComponents(),
            onRefresh: controller.onRefresh,
            child: CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                // 用户信息头部
                SliverToBoxAdapter(
                  child: _buildUserHeader(context),
                ),
                SliverToBoxAdapter(
                  child: Obx(() {
                    final userInfo = controller.userInfo.value;
                    return Wrap(
                      children: [
                        // 个人简介
                        if ((userInfo?.description ?? '').isNotEmpty)
                          GestureDetector(
                            onTap: controller.isCurrentUser
                                ? () {
                              showStatusDialog(
                                initialStatus: userInfo!.description,
                                onConfirm: (description) {
                                  controller.setUserStatus(description);
                                },
                              );
                            }
                                : null,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 12.h),
                              child: Text(
                                userInfo!.description!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: textSecondary,
                                  height: 1.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        else if (controller.isCurrentUser)
                          GestureDetector(
                            onTap: () {
                              showStatusDialog(
                                onConfirm: (description) {
                                  controller.setUserStatus(description);
                                },
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.all(16.w),
                              width: 58.w,
                              height: 25.h,
                              decoration: BoxDecoration(
                                color: Color(0XFFF6F8FA),
                                borderRadius: BorderRadius.circular(60.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/user/add_state.png",
                                    width: 10.w,
                                    height: 10.w,
                                  ),
                                  Text(
                                    "状态",
                                    style: TextStyle(
                                        fontSize: 12.sp, color: textAssist),
                                  )
                                ],
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 12.h,
                          )
                      ],
                    );
                  }),
                ),
                // 圈子区域
                SliverToBoxAdapter(
                  child: _buildGambitSection(),
                ),
                SliverToBoxAdapter(
                  child: controller.isBrand.value
                      ? _buildBrandTabBar()
                      : _buildDynamicTitle(),
                ),
                controller.isBrand.value
                    ? (_brandTabIndex == 0
                    ? _buildDynamicListSliver()
                    : _buildBrandGoodsSliver())
                    : _buildDynamicListSliver()
              ],
            ),
          ),
          // 顶部栏（滚动时显示）
          Obx(() => _buildTopBar(context)),
        ],
      ),
    );
  }

  /// 构建顶部栏
  Widget _buildTopBar(BuildContext context) {
    final showTopBar = controller.showTopBar.value;
    final nickname = controller.userInfo.value?.nickname ?? '';

    return IgnorePointer(
      ignoring: !showTopBar,
      child: AnimatedOpacity(
        opacity: showTopBar ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: showTopBar
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: Offset(0, 2.h),
                blurRadius: 4.r,
              ),
            ]
                : null,
          ),
          child: SizedBox(
            height: 44.h,
            child: Row(
              children: [
                if (Navigator.canPop(context))
                  SizedBox(
                    width: 44.w,
                    height: 44.w,
                    child: Image.asset("assets/user/left_black.png"),
                  ),
                Expanded(
                  child: Center(
                    child: Text(
                      nickname,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 44.w, height: 44.h),
                SizedBox(width: 12.w),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context, GlobalKey buttonKey) {
    showMoreMenuDialog(
      context: context,
      buttonKey: buttonKey,
      menuItems: [
        buildMenuItem(
          text: '编辑资料',
          onTap: () {
            Get.back();
            _navigateToEditProfile(controller.userInfo.value);
          },
        ),
        buildMenuDivider(),
        buildMenuItem(
          text: '收货地址',
          onTap: () {
            Get.back();
            // Get.toNamed(Routes.addressList);
          },
        ),
        buildMenuDivider(),
        buildMenuItem(
          text: '设置',
          onTap: () {
            Get.back();
            Get.to(() => const SettingsPage());
          },
        ),
        buildMenuDivider(),
        buildMenuItem(
          text: '退出登录',
          onTap: () async {
            Get.back();
            await UserService.clearAll();
            Get.offAllNamed(Routes.login);
          },
        ),
      ],
    );
  }

  /// 构建用户信息头部
  Widget _buildUserHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Obx(() {
      final userInfo = controller.userInfo.value;
      final background = userInfo?.photoWall;
      final hasBackground = background != null && background.isNotEmpty;

      return AnimatedBuilder(
        animation: controller.bgExpandAnimation,
        builder: (context, child) {
          final animValue = controller.bgExpandAnimation.value;
          final isExpanded = animValue > 0;
          final increaseHeight = 300.h;
          // 外层容器高度: 310 -> 420
          final containerHeight = 360.h + increaseHeight * animValue;
          // 背景图高度: 230 -> 340
          final bgHeight = 280.h + increaseHeight * animValue;

          return GestureDetector(
            onTap: isExpanded ? controller.collapseBg : null,
            onVerticalDragEnd: isExpanded
                ? (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity!.abs() > 50) {
                controller.collapseBg();
              }
            }
                : null,
            child: Container(
              width: double.infinity,
              height: containerHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 背景图或默认渐变
                  GestureDetector(
                    onTap: isExpanded ? null : controller.toggleBgExpand,
                    child: Stack(
                      children: [
                        // 背景图（微信朋友圈效果）
                        if (hasBackground)
                          _buildWeChatStyleBackground(
                            imageUrls: background,
                            height: bgHeight,
                            isExpanded: isExpanded,
                          )
                        else
                          _buildDefaultBackground(bgHeight),
                      ],
                    ),
                  ),
                  // 返回按钮（展开时向上移出，底部导航栏直接加载时不显示）
                  if (Navigator.canPop(context))
                    Positioned(
                      top: statusBarHeight -
                          (44.h + statusBarHeight) * animValue,
                      left: 0,
                      child: Opacity(
                        opacity: 1 - animValue,
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Image.asset(
                            backIcon,
                            width: 44.w,
                            height: 44.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // 右下角换封面按钮（展开时显示，仅自己主页）
                  if (controller.isCurrentUser && isExpanded)
                    Positioned(
                      right: 16.w,
                      top: bgHeight - 110.h,
                      child: Opacity(
                        opacity: animValue,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent, // 关键：透明区域也能点到
                          onTap: () async {
                            // final result = await Get.toNamed(
                            //   Routes.photoWall,
                            //   arguments: {
                            //     "photoWallList":
                            //     controller.userInfo.value?.photoWall ?? []
                            //   },
                            // );
                            //
                            // // 如果返回了刷新标志，刷新用户信息
                            // if (result != null && result['refresh'] == true) {
                            //   controller.onRefresh();
                            // }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(12.w), // 这里调大/调小点击范围
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  color: Colors.white,
                                  size: 20.w,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '添加图片',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // 右上角更多按钮（仅未显示顶部栏时展示）
                  // if (controller.isCurrentUser)
                  Positioned(
                    top: statusBarHeight,
                    right: 0,
                    child: GestureDetector(
                      key: _headerMoreButtonKey,
                      behavior: HitTestBehavior.translucent,
                      onTap: () =>
                          _showMoreMenu(context, _headerMoreButtonKey),
                      child: SizedBox(
                        width: 44.w,
                        height: 44.h,
                        child: Center(
                          child: SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: Image.asset(
                              'assets/user/icon_mine_more.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0.h),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.r),
                              topRight: Radius.circular(16.r))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 头像和统计数据行
                          Row(
                            children: [
                              // 头像
                              Transform.translate(
                                  offset: Offset(0, -24.h),
                                  child: _buildAvatar(userInfo, context)),
                              Spacer(),
                              // 统计数据
                              Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // Get.toNamed(Routes.partner, arguments: {
                                        //   'userId': controller.userId
                                        // });
                                      },
                                      child: _buildStatItem(
                                        count: userInfo?.followNumMutual ?? 0,
                                        label: '伙伴',
                                      ),
                                    ),
                                    SizedBox(width: 40.w),
                                    Container(
                                      height: 35.h,
                                      width: 1.w,
                                      color: dividerColor2.withOpacity(.8),
                                    ),
                                    SizedBox(width: 40.w),
                                    _buildStatItem(
                                      count: userInfo?.totalLikeNum ?? 0,
                                      label: '+1',
                                    ),
                                    SizedBox(width: 40.w),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // 昵称、地区和按钮行
                          Row(
                            children: [
                              // 昵称（当前用户可点击进入编辑页面）
                              GestureDetector(
                                onTap: controller.isCurrentUser
                                    ? () => _navigateToEditProfile(userInfo)
                                    : null,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      userInfo?.nickname ?? '',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                    SizedBox(width: 10.w,)
                                    ,
                                    Obx(() {
                                      var isBrand = controller.isBrand.value;
                                      return isBrand?
                                      Container(
                                        width: 28.w,
                                        height: 16.h,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(2.r),
                                            border: BoxBorder.all(color: Color(0XFFFFD263),width: 1.w)
                                        ),
                                        alignment: Alignment.center,
                                        child: Text("品牌",style: TextStyle(fontSize: 10.sp,color: Color(0XFFFFD263)),),
                                      )
                                          :Container();
                                    })
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (!controller.isCurrentUser) ...[
                                // 去聊天按钮
                                GestureDetector(
                                    onTap: () {
                                      // Get.toNamed(Routes.chart, arguments: {
                                      //   "peerUserId": controller.userId,
                                      //   "peerAvatar": userInfo?.avatar,
                                      //   "peerNickname": userInfo?.nickname,
                                      //   "conversationId":
                                      //   userInfo?.conversationId ?? "",
                                      // });
                                    },
                                    child: _buildActionButton('去聊天',
                                        isPrimary: false)),
                                SizedBox(width: 10.w),
                                // 结伴按钮
                                GestureDetector(
                                    onTap: () async {
                                      if (userInfo!.isFollow == true) {
                                        showTipDialog(
                                            title: '确认取消结伴',
                                            leftText: '取消',
                                            rightText: '确认',
                                            onLeftTap: () {
                                              Get.back();
                                            },
                                            onRightTap: () async {
                                              // await FollowService.unfollowUser(
                                              //   userId: userInfo!.userId!,
                                              //   onSuccess: () async {
                                              //     await controller
                                              //         .loadUserInfo();
                                              //     // 通知聊天页面重置消息发送限制
                                              //     if (Get.isRegistered<
                                              //         ChartLogic>(
                                              //         tag: userInfo!.userId!)) {
                                              //       Get.find<ChartLogic>(
                                              //           tag: userInfo!
                                              //               .userId!)
                                              //           .onPartnershipCanceled();
                                              //     }
                                              //     Get.back();
                                              //     showOkToast("取消成功");
                                              //   },
                                              // );
                                            });
                                      } else {
                                        // FollowService.showFollowConfirmDialog(
                                        //   userId: userInfo!.userId!,
                                        //   conversationId:
                                        //   userInfo.conversationId ?? '',
                                        //   onSuccess: () async {
                                        //     showOkToast("发送成功");
                                        //     await controller.loadUserInfo();
                                        //   },
                                        // );
                                      }
                                    },
                                    child: _buildActionButton(
                                        (userInfo?.isFollow == true)
                                            ? "取消结伴"
                                            : '结伴',
                                        isPrimary:
                                        (userInfo?.isFollow == true))),
                              ]
                            ],
                          ),
                          // 地区
                          SizedBox(
                            height: 12.h,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (controller.isCurrentUser)
                                _navigateToEditProfile(userInfo);
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14.w,
                                  color: textAssist,
                                ),
                                Text(
                                  (userInfo?.address ?? '').isEmpty
                                      ? "未定位"
                                      : _extractCity(userInfo!.address!),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: textAssist,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  /// 操作按钮
  Widget _buildActionButton(String text, {bool isPrimary = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isPrimary ? Color(0XFFF0F4F8) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: isPrimary
            ? null
            : Border.all(
          color: primary,
          width: 1.w,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: isPrimary ? textAssist : primary,
        ),
      ),
    );
  }

  /// 微信朋友圈风格背景
  /// 固定高度：收起 230.h，展开 530.h
  /// 收起无模糊，展开显示模糊边缘过渡
  Widget _buildWeChatStyleBackground({
    required List<String> imageUrls,
    required double height,
    required bool isExpanded,
  }) {
    // 固定高度
    final collapsedHeight = 280.h;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = imageUrls[index];
          return FutureBuilder<Size>(
            future: _getImageSize(imageUrl),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: height,
                  fit: BoxFit.cover,
                  cacheManager: AppImageCacheManager.instance,
                );
              }

              final imageSize = snapshot.data!;
              final isLandscape = imageSize.width > imageSize.height;

              // 清晰图 widget
              Widget buildClearImage({double? imageHeight}) {
                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: imageHeight ?? collapsedHeight,
                  fit: BoxFit.cover,
                  cacheManager: AppImageCacheManager.instance,
                );
              }

              // 模糊图 widget
              Widget buildBlurredImage(
                  {double? imageHeight, double sigma = 50}) {
                return ClipRect(
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(
                      sigmaX: sigma,
                      sigmaY: sigma,
                      tileMode: TileMode.clamp,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: imageHeight ?? height,
                      fit: BoxFit.cover,
                      cacheManager: AppImageCacheManager.instance,
                    ),
                  ),
                );
              }

              // 清晰图边缘透明的 ShaderMask（露出底层模糊）
              Widget buildClearImageWithFade({
                required double imageHeight,
                required double fadePx,
              }) {
                return ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (Rect rect) {
                    return ui.Gradient.linear(
                      Offset(rect.width / 2, 0),
                      Offset(rect.width / 2, rect.height),
                      [
                        Colors.white.withAlpha(0), // 顶部透明（露出模糊）
                        Colors.white, // 渐变到不透明（显示清晰）
                        Colors.white, // 中间不透明（显示清晰）
                        Colors.white.withAlpha(0), // 底部透明（露出模糊）
                      ],
                      [
                        0.0,
                        fadePx / rect.height,
                        1.0 - fadePx / rect.height,
                        1.0,
                      ],
                    );
                  },
                  child: buildClearImage(imageHeight: imageHeight),
                );
              }

              // 竖屏专用：截取上下边缘模糊区域
              Widget buildEdgeBlurForPortrait({
                required double totalHeight,
                required double edgeHeight,
              }) {
                return Stack(
                  children: [
                    // 顶部边缘模糊
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: edgeHeight,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: buildBlurredImage(
                            imageHeight: totalHeight,
                            sigma: 50,
                          ),
                        ),
                      ),
                    ),
                    // 底部边缘模糊
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: edgeHeight,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: buildBlurredImage(
                            imageHeight: totalHeight,
                            sigma: 50,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (isLandscape) {
                // 横屏图片：底层模糊填充 + 清晰图固定在中心
                return Stack(
                  children: [
                    // 底层：模糊图铺满整个高度
                    if (isExpanded)
                      Positioned.fill(
                        child:
                        buildBlurredImage(imageHeight: height, sigma: 50),
                      ),

                    // 清晰图：固定在中心，高度始终是 collapsedHeight
                    Positioned(
                      top: (height - collapsedHeight) / 2,
                      left: 0,
                      right: 0,
                      height: collapsedHeight,
                      child: isExpanded
                          ? buildClearImageWithFade(
                        imageHeight: collapsedHeight,
                        fadePx: 80.0,
                      )
                          : buildClearImage(imageHeight: collapsedHeight),
                    ),
                  ],
                );
              } else {
                // 竖屏图片：底层上下边缘模糊（各50高度） + 中间清晰图
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // 底层：展开时显示上下边缘模糊
                    if (isExpanded)
                      buildEdgeBlurForPortrait(
                        totalHeight: height,
                        edgeHeight: 130.h,
                      ),

                    // 上层：清晰图，展开时边缘透明渐变
                    isExpanded
                        ? buildClearImageWithFade(
                      imageHeight: height,
                      fadePx: 130.h,
                    )
                        : buildClearImage(imageHeight: height),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }

  /// 获取网络图片尺寸
  Future<Size> _getImageSize(String imageUrl) async {
    final completer = Completer<Size>();
    final imageProvider = CachedNetworkImageProvider(
      imageUrl,
      cacheManager: AppImageCacheManager.instance,
    );
    imageProvider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
            (ImageInfo info, bool _) {
          completer.complete(Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          ));
        },
        onError: (exception, stackTrace) {
          completer.complete(const Size(1, 1));
        },
      ),
    );
    return completer.future;
  }

  /// 默认背景
  Widget _buildDefaultBackground(double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(color: Color(0XFF333333)),
      child: controller.isCurrentUser
          ? Center(
        child: Text(
          "还未添加图片",
          style: TextStyle(fontSize: 12.sp, color: Colors.white),
        ),
      )
          : null,
    );
  }

  /// 构建头像
  Widget _buildAvatar(UserBaseInfo? userInfo, BuildContext context) {
    final avatar = userInfo?.avatar ?? '';
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FullScreenImageViewer(
              imageUrl: avatar,
              userId: controller.userId,
            ),
          ),
        );
        if (result != null && result['refresh'] == true) {
          await controller.loadUserInfo();
        }
      },
      child: Container(
        width: 76.w,
        height: 76.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.r,
            ),
          ],
        ),
        child: ClipOval(
          child: avatar.isNotEmpty
              ? CachedNetworkImage(
            imageUrl: avatar,
            width: 70.w,
            height: 70.w,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => _buildDefaultAvatar(),
          )
              : _buildDefaultAvatar(),
        ),
      ),
    );
  }

  /// 默认头像
  Widget _buildDefaultAvatar() {
    return Container(
      width: 70.w,
      height: 70.w,
      color: const Color(0xFFF5F5F5),
      child: Icon(
        Icons.person,
        size: 40.w,
        color: textAssist,
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem({required int count, required String label}) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  /// 构建圈子区域
  Widget _buildGambitSection() {
    return Column(
      children: [
        Obx(() {
          final gambitList = controller.gambitList;
          final isExpanded = controller.isGambitExpanded.value;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                GestureDetector(
                  onTap: () {
                    if (controller.isCurrentUser) {
                      // Get.toNamed(Routes.joinedCircles);
                    }
                  },
                  child: Row(
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '圈子',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: '（${gambitList.length}）',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      if (controller.isCurrentUser)
                        Image.asset(
                          "assets/user/right.png",
                          width: 22.w,
                          height: 22.w,
                        )
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                // 圈子列表或缺省文案
                if (gambitList.isEmpty)
                  _buildEmptyGambit()
                else
                  _buildGambitList(gambitList, isExpanded),
              ],
            ),
          );
        }),
        SizedBox(
          height: 16.h,
        ),
        Container(
          width: double.infinity,
          height: 8.h,
          color: background,
        )
      ],
    );
  }

  /// 空圈子缺省状态
  Widget _buildEmptyGambit() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Text(
          '还未加入任何圈子',
          style: TextStyle(
            fontSize: 12.sp,
            color: textAssist,
          ),
        ),
      ),
    );
  }

  /// 圈子列表
  Widget _buildGambitList(List<UserGambitItem> gambitList, bool isExpanded) {
    // 默认显示 3 个，展开显示全部
    final displayList = isExpanded ? gambitList : gambitList.take(3).toList();
    final showExpandButton = gambitList.length > 3;
    final divideShow = gambitList.length <= 3;

    return Column(
      children: [
        ...displayList.asMap().entries.map((entry) => _buildGambitCard(
          entry.value,
          !(divideShow && entry.key == displayList.length - 1),
        )),
        if (showExpandButton) ...[
          // SizedBox(height: 8.h),
          // Divider(height: 1.h, color: dividerColor),
          // SizedBox(height: 12.h),
          GestureDetector(
            onTap: controller.toggleGambitExpand,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isExpanded ? '收起' : '展开更多',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: primary,
                  ),
                ),
                SizedBox(width: 4.w),
                Image.asset(
                  isExpanded ? "assets/user/up.png" : "assets/user/down.png",
                  color: primary,
                  width: 14.w,
                  height: 14.w,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 圈子卡片
  Widget _buildGambitCard(UserGambitItem item, bool divideShow) {
    // type == 0 表示用户创建的圈子
    final isCreator = item.type == 0;

    return GestureDetector(
      onTap: () {
        final id = item.gambitId;
        if (id != null && id.isNotEmpty) {
          // Get.toNamed(Routes.circleDetails, arguments: {'gambitId': id});
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 圈子名称行
          Row(
            children: [
              // 圈子名称标签
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(60.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/life/star_ball.png',
                      width: 18.w,
                      height: 18.w,
                    ),
                    SizedBox(width: 6.w),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 180.w),
                      child: Text(
                        item.name ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 16.w,
              ),
              // Ta的发起标签
              if (isCreator)
                Container(
                  width: 58.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                      color: Color(0XFFF0F4F8),
                      borderRadius: BorderRadius.circular(60.r)),
                  alignment: Alignment.center,
                  child: Text(
                    controller.isCurrentUser ? "我的发起" : 'Ta的发起',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: textAssist,
                    ),
                  ),
                ),
            ],
          ),
          // 圈子描述
          if ((item.describe ?? '').isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              item.describe!,
              style: TextStyle(
                fontSize: 14.sp,
                color: textSecondary,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (divideShow)
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              height: 1.h,
              color: dividerColor,
            )
        ],
      ),
    );
  }

  Widget _buildBrandTabBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _brandTabIndex = 0;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '动态',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight:
                      _brandTabIndex == 0 ? FontWeight.w600 : FontWeight.w400,
                      color: _brandTabIndex == 0 ? primary : textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28.w,
                    height: 2.h,
                    decoration: BoxDecoration(
                      color:
                      _brandTabIndex == 0 ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _brandTabIndex = 1;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '好物',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight:
                      _brandTabIndex == 1 ? FontWeight.w600 : FontWeight.w400,
                      color: _brandTabIndex == 1 ? primary : textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28.w,
                    height: 2.h,
                    decoration: BoxDecoration(
                      color:
                      _brandTabIndex == 1 ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicListSliver() {
    return Obx(() {
      // if (controller.ugcList.isEmpty) {
        return SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(
                height: 50.h,
              ),
              Text(
                '还未发布动态',
                style: TextStyle(fontSize: 12.sp, color: textAssist),
              )
            ],
          ),
        );

    });
  }

  Widget _buildBrandGoodsSliver() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            return _buildBrandGoodsCard(_brandGoodsMockList[index], index);
          },
          childCount: _brandGoodsMockList.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 0.56,
        ),
      ),
    );
  }

  Widget _buildBrandGoodsCard(Map<String, String> item, int index) {
    final bgColors = [
      const Color(0xFFF7F1E9),
      const Color(0xFFEAF3F0),
    ];
    final iconColors = [
      const Color(0xFFD4B07B),
      const Color(0xFF3C6E67),
    ];
    return GestureDetector(
      onTap: () {
        final productId = item['productId'] ?? 'commodity_demo_001';
        // Get.toNamed(Routes.commodityDetails, arguments: productId);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgColors[index % bgColors.length],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: AspectRatio(
              aspectRatio: 0.78,
              child: Center(
                child: Icon(
                  Icons.checkroom_outlined,
                  size: 56.w,
                  color: iconColors[index % iconColors.length],
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            item['title'] ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: textPrimary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          Text(
            '¥${item['price'] ?? ''}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建动态标题
  Widget _buildDynamicTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      child: Text(
        '动态',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
    );
  }

  /// 从地址中提取市名（如"广东省深圳市" → "深圳市"）
  String _extractCity(String address) {
    // 特别行政区简称
    if (address.contains('香港')) return '香港';
    if (address.contains('澳门')) return '澳门';
    // 去掉省/自治区前缀
    var remaining = address;
    final provinceIdx = address.indexOf('省');
    if (provinceIdx != -1) {
      remaining = address.substring(provinceIdx + 1);
    } else {
      final regionIdx = address.indexOf('自治区');
      if (regionIdx != -1) {
        remaining = address.substring(regionIdx + 3);
      }
    }
    // 匹配"X市"部分
    final match = RegExp(r'[\u4e00-\u9fa5]+市').firstMatch(remaining);
    if (match != null) {
      return match.group(0)!;
    }
    return remaining.isNotEmpty ? remaining : address;
  }

  /// 跳转到编辑资料页面
  Future<void> _navigateToEditProfile(UserBaseInfo? userInfo) async {
    final result = await Get.toNamed(
      Routes.editProfile,
      arguments: {
        'nickname': userInfo?.nickname ?? '',
        'avatar': userInfo?.avatar ?? '',
        'city': userInfo?.address ?? '',
      },
    );

    // 如果返回了刷新标志，刷新用户信息
    if (result != null && result['refresh'] == true) {
      controller.onRefresh();
    }
  }
}
