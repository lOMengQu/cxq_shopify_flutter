class ImageCodeEntity {
  String? oneKey;
  String? image;

  ImageCodeEntity({this.oneKey, this.image});

  factory ImageCodeEntity.fromJson(Map<String, dynamic> json) {
    return ImageCodeEntity(
      oneKey: json['oneKey'] as String?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oneKey': oneKey,
      'image': image,
    };
  }
}
