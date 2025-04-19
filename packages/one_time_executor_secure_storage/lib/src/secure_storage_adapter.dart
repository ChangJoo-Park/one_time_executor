import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:one_time_executor/one_time_executor.dart';

/// FlutterSecureStorage를 사용하는 어댑터
///
/// 이 어댑터는 기기의 안전한 저장소를 사용하여 데이터를 저장합니다.
class SecureStorageAdapter implements OneTimeStorageAdapter {
  /// FlutterSecureStorage 인스턴스에 사용할 prefix
  final String prefix;

  /// FlutterSecureStorage 인스턴스
  final FlutterSecureStorage _secureStorage;

  /// 생성자
  ///
  /// [prefix]는 저장될 키의 접두사를 지정합니다.
  /// 기본값은 'one_time_executor_'입니다.
  ///
  /// [secureStorage]는 사용자 정의 FlutterSecureStorage 인스턴스를 지정합니다.
  /// 지정하지 않으면 기본 설정으로 새 인스턴스가 생성됩니다.
  SecureStorageAdapter({
    this.prefix = 'one_time_executor_',
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// 실제 저장소에 사용될 키를 생성합니다.
  String _getKey(String key) => '$prefix$key';

  @override
  Future<void> init() async {
    // 특별한 초기화가 필요 없습니다.
  }

  @override
  Future<bool?> read(String key) async {
    final value = await _secureStorage.read(key: _getKey(key));
    if (value == null) {
      return null;
    }
    return value == 'true';
  }

  @override
  Future<void> remove(String key) async {
    await _secureStorage.delete(key: _getKey(key));
  }

  @override
  Future<void> write(String key, bool value) async {
    await _secureStorage.write(key: _getKey(key), value: value.toString());
  }
}
