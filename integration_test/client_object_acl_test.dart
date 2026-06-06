import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

import 'base_test_case.dart';

void main() {
  group('ClientObjectACLTests', () {
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

    test('testPutObjectAcl', () async {
      final objectKey = testCase.randomObjectName();

      // Upload target object
      final putObjectRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
      );
      await expectNoAsyncError(() => client.putObject(putObjectRequest));

      // Set ACL to private (should always be allowed)
      final putAclRequest = PutObjectAclRequest(
        bucket: bucketName,
        key: objectKey,
        objectAcl: 'private',
      );
      final putAclResult = await expectNoAsyncError(
        () => client.putObjectAcl(putAclRequest),
      );
      expect(putAclResult.commonProp.statusCode, 200);

      // Verify ACL was set
      final getAclRequest = GetObjectAclRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final getAclResult = await expectNoAsyncError(
        () => client.getObjectAcl(getAclRequest),
      );
      expect(getAclResult.commonProp.statusCode, 200);
      expect(
        getAclResult.accessControlPolicy?.accessControlList?.grant,
        'private',
      );
    });

    test('testGetObjectAcl', () async {
      final objectKey = testCase.randomObjectName();

      // Upload target object
      final putObjectRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
      );
      await expectNoAsyncError(() => client.putObject(putObjectRequest));

      // Verify default ACL
      var getAclRequest = GetObjectAclRequest(
        bucket: bucketName,
        key: objectKey,
      );
      var getAclResult = await expectNoAsyncError(
        () => client.getObjectAcl(getAclRequest),
      );
      expect(getAclResult.commonProp.statusCode, 200);
      expect(
        getAclResult.accessControlPolicy?.accessControlList?.grant,
        'default',
      );

      // Set ACL to private
      var putAclRequest = PutObjectAclRequest(
        bucket: bucketName,
        key: objectKey,
        objectAcl: 'private',
      );
      await expectNoAsyncError(() => client.putObjectAcl(putAclRequest));

      // Verify private ACL
      getAclRequest = GetObjectAclRequest(bucket: bucketName, key: objectKey);
      getAclResult = await expectNoAsyncError(
        () => client.getObjectAcl(getAclRequest),
      );
      expect(getAclResult.commonProp.statusCode, 200);
      expect(
        getAclResult.accessControlPolicy?.accessControlList?.grant,
        'private',
      );
    });
  }, skip: BaseTestCase.skipReason);
}
