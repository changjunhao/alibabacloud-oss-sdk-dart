import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' show CancelToken;
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

import 'base_test_case.dart';

void main() {
  group('ClientObjectBasicTests', () {
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

    test('testPutObject', () async {
      final objectKey = testCase.randomObjectName();
      final fileName = testCase.randomFileName();
      final content = 'hello oss - put object test content' * 100;
      final filePath = await testCase.createTestFile(fileName, content);
      expect(filePath, isNotNull);

      final file = File(filePath!);
      final request = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromFile(file),
      );

      final result = await client.putObject(request);
      expect(result.statusCode, equals(200));

      // Verify object exists via headObject
      final headRequest = HeadObjectRequest(bucket: bucketName, key: objectKey);
      final headResult = await client.headObject(headRequest);
      expect(headResult.statusCode, equals(200));
      expect(headResult.contentLength, equals(content.length));

      await testCase.removeTestFile(filePath);
    });

    test('testPutObjectWithData', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - data upload test'.codeUnits);

      final request = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );

      final result = await client.putObject(request);
      expect(result.statusCode, equals(200));

      // Verify via headObject
      final headRequest = HeadObjectRequest(bucket: bucketName, key: objectKey);
      final headResult = await client.headObject(headRequest);
      expect(headResult.statusCode, equals(200));
      expect(headResult.contentLength, equals(data.length));
    });

    test('testPutObjectWithProgress', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList(
        List.generate(100 * 1024, (i) => i % 256),
      );
      var progressCalled = false;
      var lastTotalBytesTransferred = 0;

      final request = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
        progress: ProgressClosure((
          int bytesIncrement,
          int totalBytesTransferred,
          int totalBytesExpected,
        ) {
          progressCalled = true;
          expect(
            totalBytesTransferred,
            greaterThanOrEqualTo(lastTotalBytesTransferred),
          );
          lastTotalBytesTransferred = totalBytesTransferred;
          expect(totalBytesExpected, equals(data.length));
        }),
      );

      final result = await client.putObject(request);
      expect(result.statusCode, equals(200));
      expect(progressCalled, isTrue);
    });

    test('testPutObjectWithMetadata', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - metadata test'.codeUnits);
      final metadata = {'key1': 'value1', 'key2': 'value2'};

      final request = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
        metadata: metadata,
      );

      final result = await client.putObject(request);
      expect(result.statusCode, equals(200));

      // Verify metadata via headObject
      final headRequest = HeadObjectRequest(bucket: bucketName, key: objectKey);
      final headResult = await client.headObject(headRequest);
      expect(headResult.statusCode, equals(200));
      expect(headResult.metadata?['key1'], equals('value1'));
      expect(headResult.metadata?['key2'], equals('value2'));
    });

    test('testPutObjectWithAcl', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - acl test'.codeUnits);

      final request = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
        objectAcl: 'private',
      );

      final result = await client.putObject(request);
      expect(result.statusCode, equals(200));

      // Verify ACL via getObjectAcl
      final getAclRequest = GetObjectAclRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final aclResult = await client.getObjectAcl(getAclRequest);
      expect(
        aclResult.accessControlPolicy?.accessControlList?.grant,
        equals('private'),
      );
    });

    test('testGetObject', () async {
      final objectKey = testCase.randomObjectName();
      final content = 'hello oss - get object test content';
      final data = Uint8List.fromList(content.codeUnits);

      // Upload object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Download object
      final getRequest = GetObjectRequest(bucket: bucketName, key: objectKey);
      final getResult = await client.getObject(getRequest);
      expect(getResult.statusCode, equals(200));

      // Verify content
      final bodyData = await getResult.body?.readData();
      expect(bodyData, isNotNull);
      expect(bodyData!.length, equals(data.length));
      expect(String.fromCharCodes(bodyData), equals(content));
    });

    test('testGetObjectWithRange', () async {
      final objectKey = testCase.randomObjectName();
      final content = 'hello oss - range download test content';
      final data = Uint8List.fromList(content.codeUnits);

      // Upload object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Download with range (first 10 bytes)
      final getRequest = GetObjectRequest(
        bucket: bucketName,
        key: objectKey,
        range: 'bytes=0-9',
      );
      final getResult = await client.getObject(getRequest);
      expect(getResult.statusCode, equals(206));

      final bodyData = await getResult.body?.readData();
      expect(bodyData, isNotNull);
      expect(bodyData!.length, equals(10));
      expect(String.fromCharCodes(bodyData), equals('hello oss '));
    });

    test('testGetObjectToFile', () async {
      final objectKey = testCase.randomObjectName();
      final content = 'hello oss - get object to file test';
      final data = Uint8List.fromList(content.codeUnits);

      // Upload object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Download to file
      final downloadFileName = testCase.randomFileName();
      final downloadPath =
          '${testCase.tempDir}${Platform.pathSeparator}$downloadFileName';
      // Ensure temp dir exists
      await Directory(testCase.tempDir).create(recursive: true);

      final getRequest = GetObjectRequest(bucket: bucketName, key: objectKey);
      final getResult = await client.getObjectToFile(getRequest, downloadPath);
      expect(getResult.statusCode, equals(200));

      // Verify file exists and content is correct
      final downloadedFile = File(downloadPath);
      expect(await downloadedFile.exists(), isTrue);
      final fileContent = await downloadedFile.readAsString();
      expect(fileContent, equals(content));

      await testCase.removeTestFile(downloadPath);
    });

    test('testHeadObject', () async {
      final objectKey = testCase.randomObjectName();
      final content = 'hello oss - head object test';
      final data = Uint8List.fromList(content.codeUnits);

      // Upload object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
        contentType: 'text/plain',
      );
      await client.putObject(putRequest);

      // Head object
      final headRequest = HeadObjectRequest(bucket: bucketName, key: objectKey);
      final headResult = await client.headObject(headRequest);
      expect(headResult.statusCode, equals(200));
      expect(headResult.contentLength, equals(data.length));
      expect(headResult.contentType, isNotNull);
      expect(headResult.etag, isNotNull);
      expect(headResult.etag!.isNotEmpty, isTrue);
    });

    test('testGetObjectMeta', () async {
      final objectKey = testCase.randomObjectName();
      final content = 'hello oss - get object meta test';
      final data = Uint8List.fromList(content.codeUnits);

      // Upload object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Get object meta
      final metaRequest = GetObjectMetaRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final metaResult = await client.getObjectMeta(metaRequest);
      expect(metaResult.statusCode, equals(200));
      expect(metaResult.contentLength, equals(data.length));
      expect(metaResult.etag, isNotNull);
      expect(metaResult.lastModified, isNotNull);
    });

    test('testCopyObject', () async {
      final srcObjectKey = testCase.randomObjectName();
      final destObjectKey = testCase.randomObjectName();
      final content = 'hello oss - copy object test';
      final data = Uint8List.fromList(content.codeUnits);

      // Upload source object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: srcObjectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Copy object
      final copyRequest = CopyObjectRequest(
        bucket: bucketName,
        key: destObjectKey,
        sourceBucket: bucketName,
        sourceKey: srcObjectKey,
      );
      final copyResult = await client.copyObject(copyRequest);
      expect(copyResult.statusCode, equals(200));

      // Verify dest object exists
      final exists = await client.isObjectExist(bucketName, destObjectKey);
      expect(exists, isTrue);

      // Verify content
      final getRequest = GetObjectRequest(
        bucket: bucketName,
        key: destObjectKey,
      );
      final getResult = await client.getObject(getRequest);
      final bodyData = await getResult.body?.readData();
      expect(String.fromCharCodes(bodyData!), equals(content));
    });

    test('testAppendObject', () async {
      final objectKey = testCase.randomObjectName();
      final content1 = 'hello ';
      final content2 = 'oss append';
      final data1 = Uint8List.fromList(content1.codeUnits);
      final data2 = Uint8List.fromList(content2.codeUnits);

      // First append (position = 0)
      final appendRequest1 = AppendObjectRequest(
        bucket: bucketName,
        key: objectKey,
        position: 0,
        body: ByteStream.fromData(data1),
      );
      final appendResult1 = await client.appendObject(appendRequest1);
      expect(appendResult1.statusCode, equals(200));
      expect(appendResult1.nextAppendPosition, equals(data1.length));

      // Second append
      final appendRequest2 = AppendObjectRequest(
        bucket: bucketName,
        key: objectKey,
        position: appendResult1.nextAppendPosition,
        body: ByteStream.fromData(data2),
        initHashCrc64: appendResult1.hashCrc64ecma,
      );
      final appendResult2 = await client.appendObject(appendRequest2);
      expect(appendResult2.statusCode, equals(200));
      expect(
        appendResult2.nextAppendPosition,
        equals(data1.length + data2.length),
      );

      // Verify content is concatenation
      final getRequest = GetObjectRequest(bucket: bucketName, key: objectKey);
      final getResult = await client.getObject(getRequest);
      final bodyData = await getResult.body?.readData();
      expect(String.fromCharCodes(bodyData!), equals(content1 + content2));
    });

    test('testSealAppendObject', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss'.codeUnits);

      // Append data first
      final appendResult = await client.appendObject(
        AppendObjectRequest(
          bucket: bucketName,
          key: objectKey,
          position: 0,
          body: ByteStream.fromData(data),
        ),
      );
      expect(appendResult.statusCode, equals(200));
      expect(appendResult.nextAppendPosition, isNotNull);

      // Seal the appendable object using the current length as position
      final sealResult = await client.sealAppendObject(
        SealAppendObjectRequest(
          bucket: bucketName,
          key: objectKey,
          position: data.length,
        ),
      );
      expect(sealResult.statusCode, equals(200));

      // Cleanup
      await client.deleteObject(
        DeleteObjectRequest(bucket: bucketName, key: objectKey),
      );
    });

    test('testSealAppendObjectWithError', () async {
      // Missing bucket
      try {
        await client.sealAppendObject(SealAppendObjectRequest());
        fail('Expected a ClientError for missing bucket');
      } catch (e) {
        expect(e, isA<ClientError>());
        expect(
          (e as ClientError).message,
          equals('Missing required field, request.bucket.'),
        );
      }

      // Missing key
      try {
        await client.sealAppendObject(
          SealAppendObjectRequest(bucket: bucketName),
        );
        fail('Expected a ClientError for missing key');
      } catch (e) {
        expect(e, isA<ClientError>());
        expect(
          (e as ClientError).message,
          equals('Missing required field, request.key.'),
        );
      }

      // Missing position
      try {
        await client.sealAppendObject(
          SealAppendObjectRequest(bucket: bucketName, key: 'key'),
        );
        fail('Expected a ClientError for missing position');
      } catch (e) {
        expect(e, isA<ClientError>());
        expect(
          (e as ClientError).message,
          equals('Missing required field, request.position.'),
        );
      }
    });

    test('testDeleteObject', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - delete test'.codeUnits);

      // Upload object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Verify object exists
      var exists = await client.isObjectExist(bucketName, objectKey);
      expect(exists, isTrue);

      // Delete object
      final deleteRequest = DeleteObjectRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final deleteResult = await client.deleteObject(deleteRequest);
      expect(deleteResult.statusCode, equals(204));

      // Verify object no longer exists
      exists = await client.isObjectExist(bucketName, objectKey);
      expect(exists, isFalse);
    });

    test('testDeleteMultipleObjects', () async {
      final objectKeys = <String>[];
      // Upload 3 objects
      for (var i = 0; i < 3; i++) {
        final objectKey = testCase.randomObjectName();
        objectKeys.add(objectKey);
        final data = Uint8List.fromList(
          'hello oss - delete multiple $i'.codeUnits,
        );
        final putRequest = PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromData(data),
        );
        await client.putObject(putRequest);
      }

      // Verify all objects exist
      for (final key in objectKeys) {
        final exists = await client.isObjectExist(bucketName, key);
        expect(exists, isTrue);
      }

      // Delete multiple objects
      final deleteRequest = DeleteMultipleObjectsRequest(
        bucket: bucketName,
        delete: Delete(
          objects: objectKeys.map((key) => DeleteObject(key: key)).toList(),
          quiet: true,
        ),
      );
      final deleteResult = await client.deleteMultipleObjects(deleteRequest);
      expect(deleteResult.statusCode, equals(200));

      // Verify all objects are deleted
      for (final key in objectKeys) {
        final exists = await client.isObjectExist(bucketName, key);
        expect(exists, isFalse);
      }
    });

    test('testIsObjectExist', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - exist test'.codeUnits);

      // Object should not exist initially
      var exists = await client.isObjectExist(bucketName, objectKey);
      expect(exists, isFalse);

      // Upload object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Object should now exist
      exists = await client.isObjectExist(bucketName, objectKey);
      expect(exists, isTrue);

      // Non-existent object should return false
      final nonExistKey = testCase.randomObjectName();
      exists = await client.isObjectExist(bucketName, nonExistKey);
      expect(exists, isFalse);
    });

    test('testPutObjectWithForbidOverwrite', () async {
      final objectKey = testCase.randomObjectName();
      final data1 = Uint8List.fromList('first upload'.codeUnits);
      final data2 = Uint8List.fromList('second upload'.codeUnits);

      // First upload
      final putRequest1 = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data1),
      );
      final result1 = await client.putObject(putRequest1);
      expect(result1.statusCode, equals(200));

      // Second upload with forbidOverwrite = true should fail
      final putRequest2 = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data2),
        forbidOverwrite: true,
      );

      await expectAsyncError(
        () => client.putObject(putRequest2),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(409));
        },
      );
    });

    test('testRestoreObject', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - restore test'.codeUnits);

      // Upload object with Archive storage class
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
        storageClass: 'Archive',
      );
      final putResult = await client.putObject(putRequest);
      expect(putResult.statusCode, equals(200));

      // Restore object
      final restoreRequest = RestoreObjectRequest(
        bucket: bucketName,
        key: objectKey,
        restoreRequest: RestoreRequest(days: 1),
      );
      final restoreResult = await client.restoreObject(restoreRequest);
      expect(restoreResult.statusCode, equals(202));
    });

    // =========================================================================
    // PutObject Enhanced Tests
    // =========================================================================

    test('testPutObjectWithCheckCrc', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList(List.generate(50 * 1024, (i) => i % 256));

      // CRC64 is enabled by default, just upload and verify
      final request = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );

      final result = await client.putObject(request);
      expect(result.statusCode, equals(200));
      expect(result.hashCrc64ecma, isNotNull);

      // Verify content via download
      final getRequest = GetObjectRequest(bucket: bucketName, key: objectKey);
      final getResult = await client.getObject(getRequest);
      expect(getResult.statusCode, equals(200));
      final bodyData = await getResult.body?.readData();
      expect(bodyData!.length, equals(data.length));
    });

    test('testPutObjectWithStream', () async {
      final objectKey = testCase.randomObjectName();
      final content = 'hello oss - stream upload test content' * 50;
      final data = Uint8List.fromList(content.codeUnits);

      // Create a stream from data
      final stream = Stream<List<int>>.fromIterable([data]);

      final request = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromStream(stream),
      );

      final result = await client.putObject(request);
      expect(result.statusCode, equals(200));

      // Verify content
      final getRequest = GetObjectRequest(bucket: bucketName, key: objectKey);
      final getResult = await client.getObject(getRequest);
      final bodyData = await getResult.body?.readData();
      expect(String.fromCharCodes(bodyData!), equals(content));
    });

    test('testPutObjectWithCallback', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - callback test'.codeUnits);

      // Use an unreachable callback URL.
      // OSS uploads the object, then attempts the callback; when the callback
      // URL is unreachable, the server returns HTTP 203.
      final callbackBody = json.encode({
        'callbackUrl': 'https://www.callback.com',
        'callbackBody':
            'bucket=\${bucket}&object=\${object}&size=\${size}&etag=\${etag}',
      });
      final callbackEncoded = base64.encode(utf8.encode(callbackBody));

      final request = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
        callback: callbackEncoded,
      );

      final result = await client.putObject(request);
      expect(result.statusCode, equals(203));

      // Object should still be uploaded regardless of callback failure
      final exists = await client.isObjectExist(bucketName, objectKey);
      expect(exists, isTrue);
    });

    test('testPutObjectAndCancel', () async {
      final objectKey = testCase.randomObjectName();
      // Create a 5MB data payload to ensure the upload takes enough time to cancel
      final data = Uint8List.fromList(
        List.generate(5 * 1024 * 1024, (i) => i % 256),
      );

      final cancelToken = CancelToken();

      final request = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );

      final options = OperationOptions(cancelToken: cancelToken);

      // Schedule cancellation after a short delay
      Future.delayed(const Duration(milliseconds: 50), () {
        cancelToken.cancel('user cancelled');
      });

      // Expect the upload to throw a ClientError with code 'RequestCancelled'
      try {
        await client.putObject(request, options);
        fail('Expected a ClientError to be thrown due to cancellation');
      } catch (e) {
        expect(e, isA<ClientError>());
        final clientError = e as ClientError;
        expect(clientError.code, equals('RequestCancelled'));
      }

      // Test 2: Cancel immediately before the request starts
      final cancelToken2 = CancelToken();
      cancelToken2.cancel('pre-cancelled');

      final options2 = OperationOptions(cancelToken: cancelToken2);

      try {
        await client.putObject(request, options2);
        fail('Expected a ClientError to be thrown due to pre-cancellation');
      } catch (e) {
        expect(e, isA<ClientError>());
        final clientError = e as ClientError;
        expect(clientError.code, equals('RequestCancelled'));
      }
    });

    // =========================================================================
    // GetObject Enhanced Tests
    // =========================================================================

    test('testGetObjectAndCheckCRC', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList(
        List.generate(100 * 1024, (i) => i % 256),
      );

      // Upload object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      final putResult = await client.putObject(putRequest);
      expect(putResult.statusCode, equals(200));
      final uploadCrc = putResult.hashCrc64ecma;

      // Download and verify CRC (CRC check is enabled by default)
      final getRequest = GetObjectRequest(bucket: bucketName, key: objectKey);
      final getResult = await client.getObject(getRequest);
      expect(getResult.statusCode, equals(200));
      expect(getResult.hashCrc64ecma, isNotNull);
      expect(getResult.hashCrc64ecma, equals(uploadCrc));

      final bodyData = await getResult.body?.readData();
      expect(bodyData!.length, equals(data.length));
    });

    test('testGetObjectAndCheckCRCWithFile', () async {
      final objectKey = testCase.randomObjectName();
      final content = 'hello oss - file CRC test' * 1000;
      final data = Uint8List.fromList(content.codeUnits);

      // Upload object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      final putResult = await client.putObject(putRequest);
      expect(putResult.statusCode, equals(200));
      final uploadCrc = putResult.hashCrc64ecma;

      // Download to file
      final downloadFileName = testCase.randomFileName();
      final downloadPath =
          '${testCase.tempDir}${Platform.pathSeparator}$downloadFileName';
      await Directory(testCase.tempDir).create(recursive: true);

      final getRequest = GetObjectRequest(bucket: bucketName, key: objectKey);
      final getResult = await client.getObjectToFile(getRequest, downloadPath);
      expect(getResult.statusCode, equals(200));
      expect(getResult.hashCrc64ecma, equals(uploadCrc));

      // Verify file content
      final downloadedFile = File(downloadPath);
      expect(await downloadedFile.exists(), isTrue);
      final fileContent = await downloadedFile.readAsString();
      expect(fileContent, equals(content));

      await testCase.removeTestFile(downloadPath);
    });

    test('testGetObjectWithModifiedSince', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - modified since'.codeUnits);

      // Upload object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Use a date in the past - object was modified after this date, so returns 200
      final pastDate = 'Fri, 01 Jan 2021 00:00:00 GMT';
      final getRequest = GetObjectRequest(
        bucket: bucketName,
        key: objectKey,
        ifModifiedSince: pastDate,
      );
      final getResult = await client.getObject(getRequest);
      expect(getResult.statusCode, equals(200));
    });

    test('testGetObjectWithUnmodifiedSince', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - unmodified since'.codeUnits);

      // Upload object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Use a date in the future - object was modified before this date, so returns 200
      final futureDate = 'Fri, 01 Jan 2100 00:00:00 GMT';
      final getRequest = GetObjectRequest(
        bucket: bucketName,
        key: objectKey,
        ifUnmodifiedSince: futureDate,
      );
      final getResult = await client.getObject(getRequest);
      expect(getResult.statusCode, equals(200));
    });

    test('testGetObjectWithMatchingETag', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - match etag'.codeUnits);

      // Upload object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      final putResult = await client.putObject(putRequest);
      final etag = putResult.etag;
      expect(etag, isNotNull);

      // If-Match with correct ETag should return 200
      final getRequest = GetObjectRequest(
        bucket: bucketName,
        key: objectKey,
        ifMatch: etag,
      );
      final getResult = await client.getObject(getRequest);
      expect(getResult.statusCode, equals(200));
    });

    test('testGetObjectWithNomatchingETag', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - none match etag'.codeUnits);

      // Upload object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      final putResult = await client.putObject(putRequest);
      final etag = putResult.etag;
      expect(etag, isNotNull);

      // If-None-Match with same ETag should return 304
      try {
        final getRequest = GetObjectRequest(
          bucket: bucketName,
          key: objectKey,
          ifNoneMatch: etag,
        );
        final getResult = await client.getObject(getRequest);
        // Server returns 304 Not Modified
        expect(getResult.statusCode, equals(304));
      } catch (error) {
        // SDK might throw an error for 304 response
        if (error is ServerError) {
          expect(error.statusCode, equals(304));
        }
      }
    });

    test('testGetObjectWithWrongPath', () async {
      // Try to get a non-existent object
      final objectKey = 'non-existent-object-${testCase.randomObjectName()}';

      await expectAsyncError(
        () => client.getObject(
          GetObjectRequest(bucket: bucketName, key: objectKey),
        ),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    // =========================================================================
    // Head/Meta Enhanced Tests
    // =========================================================================

    test('testHeadObjectWithModifiedSince', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - head modified'.codeUnits);

      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Past date - object was modified after this, should return 200
      final pastDate = 'Fri, 01 Jan 2021 00:00:00 GMT';
      final headRequest = HeadObjectRequest(
        bucket: bucketName,
        key: objectKey,
        ifModifiedSince: pastDate,
      );
      final headResult = await client.headObject(headRequest);
      expect(headResult.statusCode, equals(200));
    });

    test('testHeadObjectWithUnmodifiedSince', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - head unmodified'.codeUnits);

      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Future date - object was not modified since this, should return 200
      final futureDate = 'Fri, 01 Jan 2100 00:00:00 GMT';
      final headRequest = HeadObjectRequest(
        bucket: bucketName,
        key: objectKey,
        ifUnmodifiedSince: futureDate,
      );
      final headResult = await client.headObject(headRequest);
      expect(headResult.statusCode, equals(200));
    });

    test('testHeadObjectWithMatchingETag', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss - head match etag'.codeUnits);

      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      final putResult = await client.putObject(putRequest);
      final etag = putResult.etag;

      // If-Match with correct ETag should return 200
      final headRequest = HeadObjectRequest(
        bucket: bucketName,
        key: objectKey,
        ifMatch: etag,
      );
      final headResult = await client.headObject(headRequest);
      expect(headResult.statusCode, equals(200));
    });

    test('testHeadObjectWithNomatchingETag', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList(
        'hello oss - head none match etag'.codeUnits,
      );

      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      final putResult = await client.putObject(putRequest);
      final etag = putResult.etag;

      // If-None-Match with same ETag should return 304
      try {
        final headRequest = HeadObjectRequest(
          bucket: bucketName,
          key: objectKey,
          ifNoneMatch: etag,
        );
        final headResult = await client.headObject(headRequest);
        expect(headResult.statusCode, equals(304));
      } catch (error) {
        if (error is ServerError) {
          expect(error.statusCode, equals(304));
        }
      }
    });

    test('testGetObjectMetaFail', () async {
      // Try to get metadata of a non-existent object
      final objectKey = 'non-existent-${testCase.randomObjectName()}';

      await expectAsyncError(
        () => client.getObjectMeta(
          GetObjectMetaRequest(bucket: bucketName, key: objectKey),
        ),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testGetObjectMetaWithAppendFile', () async {
      final objectKey = testCase.randomObjectName();
      final content1 = 'hello ';
      final content2 = 'append world';
      final data1 = Uint8List.fromList(content1.codeUnits);
      final data2 = Uint8List.fromList(content2.codeUnits);

      // First append
      final appendRequest1 = AppendObjectRequest(
        bucket: bucketName,
        key: objectKey,
        position: 0,
        body: ByteStream.fromData(data1),
      );
      final appendResult1 = await client.appendObject(appendRequest1);
      expect(appendResult1.statusCode, equals(200));

      // Second append
      final appendRequest2 = AppendObjectRequest(
        bucket: bucketName,
        key: objectKey,
        position: appendResult1.nextAppendPosition,
        body: ByteStream.fromData(data2),
        initHashCrc64: appendResult1.hashCrc64ecma,
      );
      await client.appendObject(appendRequest2);

      // Get metadata
      final metaRequest = GetObjectMetaRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final metaResult = await client.getObjectMeta(metaRequest);
      expect(metaResult.statusCode, equals(200));
      expect(metaResult.contentLength, equals(data1.length + data2.length));
      expect(metaResult.etag, isNotNull);
      expect(metaResult.lastModified, isNotNull);
    });

    test('testGetObjectMetaWithTxtFile', () async {
      final objectKey = '${testCase.randomObjectName()}.txt';
      final content = 'hello oss - txt file meta test';
      final data = Uint8List.fromList(content.codeUnits);

      // Upload with explicit content-type
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
        contentType: 'text/plain',
      );
      await client.putObject(putRequest);

      // Verify via headObject for content-type
      final headRequest = HeadObjectRequest(bucket: bucketName, key: objectKey);
      final headResult = await client.headObject(headRequest);
      expect(headResult.statusCode, equals(200));
      expect(headResult.contentType, contains('text/plain'));
      expect(headResult.contentLength, equals(data.length));

      // Also verify via getObjectMeta
      final metaRequest = GetObjectMetaRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final metaResult = await client.getObjectMeta(metaRequest);
      expect(metaResult.statusCode, equals(200));
      expect(metaResult.contentLength, equals(data.length));
    });

    // =========================================================================
    // Copy Enhanced Tests
    // =========================================================================

    test('testCopyObjectWithHeader', () async {
      final srcObjectKey = testCase.randomObjectName();
      final destObjectKey = testCase.randomObjectName();
      final content = 'hello oss - copy with header';
      final data = Uint8List.fromList(content.codeUnits);

      // Upload source object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: srcObjectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Copy with custom metadata
      final copyRequest = CopyObjectRequest(
        bucket: bucketName,
        key: destObjectKey,
        sourceBucket: bucketName,
        sourceKey: srcObjectKey,
        metadataDirective: 'REPLACE',
        metadata: {'custom-key': 'custom-value', 'another': 'data'},
        contentType: 'application/octet-stream',
      );
      final copyResult = await client.copyObject(copyRequest);
      expect(copyResult.statusCode, equals(200));

      // Verify metadata on destination
      final headRequest = HeadObjectRequest(
        bucket: bucketName,
        key: destObjectKey,
      );
      final headResult = await client.headObject(headRequest);
      expect(headResult.statusCode, equals(200));
      expect(headResult.metadata?['custom-key'], equals('custom-value'));
      expect(headResult.metadata?['another'], equals('data'));
    });

    test('testCopyObjectWithoutSourceObject', () async {
      final srcObjectKey = 'non-existent-${testCase.randomObjectName()}';
      final destObjectKey = testCase.randomObjectName();

      // Copy from non-existent source should fail
      await expectAsyncError(
        () => client.copyObject(
          CopyObjectRequest(
            bucket: bucketName,
            key: destObjectKey,
            sourceBucket: bucketName,
            sourceKey: srcObjectKey,
          ),
        ),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testCopyObjectWithStorageClass', () async {
      final srcObjectKey = testCase.randomObjectName();
      final destObjectKey = testCase.randomObjectName();
      final content = 'hello oss - copy storage class';
      final data = Uint8List.fromList(content.codeUnits);

      // Upload source object as Standard
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: srcObjectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Copy with IA storage class
      final copyRequest = CopyObjectRequest(
        bucket: bucketName,
        key: destObjectKey,
        sourceBucket: bucketName,
        sourceKey: srcObjectKey,
        storageClass: 'IA',
        metadataDirective: 'REPLACE',
      );
      final copyResult = await client.copyObject(copyRequest);
      expect(copyResult.statusCode, equals(200));

      // Verify storage class
      final headRequest = HeadObjectRequest(
        bucket: bucketName,
        key: destObjectKey,
      );
      final headResult = await client.headObject(headRequest);
      expect(headResult.statusCode, equals(200));
      expect(headResult.storageClass, equals('IA'));
    });

    test('testCopyObjectWithTagging', () async {
      final srcObjectKey = testCase.randomObjectName();
      final destObjectKey = testCase.randomObjectName();
      final content = 'hello oss - copy tagging';
      final data = Uint8List.fromList(content.codeUnits);

      // Upload source object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: srcObjectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Copy with tagging
      final copyRequest = CopyObjectRequest(
        bucket: bucketName,
        key: destObjectKey,
        sourceBucket: bucketName,
        sourceKey: srcObjectKey,
        tagging: 'TagA=ValueA&TagB=ValueB',
        taggingDirective: 'Replace',
      );
      final copyResult = await client.copyObject(copyRequest);
      expect(copyResult.statusCode, equals(200));

      // Verify tagging
      final getTagRequest = GetObjectTaggingRequest(
        bucket: bucketName,
        key: destObjectKey,
      );
      final tagResult = await client.getObjectTagging(getTagRequest);
      expect(tagResult.statusCode, equals(200));
      expect(tagResult.tagging?.tagSet?.tags, isNotNull);
      expect(tagResult.tagging!.tagSet!.tags!.length, equals(2));
    });

    // =========================================================================
    // Append Enhanced Tests
    // =========================================================================

    test('testAppendObjectFail', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('normal object'.codeUnits);

      // Upload a normal (non-appendable) object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest);

      // Try to append to a non-appendable object should fail
      final appendData = Uint8List.fromList('append data'.codeUnits);
      await expectAsyncError(
        () => client.appendObject(
          AppendObjectRequest(
            bucket: bucketName,
            key: objectKey,
            position: data.length,
            body: ByteStream.fromData(appendData),
          ),
        ),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(409));
        },
      );
    });

    test('testAppendObjectWithCrc', () async {
      final objectKey = testCase.randomObjectName();
      final content1 = 'first part ';
      final content2 = 'second part';
      final data1 = Uint8List.fromList(content1.codeUnits);
      final data2 = Uint8List.fromList(content2.codeUnits);

      // First append
      final appendRequest1 = AppendObjectRequest(
        bucket: bucketName,
        key: objectKey,
        position: 0,
        body: ByteStream.fromData(data1),
      );
      final appendResult1 = await client.appendObject(appendRequest1);
      expect(appendResult1.statusCode, equals(200));
      expect(appendResult1.hashCrc64ecma, isNotNull);

      // Second append with initHashCrc64 for CRC continuation
      final appendRequest2 = AppendObjectRequest(
        bucket: bucketName,
        key: objectKey,
        position: appendResult1.nextAppendPosition,
        body: ByteStream.fromData(data2),
        initHashCrc64: appendResult1.hashCrc64ecma,
      );
      final appendResult2 = await client.appendObject(appendRequest2);
      expect(appendResult2.statusCode, equals(200));
      expect(appendResult2.hashCrc64ecma, isNotNull);

      // Verify concatenated content
      final getRequest = GetObjectRequest(bucket: bucketName, key: objectKey);
      final getResult = await client.getObject(getRequest);
      final bodyData = await getResult.body?.readData();
      expect(String.fromCharCodes(bodyData!), equals(content1 + content2));
    });

    test('testAppendObjectWithErrorCrc', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss'.codeUnits);

      // Create a dedicated client with retryMaxAttempts: 0 to prevent
      // retrying on InconsistentError (which is retryable by default).
      // CRC64 upload validation is enabled by default in the SDK.
      final crcClient = Client(
        Configuration(
          endpoint: testCase.endpoint,
          region: testCase.region,
          credentialsProvider: StaticCredentialsProvider(
            accessKeyId: testCase.accessKeyId,
            accessKeySecret: testCase.accessKeySecret,
          ),
          retryMaxAttempts: 0,
          enableUploadCRC64Validation: true,
        ),
      );

      // Append with a deliberately wrong initHashCrc64 value.
      // The SDK computes CRC on the body using this as initial seed,
      // then compares against the server's x-oss-hash-crc64ecma header.
      // Mismatch must throw ClientError with code 'InconsistentError'.
      const wrongCrc = 10;
      final appendRequest = AppendObjectRequest(
        bucket: bucketName,
        key: objectKey,
        position: 0,
        body: ByteStream.fromData(data),
        initHashCrc64: wrongCrc,
      );

      await expectAsyncError(
        () => crcClient.appendObject(appendRequest),
        message: 'Expected CRC InconsistentError but no error was thrown',
        errorHandler: (error) {
          expect(error, isA<ClientError>());
          final clientError = error as ClientError;
          expect(clientError.code, equals('InconsistentError'));
          expect(clientError.message, contains('crc is inconsistent'));
        },
      );

      // Clean up
      final deleteRequest = DeleteObjectRequest(
        bucket: bucketName,
        key: objectKey,
      );
      await client.deleteObject(deleteRequest);
    });

    test('testAppendObjectWithProgress', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList(
        List.generate(100 * 1024, (i) => i % 256),
      );
      var progressCalled = false;
      var lastTotalBytesTransferred = 0;

      final appendRequest = AppendObjectRequest(
        bucket: bucketName,
        key: objectKey,
        position: 0,
        body: ByteStream.fromData(data),
        progress: ProgressClosure((
          int bytesIncrement,
          int totalBytesTransferred,
          int totalBytesExpected,
        ) {
          progressCalled = true;
          expect(
            totalBytesTransferred,
            greaterThanOrEqualTo(lastTotalBytesTransferred),
          );
          lastTotalBytesTransferred = totalBytesTransferred;
        }),
      );

      final result = await client.appendObject(appendRequest);
      expect(result.statusCode, equals(200));
      expect(progressCalled, isTrue);
    });

    // =========================================================================
    // Delete Enhanced Tests
    // =========================================================================

    test('testDeleteMultipleObjectsWithQuiet', () async {
      final objectKeys = <String>[];
      for (var i = 0; i < 5; i++) {
        final objectKey = testCase.randomObjectName();
        objectKeys.add(objectKey);
        final data = Uint8List.fromList('hello delete quiet $i'.codeUnits);
        await client.putObject(
          PutObjectRequest(
            bucket: bucketName,
            key: objectKey,
            body: ByteStream.fromData(data),
          ),
        );
      }

      // Delete with quiet mode (no response body for deleted objects)
      final deleteRequest = DeleteMultipleObjectsRequest(
        bucket: bucketName,
        delete: Delete(
          objects: objectKeys.map((key) => DeleteObject(key: key)).toList(),
          quiet: true,
        ),
      );
      final deleteResult = await client.deleteMultipleObjects(deleteRequest);
      expect(deleteResult.statusCode, equals(200));
      // In quiet mode, deletedObjects should be null
      expect(deleteResult.deletedObjects, isNull);

      // Verify all objects are deleted
      for (final key in objectKeys) {
        final exists = await client.isObjectExist(bucketName, key);
        expect(exists, isFalse);
      }
    });

    test('testDeleteMultiplePartialObjects', () async {
      // Create only some objects
      final existingKey1 = testCase.randomObjectName();
      final existingKey2 = testCase.randomObjectName();
      final nonExistingKey = testCase.randomObjectName();

      await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: existingKey1,
          body: ByteStream.fromData(Uint8List.fromList('data1'.codeUnits)),
        ),
      );
      await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: existingKey2,
          body: ByteStream.fromData(Uint8List.fromList('data2'.codeUnits)),
        ),
      );

      // Delete mix of existing and non-existing objects (non-quiet mode)
      final deleteRequest = DeleteMultipleObjectsRequest(
        bucket: bucketName,
        delete: Delete(
          objects: [
            DeleteObject(key: existingKey1),
            DeleteObject(key: existingKey2),
            DeleteObject(key: nonExistingKey),
          ],
          quiet: false,
        ),
      );
      final deleteResult = await client.deleteMultipleObjects(deleteRequest);
      expect(deleteResult.statusCode, equals(200));
      // All requested objects should be reported as deleted
      expect(deleteResult.deletedObjects, isNotNull);
      expect(deleteResult.deletedObjects!.length, equals(3));

      // Verify objects are deleted
      expect(await client.isObjectExist(bucketName, existingKey1), isFalse);
      expect(await client.isObjectExist(bucketName, existingKey2), isFalse);
    });

    test('testDeleteMultiplePartialObjectsWithVersion', () async {
      // First enable versioning on the bucket
      try {
        final versioningRequest = PutBucketVersioningRequest(
          bucket: bucketName,
          versioningConfiguration: VersioningConfiguration(status: 'Enabled'),
        );
        await client.putBucketVersioning(versioningRequest);
      } catch (_) {
        // Skip if versioning cannot be enabled
        return;
      }

      // Upload objects (will get version IDs)
      final objectKey = testCase.randomObjectName();
      final data1 = Uint8List.fromList('version 1'.codeUnits);
      final data2 = Uint8List.fromList('version 2'.codeUnits);

      final putResult1 = await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromData(data1),
        ),
      );
      final versionId1 = putResult1.versionId;

      final putResult2 = await client.putObject(
        PutObjectRequest(
          bucket: bucketName,
          key: objectKey,
          body: ByteStream.fromData(data2),
        ),
      );
      final versionId2 = putResult2.versionId;

      if (versionId1 == null || versionId2 == null) {
        // Versioning not properly enabled, skip
        return;
      }

      // Delete specific versions
      final deleteRequest = DeleteMultipleObjectsRequest(
        bucket: bucketName,
        delete: Delete(
          objects: [
            DeleteObject(key: objectKey, versionId: versionId1),
            DeleteObject(key: objectKey, versionId: versionId2),
          ],
          quiet: false,
        ),
      );
      final deleteResult = await client.deleteMultipleObjects(deleteRequest);
      expect(deleteResult.statusCode, equals(200));
      expect(deleteResult.deletedObjects, isNotNull);
    });

    // =========================================================================
    // Other Enhanced Tests
    // =========================================================================

    test('testAsyncPutObject', () async {
      // Upload multiple objects concurrently
      final futures = <Future<PutObjectResult>>[];
      final objectKeys = <String>[];

      for (var i = 0; i < 5; i++) {
        final objectKey = testCase.randomObjectName();
        objectKeys.add(objectKey);
        final data = Uint8List.fromList('async upload $i - data'.codeUnits);
        futures.add(
          client.putObject(
            PutObjectRequest(
              bucket: bucketName,
              key: objectKey,
              body: ByteStream.fromData(data),
            ),
          ),
        );
      }

      final results = await Future.wait(futures);
      for (final result in results) {
        expect(result.statusCode, equals(200));
      }

      // Verify all objects exist
      for (final key in objectKeys) {
        final exists = await client.isObjectExist(bucketName, key);
        expect(exists, isTrue);
      }
    });

    test('testConcurrencyGetObject', () async {
      // Upload multiple objects first
      final objectKeys = <String>[];
      for (var i = 0; i < 5; i++) {
        final objectKey = testCase.randomObjectName();
        objectKeys.add(objectKey);
        final data = Uint8List.fromList(
          'concurrency get $i - data content'.codeUnits,
        );
        await client.putObject(
          PutObjectRequest(
            bucket: bucketName,
            key: objectKey,
            body: ByteStream.fromData(data),
          ),
        );
      }

      // Download all concurrently
      final futures = <Future<GetObjectResult>>[];
      for (final key in objectKeys) {
        futures.add(
          client.getObject(GetObjectRequest(bucket: bucketName, key: key)),
        );
      }

      final results = await Future.wait(futures);
      for (var i = 0; i < results.length; i++) {
        expect(results[i].statusCode, equals(200));
        final bodyData = await results[i].body?.readData();
        expect(bodyData, isNotNull);
        expect(
          String.fromCharCodes(bodyData!),
          equals('concurrency get $i - data content'),
        );
      }
    });

    test('testSerialGetObject', () async {
      // Upload multiple objects first
      final objectKeys = <String>[];
      for (var i = 0; i < 3; i++) {
        final objectKey = testCase.randomObjectName();
        objectKeys.add(objectKey);
        final data = Uint8List.fromList(
          'serial get $i - data content'.codeUnits,
        );
        await client.putObject(
          PutObjectRequest(
            bucket: bucketName,
            key: objectKey,
            body: ByteStream.fromData(data),
          ),
        );
      }

      // Download serially and verify each
      for (var i = 0; i < objectKeys.length; i++) {
        final getResult = await client.getObject(
          GetObjectRequest(bucket: bucketName, key: objectKeys[i]),
        );
        expect(getResult.statusCode, equals(200));
        final bodyData = await getResult.body?.readData();
        expect(
          String.fromCharCodes(bodyData!),
          equals('serial get $i - data content'),
        );
      }
    });

    test('testRestoreObjectFail', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('not archive object'.codeUnits);

      // Upload as Standard storage class (not Archive)
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(data),
        storageClass: 'Standard',
      );
      await client.putObject(putRequest);

      // Restore should fail on non-archive objects
      await expectAsyncError(
        () => client.restoreObject(
          RestoreObjectRequest(
            bucket: bucketName,
            key: objectKey,
            restoreRequest: RestoreRequest(days: 1),
          ),
        ),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          // 400 OperationNotSupported for non-archive objects
          expect(serverError.statusCode, equals(400));
        },
      );
    });

    test('testPutObjectStorageClass', () async {
      final objectKey = testCase.randomObjectName();

      // Test PutObject with Standard StorageClass
      var storageClass = 'Standard';
      var putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        storageClass: storageClass,
      );
      var putResult = await client.putObject(putRequest);
      expect(putResult.statusCode, equals(200));

      var headRequest = HeadObjectRequest(bucket: bucketName, key: objectKey);
      var headResult = await client.headObject(headRequest);
      expect(headResult.storageClass, equals(storageClass));

      // Test PutObject with IA StorageClass
      storageClass = 'IA';
      putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        storageClass: storageClass,
      );
      putResult = await client.putObject(putRequest);
      expect(putResult.statusCode, equals(200));

      headRequest = HeadObjectRequest(bucket: bucketName, key: objectKey);
      headResult = await client.headObject(headRequest);
      expect(headResult.storageClass, equals(storageClass));

      // Test PutObject with Archive StorageClass
      storageClass = 'Archive';
      putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        storageClass: storageClass,
      );
      putResult = await client.putObject(putRequest);
      expect(putResult.statusCode, equals(200));

      headRequest = HeadObjectRequest(bucket: bucketName, key: objectKey);
      headResult = await client.headObject(headRequest);
      expect(headResult.storageClass, equals(storageClass));

      // Test PutObject with ColdArchive StorageClass
      storageClass = 'ColdArchive';
      putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        storageClass: storageClass,
      );
      putResult = await client.putObject(putRequest);
      expect(putResult.statusCode, equals(200));

      headRequest = HeadObjectRequest(bucket: bucketName, key: objectKey);
      headResult = await client.headObject(headRequest);
      expect(headResult.storageClass, equals(storageClass));
    });

    test('testPutObjectWithClientError', () async {
      final data = Uint8List.fromList('hello oss'.codeUnits);
      final objectKey = testCase.randomObjectName();

      // Use an invalid bucket name to trigger client validation error
      final request = PutObjectRequest(
        bucket: 'invalid-bucket-name_',
        key: objectKey,
        body: ByteStream.fromData(data),
      );

      await expectAsyncError(
        () => client.putObject(request),
        errorHandler: (error) {
          expect(error, isA<ClientError>());
          final clientError = error as ClientError;
          expect(clientError.message, contains('Bucket name is invalid'));
        },
      );
    });

    test('testPutObjectWithServerError', () async {
      final objectKey = testCase.randomObjectName();
      final data = Uint8List.fromList('hello oss'.codeUnits);

      // Use a non-existent bucket to trigger server error
      final request = PutObjectRequest(
        bucket: 'non-existent-bucket-for-test',
        key: objectKey,
        body: ByteStream.fromData(data),
      );

      await expectAsyncError(
        () => client.putObject(request),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testCopyObjectWithACL', () async {
      final data = Uint8List.fromList('hello oss - copy acl test'.codeUnits);
      final sourceObjectKey = testCase.randomObjectName();
      final targetObjectKey = testCase.randomObjectName();
      final acls = ['default', 'private'];

      // Upload source object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: sourceObjectKey,
        body: ByteStream.fromData(data),
        metadata: {'originalKey': 'originalValue'},
      );
      final putResult = await client.putObject(putRequest);
      expect(putResult.statusCode, equals(200));

      // Upload target object
      final putRequest2 = PutObjectRequest(
        bucket: bucketName,
        key: targetObjectKey,
        body: ByteStream.fromData(data),
      );
      await client.putObject(putRequest2);

      // Copy with each ACL and verify
      for (final acl in acls) {
        final copyRequest = CopyObjectRequest(
          bucket: bucketName,
          key: targetObjectKey,
          sourceBucket: bucketName,
          sourceKey: sourceObjectKey,
          objectAcl: acl,
        );
        final copyResult = await client.copyObject(copyRequest);
        expect(copyResult.statusCode, equals(200));

        final getAclRequest = GetObjectAclRequest(
          bucket: bucketName,
          key: targetObjectKey,
        );
        final getAclResult = await client.getObjectAcl(getAclRequest);
        expect(
          getAclResult.accessControlPolicy?.accessControlList?.grant,
          equals(acl),
        );
      }
    });

    test('testAppendObjectWithFile', () async {
      final objectKey = testCase.randomObjectName();
      final fileSize = 100 * 1024; // 100KB
      final fileName = testCase.randomFileName();
      final filePath = await testCase.createTestFileWithSize(
        fileName,
        fileSize,
      );
      expect(filePath, isNotNull);

      final file = File(filePath!);
      final count = 5;
      var uploadedCount = 0;
      int? crc;

      // Append the file multiple times
      while (uploadedCount < count) {
        final request = AppendObjectRequest(
          bucket: bucketName,
          key: objectKey,
          position: uploadedCount * fileSize,
          body: ByteStream.fromFile(file),
          initHashCrc64: crc,
        );
        final result = await client.appendObject(request);
        expect(result.statusCode, equals(200));
        expect(result.nextAppendPosition, isNotNull);
        // hashCrc64ecma may be null when uploading from file
        crc = result.hashCrc64ecma;
        uploadedCount++;
      }

      // Verify total content length
      final getRequest = GetObjectRequest(bucket: bucketName, key: objectKey);
      final getResult = await client.getObject(getRequest);
      expect(getResult.statusCode, equals(200));
      final bodyData = await getResult.body?.readData();
      expect(bodyData, isNotNull);
      expect(bodyData!.length, equals(fileSize * count));

      // Clean up
      await testCase.removeTestFile(filePath);
    });
  }, skip: BaseTestCase.skipReason);
}
