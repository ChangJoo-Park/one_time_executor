# OneTimeExecutor Secure Storage Adapter

이 패키지는 [one_time_executor](https://github.com/changjoo-park/one_time_executor) 패키지에서 사용할 수 있는 Flutter Secure Storage 어댑터를 제공합니다.

## 설치

```yaml
dependencies:
  one_time_executor: ^0.0.1
  one_time_executor_secure_storage: ^0.0.1
```

## 사용 방법

```dart
import 'package:one_time_executor/one_time_executor.dart';
import 'package:one_time_executor_secure_storage/one_time_executor_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Secure Storage 어댑터 초기화
  await OneTimeExecutor.init(SecureStorageAdapter());

  // 이제 OneTimeExecutor 사용 가능
  await OneTimeExecutor.run('my_key', () async {
    // 한 번만 실행될 작업
  });
}
```

## 커스터마이징

SecureStorage에 저장될 때 사용되는 접두사를 변경할 수 있습니다:

```dart
// 기본 접두사는 'one_time_executor_'입니다.
await OneTimeExecutor.init(SecureStorageAdapter(prefix: 'custom_prefix_'));
```

커스텀 SecureStorage 인스턴스를 사용할 수도 있습니다:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 커스텀 설정으로 SecureStorage 생성
final storage = const FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
);

// 커스텀 SecureStorage 인스턴스 사용
await OneTimeExecutor.init(SecureStorageAdapter(secureStorage: storage));
```

## 플랫폼 지원

이 어댑터는 flutter_secure_storage 패키지를 사용하므로 해당 패키지가 지원하는 모든 플랫폼에서 사용할 수 있습니다:

- iOS
- Android
- macOS
- Windows
- Linux
- Web (실험적)
