import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/credentials/anonymous_credentials_provider.dart';

void main() {
  group('AnonymousCredentialsProvider Tests', () {
    test('testAnonymousCredentialsProvider', () async {
      final credentialsProvider = AnonymousCredentialsProvider();
      final credentials = await credentialsProvider.getCredentials();

      expect(credentials.accessKeyId, equals(''));
      expect(credentials.accessKeySecret, equals(''));
      expect(credentials.securityToken, isNull);
      expect(credentials.expiration, isNull);
    });
  });
}
