import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_time_executor/one_time_executor.dart';

/// SharedPreferences를 사용하는 어댑터
///
/// 이 어댑터는 기기의 SharedPreferences를 사용하여 데이터를 저장합니다.
class SharedPreferencesAdapter implements OneTimeStorageAdapter {
  /// SharedPreferences 인스턴스에 사용할 prefix
  ///
  /// 다른 데이터와 충돌을 방지하기 위해 사용됩니다.
  final String prefix;

  /// SharedPreferences 인스턴스
  SharedPreferences? _prefs;

  /// 생성자
  ///
  /// [prefix]는 SharedPreferences에 저장될 키의 접두사를 지정합니다.
  /// 기본값은 'one_time_executor_'입니다.
  SharedPreferencesAdapter({this.prefix = 'one_time_executor_'});

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 실제 저장소에 사용될 키를 생성합니다.
  String _getKey(String key) => '$prefix$key';

  @override
  Future<bool?> read(String key) async {
    _checkInitialized();
    final actualKey = _getKey(key);
    if (_prefs!.containsKey(actualKey)) {
      return _prefs!.getBool(actualKey);
    }
    return null;
  }

  @override
  Future<void> remove(String key) async {
    _checkInitialized();
    await _prefs!.remove(_getKey(key));
  }

  @override
  Future<void> write(String key, bool value) async {
    _checkInitialized();
    await _prefs!.setBool(_getKey(key), value);
  }

  /// SharedPreferences가 초기화되었는지 확인합니다.
  void _checkInitialized() {
    if (_prefs == null) {
      throw Exception(
        'SharedPreferencesAdapter가 초기화되지 않았습니다. init()을 먼저 호출하세요.',
      );
    }
  }
}
