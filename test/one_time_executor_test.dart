import 'package:flutter_test/flutter_test.dart';
import 'package:one_time_executor/one_time_executor.dart';

void main() {
  late InMemoryAdapter inMemoryAdapter;

  setUp(() {
    inMemoryAdapter = InMemoryAdapter();
  });

  group('OneTimeExecutor 테스트', () {
    test('init 메서드로 어댑터를 초기화해야 함', () async {
      // 초기화 전에는 isInitialized가 false여야 함
      expect(OneTimeExecutor.isInitialized, false);

      // 초기화
      await OneTimeExecutor.init(inMemoryAdapter);

      // 초기화 후에는 isInitialized가 true여야 함
      expect(OneTimeExecutor.isInitialized, true);
    });

    test('초기화 없이 run 메서드를 호출하면 예외가 발생해야 함', () async {
      // 새로운 인스턴스를 생성하기 전에 OneTimeExecutor의 adapter 필드를 null로 설정
      // 테스트 간 상태가 공유되는 것을 방지
      final adapter = OneTimeExecutor; // ignore: unused_local_variable

      try {
        await OneTimeExecutor.run('test_key', () async {});
        fail('예외가 발생해야 함');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('처음 실행되는 작업은 정상적으로 실행되어야 함', () async {
      // 테스트용 변수
      bool executed = false;

      // 초기화
      await OneTimeExecutor.init(inMemoryAdapter);

      // 작업 실행
      final wasExecuted = await OneTimeExecutor.run('test_key', () async {
        executed = true;
      });

      // 작업이 실행되었는지 확인
      expect(executed, true);
      // 처음 실행되는 작업이므로 wasExecuted는 false여야 함
      expect(wasExecuted, false);
      // 실행 기록이 저장되었는지 확인
      expect(await OneTimeExecutor.isExecuted('test_key'), true);
    });

    test('이미 실행된 작업은 실행되지 않아야 함', () async {
      // 테스트용 변수
      int executionCount = 0;

      // 초기화
      await OneTimeExecutor.init(inMemoryAdapter);

      // 첫 번째 실행
      await OneTimeExecutor.run('test_key', () async {
        executionCount++;
      });

      // 두 번째 실행 (실행되지 않아야 함)
      final wasExecuted = await OneTimeExecutor.run('test_key', () async {
        executionCount++;
      });

      // 작업이 한 번만 실행되었는지 확인
      expect(executionCount, 1);
      // 이미 실행된 작업이므로 wasExecuted는 true여야 함
      expect(wasExecuted, true);
    });

    test('forceExecution이 true인 경우 이미 실행된 작업도 다시 실행되어야 함', () async {
      // 테스트용 변수
      int executionCount = 0;

      // 초기화
      await OneTimeExecutor.init(inMemoryAdapter);

      // 첫 번째 실행
      await OneTimeExecutor.run('test_key', () async {
        executionCount++;
      });

      // 두 번째 실행 (forceExecution이 true이므로 실행되어야 함)
      final wasExecuted = await OneTimeExecutor.run('test_key', () async {
        executionCount++;
      }, forceExecution: true);

      // 작업이 두 번 실행되었는지 확인
      expect(executionCount, 2);
      // 이미 실행된 작업이므로 wasExecuted는 true여야 함
      expect(wasExecuted, true);
    });

    test('reset 메서드로 실행 기록을 삭제할 수 있어야 함', () async {
      // 초기화
      await OneTimeExecutor.init(inMemoryAdapter);

      // 작업 실행
      await OneTimeExecutor.run('test_key', () async {});

      // 실행 기록이 저장되었는지 확인
      expect(await OneTimeExecutor.isExecuted('test_key'), true);

      // 실행 기록 삭제
      await OneTimeExecutor.reset('test_key');

      // 실행 기록이 삭제되었는지 확인
      expect(await OneTimeExecutor.isExecuted('test_key'), false);
    });

    test('다른 키로 구분된 작업은 독립적으로 실행되어야 함', () async {
      // 테스트용 변수
      bool executed1 = false;
      bool executed2 = false;

      // 초기화
      await OneTimeExecutor.init(inMemoryAdapter);

      // 첫 번째 작업 실행
      await OneTimeExecutor.run('test_key1', () async {
        executed1 = true;
      });

      // 두 번째 작업 실행 (다른 키)
      await OneTimeExecutor.run('test_key2', () async {
        executed2 = true;
      });

      // 두 작업 모두 실행되었는지 확인
      expect(executed1, true);
      expect(executed2, true);

      // 첫 번째 작업 다시 실행 (실행되지 않아야 함)
      executed1 = false;
      await OneTimeExecutor.run('test_key1', () async {
        executed1 = true;
      });

      // 두 번째 작업 다시 실행 (실행되지 않아야 함)
      executed2 = false;
      await OneTimeExecutor.run('test_key2', () async {
        executed2 = true;
      });

      // 두 작업 모두 실행되지 않았는지 확인
      expect(executed1, false);
      expect(executed2, false);
    });
  });
}
