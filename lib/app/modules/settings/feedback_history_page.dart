import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common/constants/app_constants.dart';
import 'feedback_model.dart';

class FeedbackHistoryPage extends StatefulWidget {
  const FeedbackHistoryPage({Key? key}) : super(key: key);

  @override
  _FeedbackHistoryPageState createState() => _FeedbackHistoryPageState();
}

class _FeedbackHistoryPageState extends State<FeedbackHistoryPage> {
  final List<FeedbackItem> _feedbackList = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _currentPage = 1;
  final int _perPage = 10;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadFeedbackHistory();
  }

  Future<void> _loadFeedbackHistory() async {
    try {
      setState(() => _isLoading = true);
      // TODO: 接入反馈历史列表API
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

  Future<void> _refresh() async {
    setState(() {
      _currentPage = 1;
      _feedbackList.clear();
      _hasMore = true;
    });
    await _loadFeedbackHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(248, 248, 248, 1),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Color.fromRGBO(248, 248, 248, 1),
        elevation: 0,
        title: const Text(
          '反馈历史',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _feedbackList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('加载失败，请重试'),
            TextButton(
              onPressed: _refresh,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    if (_feedbackList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('还没有任何反馈', style: TextStyle(fontSize: 16, color: Colors.grey)),
            TextButton(
              onPressed: () => Get.back(),
              child: Text('去提交反馈', style: TextStyle(color: primary)),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _feedbackList.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _feedbackList.length) {
            return _buildLoadMore();
          }
          return _buildFeedbackItem(_feedbackList[index]);
        },
      ),
    );
  }

  Widget _buildFeedbackItem(FeedbackItem item) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      color: Colors.white, // Card background color
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(item.id),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '反馈时间: ${_formatDate(item.getCreateDateTime())}',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.grey,
                            ),
                            maxLines: 1, // 限制为1行
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '反馈类型: ${item.getProblemTypeText()}',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(
                            text: '反馈描述：',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: item.content,
                            style: const TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMore() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: _isLoading
            ? const CircularProgressIndicator()
            : TextButton(
          onPressed: () {
            setState(() => _currentPage++);
            _loadFeedbackHistory();
          },
          child: const Text('加载更多'),
        ),
      ),
    );
  }

  void _navigateToDetail(String feedbackId) {
    Get.to(() => FeedbackDetailPage(feedbackId: feedbackId));
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
}

class FeedbackDetailPage extends StatefulWidget {
  final String feedbackId;

  const FeedbackDetailPage({Key? key, required this.feedbackId}) : super(key: key);

  @override
  _FeedbackDetailPageState createState() => _FeedbackDetailPageState();
}

class _FeedbackDetailPageState extends State<FeedbackDetailPage> {
  FeedbackDetail? _feedback;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      // TODO: 接入反馈详情API
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
        title: const Text(
          '反馈详情',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError || _feedback == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('加载失败'),
            TextButton(
              onPressed: _loadDetail,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    final feedback = _feedback!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '反馈时间: ${_formatDate(feedback.getCreateDateTime())}',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
              ),
              Flexible(
                child: Text(
                  '反馈类型: ${feedback.getProblemTypeText()}',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black,
              ),
              children: [
                const TextSpan(
                  text: '反馈描述：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: feedback.content,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (feedback.pictureList != null && feedback.pictureList!.isNotEmpty) ...[
            const Text(
              '反馈图片：',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100.w,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: feedback.pictureList!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        image: DecorationImage(
                          image: NetworkImage(feedback.pictureList![index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (feedback.reply != null && feedback.reply!.isNotEmpty) ...[
            const Text(
              '管理员回复：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(feedback.reply!),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
}