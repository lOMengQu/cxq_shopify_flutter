import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common/constants/app_constants.dart';
import '../../../common/utils/toast.dart';
import 'block_user_model.dart';

class BlockUserListPage extends StatefulWidget {
  const BlockUserListPage({Key? key}) : super(key: key);

  @override
  _BlockUserListPageState createState() => _BlockUserListPageState();
}

class _BlockUserListPageState extends State<BlockUserListPage> {
  final List<BlockUser> _blockUsers = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasError = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadBlockUsers();
  }

  Future<void> _loadBlockUsers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // TODO: 接入黑名单列表API
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '黑名单',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _blockUsers.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primary),
        ),
      );
    }

    if (_hasError && _blockUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '加载失败，请重试',
              style: TextStyle(color: textAssist),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBlockUsers,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: const Text(
                '重新加载',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_blockUsers.isEmpty) {
      return Center(
        child: Text(
          '暂无黑名单用户',
          style: TextStyle(color: textAssist),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h), // 使用.w和.h进行边距适配
      itemCount: _blockUsers.length,
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFFF0F4F7),
        height: 1,
        indent: 16,
      ),
      itemBuilder: (context, index) {
        return _buildBlockUserItem(_blockUsers[index]);
      },
    );
  }

  Widget _buildBlockUserItem(BlockUser user) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h), // 使用.h进行垂直边距适配
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: Colors.grey[200],
            backgroundImage: user.avatar.isNotEmpty
                ? NetworkImage(user.avatar)
                : null,
            child: user.avatar.isEmpty
                ? const Icon(Icons.person, color: Colors.white54, size: 24)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 110.w,
                      child: Text(
                        user.nickname,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.identityDtoList.isNotEmpty)
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 8.w), // 使用.w进行左边距适配
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h), // 使用.w和.h进行边距适配
                          decoration: BoxDecoration(
                            color: const Color(0xFF363940),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            user.identityDtoList.map((e) => e.name).join(' '),
                            style: const TextStyle(
                              color: Color(0xFF9E9DA1),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.contentCnt}个作品',
                  style: const TextStyle(
                    color: Color(0xFF9E9DA1),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showUnblockDialog(user),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
                side: BorderSide(
                  color: primary,
                  width: 1,
                ),
              ),
            ),
            child: const Text(
              '移除黑名单',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnblockDialog(BlockUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          '确认移除',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        content: const Text(
          '确定要将此用户移出黑名单吗？',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: 接入移除黑名单API
              setState(() {
                _blockUsers.removeWhere((u) => u.id == user.id);
              });
              FToastUtil.show('已移除黑名单');
            },
            child: const Text(
              '确认',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}