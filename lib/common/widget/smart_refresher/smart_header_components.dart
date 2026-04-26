import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class SmartHeaderComponents extends StatelessWidget {
  const SmartHeaderComponents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClassicHeader(
      idleIcon: Icon((Icons.arrow_downward)),
      idleText: "下拉可以刷新",
      releaseText: "释放立即刷新",
      releaseIcon: Icon(Icons.arrow_upward),
      refreshingText: "正在刷新",
      refreshingIcon: CupertinoActivityIndicator(color: Colors.grey,),
      completeText: "刷新完成",
    );

  }
}
