import 'dart:async';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/internal/expiring_value.dart';

void main() {
  group('ExpiringValue Tests', () {
    /// Test value returned from closure is given back
    test('testValue', () async {
      final expiringValue = ExpiringValue<int>();
      final value = await expiringValue.getValue(() async {
        await Future.delayed(const Duration(microseconds: 1));
        return (1, DateTime.now());
      });
      expect(value, equals(1));
    });

    /// Test an expired value is updated
    test('testExpiredValue', () async {
      final expiringValue = ExpiringValue<int>.withValue(
        0,
        DateTime.now().subtract(const Duration(seconds: 1)),
      );
      final value = await expiringValue.getValue(() async {
        await Future.delayed(const Duration(microseconds: 1));
        return (1, DateTime.now());
      });
      expect(value, equals(1));
    });

    /// Test when a value is just about to expire it returns current value and kicks off
    /// new task to get new value
    test('testJustAboutToExpireValue', () async {
      final expiringValue = ExpiringValue<int>.withValue(
        0,
        DateTime.now().add(const Duration(milliseconds: 100)),
        threshold: const Duration(seconds: 3),
      );

      final streamController = StreamController<void>();
      final value = await expiringValue.getValue(() async {
        streamController.add(null);
        await Future.delayed(const Duration(microseconds: 1));
        return (1, DateTime.now());
      });

      // Wait for the stream to receive the signal
      await streamController.stream.first;
      streamController.close();

      // test it returns current value
      expect(value, equals(0));
    });

    /// Test closure is not called if value has not expired
    test('testClosureNotCalled', () async {
      bool called = false;
      final expiringValue = ExpiringValue<int>.withValue(
        0,
        DateTime.now().add(const Duration(days: 365)), // distant future
        threshold: const Duration(seconds: 1),
      );

      final value = await expiringValue.getValue(() async {
        called = true;
        await Future.delayed(const Duration(microseconds: 1));
        return (1, DateTime.now());
      });

      expect(value, equals(0));
      expect(called, isFalse);
    });

    /// Test closure is only called once even though we asked for value 100 times
    test('testClosureCalledOnce', () async {
      int callCount = 0;
      final expiringValue = ExpiringValue<int>();

      final futures = <Future<int>>[];
      for (int i = 0; i < 100; i++) {
        futures.add(
          expiringValue.getValue(() async {
            callCount++;
            await Future.delayed(const Duration(milliseconds: 10));
            return (123, DateTime.now().add(const Duration(days: 365)));
          }),
        );
      }

      final results = await Future.wait(futures);

      for (final result in results) {
        expect(result, equals(123));
      }

      expect(callCount, equals(1));
    });

    /// Test value returned from initial closure is given back
    test('testInitialClosure', () async {
      final expiringValue = ExpiringValue<int>.withAsyncValue(
        getExpiringValue: () async {
          await Future.delayed(const Duration(microseconds: 1));
          return (1, DateTime.now().add(const Duration(seconds: 3)));
        },
      );

      final value = await expiringValue.getValue(() async {
        return (2, DateTime.now());
      });

      expect(value, equals(1));
    });

    /// Test error handling
    test('testErrorHandling', () async {
      final expiringValue = ExpiringValue<int>();

      expect(
        () => expiringValue.getValue(() async {
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );
    });

    /// Test cancel operation
    test('testCancel', () async {
      final expiringValue = ExpiringValue<int>();

      // Start a getValue operation
      final future = expiringValue.getValue(() async {
        await Future.delayed(const Duration(seconds: 1));
        return (1, DateTime.now());
      });

      // Cancel the operation
      expiringValue.cancel();

      expect(() => future, throwsA(isA<Exception>()));
    });

    /// Test threshold behavior
    test('testThresholdBehavior', () async {
      final threshold = const Duration(milliseconds: 500);
      final expiringValue = ExpiringValue<int>.withValue(
        42,
        DateTime.now().add(const Duration(milliseconds: 100)), // expires soon
        threshold: threshold,
      );

      bool refreshCalled = false;
      final value = await expiringValue.getValue(() async {
        refreshCalled = true;
        await Future.delayed(const Duration(milliseconds: 10));
        return (99, DateTime.now().add(const Duration(seconds: 10)));
      });

      // Should return current value but trigger refresh
      expect(value, equals(42));

      // Give some time for the refresh to complete
      await Future.delayed(const Duration(milliseconds: 50));
      expect(refreshCalled, isTrue);
    });
  });
}
