import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SmartFooterComponents extends StatelessWidget {
  const SmartFooterComponents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClassicFooter(
        loadingIcon: CupertinoActivityIndicator(),
        noDataText: "无更多数据",
        loadingText: "正在加载中",
        idleText: "上拉加载更多",
        canLoadingText: "松手立即加载");
  }
}
