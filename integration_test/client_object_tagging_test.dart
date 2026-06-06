import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

import 'base_test_case.dart';

void main() {
  group('ClientObjectTaggingTests', () {
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

    test('testPutObjectTagging', () async {
      final objectKey = testCase.randomObjectName();

      // Upload target object
      final putObjectRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
      );
      await expectNoAsyncError(() => client.putObject(putObjectRequest));

      // Set tags
      final tags = [Tag(key: 'tagKey1', value: 'tagValue1')];
      final putTaggingRequest = PutObjectTaggingRequest(
        bucket: bucketName,
        key: objectKey,
        tagging: Tagging(tagSet: TagSet(tags: tags)),
      );
      final putTaggingResult = await expectNoAsyncError(
        () => client.putObjectTagging(putTaggingRequest),
      );
      expect(putTaggingResult.commonProp.statusCode, 200);

      // Verify tags were set
      final getTaggingRequest = GetObjectTaggingRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final getTaggingResult = await expectNoAsyncError(
        () => client.getObjectTagging(getTaggingRequest),
      );
      expect(getTaggingResult.commonProp.statusCode, 200);
      expect(getTaggingResult.tagging?.tagSet?.tags?.length, 1);
      expect(getTaggingResult.tagging?.tagSet?.tags?.first.key, 'tagKey1');
      expect(getTaggingResult.tagging?.tagSet?.tags?.first.value, 'tagValue1');
    });

    test('testGetObjectTagging', () async {
      final objectKey = testCase.randomObjectName();

      // Upload target object
      final putObjectRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
      );
      await expectNoAsyncError(() => client.putObject(putObjectRequest));

      // Set multiple tags
      final tags = [
        Tag(key: 'tagKey1', value: 'tagValue1'),
        Tag(key: 'tagKey2', value: 'tagValue2'),
      ];
      final putTaggingRequest = PutObjectTaggingRequest(
        bucket: bucketName,
        key: objectKey,
        tagging: Tagging(tagSet: TagSet(tags: tags)),
      );
      await expectNoAsyncError(
        () => client.putObjectTagging(putTaggingRequest),
      );

      // Get and verify tags
      final getTaggingRequest = GetObjectTaggingRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final getTaggingResult = await expectNoAsyncError(
        () => client.getObjectTagging(getTaggingRequest),
      );
      expect(getTaggingResult.commonProp.statusCode, 200);
      expect(getTaggingResult.tagging?.tagSet?.tags?.length, 2);

      final tagMap = <String, String>{};
      for (final tag in getTaggingResult.tagging!.tagSet!.tags!) {
        tagMap[tag.key!] = tag.value!;
      }
      expect(tagMap['tagKey1'], 'tagValue1');
      expect(tagMap['tagKey2'], 'tagValue2');
    });

    test('testDeleteObjectTagging', () async {
      final objectKey = testCase.randomObjectName();

      // Upload target object
      final putObjectRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
      );
      await expectNoAsyncError(() => client.putObject(putObjectRequest));

      // Set tags
      final tags = [
        Tag(key: 'tagKey1', value: 'tagValue1'),
        Tag(key: 'tagKey2', value: 'tagValue2'),
      ];
      final putTaggingRequest = PutObjectTaggingRequest(
        bucket: bucketName,
        key: objectKey,
        tagging: Tagging(tagSet: TagSet(tags: tags)),
      );
      await expectNoAsyncError(
        () => client.putObjectTagging(putTaggingRequest),
      );

      // Verify tags exist
      var getTaggingRequest = GetObjectTaggingRequest(
        bucket: bucketName,
        key: objectKey,
      );
      var getTaggingResult = await expectNoAsyncError(
        () => client.getObjectTagging(getTaggingRequest),
      );
      expect(getTaggingResult.tagging?.tagSet?.tags?.length, 2);

      // Delete tags
      final deleteTaggingRequest = DeleteObjectTaggingRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final deleteResult = await expectNoAsyncError(
        () => client.deleteObjectTagging(deleteTaggingRequest),
      );
      expect(deleteResult.commonProp.statusCode, 204);

      // Verify tags are deleted
      getTaggingRequest = GetObjectTaggingRequest(
        bucket: bucketName,
        key: objectKey,
      );
      getTaggingResult = await expectNoAsyncError(
        () => client.getObjectTagging(getTaggingRequest),
      );
      expect(getTaggingResult.commonProp.statusCode, 200);
      expect(getTaggingResult.tagging?.tagSet?.tags?.length ?? 0, 0);
    });
  }, skip: BaseTestCase.skipReason);
}
