import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketPublicAccessBlockTests', () {
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

    test('testPutBucketPublicAccessBlock', () async {
      final request = PutBucketPublicAccessBlockRequest(
        bucket: bucketName,
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: true,
        ),
      );
      final result = await client.putBucketPublicAccessBlock(request);
      expect(result.statusCode, equals(200));
    });

    test('testGetBucketPublicAccessBlock', () async {
      // First set public access block
      final putRequest = PutBucketPublicAccessBlockRequest(
        bucket: bucketName,
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: true,
        ),
      );
      await client.putBucketPublicAccessBlock(putRequest);

      // Then get public access block
      final getRequest = GetBucketPublicAccessBlockRequest(bucket: bucketName);
      final result = await client.getBucketPublicAccessBlock(getRequest);
      expect(result.statusCode, equals(200));
      expect(result.publicAccessBlockConfiguration, isNotNull);
      expect(
        result.publicAccessBlockConfiguration?.blockPublicAccess,
        equals(true),
      );
    });

    test('testDeleteBucketPublicAccessBlock', () async {
      // First set public access block
      final putRequest = PutBucketPublicAccessBlockRequest(
        bucket: bucketName,
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: true,
        ),
      );
      await client.putBucketPublicAccessBlock(putRequest);

      // Verify it's set
      var getResult = await client.getBucketPublicAccessBlock(
        GetBucketPublicAccessBlockRequest(bucket: bucketName),
      );
      expect(
        getResult.publicAccessBlockConfiguration?.blockPublicAccess,
        equals(true),
      );

      // Delete public access block
      final deleteRequest = DeleteBucketPublicAccessBlockRequest(
        bucket: bucketName,
      );
      final deleteResult = await client.deleteBucketPublicAccessBlock(
        deleteRequest,
      );
      expect(deleteResult.statusCode, equals(204));

      // Verify it's deleted (should be false now)
      getResult = await client.getBucketPublicAccessBlock(
        GetBucketPublicAccessBlockRequest(bucket: bucketName),
      );
      expect(
        getResult.publicAccessBlockConfiguration?.blockPublicAccess,
        equals(false),
      );
    });

    test('testGetBucketPublicAccessBlockFail', () async {
      await expectAsyncError(
        () async {
          final request = GetBucketPublicAccessBlockRequest(
            bucket: 'non-existent-bucket-${BaseTestCase.randomStr(8)}',
          );
          await client.getBucketPublicAccessBlock(request);
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
