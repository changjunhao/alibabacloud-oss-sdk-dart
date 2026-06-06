import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/credentials/credentials.dart';

void main() {
  group('Credentials Tests', () {
    test('testCredentials', () {
      var cred = const Credentials(accessKeyId: 'ak', accessKeySecret: 'sk');
      expect(cred.accessKeyId, equals('ak'));
      expect(cred.accessKeySecret, equals('sk'));
      expect(cred.securityToken, isNull);
      expect(cred.expiration, isNull);
      expect(cred.isEmpty(), isFalse);
      expect(cred.isExpired, isFalse);

      cred = const Credentials(
        accessKeyId: 'ak',
        accessKeySecret: 'sk',
        securityToken: 'token',
      );
      expect(cred.accessKeyId, equals('ak'));
      expect(cred.accessKeySecret, equals('sk'));
      expect(cred.securityToken, equals('token'));
      expect(cred.expiration, isNull);
    });
  });
}
