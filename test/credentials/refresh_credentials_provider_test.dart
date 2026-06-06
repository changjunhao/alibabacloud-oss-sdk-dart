import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/credentials/refresh_credentials_provider.dart';
import 'package:alibabacloud_oss_sdk_dart/src/credentials/static_credentials_provider.dart';
import 'package:alibabacloud_oss_sdk_dart/src/credentials/credentials.dart';

void main() {

  setUp(() {
  });

  group('RefreshCredentialsProvider Tests', () {
    test('testClosureWithoutExpiration', () async {
      final credentialsProvider = RefreshCredentialsProvider.fromClosure(
        closure: () async {
          return const Credentials(
            accessKeyId: 'ak',
            accessKeySecret: 'sk',
          );
        },
      );
      final token = await credentialsProvider.getCredentials();
      expect(token.accessKeyId, equals('ak'));
      expect(token.accessKeySecret, equals('sk'));
      expect(token.securityToken, isNull);
      expect(token.expiration, isNull);
      expect(token.isExpired, isFalse);
    });

    test('testClosureWithExpiration', () async {
      var credentialsProvider = RefreshCredentialsProvider.fromClosure(
        closure: () async {
          return Credentials(
            accessKeyId: 'ak',
            accessKeySecret: 'sk',
            securityToken: 'token',
            expiration: DateTime.now().add(const Duration(minutes: 10)),
          );
        },
      );
      var token = await credentialsProvider.getCredentials();
      expect(token.accessKeyId, equals('ak'));
      expect(token.accessKeySecret, equals('sk'));
      expect(token.securityToken, equals('token'));
      expect(token.expiration, isNotNull);
      expect(token.isExpired, isFalse);

      credentialsProvider = RefreshCredentialsProvider.fromClosure(
        closure: () async {
          return Credentials(
            accessKeyId: 'ak-1',
            accessKeySecret: 'sk-1',
            securityToken: 'token-1',
            expiration: DateTime.now().add(const Duration(seconds: 1)),
          );
        },
      );
      token = await credentialsProvider.getCredentials();
      expect(token.accessKeyId, equals('ak-1'));
      expect(token.accessKeySecret, equals('sk-1'));
      expect(token.securityToken, equals('token-1'));
      expect(token.expiration, isNotNull);
      expect(token.isExpired, isFalse);
      
      // Wait for token to expire
      await Future.delayed(const Duration(seconds: 3));
      expect(token.isExpired, isTrue);
    });

    test('testProviderWithoutExpiration', () async {
      final credentialsProvider = RefreshCredentialsProvider(
        provider: StaticCredentialsProvider(
          accessKeyId: 'ak',
          accessKeySecret: 'sk',
        ),
      );
      final token = await credentialsProvider.getCredentials();
      expect(token.accessKeyId, equals('ak'));
      expect(token.accessKeySecret, equals('sk'));
      expect(token.securityToken, isNull);
      expect(token.expiration, isNull);
      expect(token.isExpired, isFalse);
    });

    test('testExpirationGreaterThanRefreshInterval', () async {
      final counter = Counter();
      final expiration = DateTime.now().add(const Duration(hours: 1));
      final credentialsProvider = RefreshCredentialsProvider.fromClosure(
        closure: () async {
          final count = await counter.getCount();
          final cred = Credentials(
            accessKeyId: 'ak-$count',
            accessKeySecret: 'sk-$count',
            securityToken: 'token-$count',
            expiration: expiration,
          );
          await counter.increment();
          return cred;
        },
      );

      var testCount = 0;
      for (int i = 0; i < 30; i++) {
        final token = await credentialsProvider.getCredentials();
        expect(token.accessKeyId, equals('ak-0'));
        expect(token.accessKeySecret, equals('sk-0'));
        expect(token.securityToken, equals('token-0'));
        expect(token.expiration, equals(expiration));
        testCount++;
      }
      expect(testCount, equals(30));
      final count = await counter.getCount();
      expect(count, equals(1));
    });

    test('testExpirationLessThanRefreshInterval', () async {
      // default refreshInterval is 5 * 60
      final counter = Counter();
      final expiration = DateTime.now().add(const Duration(minutes: 4));
      final credentialsProvider = RefreshCredentialsProvider.fromClosure(
        closure: () async {
          final count = await counter.getCount();
          final cred = Credentials(
            accessKeyId: 'ak-$count',
            accessKeySecret: 'sk-$count',
            securityToken: 'token-$count',
            expiration: expiration,
          );
          await counter.increment();
          return cred;
        },
      );

      var cred = await credentialsProvider.getCredentials();
      expect(cred.accessKeyId, equals('ak-0'));
      expect(cred.accessKeySecret, equals('sk-0'));
      expect(cred.securityToken, equals('token-0'));
      expect(cred.expiration, equals(expiration));

      var testCount = 0;
      for (int i = 0; i < 30; i++) {
        cred = await credentialsProvider.getCredentials();
        expect(cred.accessKeyId, equals('ak-$testCount'));
        expect(cred.accessKeySecret, equals('sk-$testCount'));
        expect(cred.securityToken, equals('token-$testCount'));
        expect(cred.expiration, equals(expiration));
        testCount++;
        await Future.delayed(const Duration(milliseconds: 200)); // sleep 0.2 second
      }
      expect(testCount, equals(30));
      final count = await counter.getCount();
      expect(count, equals(31));
    });

    test('testUpdateDefaultRefreshInterval', () async {
      // default refreshInterval is 5 * 60
      final counter = Counter();
      final expiration0 = DateTime.now().add(const Duration(minutes: 4));
      final expiration1 = DateTime.now().add(const Duration(hours: 1));
      final credentialsProvider = RefreshCredentialsProvider.fromClosure(
        closure: () async {
          final count = await counter.getCount();
          Credentials cred;
          if (count == 0) {
            cred = Credentials(
              accessKeyId: 'ak-$count',
              accessKeySecret: 'sk-$count',
              securityToken: 'token-$count',
              expiration: expiration0,
            );
          } else {
            cred = Credentials(
              accessKeyId: 'ak-$count',
              accessKeySecret: 'sk-$count',
              securityToken: 'token-$count',
              expiration: expiration1,
            );
          }
          await counter.increment();
          return cred;
        },
      );

      // 1st
      var cred = await credentialsProvider.getCredentials();
      expect(cred.accessKeyId, equals('ak-0'));
      expect(cred.accessKeySecret, equals('sk-0'));
      expect(cred.securityToken, equals('token-0'));
      expect(cred.expiration, equals(expiration0));

      // 2nd in cache
      cred = await credentialsProvider.getCredentials();
      expect(cred.accessKeyId, equals('ak-0'));
      expect(cred.accessKeySecret, equals('sk-0'));
      expect(cred.securityToken, equals('token-0'));
      expect(cred.expiration, equals(expiration0));

      // wait task done
      await Future.delayed(const Duration(milliseconds: 200)); // sleep 0.2 second

      var testCount = 0;
      for (int i = 0; i < 30; i++) {
        cred = await credentialsProvider.getCredentials();
        expect(cred.accessKeyId, equals('ak-1'));
        expect(cred.accessKeySecret, equals('sk-1'));
        expect(cred.securityToken, equals('token-1'));
        expect(cred.expiration, equals(expiration1));
        testCount++;
      }
      expect(testCount, equals(30));
      final count = await counter.getCount();
      expect(count, equals(2));
    });

    test('testConcurrencyGetCredentials', () async {
      // default refreshInterval is 5 * 60
      final counter = Counter();
      final expiration0 = DateTime.now().add(const Duration(hours: 1)); // Use longer expiration to avoid refresh
      final expiration1 = DateTime.now().add(const Duration(hours: 2));
      final credentialsProvider = RefreshCredentialsProvider.fromClosure(
        closure: () async {
          final count = await counter.getCount();
          Credentials cred;
          if (count == 0) {
            cred = Credentials(
              accessKeyId: 'ak-$count',
              accessKeySecret: 'sk-$count',
              securityToken: 'token-$count',
              expiration: expiration0,
            );
          } else {
            cred = Credentials(
              accessKeyId: 'ak-$count',
              accessKeySecret: 'sk-$count',
              securityToken: 'token-$count',
              expiration: expiration1,
            );
          }
          await counter.increment();
          return cred;
        },
      );

      // First get credentials to initialize
      var initialCred = await credentialsProvider.getCredentials();
      expect(initialCred.accessKeyId, equals('ak-0'));

      // run concurrent tasks for a short time
      final task0 = Future(() async {
        for (int i = 0; i < 10; i++) {
          final cred = await credentialsProvider.getCredentials();
          expect(cred.accessKeyId, equals('ak-0'));
          expect(cred.accessKeySecret, equals('sk-0'));
          expect(cred.securityToken, equals('token-0'));
          expect(cred.expiration, equals(expiration0));
          await Future.delayed(const Duration(milliseconds: 10));
        }
      });
      final task1 = Future(() async {
        for (int i = 0; i < 10; i++) {
          final cred = await credentialsProvider.getCredentials();
          expect(cred.accessKeyId, equals('ak-0'));
          expect(cred.accessKeySecret, equals('sk-0'));
          expect(cred.securityToken, equals('token-0'));
          expect(cred.expiration, equals(expiration0));
          await Future.delayed(const Duration(milliseconds: 10));
        }
      });
      await Future.wait([task0, task1]);

      // Verify only one credential was created
      final count = await counter.getCount();
      expect(count, equals(1));
    });
  });
}

/// A simple counter class for testing
class Counter {
  int _count = 0;

  void setCount(int count) {
    _count = count;
  }

  Future<void> increment() async {
    _count++;
  }

  Future<int> getCount() async {
    return _count;
  }
}