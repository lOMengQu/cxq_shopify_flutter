class BlockUserListResponse {
  final List<BlockUser> blockUserDtoList;
  BlockUserListResponse({required this.blockUserDtoList});

  factory BlockUserListResponse.fromJson(Map<String, dynamic> json) {
    return BlockUserListResponse(
      blockUserDtoList: (json['blockUserDtoList'] as List)
          .map((e) => BlockUser.fromJson(e))
          .toList(),
    );
  }
}

class BlockUser {
  final String id;
  final String nickname;
  final String avatar;
  final int contentCnt;
  final String vipImage;
  final int followStatus;
  final int isBlock;
  final int isFollow;
  final int isFans;
  final int isMusician;
  final List<Identity> identityDtoList;

  BlockUser({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.contentCnt,
    required this.vipImage,
    required this.followStatus,
    required this.isBlock,
    required this.isFollow,
    required this.isFans,
    required this.isMusician,
    required this.identityDtoList,
  });

  factory BlockUser.fromJson(Map<String, dynamic> json) {
    return BlockUser(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? '',
      avatar: json['avatar'] ?? '',
      contentCnt: json['contentCnt'] ?? 0,
      vipImage: json['vipImage'] ?? '',
      followStatus: json['followStatus'] ?? 0,
      isBlock: json['isBlock'] ?? 0,
      isFollow: json['isFollow'] ?? 0,
      isFans: json['isFans'] ?? 0,
      isMusician: json['isMusician'] ?? 0,
      identityDtoList: (json['identityDtoList'] as List?)
          ?.map((e) => Identity.fromJson(e))
          .toList() ?? [],
    );
  }
}

class Identity {
  final String id;
  final String name;
  Identity({required this.id, required this.name});

  factory Identity.fromJson(Map<String, dynamic> json) {
    return Identity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}