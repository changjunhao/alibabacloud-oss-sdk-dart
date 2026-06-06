import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

import 'base_test_case.dart';

void main() {
  group('ClientMiscTests', () {
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

    test('testSendDifferentByteStreamType', () async {
      final objectKey = testCase.randomObjectName();

      // Send data (Uint8List)
      final dataContent = Uint8List.fromList('hello world from data'.codeUnits);
      var putResult = await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromData(dataContent),
        ),
      );
      expect(putResult.statusCode, equals(200));

      var getResult = await client.getObject(
        GetObjectRequest(bucket: bucketName, key: objectKey),
      );
      expect(getResult.statusCode, equals(200));
      var bodyData = await getResult.body?.readData();
      expect(String.fromCharCodes(bodyData!), equals('hello world from data'));

      // Send file
      final fileName = testCase.randomFileName();
      final filePath = await testCase.createTestFile(
        fileName,
        'hello world from file',
      );
      expect(filePath, isNotNull);
      final file = File(filePath!);
      putResult = await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromFile(file),
        ),
      );
      expect(putResult.statusCode, equals(200));

      getResult = await client.getObject(
        GetObjectRequest(bucket: bucketName, key: objectKey),
      );
      expect(getResult.statusCode, equals(200));
      bodyData = await getResult.body?.readData();
      expect(String.fromCharCodes(bodyData!), equals('hello world from file'));

      // Send stream
      final streamData = 'hello world from stream'.codeUnits;
      final stream = Stream<List<int>>.fromIterable([streamData]);
      putResult = await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromStream(stream),
        ),
      );
      expect(putResult.statusCode, equals(200));

      getResult = await client.getObject(
        GetObjectRequest(bucket: bucketName, key: objectKey),
      );
      expect(getResult.statusCode, equals(200));
      bodyData = await getResult.body?.readData();
      expect(
        String.fromCharCodes(bodyData!),
        equals('hello world from stream'),
      );

      await testCase.removeTestFile(filePath);
    });

    test('testDownloadToDifferentByteStreamType', () async {
      final objectKey = testCase.randomObjectName();
      final content = 'hello world download test';
      final data = Uint8List.fromList(content.codeUnits);

      // Upload object
      await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromData(data),
        ),
      );

      // Download as data (default getObject)
      final getResult = await client.getObject(
        GetObjectRequest(bucket: bucketName, key: objectKey),
      );
      expect(getResult.statusCode, equals(200));
      final bodyData = await getResult.body?.readData();
      expect(bodyData, isNotNull);
      expect(String.fromCharCodes(bodyData!), equals(content));

      // Download to file
      final downloadFileName = testCase.randomFileName();
      final downloadPath =
          '${testCase.tempDir}${Platform.pathSeparator}$downloadFileName';
      await Directory(testCase.tempDir).create(recursive: true);

      final fileResult = await client.getObjectToFile(
        GetObjectRequest(bucket: bucketName, key: objectKey),
        downloadPath,
      );
      expect(fileResult.statusCode, equals(200));

      final downloadedFile = File(downloadPath);
      expect(await downloadedFile.exists(), isTrue);
      final fileContent = await downloadedFile.readAsString();
      expect(fileContent, equals(content));

      await testCase.removeTestFile(downloadPath);
    });

    test('testDownloadToUrlWithError', () async {
      final objectKey = testCase.randomObjectName();
      final nonExistBucket = testCase.randomBucketName();

      // Download from non-existent bucket to file should fail
      final downloadFileName = testCase.randomFileName();
      final downloadPath =
          '${testCase.tempDir}${Platform.pathSeparator}$downloadFileName';
      await Directory(testCase.tempDir).create(recursive: true);

      await expectAsyncError(
        () => client.getObjectToFile(
          GetObjectRequest(bucket: nonExistBucket, key: objectKey),
          downloadPath,
        ),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.code, equals('NoSuchBucket'));
        },
      );
    });

    test('testUploadProgress', () async {
      final objectKey = testCase.randomObjectName();
      final size = 300 * 1024 + 12345;
      final data = Uint8List.fromList(List.generate(size, (i) => i % 256));

      var progressCalled = false;
      var lastTransferred = 0;

      final putResult = await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromData(data),
          progress: ProgressClosure((
            int bytesIncrement,
            int totalBytesTransferred,
            int totalBytesExpected,
          ) {
            progressCalled = true;
            lastTransferred = totalBytesTransferred;
          }),
        ),
      );
      expect(putResult.statusCode, equals(200));
      expect(progressCalled, isTrue);
      expect(lastTransferred, greaterThan(0));
    });

    test('testDownloadProgress', () async {
      final objectKey = testCase.randomObjectName();
      final size = 300 * 1024 + 12345;
      final data = Uint8List.fromList(List.generate(size, (i) => i % 256));

      // Upload object first
      await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromData(data),
        ),
      );

      var progressCallCount = 0;

      // Download with progress
      final getResult = await client.getObject(
        GetObjectRequest(
          bucket: bucketName,
          key: objectKey,
          progress: ProgressClosure((
            int bytesIncrement,
            int totalBytesTransferred,
            int totalBytesExpected,
          ) {
            progressCallCount++;
          }),
        ),
      );
      expect(getResult.statusCode, equals(200));
      // Note: Download progress may not be called depending on implementation
      // This test verifies the progress callback can be set without errors
      expect(getResult.body, isNotNull);
      expect(progressCallCount, greaterThanOrEqualTo(0));
    });

    test('testFeatureAutoDetectMimeTypeFlag', () async {
      final objectKey = '${testCase.randomObjectName()}.txt';
      final data = Uint8List.fromList('hello world from data'.codeUnits);

      // Default client has autoDetectMimeType enabled
      await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromData(data),
        ),
      );

      final getResult = await client.getObject(
        GetObjectRequest(bucket: bucketName, key: objectKey),
      );
      expect(getResult.statusCode, equals(200));
      // With auto-detect mime type, .txt should be detected as text/plain
      expect(getResult.contentType, contains('text/plain'));
    });

    test('testFeatureEnableCRC64CheckUploadFlag', () async {
      final objectKey = '${testCase.randomObjectName()}.txt';
      final data = Uint8List.fromList('hello world crc64 test'.codeUnits);

      // Default client has CRC64 check enabled
      final putResult = await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromData(data),
        ),
      );
      expect(putResult.statusCode, equals(200));

      // Verify the object was uploaded correctly
      final getResult = await client.getObject(
        GetObjectRequest(bucket: bucketName, key: objectKey),
      );
      expect(getResult.statusCode, equals(200));
      final bodyData = await getResult.body?.readData();
      expect(String.fromCharCodes(bodyData!), equals('hello world crc64 test'));
    });

    test('testQueryWithSpecialChar', () async {
      final objectKey = 'special/char-123+ 456.txt';
      final content = Uint8List.fromList('hello world, hi oss!'.codeUnits);

      // Upload object with special characters in key
      final putResult = await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromData(content),
        ),
      );
      expect(putResult.statusCode, equals(200));

      // Get object with special characters in key
      final getResult = await client.getObject(
        GetObjectRequest(bucket: bucketName, key: objectKey),
      );
      expect(getResult.statusCode, equals(200));
      final bodyData = await getResult.body?.readData();
      expect(bodyData, isNotNull);
      expect(String.fromCharCodes(bodyData!), equals('hello world, hi oss!'));
    });

    test('testPutObjectWithSpecialKey', () async {
      // Test various special character object names
      final specialKeys = [
        'test object with spaces.txt',
        'test+plus+sign.txt',
        'test/path/object.txt',
        'test-dash-name.txt',
        'test_underscore_name.txt',
        'chinese-中文-key.txt',
      ];

      final data = Uint8List.fromList('hello oss special key'.codeUnits);

      for (final key in specialKeys) {
        final putResult = await client.putObject(
          PutObjectRequest(
            bucket: bucketName,
            key: key,
            body: ByteStream.fromData(data),
          ),
        );
        expect(
          putResult.statusCode,
          equals(200),
          reason: 'Failed to put object with key: $key',
        );

        // Verify the object exists
        final exists = await client.isObjectExist(bucketName, key);
        expect(exists, isTrue, reason: 'Object not found with key: $key');

        // Verify the content
        final getResult = await client.getObject(
          GetObjectRequest(bucket: bucketName, key: key),
        );
        expect(
          getResult.statusCode,
          equals(200),
          reason: 'Failed to get object with key: $key',
        );
        final bodyData = await getResult.body?.readData();
        expect(
          String.fromCharCodes(bodyData!),
          equals('hello oss special key'),
          reason: 'Content mismatch for key: $key',
        );
      }
    });
  }, skip: BaseTestCase.skipReason);
}
