/// 用户个人主页信息响应实体
class UserHomepageInfoEntity {
  final List<UserBaseInfo>? baseInfo;

  const UserHomepageInfoEntity({this.baseInfo});

  factory UserHomepageInfoEntity.fromJson(Map<String, dynamic> json) {
    return UserHomepageInfoEntity(
      baseInfo: (json['base_info'] as List?)
          ?.map((e) => UserBaseInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_info': baseInfo?.map((e) => e.toJson()).toList(),
    };
  }

  UserBaseInfo? get firstBaseInfo => baseInfo?.isNotEmpty == true ? baseInfo!.first : null;
}

/// 用户基本信息
class UserBaseInfo {
  final String? userId;
  final String? nickname;
  final String? address;
  final String? avatar;
  final String? conversationId;
  final int? followNum;
  final int? followNumMutual;
  final String? background;
  final String? description;
  final String? provinces;
  final bool? isFollow;
  final List<String>? photoWall;
  final int? totalLikeNum;

  const UserBaseInfo({
    this.userId,
    this.nickname,
    this.avatar,
    this.address,
    this.followNum,
    this.followNumMutual,
    this.background,
    this.conversationId,
    this.description,
    this.provinces,
    this.isFollow,
    this.photoWall,
    this.totalLikeNum,
  });


  @override
  String toString() {
    return 'UserBaseInfo{userId: $userId, nickname: $nickname, avatar: $avatar, followNum: $followNum, followNumMutual: $followNumMutual, background: $background, description: $description, provinces: $provinces, photoWall: $photoWall, totalLikeNum: $totalLikeNum}';
  }

  factory UserBaseInfo.fromJson(Map<String, dynamic> json) {
    final dynamic rawIsFollow = json['isFollow'];
    final bool? parsedIsFollow = rawIsFollow is bool
        ? rawIsFollow
        : (rawIsFollow is num ? rawIsFollow.toInt() == 1 : null);

    return UserBaseInfo(
      userId: json['user_id'] as String?,
      conversationId: json['conversationId'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      address: json['address'] as String?,
      followNum: json['followNum'] as int?,
      followNumMutual: json['followNumMutual'] as int?,
      background: json['background'] as String?,
      description: json['description'] as String?,
      isFollow: parsedIsFollow,
      provinces: json['provinces'] as String?,
      photoWall: (json['photoWall'] as List?)?.map((e) => e.toString()).toList(),
      totalLikeNum: json['totalLikeNum'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nickname': nickname,
      'avatar': avatar,
      'followNum': followNum,
      'followNumMutual': followNumMutual,
      'background': background,
      'address': address,
      'description': description,
      'isFollow': isFollow,
      'provinces': provinces,
      'photoWall': photoWall,
      'totalLikeNum': totalLikeNum,
    };
  }
}

/// 用户圈子列表响应实体
class UserGambitListEntity {
  final int? count;
  final int? totalPages;
  final int? curPage;
  final int? perPage;
  final int? initNum;
  final List<String>? dtoList;
  final List<UserGambitItem>? gambitList;

  const UserGambitListEntity({
    this.count,
    this.totalPages,
    this.curPage,
    this.perPage,
    this.initNum,
    this.dtoList,
    this.gambitList,
  });

  factory UserGambitListEntity.fromJson(Map<String, dynamic> json) {
    return UserGambitListEntity(
      count: json['count'] as int?,
      totalPages: json['totalPages'] as int?,
      curPage: json['curPage'] as int?,
      perPage: json['perPage'] as int?,
      initNum: json['initNum'] as int?,
      dtoList: (json['dtoList'] as List?)?.map((e) => e.toString()).toList(),
      gambitList: (json['gambitList'] as List?)
          ?.map((e) => UserGambitItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'totalPages': totalPages,
      'curPage': curPage,
      'perPage': perPage,
      'initNum': initNum,
      'dtoList': dtoList,
      'gambitList': gambitList?.map((e) => e.toJson()).toList(),
    };
  }
}

/// 用户圈子项
class UserGambitItem {
  final String? gambitId;
  final String? name;
  final String? describe;
  final int? type;

  const UserGambitItem({
    this.gambitId,
    this.name,
    this.describe,
    this.type,
  });

  factory UserGambitItem.fromJson(Map<String, dynamic> json) {
    return UserGambitItem(
      gambitId: json['gambit_id'] as String?,
      name: json['name'] as String?,
      describe: json['describe'] as String?,
      type: json['type'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gambit_id': gambitId,
      'name': name,
      'describe': describe,
      'type': type,
    };
  }
}

/// 用户动态列表响应实体 (复用 GambitUgcListEntity 中的结构)
class UserUgcListEntity {
  final int? count;
  final int? totalPages;
  final int? curPage;
  final int? perPage;
  final int? initNum;
  final List<String>? dtoList;

  const UserUgcListEntity({
    this.count,
    this.totalPages,
    this.curPage,
    this.perPage,
    this.initNum,
    this.dtoList,
  });

  factory UserUgcListEntity.fromJson(Map<String, dynamic> json) {
    return UserUgcListEntity(
      count: json['count'] as int?,
      totalPages: json['totalPages'] as int?,
      curPage: json['curPage'] as int?,
      perPage: json['perPage'] as int?,
      initNum: json['initNum'] as int?,
      dtoList: (json['dtoList'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'totalPages': totalPages,
      'curPage': curPage,
      'perPage': perPage,
      'initNum': initNum,
      'dtoList': dtoList,
    };
  }
}
