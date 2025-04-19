import 'adapters/one_time_storage_adapter.dart';

/// 특정 작업을 앱 라이프사이클 중 한 번만 실행하도록 보장하는 클래스
///
/// 이 클래스는 사용자가 특정 작업을 앱 라이프사이클 중 한 번만 실행하도록 보장합니다.
/// 어댑터 패턴을 사용하여 다양한 저장소를 지원합니다.
class OneTimeExecutor {
  static OneTimeStorageAdapter? _adapter;

  /// 어댑터가 초기화되지 않았을 때 발생하는 예외
  static final Exception _notInitializedException = Exception(
    '어댑터가 초기화되지 않았습니다. OneTimeExecutor.init()을 먼저 호출하세요.',
  );

  /// 초기화 상태를 나타내는 변수
  static bool get isInitialized => _adapter != null;

  /// 원하는 저장소 어댑터를 설정합니다.
  ///
  /// [adapter] 사용할 저장소 어댑터
  static Future<void> init(OneTimeStorageAdapter adapter) async {
    _adapter = adapter;
    await _adapter!.init();
  }

  /// 주어진 키에 대해 작업이 한 번만 실행되도록 보장합니다.
  ///
  /// [key] 작업을 구분하는 고유 키
  /// [action] 실행할 작업
  /// [skipIfExecuted] true인 경우 이미 실행된 작업이면 건너뜁니다.
  /// [forceExecution] true인 경우 이미 실행된 작업이라도 강제로 실행합니다.
  ///
  /// 작업이 이미 실행된 경우, true를 반환합니다.
  /// 작업이 처음 실행되는 경우, false를 반환합니다.
  static Future<bool> run(
    String key,
    Future<void> Function() action, {
    bool skipIfExecuted = true,
    bool forceExecution = false,
  }) async {
    _checkInitialized();

    final bool? isExecuted = await _adapter!.read(key);

    // 이미 실행된 작업이고 실행을 건너뛰는 경우
    if (isExecuted == true && skipIfExecuted && !forceExecution) {
      return true;
    }

    // 작업 실행
    await action();

    // 강제 실행이 아니고 처음 실행되는 작업인 경우 성공 여부를 저장
    if (!forceExecution && isExecuted != true) {
      await _adapter!.write(key, true);
    }

    return isExecuted == true;
  }

  /// 특정 키에 대한 실행 기록을 삭제합니다.
  ///
  /// [key] 삭제할 실행 기록의 키
  static Future<void> reset(String key) async {
    _checkInitialized();
    await _adapter!.remove(key);
  }

  /// 작업이 이미 실행되었는지 확인합니다.
  ///
  /// [key] 확인할 작업의 키
  /// 작업이 이미 실행된 경우 true를 반환하고, 그렇지 않은 경우 false를 반환합니다.
  static Future<bool> isExecuted(String key) async {
    _checkInitialized();
    return await _adapter!.read(key) ?? false;
  }

  /// 어댑터가 초기화되었는지 확인합니다.
  ///
  /// 초기화되지 않은 경우 예외를 발생시킵니다.
  static void _checkInitialized() {
    if (_adapter == null) {
      throw _notInitializedException;
    }
  }
}
