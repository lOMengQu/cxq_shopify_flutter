import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_constants.dart';

class AppBarWidget extends StatelessWidget {
  final VoidCallback backOnTap;
  final String title;
  final Widget? rightWidget;
  final bool showBack;
  const AppBarWidget({super.key, required this.backOnTap, required this.title, this.rightWidget, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44.h,
      child: Stack(
        children: [
          if (showBack)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: Center(
                child: GestureDetector(
                  onTap: backOnTap,
                  child: Container(
                    width: 44.w,
                    height: 44.h,
                    child: Image.asset(backIcon,fit: BoxFit.cover,),
                  ),
                ),
              ),
            ),
          Center(
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: Platform.isIOS ? FontWeight.w500 : FontWeight.w600,
                  color: textFiledColor),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: Center(
              child: rightWidget,
            ),
          ),
        ],
      ),
    );
  }
}
