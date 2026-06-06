import 'dart:io';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/credentials/environment_credentials_provider.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('EnvironmentCredentialsProvider Tests', () {
    test('testSuccess', () async {
      // This test needs to be run with environment variables set
      // We'll test the functionality by checking if environment variables exist
      // and the provider can read them correctly

      // Check if test environment variables are set
      final accessKeyId = Platform.environment['OSS_ACCESS_KEY_ID'];
      final accessKeySecret = Platform.environment['OSS_ACCESS_KEY_SECRET'];
      final securityToken = Platform.environment['OSS_SESSION_TOKEN'];

      if (accessKeyId != null && accessKeySecret != null) {
        final provider = EnvironmentCredentialsProvider();
        final cred = await provider.getCredentials();

        expect(cred.accessKeyId, equals(accessKeyId));
        expect(cred.accessKeySecret, equals(accessKeySecret));
        expect(cred.securityToken, equals(securityToken));
      } else {
        // Test error case when environment variables are not set
        final provider = EnvironmentCredentialsProvider();

        expect(
          () async => await provider.getCredentials(),
          throwsA(isA<ClientError>()),
        );
      }
    });

    test('testMissingEnvironmentVariables', () async {
      // This test assumes no OSS environment variables are set
      // If they are set, we skip this test
      final accessKeyId = Platform.environment['OSS_ACCESS_KEY_ID'];
      final accessKeySecret = Platform.environment['OSS_ACCESS_KEY_SECRET'];

      if (accessKeyId == null || accessKeySecret == null) {
        final provider = EnvironmentCredentialsProvider();

        expect(
          () async => await provider.getCredentials(),
          throwsA(isA<ClientError>()),
        );
      }
    });
  });
}
