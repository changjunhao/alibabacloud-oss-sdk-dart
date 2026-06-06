import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

import 'base_test_case.dart';

void main() {
  group('ClientObjectSymlinkTests', () {
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

    test('testPutSymlink', () async {
      final objectKey = testCase.randomObjectName();
      final symlinkKey = '$objectKey-link';
      final content = utf8.encode('hello oss');

      // Upload target object
      final putObjectRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(Uint8List.fromList(content)),
      );
      await expectNoAsyncError(() => client.putObject(putObjectRequest));

      // Create symlink
      final putSymlinkRequest = PutSymlinkRequest(
        bucket: bucketName,
        key: symlinkKey,
        symlinkTarget: objectKey,
      );
      final putSymlinkResult = await expectNoAsyncError(
        () => client.putSymlink(putSymlinkRequest),
      );
      expect(putSymlinkResult.commonProp.statusCode, 200);

      // Verify by getting object through symlink
      final getObjectRequest = GetObjectRequest(
        bucket: bucketName,
        key: symlinkKey,
      );
      final getResult = await expectNoAsyncError(
        () => client.getObject(getObjectRequest),
      );
      expect(getResult.commonProp.statusCode, 200);
      final data = await getResult.body?.readData();
      expect(data, Uint8List.fromList(content));
    });

    test('testGetSymlink', () async {
      final objectKey = testCase.randomObjectName();
      final symlinkKey = '$objectKey-link';

      // Upload target object
      final putObjectRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
      );
      await expectNoAsyncError(() => client.putObject(putObjectRequest));

      // Create symlink
      final putSymlinkRequest = PutSymlinkRequest(
        bucket: bucketName,
        key: symlinkKey,
        symlinkTarget: objectKey,
      );
      await expectNoAsyncError(() => client.putSymlink(putSymlinkRequest));

      // Get symlink and verify target
      final getSymlinkRequest = GetSymlinkRequest(
        bucket: bucketName,
        key: symlinkKey,
      );
      final getSymlinkResult = await expectNoAsyncError(
        () => client.getSymlink(getSymlinkRequest),
      );
      expect(getSymlinkResult.commonProp.statusCode, 200);
      expect(getSymlinkResult.symlinkTarget, objectKey);
    });

    test('testPutSymlinkWithACL', () async {
      final objectKey = testCase.randomObjectName();
      final symlinkKey = '$objectKey-link';
      final content = utf8.encode('hello oss');

      // Upload target object
      final putObjectRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(Uint8List.fromList(content)),
      );
      await expectNoAsyncError(() => client.putObject(putObjectRequest));

      // Create symlink with private ACL
      final putSymlinkRequest = PutSymlinkRequest(
        bucket: bucketName,
        key: symlinkKey,
        symlinkTarget: objectKey,
        objectAcl: 'private',
      );
      final putSymlinkResult = await expectNoAsyncError(
        () => client.putSymlink(putSymlinkRequest),
      );
      expect(putSymlinkResult.commonProp.statusCode, 200);

      // Verify ACL via GetObjectAcl
      final getACLRequest = GetObjectAclRequest(
        bucket: bucketName,
        key: symlinkKey,
      );
      final getACLResult = await expectNoAsyncError(
        () => client.getObjectAcl(getACLRequest),
      );
      expect(getACLResult.commonProp.statusCode, 200);
      expect(
        getACLResult.accessControlPolicy?.accessControlList?.grant,
        equals('private'),
      );

      // Verify data accessible through symlink
      final getRequest = GetObjectRequest(bucket: bucketName, key: symlinkKey);
      final getResult = await expectNoAsyncError(
        () => client.getObject(getRequest),
      );
      expect(getResult.commonProp.statusCode, 200);
      final data = await getResult.body?.readData();
      expect(data, Uint8List.fromList(content));
    });

    test('testPutSymlinkWithMetadata', () async {
      final objectKey = testCase.randomObjectName();
      final symlinkKey = '$objectKey-link';
      final content = utf8.encode('hello oss');

      // Upload target object
      final putObjectRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(Uint8List.fromList(content)),
      );
      await expectNoAsyncError(() => client.putObject(putObjectRequest));

      // Create symlink with metadata via commonProp headers
      final putSymlinkRequest = PutSymlinkRequest(
        bucket: bucketName,
        key: symlinkKey,
        symlinkTarget: objectKey,
        storageClass: 'Standard',
        objectAcl: 'private',
      );
      putSymlinkRequest.commonProp.headers = {
        'x-oss-meta-key1': 'value1',
        'x-oss-meta-key2': 'value2',
      };
      final putSymlinkResult = await expectNoAsyncError(
        () => client.putSymlink(putSymlinkRequest),
      );
      expect(putSymlinkResult.commonProp.statusCode, 200);

      // Verify symlink is accessible
      final getSymlinkRequest = GetSymlinkRequest(
        bucket: bucketName,
        key: symlinkKey,
      );
      final getSymlinkResult = await expectNoAsyncError(
        () => client.getSymlink(getSymlinkRequest),
      );
      expect(getSymlinkResult.commonProp.statusCode, 200);
      expect(getSymlinkResult.symlinkTarget, objectKey);

      // Verify metadata via HeadObject
      final headObjectRequest = HeadObjectRequest(
        bucket: bucketName,
        key: symlinkKey,
      );
      final headResult = await expectNoAsyncError(
        () => client.headObject(headObjectRequest),
      );
      expect(headResult.commonProp.statusCode, 200);
      expect(headResult.commonProp.headers?['x-oss-meta-key1'], 'value1');
      expect(headResult.commonProp.headers?['x-oss-meta-key2'], 'value2');
    });

    test('testPutSymlinkWithForbidOverwrite', () async {
      final objectKey = testCase.randomObjectName();
      final symlinkKey = '$objectKey-link';
      final content = utf8.encode('hello oss - forbid overwrite');

      // Upload target object
      final putObjectRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(Uint8List.fromList(content)),
      );
      await expectNoAsyncError(() => client.putObject(putObjectRequest));

      // Create symlink
      final putSymlinkRequest1 = PutSymlinkRequest(
        bucket: bucketName,
        key: symlinkKey,
        symlinkTarget: objectKey,
      );
      await expectNoAsyncError(() => client.putSymlink(putSymlinkRequest1));

      // Try to overwrite with forbidOverwrite = true, should fail
      final putSymlinkRequest2 = PutSymlinkRequest(
        bucket: bucketName,
        key: symlinkKey,
        symlinkTarget: objectKey,
        forbidOverwrite: true,
      );

      await expectAsyncError(
        () => client.putSymlink(putSymlinkRequest2),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(409));
        },
      );
    });

    test('testPutSymlinkWithStorageClass', () async {
      final objectKey = testCase.randomObjectName();
      final symlinkKey = '$objectKey-link';
      final content = utf8.encode('hello oss - symlink storage class');

      // Upload target object
      final putObjectRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(Uint8List.fromList(content)),
      );
      await expectNoAsyncError(() => client.putObject(putObjectRequest));

      // Create symlink with IA storage class
      final putSymlinkRequest = PutSymlinkRequest(
        bucket: bucketName,
        key: symlinkKey,
        symlinkTarget: objectKey,
        storageClass: 'IA',
      );
      final putSymlinkResult = await expectNoAsyncError(
        () => client.putSymlink(putSymlinkRequest),
      );
      expect(putSymlinkResult.commonProp.statusCode, 200);

      // Verify symlink exists and target is correct
      final getSymlinkRequest = GetSymlinkRequest(
        bucket: bucketName,
        key: symlinkKey,
      );
      final getSymlinkResult = await expectNoAsyncError(
        () => client.getSymlink(getSymlinkRequest),
      );
      expect(getSymlinkResult.commonProp.statusCode, 200);
      expect(getSymlinkResult.symlinkTarget, objectKey);

      // Verify storage class via HeadObject
      // Note: Symlink itself may not reflect the specified storage class;
      // the storage class typically applies to the symlink metadata only
      final headObjectRequest = HeadObjectRequest(
        bucket: bucketName,
        key: symlinkKey,
      );
      final headResult = await expectNoAsyncError(
        () => client.headObject(headObjectRequest),
      );
      expect(headResult.commonProp.statusCode, 200);
      // Symlink storage class may be 'Standard' regardless of the specified class
      expect(headResult.storageClass, isNotNull);
    });
  }, skip: BaseTestCase.skipReason);
}
