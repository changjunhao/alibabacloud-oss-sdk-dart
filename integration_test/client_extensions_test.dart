import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

import 'base_test_case.dart';

void main() {
  group('ClientExtensionsTests', () {
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

    test('testIsBucketExistSuccess', () async {
      // Existing bucket should return true
      final exists = await client.isBucketExist(bucketName);
      expect(exists, isTrue);

      // Non-existent bucket should return false
      final nonExistBucket = testCase.randomBucketName();
      final notExists = await client.isBucketExist(nonExistBucket);
      expect(notExists, isFalse);
    });

    test('testIsBucketExistFail', () async {
      // Invalid credentials should cause failure
      final invalidClient = testCase.getInvalidAkClient();

      await expectAsyncError(
        () => invalidClient.isBucketExist(bucketName),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(403));
        },
      );
    });

    test('testIsObjectExistSuccess', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - exist test'.codeUnits);

      // Object should not exist initially
      var exists = await client.isObjectExist(bucketName, objectKey);
      expect(exists, isFalse);

      // Upload object
      await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromData(data),
        ),
      );

      // Object should now exist
      exists = await client.isObjectExist(bucketName, objectKey);
      expect(exists, isTrue);
    });

    test('testIsObjectExistFail', () async {
      final objectKey = testCase.randomObjectName();

      // Invalid credentials should cause failure
      final invalidClient = testCase.getInvalidAkClient();

      await expectAsyncError(
        () => invalidClient.isObjectExist(bucketName, objectKey),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(403));
        },
      );
    });

    test('testGetObjectToFileSuccess', () async {
      final objectKey = testCase.randomObjectName();
      final content = 'hello oss - get object to file extension test';
      final data = Uint8List.fromList(content.codeUnits);

      // Upload object
      await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromData(data),
        ),
      );

      // Download to file
      final downloadFileName = testCase.randomFileName();
      final downloadPath =
          '${testCase.tempDir}${Platform.pathSeparator}$downloadFileName';
      await Directory(testCase.tempDir).create(recursive: true);

      final getRequest = GetObjectRequest(bucket: bucketName, key: objectKey);
      final getResult = await client.getObjectToFile(getRequest, downloadPath);
      expect(getResult.statusCode, equals(200));

      // Verify file content
      final downloadedFile = File(downloadPath);
      expect(await downloadedFile.exists(), isTrue);
      final fileContent = await downloadedFile.readAsString();
      expect(fileContent, equals(content));

      await testCase.removeTestFile(downloadPath);
    });
  }, skip: BaseTestCase.skipReason);
}
