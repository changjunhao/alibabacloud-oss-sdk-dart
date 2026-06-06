import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketTransferAccelerationTests', () {
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

    test('testPutBucketTransferAcceleration', () async {
      final request = PutBucketTransferAccelerationRequest(
        bucket: bucketName,
        transferAccelerationConfiguration: TransferAccelerationConfiguration(
          enabled: true,
        ),
      );
      final result = await client.putBucketTransferAcceleration(request);
      expect(result.statusCode, equals(200));
    });

    test('testGetBucketTransferAcceleration', () async {
      // First enable transfer acceleration
      final putRequest = PutBucketTransferAccelerationRequest(
        bucket: bucketName,
        transferAccelerationConfiguration: TransferAccelerationConfiguration(
          enabled: true,
        ),
      );
      await client.putBucketTransferAcceleration(putRequest);

      // Then get transfer acceleration
      final getRequest = GetBucketTransferAccelerationRequest(
        bucket: bucketName,
      );
      final result = await client.getBucketTransferAcceleration(getRequest);
      expect(result.statusCode, equals(200));
      expect(result.transferAccelerationConfiguration, isNotNull);
      expect(result.transferAccelerationConfiguration?.enabled, equals(true));
    });

    test('testGetBucketTransferAccelerationFail', () async {
      await expectAsyncError(
        () async {
          final request = GetBucketTransferAccelerationRequest(
            bucket: 'non-existent-bucket-${BaseTestCase.randomStr(8)}',
          );
          await client.getBucketTransferAcceleration(request);
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
