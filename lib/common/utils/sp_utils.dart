import 'package:get_storage/get_storage.dart';

class SPUtils {
  static const String _defaultBox = 'app_storage';
  static late GetStorage _box;

  // ======================
  // 初始化
  // ======================
  static Future<void> init({String boxName = _defaultBox}) async {
    await GetStorage.init(boxName);
    _box = GetStorage(boxName);
  }

  // ======================
  // 命名空间
  // ======================
  static StorageBox box([String namespace = '']) => StorageBox._(namespace);

  // ======================
  // 写入（支持 TTL）
  // ======================
  static Future<void> write<T>(String key, T value,
      {Duration? ttl, String? namespace}) async {
    final k = _k(key, namespace);

    if (ttl == null) {
      await _box.write(k, value);
    } else {
      final expireAt = DateTime.now().add(ttl).millisecondsSinceEpoch;
      await _box.write(k, {'_v': value, '_e': expireAt});
    }
  }

  // ======================
  // 读取（自动 TTL）
  // ======================
  static T? read<T>(String key, {String? namespace}) {
    final k = _k(key, namespace);

    if (!_box.hasData(k)) return null;

    final data = _box.read(k);

    if (data is Map && data.containsKey('_v')) {
      final expireAt = data['_e'] as int?;

      if (expireAt != null && expireAt > 0) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > expireAt) {
          _box.remove(k);
          return null;
        }
      }

      return data['_v'] as T?;
    }

    return data as T?;
  }

  // ======================
  // 是否存在（含 TTL 判断）
  // ======================
  static bool has(String key, {String? namespace}) {
    final k = _k(key, namespace);

    if (!_box.hasData(k)) return false;

    final data = _box.read(k);

    if (data is Map && data.containsKey('_v')) {
      final expireAt = data['_e'] as int?;

      if (expireAt != null && expireAt > 0) {
        if (DateTime.now().millisecondsSinceEpoch > expireAt) {
          _box.remove(k);
          return false;
        }
      }
    }

    return true;
  }

  // ======================
  // 删除 & 清空
  // ======================
  static Future<void> remove(String key, {String? namespace}) =>
      _box.remove(_k(key, namespace));

  static Future<void> clear() => _box.erase();

  // ======================
  // 监听
  // ======================
  static void listen<T>(String key, void Function(T? value) onChanged,
      {String? namespace}) {
    final k = _k(key, namespace);

    _box.listenKey(k, (value) {
      if (value is Map && value.containsKey('_v')) {
        final expireAt = value['_e'];

        if (expireAt != null &&
            DateTime.now().millisecondsSinceEpoch > expireAt) {
          _box.remove(k);
          onChanged(null);
          return;
        }

        onChanged(value['_v'] as T?);
      } else {
        onChanged(value as T?);
      }
    });
  }

  // ======================
  // 便捷 API
  // ======================
  static Future<void> setString(String key, String value,
      {Duration? ttl, String? namespace}) =>
      write(key, value, ttl: ttl, namespace: namespace);

  static String? getString(String key, {String? namespace}) =>
      read(key, namespace: namespace);

  static Future<void> setBool(String key, bool value,
      {Duration? ttl, String? namespace}) =>
      write(key, value, ttl: ttl, namespace: namespace);

  static bool? getBool(String key, {String? namespace}) =>
      read(key, namespace: namespace);

  static Future<void> setInt(String key, int value,
      {Duration? ttl, String? namespace}) =>
      write(key, value, ttl: ttl, namespace: namespace);

  static int? getInt(String key, {String? namespace}) =>
      read(key, namespace: namespace);

  static Future<void> setDouble(String key, double value,
      {Duration? ttl, String? namespace}) =>
      write(key, value, ttl: ttl, namespace: namespace);

  static double? getDouble(String key, {String? namespace}) =>
      read(key, namespace: namespace);

  static Future<void> setStringList(String key, List<String> value,
      {Duration? ttl, String? namespace}) =>
      write(key, value, ttl: ttl, namespace: namespace);

  static List<String>? getStringList(String key, {String? namespace}) {
    final data = read(key, namespace: namespace);
    if (data is List) return data.map((e) => e.toString()).toList();
    return null;
  }

  // ======================
  // 模型 API
  // ======================
  static Future<void> writeModel<T>(
      String key,
      T model, {
        required Map<String, dynamic> Function(T) toJson,
        Duration? ttl,
        String? namespace,
      }) {
    return write<Map<String, dynamic>>(key, toJson(model),
        ttl: ttl, namespace: namespace);
  }

  static T? readModel<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson, {
        String? namespace,
      }) {
    final map = read<Map>(key, namespace: namespace);
    if (map == null) return null;
    return fromJson(Map<String, dynamic>.from(map));
  }

  // ======================
  // 内部 key 拼接
  // ======================
  static String _k(String key, String? namespace) =>
      (namespace == null || namespace.isEmpty) ? key : '$namespace:$key';
}

// ========================================================
// 命名空间包装
// ========================================================
class StorageBox {
  final String _ns;

  StorageBox._(this._ns);

  Future<void> write<T>(String key, T value, {Duration? ttl}) =>
      SPUtils.write(key, value, ttl: ttl, namespace: _ns);

  T? read<T>(String key) => SPUtils.read<T>(key, namespace: _ns);

  bool has(String key) => SPUtils.has(key, namespace: _ns);

  Future<void> remove(String key) => SPUtils.remove(key, namespace: _ns);

  void listen<T>(String key, void Function(T?) onChanged) =>
      SPUtils.listen(key, onChanged, namespace: _ns);

  Future<void> setString(String key, String value, {Duration? ttl}) =>
      SPUtils.setString(key, value, ttl: ttl, namespace: _ns);

  String? getString(String key) => SPUtils.getString(key, namespace: _ns);

  Future<void> setBool(String key, bool value, {Duration? ttl}) =>
      SPUtils.setBool(key, value, ttl: ttl, namespace: _ns);

  bool? getBool(String key) => SPUtils.getBool(key, namespace: _ns);

  Future<void> setInt(String key, int value, {Duration? ttl}) =>
      SPUtils.setInt(key, value, ttl: ttl, namespace: _ns);

  int? getInt(String key) => SPUtils.getInt(key, namespace: _ns);

  Future<void> setDouble(String key, double value, {Duration? ttl}) =>
      SPUtils.setDouble(key, value, ttl: ttl, namespace: _ns);

  double? getDouble(String key) => SPUtils.getDouble(key, namespace: _ns);

  Future<void> setStringList(String key, List<String> value, {Duration? ttl}) =>
      SPUtils.setStringList(key, value, ttl: ttl, namespace: _ns);

  List<String>? getStringList(String key) =>
      SPUtils.getStringList(key, namespace: _ns);

  Future<void> writeModel<T>(String key, T model,
      {required Map<String, dynamic> Function(T) toJson, Duration? ttl}) =>
      SPUtils.writeModel(key, model,
          toJson: toJson, ttl: ttl, namespace: _ns);

  T? readModel<T>(String key, T Function(Map<String, dynamic>) fromJson) =>
      SPUtils.readModel(key, fromJson, namespace: _ns);
}
