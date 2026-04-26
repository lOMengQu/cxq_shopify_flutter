class FeedbackListResponse {
  final int? count;
  final int? totalPages;
  final int? curPage;
  final int? perPage;
  final int? initNum;
  final List<FeedbackItem>? dtoList;

  FeedbackListResponse({
    this.count,
    this.totalPages,
    this.curPage,
    this.perPage,
    this.initNum,
    this.dtoList,
  });

  factory FeedbackListResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackListResponse(
      count: json['count'],
      totalPages: json['totalPages'],
      curPage: json['curPage'],
      perPage: json['perPage'],
      initNum: json['initNum'],
      dtoList: json['dtoList'] != null
          ? (json['dtoList'] as List).map((e) => FeedbackItem.fromJson(e)).toList()
          : null,
    );
  }
}

class FeedbackItem {
  final String id;
  final String content;
  final String contact;
  final int problemType;
  final List<String>? pictureList;
  final double createTime;

  FeedbackItem({
    required this.id,
    required this.content,
    required this.contact,
    required this.problemType,
    this.pictureList,
    required this.createTime,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['id'],
      content: json['content'],
      contact: json['contact'],
      problemType: json['problemType'],
      pictureList: json['pictureList'] != null
          ? List<String>.from(json['pictureList'])
          : null,
      createTime: json['createTime'].toDouble(),
    );
  }

  String getProblemTypeText() {
    switch (problemType) {
      case 1: return '账号问题';
      case 2: return '播放问题';
      case 3: return '上传问题';
      case 4: return '审核问题';
      case 5: return '交易问题';
      case 6: return '其他问题';
      default: return '未知类型';
    }
  }

  DateTime getCreateDateTime() {
    return DateTime.fromMillisecondsSinceEpoch((createTime * 1000).toInt());
  }
}

class FeedbackDetail {
  final String id;
  final String content;
  final String contact;
  final int problemType;
  final List<String>? pictureList;
  final DateTime createTime;
  final String? reply;

  FeedbackDetail({
    required this.id,
    required this.content,
    required this.contact,
    required this.problemType,
    this.pictureList,
    required this.createTime,
    this.reply,
  });

  factory FeedbackDetail.fromJson(Map<String, dynamic> json) {
    return FeedbackDetail(
      id: json['id'].toString(),
      content: json['content'] ?? '',
      contact: json['contact'] ?? '',
      problemType: json['problemType'] ?? 6,
      pictureList: json['pictureList'] != null
          ? List<String>.from(json['pictureList'])
          : null,
      createTime: DateTime.fromMillisecondsSinceEpoch(
          (json['createTime'] as num).toInt() * 1000),
      reply: json['reply'],
    );
  }

  // 添加辅助方法
  String getProblemTypeText() {
    const types = {
      1: '账号问题',
      2: '播放问题',
      3: '上传问题',
      4: '审核问题',
      5: '交易问题',
      6: '其他问题'
    };
    return types[problemType] ?? '未知类型';
  }

  DateTime getCreateDateTime() => createTime;
}