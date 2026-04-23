class OssAuthEntity {
  String? accessKeyId;
  String? accessKeySecret;
  String? securityToken;
  String? expiration;
  String? savePath;

  OssAuthEntity({
    this.accessKeyId,
    this.accessKeySecret,
    this.securityToken,
    this.expiration,
    this.savePath,
  });

  factory OssAuthEntity.fromJson(Map<String, dynamic> json) {
    return OssAuthEntity(
      accessKeyId: json['accessKeyId']?.toString(),
      accessKeySecret: json['accessKeySecret']?.toString(),
      securityToken: json['securityToken']?.toString(),
      expiration: json['expiration']?.toString(),
      savePath: json['savePath']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessKeyId': accessKeyId,
      'accessKeySecret': accessKeySecret,
      'securityToken': securityToken,
      'expiration': expiration,
      'savePath': savePath,
    };
  }
}
