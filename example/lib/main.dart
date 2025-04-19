import 'package:flutter/material.dart';
import 'package:one_time_executor/one_time_executor.dart';
import 'package:one_time_executor_shared_preferences/one_time_executor_shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferencesAdapter를 사용
  await OneTimeExecutor.init(SharedPreferencesAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneTimeExecutor 예제',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String welcomeMessageKey = 'welcome_message_shown';
  final String tooltipKey = 'tooltip_shown';
  final String dailyReminderKey = 'daily_reminder';

  bool hasShownWelcome = false;
  bool hasShownTooltip = false;
  bool hasSetDailyReminder = false;

  @override
  void initState() {
    super.initState();
    _loadExecutionStatus();
  }

  Future<void> _loadExecutionStatus() async {
    final welcomeExecuted = await OneTimeExecutor.isExecuted(welcomeMessageKey);
    final tooltipExecuted = await OneTimeExecutor.isExecuted(tooltipKey);
    final dailyReminderExecuted = await OneTimeExecutor.isExecuted(
      dailyReminderKey,
    );

    setState(() {
      hasShownWelcome = welcomeExecuted;
      hasShownTooltip = tooltipExecuted;
      hasSetDailyReminder = dailyReminderExecuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OneTimeExecutor 예제'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('사용된 어댑터'),
                      content: const Text(
                        '이 예제는 SharedPreferencesAdapter를 사용합니다.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'OneTimeExecutor 기능 데모',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 환영 메시지 버튼
              _buildExecutionCard(
                title: '환영 메시지',
                subtitle: '앱 사용 시 처음 한 번만 표시되는 환영 메시지',
                isExecuted: hasShownWelcome,
                onExecute: () async {
                  await OneTimeExecutor.run(welcomeMessageKey, () async {
                    await showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('환영합니다!'),
                            content: const Text('이 메시지는 한 번만 표시됩니다.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('확인'),
                              ),
                            ],
                          ),
                    );
                  });
                  await _loadExecutionStatus();
                },
                onReset: () async {
                  await OneTimeExecutor.reset(welcomeMessageKey);
                  await _loadExecutionStatus();
                },
              ),

              const SizedBox(height: 20),

              // 툴팁 버튼
              _buildExecutionCard(
                title: '툴팁',
                subtitle: '새 기능에 대한 도움말을 한 번만 표시',
                isExecuted: hasShownTooltip,
                onExecute: () async {
                  await OneTimeExecutor.run(tooltipKey, () async {
                    final scaffold = ScaffoldMessenger.of(context);
                    scaffold.showSnackBar(
                      const SnackBar(
                        content: Text('이 툴팁은 한 번만 표시됩니다!'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  });
                  await _loadExecutionStatus();
                },
                onReset: () async {
                  await OneTimeExecutor.reset(tooltipKey);
                  await _loadExecutionStatus();
                },
              ),

              const SizedBox(height: 20),

              // 강제 실행 버튼 (forceExecution 옵션 사용)
              _buildExecutionCard(
                title: '일일 알림',
                subtitle: '이미 실행되었어도 강제로 다시 실행 (forceExecution)',
                isExecuted: hasSetDailyReminder,
                onExecute: () async {
                  final wasExecuted = await OneTimeExecutor.run(
                    dailyReminderKey,
                    () async {
                      await showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('일일 알림'),
                              content: const Text(
                                '이 작업은 forceExecution이 true로 설정되어 있어 '
                                '이미 실행되었어도 항상 실행됩니다. '
                                '그러나 실행 상태는 저장됩니다.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                      );
                    },
                    forceExecution: true,
                  );

                  if (wasExecuted) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('이 작업은 이전에 이미 실행되었습니다.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }

                  await _loadExecutionStatus();
                },
                onReset: () async {
                  await OneTimeExecutor.reset(dailyReminderKey);
                  await _loadExecutionStatus();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExecutionCard({
    required String title,
    required String subtitle,
    required bool isExecuted,
    required VoidCallback onExecute,
    required VoidCallback onReset,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(subtitle),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(
                    isExecuted ? '실행됨' : '실행되지 않음',
                    style: TextStyle(
                      color: isExecuted ? Colors.white : Colors.black,
                    ),
                  ),
                  backgroundColor: isExecuted ? Colors.green : Colors.grey[300],
                ),
                const Spacer(),
                ElevatedButton(onPressed: onExecute, child: const Text('실행')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: onReset, child: const Text('초기화')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
