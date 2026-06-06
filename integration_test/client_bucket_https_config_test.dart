import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketHttpsConfigTests', () {
    late BaseTestCase testCase;
    late Client client;
    late String bucketName;

    setUp(() async {
      testCase = BaseTestCase();
      client = testCase.getDefaultClient();
      bucketName = testCase.randomBucketName();
      await testCase.createBucket(client, bucketName);
    });

    tearDown(() async {
      await testCase.cleanBucket(client, bucketName);
    });

    test('testPutBucketHttpsConfig', () async {
      final request = PutBucketHttpsConfigRequest(
        bucket: bucketName,
        httpsConfiguration: HttpsConfiguration(
          tls: TLS(enable: true, tlsVersions: ['TLSv1.2']),
        ),
      );
      final result = await client.putBucketHttpsConfig(request);
      expect(result.statusCode, equals(200));
    });

    test('testGetBucketHttpsConfig', () async {
      // First set HTTPS config
      final putRequest = PutBucketHttpsConfigRequest(
        bucket: bucketName,
        httpsConfiguration: HttpsConfiguration(
          tls: TLS(enable: true, tlsVersions: ['TLSv1.2']),
        ),
      );
      await client.putBucketHttpsConfig(putRequest);

      // Then get HTTPS config
      final getRequest = GetBucketHttpsConfigRequest(bucket: bucketName);
      final result = await client.getBucketHttpsConfig(getRequest);
      expect(result.statusCode, equals(200));
      expect(result.httpsConfiguration, isNotNull);
      expect(result.httpsConfiguration?.tls, isNotNull);
      expect(result.httpsConfiguration?.tls?.enable, equals(true));
      expect(result.httpsConfiguration?.tls?.tlsVersions, contains('TLSv1.2'));
    });

    test('testGetBucketHttpsConfigFail', () async {
      await expectAsyncError(
        () async {
          final request = GetBucketHttpsConfigRequest(
            bucket: 'non-existent-bucket-${BaseTestCase.randomStr(8)}',
          );
          await client.getBucketHttpsConfig(request);
        },
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });
  }, skip: BaseTestCase.skipReason);
}
