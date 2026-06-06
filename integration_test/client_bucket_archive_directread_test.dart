import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketArchiveDirectreadTests', () {
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

    test('testPutBucketArchiveDirectRead', () async {
      final request = PutBucketArchiveDirectReadRequest(
        bucket: bucketName,
        archiveDirectReadConfiguration: ArchiveDirectReadConfiguration(
          enabled: true,
        ),
      );
      final result = await client.putBucketArchiveDirectRead(request);
      expect(result.statusCode, equals(200));
    });

    test('testGetBucketArchiveDirectRead', () async {
      // First enable archive direct read
      final putRequest = PutBucketArchiveDirectReadRequest(
        bucket: bucketName,
        archiveDirectReadConfiguration: ArchiveDirectReadConfiguration(
          enabled: true,
        ),
      );
      await client.putBucketArchiveDirectRead(putRequest);

      // Then get archive direct read
      final getRequest = GetBucketArchiveDirectReadRequest(bucket: bucketName);
      final result = await client.getBucketArchiveDirectRead(getRequest);
      expect(result.statusCode, equals(200));
      expect(result.archiveDirectReadConfiguration?.enabled, equals(true));
    });

    test('testGetBucketArchiveDirectReadFail', () async {
      await expectAsyncError(
        () async {
          final request = GetBucketArchiveDirectReadRequest(
            bucket: 'non-existent-bucket-${BaseTestCase.randomStr(8)}',
          );
          await client.getBucketArchiveDirectRead(request);
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
