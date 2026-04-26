import 'package:cxq_merchant_flutter/api/z_entity/file/oss_auth_entity.dart';

import '../z_entity/base_response.dart';
import '../http/api_client.dart';
import '../http/env_config.dart';

/// 获取 OSS 上传临时凭证（走用户端服务器，公共服务）
/// [category] 分类: 1=ugc
/// [fileType] 文件类型: 1=图片
Future<BaseResponse<OssAuthEntity>> postFileUploadAuth({
  int category = 1,
  int fileType = 1,
}) {
  return ApiClient().post(
    '${EnvConfig.userHttpBaseUrl}/file/uploads/auth/info/?category=$category&fileType=$fileType',
    fromJsonT: (json) => OssAuthEntity.fromJson(json),
  );
}
