import 'one_time_storage_adapter.dart';

/// 메모리 기반 저장소 어댑터
///
/// 이 어댑터는 앱이 실행되는 동안만 데이터를 유지합니다.
/// 주로 테스트 목적으로 사용됩니다.
class InMemoryAdapter implements OneTimeStorageAdapter {
  final Map<String, bool> _storage = {};

  @override
  Future<void> init() async {
    // 메모리 어댑터는 특별한 초기화가 필요 없습니다.
  }

  @override
  Future<bool?> read(String key) async {
    return _storage[key];
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> write(String key, bool value) async {
    _storage[key] = value;
  }

  /// 저장소를 초기화합니다.
  void clear() {
    _storage.clear();
  }
}
