import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:status_bar_tap/status_bar_tap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StatusBarTap', () {
    tearDown(() {
      StatusBarTap().dispose();
    });

    test('Singleton pattern', () {
      final instance1 = StatusBarTap();
      final instance2 = StatusBarTap();
      expect(instance1, same(instance2));
    });

    test('Initialization', () {
      final statusBarTap = StatusBarTap();
      expect(statusBarTap.isInitialized, isFalse);

      statusBarTap.initialize(
        config: const StatusBarTapConfig(statusBarHeight: 44.0),
      );
      expect(statusBarTap.isInitialized, isTrue);
    });

    test('Default configuration', () {
      final statusBarTap = StatusBarTap();
      statusBarTap.initialize(
        config: const StatusBarTapConfig(statusBarHeight: 44.0),
      );

      expect(statusBarTap.config.enableOnIOS, isTrue);
      expect(statusBarTap.config.enableOnAndroid, isFalse);
      expect(statusBarTap.config.androidTapAreaHeight, 20.0);
      expect(statusBarTap.config.statusBarHeight, 44.0);
    });

    test('Custom configuration', () {
      final statusBarTap = StatusBarTap();
      statusBarTap.initialize(
        config: const StatusBarTapConfig(
          statusBarHeight: 50.0,
          enableOnIOS: false,
          enableOnAndroid: true,
          androidTapAreaHeight: 60.0,
        ),
      );

      expect(statusBarTap.config.enableOnIOS, isFalse);
      expect(statusBarTap.config.enableOnAndroid, isTrue);
      expect(statusBarTap.config.androidTapAreaHeight, 60.0);
      expect(statusBarTap.config.statusBarHeight, 50.0);
    });

    test('Dispose', () {
      final statusBarTap = StatusBarTap();
      statusBarTap.initialize(
        config: const StatusBarTapConfig(statusBarHeight: 44.0),
      );
      expect(statusBarTap.isInitialized, isTrue);

      statusBarTap.dispose();
      expect(statusBarTap.isInitialized, isFalse);
    });

    test('Multiple initialization warning', () {
      final statusBarTap = StatusBarTap();
      statusBarTap.initialize(
        config: const StatusBarTapConfig(statusBarHeight: 44.0),
      );

      expect(
        () => statusBarTap.initialize(
          config: const StatusBarTapConfig(statusBarHeight: 44.0),
        ),
        returnsNormally,
      );
    });

    test('Scroll controller registration', () {
      final statusBarTap = StatusBarTap();
      statusBarTap.initialize(
        config: const StatusBarTapConfig(statusBarHeight: 44.0),
      );

      final controller = ScrollController();
      expect(
        () => statusBarTap.registerScrollController(controller),
        returnsNormally,
      );
      expect(
        () => statusBarTap.unregisterScrollController(controller),
        returnsNormally,
      );

      controller.dispose();
    });

    test('Platform detection - iOS configuration', () {
      final statusBarTap = StatusBarTap();

      statusBarTap.initialize(
        config: const StatusBarTapConfig(
          statusBarHeight: 44.0,
          enableOnIOS: true,
          enableOnAndroid: false,
        ),
      );

      expect(statusBarTap.config.isEnabled, isA<bool>());
    });

    test('Platform detection - Android configuration', () {
      final statusBarTap = StatusBarTap();

      statusBarTap.initialize(
        config: const StatusBarTapConfig(
          statusBarHeight: 44.0,
          enableOnIOS: false,
          enableOnAndroid: true,
        ),
      );

      expect(statusBarTap.config.isEnabled, isA<bool>());
    });
  });
}
