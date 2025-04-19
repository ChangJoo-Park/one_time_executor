import 'package:hive/hive.dart';
import 'package:one_time_executor/one_time_executor.dart';

/// Hive를 사용하는 어댑터
///
/// 이 어댑터는 Hive를 사용하여 데이터를 저장합니다.
class HiveAdapter implements OneTimeStorageAdapter {
  /// Hive 박스 이름
  final String boxName;

  /// Hive 박스 인스턴스
  Box<bool>? _box;

  /// 생성자
  ///
  /// [boxName]은 Hive 박스의 이름을 지정합니다.
  /// 기본값은 'one_time_executor'입니다.
  HiveAdapter({this.boxName = 'one_time_executor'});

  @override
  Future<void> init() async {
    _box = await Hive.openBox<bool>(boxName);
  }

  @override
  Future<bool?> read(String key) async {
    _checkInitialized();
    return _box!.get(key);
  }

  @override
  Future<void> remove(String key) async {
    _checkInitialized();
    await _box!.delete(key);
  }

  @override
  Future<void> write(String key, bool value) async {
    _checkInitialized();
    await _box!.put(key, value);
  }

  /// Hive 박스가 초기화되었는지 확인합니다.
  void _checkInitialized() {
    if (_box == null) {
      throw Exception('HiveAdapter가 초기화되지 않았습니다. init()을 먼저 호출하세요.');
    }
  }

  /// Hive 박스를 닫습니다.
  Future<void> close() async {
    _checkInitialized();
    await _box!.close();
  }
}
