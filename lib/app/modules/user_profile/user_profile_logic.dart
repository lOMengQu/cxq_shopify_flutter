
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../api/http/async_handler.dart';
import '../../../api/service/user_api.dart';
import '../../../api/z_entity/user/user_homepage_entity.dart';
import '../../../common/utils/service/user_service.dart';

class UserProfileLogic extends GetxController with GetSingleTickerProviderStateMixin {
  /// 用户ID，从路由参数获取
  late String userId;

  /// 是否从底部导航栏进入（不显示返回按钮）
  bool fromTab = false;

  /// 是否是当前登录用户
  bool get isCurrentUser => UserService.isCurrentUser(userId);

  /// 用户基本信息
  final userInfo = Rxn<UserBaseInfo>();

  /// 圈子列表
  final gambitList = <UserGambitItem>[].obs;

  /// 圈子展开状态
  final isGambitExpanded = false.obs;

  /// 背景图展开状态
  final isBgExpanded = false.obs;

  /// 背景图展开动画控制器
  late AnimationController bgExpandController;

  /// 背景图展开动画
  late Animation<double> bgExpandAnimation;

  /// 滚动控制器
  final scrollController = ScrollController();

  /// 是否显示顶部栏
  final showTopBar = false.obs;

  /// 刷新控制器
  final refreshController = RefreshController(initialRefresh: false);

  /// 动态分页
  int ugcPage = 1;
  int ugcTotalPages = 1;

  /// 加载状态
  final isLoading = true.obs;

  ///是否是当前用户
  var isUser =false.obs;

  ///是否是品牌
  var isBrand =false.obs;
  @override
  void onInit() {
    super.onInit();
    // 从路由参数获取 userId
    userId = Get.arguments?['userId'] ?? '';
    if (userId.isEmpty) {
      userId = UserService.getUserId() ?? '';
    }
    // 是否从底部导航栏进入
    fromTab = Get.arguments?['fromTab'] ?? false;
    // 初始化背景图展开动画控制器
    bgExpandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    bgExpandAnimation = CurvedAnimation(
      parent: bgExpandController,
      curve: Curves.easeInOut,
    );

    // 监听滚动
    scrollController.addListener(_onScroll);

    // 加载数据
    _loadAllData();
  }

  void _onScroll() {
    // 当滚动超过 200 时显示顶部栏
    showTopBar.value = scrollController.offset > 200;
  }

  /// 加载所有数据
  Future<void> _loadAllData() async {
    isLoading.value = true;
    await Future.wait([
      loadUserInfo(),
      loadGambitList(),
    ]);
    isLoading.value = false;
  }

  /// 刷新数据
  Future<void> onRefresh() async {
    await _loadAllData();
    refreshController.refreshCompleted();
  }

  /// 加载用户信息
  Future<void> loadUserInfo() async {
    if (userId.isEmpty) return;
    final response = await AsyncHandler.handle(future: postHomepageInfo(userId: userId));
    if (!response.ok) return;
    userInfo.value = response.data?.firstBaseInfo;
  }

  /// 加载圈子列表
  Future<void> loadGambitList() async {
    if (userId.isEmpty) return;
    final response = await AsyncHandler.handle(future: postHomepageGambitList(userId: userId, page: 1));
    if (!response.ok) return;
    gambitList.value = response.data?.gambitList ?? [];
  }

  /// 切换圈子展开/收起
  void toggleGambitExpand() {
    isGambitExpanded.value = !isGambitExpanded.value;
  }

  /// 切换背景图展开/收起
  void toggleBgExpand() {
    if (isBgExpanded.value) {
      collapseBg();
    } else {
      expandBg();
    }
  }

  /// 展开背景图
  void expandBg() {
    isBgExpanded.value = true;
    bgExpandController.forward();
  }

  /// 收起背景图
  void collapseBg() {
    isBgExpanded.value = false;
    bgExpandController.reverse();
  }


  /// 设置用户状态
  Future<void> setUserStatus(String description) async {
    final response = await AsyncHandler.handle(
      future: postUserStatus(description: description),
    );
    if (!response.ok) return;

    await loadUserInfo();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    refreshController.dispose();
    bgExpandController.dispose();
    super.onClose();
  }
}
