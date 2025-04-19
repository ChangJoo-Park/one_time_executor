# OneTimeExecutor Hive Adapter

이 패키지는 [one_time_executor](https://github.com/changjoo-park/one_time_executor) 패키지에서 사용할 수 있는 Hive 어댑터를 제공합니다.

## 설치

```yaml
dependencies:
  one_time_executor: ^0.0.1
  one_time_executor_hive: ^0.0.1
```

## 사용 방법

Hive를 사용하기 전에 반드시 초기화해야 합니다:

```dart
import 'package:one_time_executor/one_time_executor.dart';
import 'package:one_time_executor_hive/one_time_executor_hive.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Hive 어댑터 초기화
  await OneTimeExecutor.init(HiveAdapter());

  // 이제 OneTimeExecutor 사용 가능
  await OneTimeExecutor.run('my_key', () async {
    // 한 번만 실행될 작업
  });
}
```

## 커스터마이징

Hive 박스 이름을 변경할 수 있습니다:

```dart
// 기본 박스 이름은 'one_time_executor'입니다.
await OneTimeExecutor.init(HiveAdapter(boxName: 'custom_box_name'));
```

## 정리

어댑터를 더 이상 사용하지 않을 때 박스를 닫을 수 있습니다:

```dart
final hiveAdapter = HiveAdapter();
await OneTimeExecutor.init(hiveAdapter);

// 사용 후 정리
await hiveAdapter.close();
```
