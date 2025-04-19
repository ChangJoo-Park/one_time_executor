/// 다양한 저장소를 위한 어댑터 인터페이스
///
/// 이 추상 클래스는 저장소에서 값을 읽고 쓰고 삭제하는 메서드를 정의합니다.
/// 사용자는 이 클래스를 구현하여 원하는 저장소를 사용할 수 있습니다.
abstract class OneTimeStorageAdapter {
  /// 특정 키에 대한 값을 저장합니다.
  ///
  /// [key] 저장할 키
  /// [value] 저장할 값
  Future<void> write(String key, bool value);

  /// 특정 키에 대한 값을 읽어옵니다.
  ///
  /// [key] 읽을 키
  /// 키가 존재하지 않는 경우 null을 반환합니다.
  Future<bool?> read(String key);

  /// 특정 키에 대한 값을 삭제합니다.
  ///
  /// [key] 삭제할 키
  Future<void> remove(String key);

  /// 어댑터 초기화 메서드
  ///
  /// 필요한 경우 이 메서드를 오버라이드하여 초기화 작업을 수행합니다.
  Future<void> init() async {
    // 기본 구현은 아무것도 하지 않습니다.
  }
}
