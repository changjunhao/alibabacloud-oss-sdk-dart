import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart'
    hide ServerSideEncryptionRule;
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketEncryptionTests', () {
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

    test('testPutBucketEncryption', () async {
      final request = PutBucketEncryptionRequest(
        bucket: bucketName,
        serverSideEncryptionRule: ServerSideEncryptionRule(
          applyServerSideEncryptionByDefault:
              ApplyServerSideEncryptionByDefault(sseAlgorithm: 'AES256'),
        ),
      );
      final result = await expectNoAsyncError(
        () => client.putBucketEncryption(request),
      );
      expect(result.commonProp.statusCode, 200);
    });

    test('testGetBucketEncryption', () async {
      // Put encryption first
      final putRequest = PutBucketEncryptionRequest(
        bucket: bucketName,
        serverSideEncryptionRule: ServerSideEncryptionRule(
          applyServerSideEncryptionByDefault:
              ApplyServerSideEncryptionByDefault(sseAlgorithm: 'AES256'),
        ),
      );
      await expectNoAsyncError(() => client.putBucketEncryption(putRequest));

      // Get encryption
      final getRequest = GetBucketEncryptionRequest(bucket: bucketName);
      final getResult = await expectNoAsyncError(
        () => client.getBucketEncryption(getRequest),
      );
      expect(getResult.commonProp.statusCode, 200);
      expect(
        getResult
            .serverSideEncryptionRule
            ?.applyServerSideEncryptionByDefault
            ?.sseAlgorithm,
        'AES256',
      );
    });

    test('testDeleteBucketEncryption', () async {
      // Put encryption
      final putRequest = PutBucketEncryptionRequest(
        bucket: bucketName,
        serverSideEncryptionRule: ServerSideEncryptionRule(
          applyServerSideEncryptionByDefault:
              ApplyServerSideEncryptionByDefault(sseAlgorithm: 'AES256'),
        ),
      );
      await expectNoAsyncError(() => client.putBucketEncryption(putRequest));

      // Verify encryption is set
      final getResult = await expectNoAsyncError(
        () => client.getBucketEncryption(
          GetBucketEncryptionRequest(bucket: bucketName),
        ),
      );
      expect(
        getResult
            .serverSideEncryptionRule
            ?.applyServerSideEncryptionByDefault
            ?.sseAlgorithm,
        'AES256',
      );

      // Delete encryption
      final deleteRequest = DeleteBucketEncryptionRequest(bucket: bucketName);
      final deleteResult = await expectNoAsyncError(
        () => client.deleteBucketEncryption(deleteRequest),
      );
      expect(deleteResult.commonProp.statusCode, 204);

      // Verify encryption is deleted
      await expectAsyncError(
        () => client.getBucketEncryption(
          GetBucketEncryptionRequest(bucket: bucketName),
        ),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testGetBucketEncryptionFail', () async {
      // Bucket without encryption configured
      final request = GetBucketEncryptionRequest(bucket: bucketName);
      await expectAsyncError(
        () => client.getBucketEncryption(request),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });
  }, skip: BaseTestCase.skipReason);
}
