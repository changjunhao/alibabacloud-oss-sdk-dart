import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketRequestPaymentTests', () {
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

    test('testPutBucketRequestPayment', () async {
      final request = PutBucketRequestPaymentRequest(
        bucket: bucketName,
        requestPaymentConfiguration: RequestPaymentConfiguration(
          payer: 'Requester',
        ),
      );
      final result = await client.putBucketRequestPayment(request);
      expect(result.statusCode, equals(200));
    });

    test('testGetBucketRequestPayment', () async {
      // First set request payment
      final putRequest = PutBucketRequestPaymentRequest(
        bucket: bucketName,
        requestPaymentConfiguration: RequestPaymentConfiguration(
          payer: 'Requester',
        ),
      );
      await client.putBucketRequestPayment(putRequest);

      // Then get request payment
      final getRequest = GetBucketRequestPaymentRequest(bucket: bucketName);
      final result = await client.getBucketRequestPayment(getRequest);
      expect(result.statusCode, equals(200));
      expect(result.requestPaymentConfiguration, isNotNull);
      expect(result.requestPaymentConfiguration?.payer, equals('Requester'));
    });

    test('testGetBucketRequestPaymentFail', () async {
      await expectAsyncError(
        () async {
          final request = GetBucketRequestPaymentRequest(
            bucket: 'non-existent-bucket-${BaseTestCase.randomStr(8)}',
          );
          await client.getBucketRequestPayment(request);
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
