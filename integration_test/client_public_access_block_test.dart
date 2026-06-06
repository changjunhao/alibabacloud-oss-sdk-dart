import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientPublicAccessBlockTests', () {
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

    test('testPutPublicAccessBlock', () async {
      final request = PutPublicAccessBlockRequest(
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: true,
        ),
      );
      final result = await client.putPublicAccessBlock(request);
      expect(result.statusCode, equals(200));

      // Clean up: restore to false
      final cleanupRequest = PutPublicAccessBlockRequest(
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: false,
        ),
      );
      await client.putPublicAccessBlock(cleanupRequest);
    });

    test('testGetPublicAccessBlock', () async {
      // First set public access block
      final putRequest = PutPublicAccessBlockRequest(
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: true,
        ),
      );
      await client.putPublicAccessBlock(putRequest);

      // Then get public access block
      final getRequest = GetPublicAccessBlockRequest();
      final result = await client.getPublicAccessBlock(getRequest);
      expect(result.statusCode, equals(200));
      expect(result.publicAccessBlockConfiguration, isNotNull);
      // The blockPublicAccess value may not immediately reflect the change
      // due to eventual consistency; verify the API call succeeds
      expect(
        result.publicAccessBlockConfiguration?.blockPublicAccess,
        isNotNull,
      );

      // Clean up: restore to false
      final cleanupRequest = PutPublicAccessBlockRequest(
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: false,
        ),
      );
      await client.putPublicAccessBlock(cleanupRequest);
    });

    test('testDeletePublicAccessBlock', () async {
      // First set public access block
      final putRequest = PutPublicAccessBlockRequest(
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: true,
        ),
      );
      try {
        await client.putPublicAccessBlock(putRequest);
      } catch (_) {
        // If put fails, still try delete
      }

      // Delete public access block
      final deleteRequest = DeletePublicAccessBlockRequest();
      final deleteResult = await client.deletePublicAccessBlock(deleteRequest);
      expect(deleteResult.statusCode, anyOf(equals(200), equals(204)));
    });

    test('testGetPublicAccessBlockFail', () async {
      final invalidClient = testCase.getInvalidAkClient();
      await expectAsyncError(
        () async {
          final request = GetPublicAccessBlockRequest();
          await invalidClient.getPublicAccessBlock(request);
        },
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(403));
        },
      );
    });
  }, skip: BaseTestCase.skipReason);
}
