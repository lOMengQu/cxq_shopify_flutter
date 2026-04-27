import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:cxq_merchant_flutter/common/constants/app_constants.dart';
import 'package:cxq_merchant_flutter/common/widget/app_bar_widget.dart';
import 'package:cxq_merchant_flutter/common/widget/button_widget.dart';

import 'product_params_logic.dart';

class ProductParamsPage extends StatelessWidget {
  const ProductParamsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductParamsLogic>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppBarWidget(
              backOnTap: controller.onBackPressed,
              title: '商品参数',
              rightWidget: GestureDetector(
                onTap: controller.onComplete,
                child: Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Text(
                    '完成',
                    style: TextStyle(fontSize: 14.sp, color: primary),
                  ),
                ),
              ),
            ),
          ),

          // ========== 内容区 ==========
          Expanded(
            child: Container(
              color: background,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    // 说明文字
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14.sp, color: textAssist),
                        children: [
                          TextSpan(text: '说明：'),
                          TextSpan(
                            text:
                                '商品参数，如(材质:羊毛;适用人群:12岁以上等介绍描述)',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // 参数列表
                    Obx(() {
                      return Column(
                        children: [
                          ...List.generate(controller.params.length, (index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _buildParamRow(controller, index),
                            );
                          }),
                        ],
                      );
                    }),

                    SizedBox(height: 16.h),

                    // 新增参数按钮
                    SizedBox(
                      width: double.infinity,
                      height: 46.h,
                      child: ThemeButton(
                        radius: 60,
                        onTap: controller.addParam,
                        child: Text(
                          '新增参数',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParamRow(ProductParamsLogic controller, int index) {
    final nameCtrl = controller.params[index]['name']!;
    final descCtrl = controller.params[index]['desc']!;

    return Row(
      children: [
        // 名称输入框
        Expanded(
          flex: 2,
          child: Container(
            height: 40.h,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: dividerColor, width: 1),
              ),
            ),
            child: TextField(
              controller: nameCtrl,
              maxLength: 8,
              inputFormatters: [
                LengthLimitingTextInputFormatter(8),
              ],
              decoration: InputDecoration(
                hintText: '名称(最多8个字)',
                hintStyle: TextStyle(fontSize: 13.sp, color: textAssist),
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
              ),
              style: TextStyle(fontSize: 13.sp, color: textPrimary),
            ),
          ),
        ),

        // 分隔符
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            '：',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
        ),

        // 介绍输入框
        Expanded(
          flex: 4,
          child: Container(
            height: 40.h,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: dividerColor, width: 1),
              ),
            ),
            child: TextField(
              controller: descCtrl,
              maxLength: 20,
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
              decoration: InputDecoration(
                hintText: '介绍(最多20个字)',
                hintStyle: TextStyle(fontSize: 13.sp, color: textAssist),
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
              ),
              style: TextStyle(fontSize: 13.sp, color: textPrimary),
            ),
          ),
        ),

        SizedBox(width: 8.w),

        // 删除按钮
        GestureDetector(
          onTap: () => controller.removeParam(index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '删除',
              style: TextStyle(fontSize: 12.sp, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
