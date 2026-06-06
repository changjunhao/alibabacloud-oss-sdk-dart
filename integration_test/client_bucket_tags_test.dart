import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketTagsTests', () {
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

    test('testPutBucketTags', () async {
      final request = PutBucketTagsRequest(
        bucket: bucketName,
        tagging: Tagging(
          tagSet: TagSet(
            tags: [
              Tag(key: 'key1', value: 'value1'),
              Tag(key: 'key2', value: 'value2'),
            ],
          ),
        ),
      );
      final result = await client.putBucketTags(request);
      expect(result.statusCode, equals(200));
    });

    test('testGetBucketTags', () async {
      // First set tags
      final putRequest = PutBucketTagsRequest(
        bucket: bucketName,
        tagging: Tagging(
          tagSet: TagSet(
            tags: [
              Tag(key: 'key1', value: 'value1'),
              Tag(key: 'key2', value: 'value2'),
            ],
          ),
        ),
      );
      await client.putBucketTags(putRequest);

      // Then get tags
      final getRequest = GetBucketTagsRequest(bucket: bucketName);
      final result = await client.getBucketTags(getRequest);
      expect(result.statusCode, equals(200));
      expect(result.tagging, isNotNull);
      expect(result.tagging?.tagSet?.tags, isNotNull);
      expect(result.tagging?.tagSet?.tags?.length, equals(2));
      expect(result.tagging?.tagSet?.tags?.first.key, equals('key1'));
      expect(result.tagging?.tagSet?.tags?.first.value, equals('value1'));
      expect(result.tagging?.tagSet?.tags?.last.key, equals('key2'));
      expect(result.tagging?.tagSet?.tags?.last.value, equals('value2'));
    });

    test('testDeleteBucketTags', () async {
      // First set tags
      final putRequest = PutBucketTagsRequest(
        bucket: bucketName,
        tagging: Tagging(
          tagSet: TagSet(
            tags: [
              Tag(key: 'key1', value: 'value1'),
              Tag(key: 'key2', value: 'value2'),
            ],
          ),
        ),
      );
      await client.putBucketTags(putRequest);

      // Verify tags exist
      var getResult = await client.getBucketTags(
        GetBucketTagsRequest(bucket: bucketName),
      );
      expect(getResult.tagging?.tagSet?.tags?.length, equals(2));

      // Delete tags
      final deleteRequest = DeleteBucketTagsRequest(bucket: bucketName);
      final deleteResult = await client.deleteBucketTags(deleteRequest);
      expect(deleteResult.statusCode, equals(204));

      // Verify tags are deleted
      getResult = await client.getBucketTags(
        GetBucketTagsRequest(bucket: bucketName),
      );
      expect(getResult.tagging?.tagSet?.tags, anyOf(isNull, isEmpty));
    });

    test('testPutBucketTagsFail', () async {
      final invalidClient = testCase.getInvalidAkClient();
      await expectAsyncError(
        () async {
          final request = PutBucketTagsRequest(
            bucket: bucketName,
            tagging: Tagging(
              tagSet: TagSet(
                tags: [Tag(key: 'key1', value: 'value1')],
              ),
            ),
          );
          await invalidClient.putBucketTags(request);
        },
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(403));
        },
      );
    });

    test('testGetBucketTagsFail', () async {
      await expectAsyncError(
        () async {
          final request = GetBucketTagsRequest(
            bucket: 'non-existent-bucket-${BaseTestCase.randomStr(8)}',
          );
          await client.getBucketTags(request);
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
