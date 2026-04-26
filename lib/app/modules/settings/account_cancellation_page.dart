import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import '../../../common/constants/app_constants.dart';
import '../../../common/utils/dialog/tip_dialog.dart';
import '../../../common/utils/sp_utils.dart';

class AccountCancellationPage extends StatefulWidget {
  const AccountCancellationPage({Key? key}) : super(key: key);

  @override
  _AccountCancellationPageState createState() => _AccountCancellationPageState();
}

class _AccountCancellationPageState extends State<AccountCancellationPage> {
  bool _isApplied = false;

  @override
  void initState() {
    super.initState();
    _loadApplicationStatus();
  }

  Future<void> _loadApplicationStatus() async {
    setState(() {
      _isApplied = SPUtils.getBool('account_cancellation_applied') ?? false;
    });
  }

  Future<void> _saveApplicationStatus() async {
    await SPUtils.setBool('account_cancellation_applied', true);
  }

  void _onButtonPressed() {
    showTipDialog(
      title: '确认提交注销申请？',
      leftText: '取消',
      rightText: '确认',
      leftTextColor: Colors.black54,
      onLeftTap: () {
        Get.back();
      },
      onRightTap: () {
        Get.back();
        setState(() {
          _isApplied = true;
        });
        _saveApplicationStatus();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '账号注销',
          style: TextStyle(color: Colors.black, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '潮星球个人账号可以申请注销。注销前请确认账号所属及虚拟财产结算。',
              style: TextStyle(fontSize: 16.sp, color: Colors.black87),
            ),
            SizedBox(height: 16.h),
            Text(
              '申请注销前，您的账号需要满足以下条件:',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            _buildConditionItem(
              title: '账号安全',
              content: '申请注销的账号短期内（7天内）无修改密码等安全类操作。',
            ),
            _buildConditionItem(
              title: '账号状态',
              content: '审核状态中的账号无法进行注销，需为正常使用状态。',
            ),
            _buildConditionItem(
              title: '账号财产',
              content: '账号需15天内没有购买记录。',
            ),
            SizedBox(height: 24.h),
            // 按钮
            GestureDetector(
              onTap: _isApplied ? null : _onButtonPressed,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isApplied ? Colors.grey.shade300 : primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _isApplied ? '已申请' : '账号注销',
                  style: TextStyle(
                    color: _isApplied ? Colors.grey : Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionItem({
    required String title,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            content,
            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}