import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/credentials/static_credentials_provider.dart';
import 'package:alibabacloud_oss_sdk_dart/src/credentials/credentials.dart';

void main() {
  group('StaticCredentialsProvider Tests', () {
    test('testOSSStsTokenCredentialsProvider', () async {
      final credentials = Credentials(
        accessKeyId: 'accessKey',
        accessKeySecret: 'secretKey',
        securityToken: 'token',
        expiration: null,
      );
      final credentialsProvider = StaticCredentialsProvider(
        accessKeyId: credentials.accessKeyId,
        accessKeySecret: credentials.accessKeySecret,
        securityToken: credentials.securityToken,
      );
      final token = await credentialsProvider.getCredentials();
      expect(token.accessKeyId, equals(credentials.accessKeyId));
      expect(token.accessKeySecret, equals(credentials.accessKeySecret));
      expect(token.securityToken, equals(credentials.securityToken));
    });
  });
}