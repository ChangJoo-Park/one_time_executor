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

A Flutter package that ensures specific tasks are executed only once during the app lifecycle.

## Features

- Guarantees that tasks identified by specific keys run only once
- Supports various storage adapters
- Easy to use with a simple API
- Allows custom storage adapter implementation
- External storage dependencies are separated for extensibility

## Getting Started

Add the dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  one_time_executor: ^0.0.1
```

Also add the required storage adapter package:

```yaml
dependencies:
  one_time_executor: ^0.0.1
  # Choose one or more of the adapters below
  one_time_executor_shared_preferences: ^0.0.1
  one_time_executor_hive: ^0.0.1
  one_time_executor_secure_storage: ^0.0.1
```

Then import the package:

```dart
import 'package:one_time_executor/one_time_executor.dart';
// Also import the adapter you want to use
import 'package:one_time_executor_shared_preferences/one_time_executor_shared_preferences.dart';
```

## Usage

### Initialization

Initialize the OneTimeExecutor when your app starts:

```dart
// Using SharedPreferences adapter (requires additional package)
import 'package:one_time_executor_shared_preferences/one_time_executor_shared_preferences.dart';
await OneTimeExecutor.init(SharedPreferencesAdapter());

// Or using Hive adapter (requires additional package)
import 'package:one_time_executor_hive/one_time_executor_hive.dart';
await OneTimeExecutor.init(HiveAdapter());

// Or using SecureStorage adapter (requires additional package)
import 'package:one_time_executor_secure_storage/one_time_executor_secure_storage.dart';
await OneTimeExecutor.init(SecureStorageAdapter());

// Using InMemory adapter for testing (included in the core package)
await OneTimeExecutor.init(InMemoryAdapter());
```

### Defining Tasks to Run Once

```dart
// Ensure a task runs only once with the key "tutorial_shown"
await OneTimeExecutor.run("tutorial_shown", () async {
  // Show tutorial or perform other task
  await showTutorial();
});

// Check if a task has already been executed
bool hasShownOnboarding = await OneTimeExecutor.isExecuted("onboarding_shown");

// Reset the execution state of a task
await OneTimeExecutor.reset("feature_announcement");
```

### Advanced Usage

Run with specific options:

```dart
// Force execution even if the task has been run before by setting forceExecution to true
await OneTimeExecutor.run(
  "daily_notification",
  () async {
    await showNotification();
  },
  forceExecution: true,
);

// Skip if already executed but don't store execution record
await OneTimeExecutor.run(
  "temporary_banner",
  () async {
    await showBanner();
  },
  skipIfExecuted: true,
  forceExecution: true,
);
```

### Custom Adapter Implementation

You can implement your own storage adapter:

```dart
class CustomStorageAdapter implements OneTimeStorageAdapter {
  @override
  Future<void> init() async {
    // Initialization code
  }

  @override
  Future<bool?> read(String key) async {
    // Read implementation
  }

  @override
  Future<void> remove(String key) async {
    // Remove implementation
  }

  @override
  Future<void> write(String key, bool value) async {
    // Write implementation
  }
}

// Initialize with custom adapter
await OneTimeExecutor.init(CustomStorageAdapter());
```

## Storage Adapters

This package separates dependencies for different storage backends for extensibility. The following separate adapter packages are available:

- **InMemoryAdapter**: Included in the core package, mainly for testing
- **SharedPreferencesAdapter**: In the `one_time_executor_shared_preferences` package
- **HiveAdapter**: In the `one_time_executor_hive` package
- **SecureStorageAdapter**: In the `one_time_executor_secure_storage` package

For detailed usage of each adapter package, refer to the README of the respective package.

## Examples

See the `/example` folder for a complete example.

## License

MIT
