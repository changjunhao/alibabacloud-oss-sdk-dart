import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketAccessMonitorTests', () {
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

    test('testPutBucketAccessMonitor', () async {
      final request = PutBucketAccessMonitorRequest(
        bucket: bucketName,
        accessMonitorConfiguration: AccessMonitorConfiguration(
          status: AccessMonitorStatus.enabled,
        ),
      );
      final result = await client.putBucketAccessMonitor(request);
      expect(result.statusCode, equals(200));
    });

    test('testGetBucketAccessMonitor', () async {
      // First enable access monitor
      final putRequest = PutBucketAccessMonitorRequest(
        bucket: bucketName,
        accessMonitorConfiguration: AccessMonitorConfiguration(
          status: AccessMonitorStatus.enabled,
        ),
      );
      await client.putBucketAccessMonitor(putRequest);

      // Then get access monitor
      final getRequest = GetBucketAccessMonitorRequest(bucket: bucketName);
      final result = await client.getBucketAccessMonitor(getRequest);
      expect(result.statusCode, equals(200));
      expect(
        result.accessMonitorConfiguration?.status,
        equals(AccessMonitorStatus.enabled),
      );
    });

    test('testGetBucketAccessMonitorFail', () async {
      await expectAsyncError(
        () async {
          final request = GetBucketAccessMonitorRequest(
            bucket: 'non-existent-bucket-${BaseTestCase.randomStr(8)}',
          );
          await client.getBucketAccessMonitor(request);
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
