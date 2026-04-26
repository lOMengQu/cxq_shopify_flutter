import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 自定义缓存：
/// - key: 用于区分不同缓存池（目录名、db名）
/// - stalePeriod: 过期时间（到期会被认为“旧”，下次会尝试重新拉取）
/// - maxNrOfCacheObjects: 最大缓存文件数（超过会按LRU逐出）
class AppImageCacheManager {
  static const String _key = 'appImageCache_cxq';

  static final CacheManager instance = CacheManager(
    Config(
      _key,
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 500,
      repo: JsonCacheInfoRepository(databaseName: _key),
      fileService: HttpFileService(),
    ),
  );

  /// 清空整个缓存池（目录 + db记录）
  static Future<void> clear() => instance.emptyCache();

  /// 删除某一个 url 对应的缓存（包括不同尺寸同 url 的情况：取决于你传入的 key）
  static Future<void> removeByUrl(String url) => instance.removeFile(url);

  /// 预下载并写入缓存（常用于列表/详情页提前加载）
  static Future<FileInfo?> prefetch(String url) async {
    try {
      return await instance.downloadFile(url);
    } catch (_) {
      return null;
    }
  }
}
