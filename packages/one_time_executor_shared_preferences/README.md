# OneTimeExecutor SharedPreferences Adapter

이 패키지는 [one_time_executor](https://github.com/changjoo-park/one_time_executor) 패키지에서 사용할 수 있는 SharedPreferences 어댑터를 제공합니다.

## 설치

```yaml
dependencies:
  one_time_executor: ^0.0.1
  one_time_executor_shared_preferences: ^0.0.1
```

## 사용 방법

```dart
import 'package:one_time_executor/one_time_executor.dart';
import 'package:one_time_executor_shared_preferences/one_time_executor_shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences 어댑터 초기화
  await OneTimeExecutor.init(SharedPreferencesAdapter());

  // 이제 OneTimeExecutor 사용 가능
  await OneTimeExecutor.run('my_key', () async {
    // 한 번만 실행될 작업
  });
}
```

## 커스터마이징

SharedPreferences에 저장될 때 사용되는 접두사를 변경할 수 있습니다:

```dart
// 기본 접두사는 'one_time_executor_'입니다.
await OneTimeExecutor.init(SharedPreferencesAdapter(prefix: 'custom_prefix_'));
```
