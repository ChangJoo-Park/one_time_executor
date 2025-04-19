<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# OneTimeExecutor

특정 작업을 앱 라이프사이클 중 한 번만 실행하도록 보장하는 Flutter 패키지입니다.

## 특징

- 특정 키로 구분되는 작업을 한 번만 실행하도록 보장합니다.
- 다양한 저장소 어댑터를 지원합니다.
- 간편한 API로 사용하기 쉽습니다.
- 사용자 정의 저장소 어댑터 구현이 가능합니다.
- 확장성을 위해 외부 스토리지 의존성이 분리되어 있습니다.

## 시작하기

`pubspec.yaml` 파일에 의존성을 추가합니다:

```yaml
dependencies:
  one_time_executor: ^0.0.1
```

필요한 스토리지 어댑터 패키지도 추가합니다:

```yaml
dependencies:
  one_time_executor: ^0.0.1
  # 아래 어댑터 중 하나 또는 여러 개를 선택합니다
  one_time_executor_shared_preferences: ^0.0.1
  one_time_executor_hive: ^0.0.1
  one_time_executor_secure_storage: ^0.0.1
```

그리고 패키지를 가져옵니다:

```dart
import 'package:one_time_executor/one_time_executor.dart';
// 사용할 어댑터도 import 합니다
import 'package:one_time_executor_shared_preferences/one_time_executor_shared_preferences.dart';
```

## 사용 방법

### 초기화

앱 시작 시 OneTimeExecutor를 초기화합니다:

```dart
// SharedPreferences 어댑터 사용 (추가 패키지 필요)
import 'package:one_time_executor_shared_preferences/one_time_executor_shared_preferences.dart';
await OneTimeExecutor.init(SharedPreferencesAdapter());

// 또는 Hive 어댑터 사용 (추가 패키지 필요)
import 'package:one_time_executor_hive/one_time_executor_hive.dart';
await OneTimeExecutor.init(HiveAdapter());

// 또는 SecureStorage 어댑터 사용 (추가 패키지 필요)
import 'package:one_time_executor_secure_storage/one_time_executor_secure_storage.dart';
await OneTimeExecutor.init(SecureStorageAdapter());

// 테스트를 위한 InMemory 어댑터 사용 (기본 패키지에 포함됨)
await OneTimeExecutor.init(InMemoryAdapter());
```

### 한 번만 실행하는 작업 정의

```dart
// "tutorial_shown" 키로 작업이 한 번만 실행되도록 합니다
await OneTimeExecutor.run("tutorial_shown", () async {
  // 튜토리얼 표시 또는 다른 작업 수행
  await showTutorial();
});

// 이미 실행된 작업인지 확인
bool hasShownOnboarding = await OneTimeExecutor.isExecuted("onboarding_shown");

// 작업 실행 상태 초기화
await OneTimeExecutor.reset("feature_announcement");
```

### 고급 사용법

특정 옵션으로 실행:

```dart
// 이미 실행된 작업이라도 forceExecution을 true로 설정하여 강제 실행
await OneTimeExecutor.run(
  "daily_notification",
  () async {
    await showNotification();
  },
  forceExecution: true,
);

// 이미 실행된 작업이라면 건너뛰지만, 실행 기록은 저장하지 않음
await OneTimeExecutor.run(
  "temporary_banner",
  () async {
    await showBanner();
  },
  skipIfExecuted: true,
  forceExecution: true,
);
```

### 사용자 정의 어댑터 구현

자신만의 저장소 어댑터를 구현할 수 있습니다:

```dart
class CustomStorageAdapter implements OneTimeStorageAdapter {
  @override
  Future<void> init() async {
    // 초기화 코드
  }

  @override
  Future<bool?> read(String key) async {
    // 읽기 구현
  }

  @override
  Future<void> remove(String key) async {
    // 삭제 구현
  }

  @override
  Future<void> write(String key, bool value) async {
    // 쓰기 구현
  }
}

// 사용자 정의 어댑터 초기화
await OneTimeExecutor.init(CustomStorageAdapter());
```

## 스토리지 어댑터

이 패키지는 확장성을 위해 다양한 스토리지 백엔드에 대한 의존성을 분리했습니다. 다음과 같은 별도의 어댑터 패키지가 제공됩니다:

- **InMemoryAdapter**: 코어 패키지에 포함됨, 주로 테스트용
- **SharedPreferencesAdapter**: `one_time_executor_shared_preferences` 패키지
- **HiveAdapter**: `one_time_executor_hive` 패키지
- **SecureStorageAdapter**: `one_time_executor_secure_storage` 패키지

각 어댑터 패키지에 대한 자세한 사용법은 해당 패키지의 README를 참조하세요.

## 예제

전체 예제는 `/example` 폴더를 참조하세요.

## 라이선스

MIT
