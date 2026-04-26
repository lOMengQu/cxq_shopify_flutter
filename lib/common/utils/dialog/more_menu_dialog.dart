import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_constants.dart';

/// 显示更多菜单弹窗
///
/// [context] 上下文
/// [buttonKey] 按钮的 GlobalKey，用于定位菜单位置
/// [menuItems] 菜单项列表
void showMoreMenuDialog({
  required BuildContext context,
  required GlobalKey buttonKey,
  required List<Widget> menuItems
  ,
  double rightWidth=16,
  double? menuWidth
}) {
  final RenderBox? button = buttonKey.currentContext?.findRenderObject() as RenderBox?;

  if (button == null) return;

  final Offset buttonPosition = button.localToGlobal(Offset.zero);
  final Size buttonSize = button.size;

  // 计算菜单位置：在按钮右下方
  final double resolvedMenuWidth = (menuWidth ?? 90).w;
  final double spacing = 4.h;

  // 计算菜单左上角位置（按钮右下角偏移，右对齐）
  final double menuLeft = buttonPosition.dx + buttonSize.width - resolvedMenuWidth - rightWidth.w;
  final double menuTop = buttonPosition.dy-10.h;

  final int optionCount = menuItems.whereType<InkWell>().length;
  final int resolvedOptionCount = optionCount == 0 ? menuItems.length : optionCount;
  final List<Widget> resolvedMenuItems = resolvedOptionCount <= 1
      ? menuItems.where((e) => e is! Divider).toList()
      : menuItems;

  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (BuildContext dialogContext) {
      return Stack(
        children: [
          // 透明背景，点击关闭
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(dialogContext),
              child: Container(color: Colors.transparent),
            ),
          ),
          // 菜单内容
          Positioned(
            left: menuLeft,
            top: menuTop,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: resolvedMenuWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: resolvedOptionCount > 1
                      ? Border.all(color: const Color(0xFF999999), width: 0.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: resolvedMenuItems,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// 构建菜单项
Widget buildMenuItem({
  required String text,
  required VoidCallback onTap,
  double? itemWidth,
}) {
  return InkWell(
    onTap: onTap,
    child: Align(
      alignment: Alignment.center,
      child: Container(
        width: itemWidth == null ? double.infinity : itemWidth.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: textFiledColor,
          ),
        ),
      ),
    ),
  );
}

/// 构建菜单分隔线
Widget buildMenuDivider() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Divider(height: 1, color: const Color(0xFF999999), thickness: 0.5),
  );
}

