import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

import 'base_test_case.dart';

void main() {
  group('ClientObjectMultipartTests', () {
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

    test('testInitiateMultipartUpload', () async {
      final objectKey = testCase.randomObjectName();

      // Initiate multipart upload
      final request = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final result = await client.initiateMultipartUpload(request);

      // Verify
      expect(result.statusCode, equals(200));
      expect(result.uploadId, isNotNull);
      expect(result.uploadId, isNotEmpty);

      // Cleanup: abort the upload
      final abortRequest = AbortMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: result.uploadId,
      );
      await client.abortMultipartUpload(abortRequest);
    });

    test('testUploadPart', () async {
      final objectKey = testCase.randomObjectName();

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.uploadId, isNotNull);

      // Upload a part (100KB)
      final partData = _generateRandomData(100 * 1024);
      final uploadPartRequest = UploadPartRequest(
        bucket: bucketName,
        key: objectKey,
        partNumber: 1,
        uploadId: initResult.uploadId,
        body: ByteStream.fromData(partData),
      );
      final uploadPartResult = await client.uploadPart(uploadPartRequest);

      // Verify
      expect(uploadPartResult.statusCode, equals(200));
      expect(uploadPartResult.etag, isNotNull);
      expect(uploadPartResult.etag, isNotEmpty);

      // Cleanup: abort the upload
      final abortRequest = AbortMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
      );
      await client.abortMultipartUpload(abortRequest);
    });

    test('testCompleteMultipartUpload', () async {
      final objectKey = testCase.randomObjectName();

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.uploadId, isNotNull);

      // Upload part 1 (100KB)
      final partData1 = _generateRandomData(100 * 1024);
      final uploadPart1Request = UploadPartRequest(
        bucket: bucketName,
        key: objectKey,
        partNumber: 1,
        uploadId: initResult.uploadId,
        body: ByteStream.fromData(partData1),
      );
      final uploadPart1Result = await client.uploadPart(uploadPart1Request);
      expect(uploadPart1Result.etag, isNotNull);

      // Upload part 2 (100KB)
      final partData2 = _generateRandomData(100 * 1024);
      final uploadPart2Request = UploadPartRequest(
        bucket: bucketName,
        key: objectKey,
        partNumber: 2,
        uploadId: initResult.uploadId,
        body: ByteStream.fromData(partData2),
      );
      final uploadPart2Result = await client.uploadPart(uploadPart2Request);
      expect(uploadPart2Result.etag, isNotNull);

      // Complete multipart upload
      final completeRequest = CompleteMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
        completeMultipartUpload: CompleteMultipartUpload(
          parts: [
            UploadPart(partNumber: 1, etag: uploadPart1Result.etag),
            UploadPart(partNumber: 2, etag: uploadPart2Result.etag),
          ],
        ),
      );
      final completeResult = await client.completeMultipartUpload(
        completeRequest,
      );

      // Verify
      expect(completeResult.statusCode, equals(200));
      expect(completeResult.bucket, equals(bucketName));
      expect(completeResult.key, equals(objectKey));
      expect(completeResult.etag, isNotNull);

      // Verify the object exists
      final exists = await client.isObjectExist(bucketName, objectKey);
      expect(exists, isTrue);
    });

    test('testAbortMultipartUpload', () async {
      final objectKey = testCase.randomObjectName();

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.uploadId, isNotNull);

      // Abort the multipart upload
      final abortRequest = AbortMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
      );
      final abortResult = await client.abortMultipartUpload(abortRequest);
      expect(abortResult.statusCode, equals(204));

      // Verify: listing parts for the aborted upload should fail
      await expectAsyncError(() async {
        final listPartsRequest = ListPartsRequest(
          bucket: bucketName,
          key: objectKey,
          uploadId: initResult.uploadId,
        );
        await client.listParts(listPartsRequest);
      });
    });

    test('testListMultipartUploads', () async {
      final prefix = 'multipart-list-test-${BaseTestCase.randomStr(6)}/';
      final uploadIds = <String>[];

      // Initiate 3 multipart uploads
      for (var i = 0; i < 3; i++) {
        final initRequest = InitiateMultipartUploadRequest(
          bucket: bucketName,
          key: '${prefix}object-$i',
        );
        final initResult = await client.initiateMultipartUpload(initRequest);
        expect(initResult.uploadId, isNotNull);
        uploadIds.add(initResult.uploadId!);
      }

      // List multipart uploads with prefix
      final listRequest = ListMultipartUploadsRequest(
        bucket: bucketName,
        prefix: prefix,
      );
      final listResult = await client.listMultipartUploads(listRequest);

      // Verify
      expect(listResult.statusCode, equals(200));
      expect(listResult.uploads, isNotNull);
      expect(listResult.uploads!.length, equals(3));

      // Cleanup: abort all uploads
      for (var i = 0; i < 3; i++) {
        final abortRequest = AbortMultipartUploadRequest(
          bucket: bucketName,
          key: '${prefix}object-$i',
          uploadId: uploadIds[i],
        );
        await client.abortMultipartUpload(abortRequest);
      }
    });

    test('testListParts', () async {
      final objectKey = testCase.randomObjectName();

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.uploadId, isNotNull);

      // Upload 3 parts
      for (var i = 1; i <= 3; i++) {
        final partData = _generateRandomData(100 * 1024);
        final uploadPartRequest = UploadPartRequest(
          bucket: bucketName,
          key: objectKey,
          partNumber: i,
          uploadId: initResult.uploadId,
          body: ByteStream.fromData(partData),
        );
        final uploadPartResult = await client.uploadPart(uploadPartRequest);
        expect(uploadPartResult.etag, isNotNull);
      }

      // List parts
      final listPartsRequest = ListPartsRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
      );
      final listPartsResult = await client.listParts(listPartsRequest);

      // Verify
      expect(listPartsResult.statusCode, equals(200));
      expect(listPartsResult.parts, isNotNull);
      expect(listPartsResult.parts!.length, equals(3));
      expect(listPartsResult.parts![0].partNumber, equals(1));
      expect(listPartsResult.parts![1].partNumber, equals(2));
      expect(listPartsResult.parts![2].partNumber, equals(3));

      // Verify each part has expected size
      for (final part in listPartsResult.parts!) {
        expect(part.size, equals(100 * 1024));
        expect(part.etag, isNotNull);
      }

      // Cleanup: abort the upload
      final abortRequest = AbortMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
      );
      await client.abortMultipartUpload(abortRequest);
    });

    test('testUploadPartCopy', () async {
      final sourceKey = testCase.randomObjectName();
      final destKey = testCase.randomObjectName();

      // Upload a source object (200KB)
      final sourceData = _generateRandomData(200 * 1024);
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: sourceKey,
        body: ByteStream.fromData(sourceData),
      );
      await client.putObject(putRequest);

      // Initiate multipart upload for destination
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: destKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.uploadId, isNotNull);

      // Copy source object as part 1
      final copyPartRequest = UploadPartCopyRequest(
        bucket: bucketName,
        key: destKey,
        sourceBucket: bucketName,
        sourceKey: sourceKey,
        partNumber: 1,
        uploadId: initResult.uploadId,
      );
      final copyPartResult = await client.uploadPartCopy(copyPartRequest);

      // Verify
      expect(copyPartResult.statusCode, equals(200));
      expect(copyPartResult.copyPartResult, isNotNull);
      expect(copyPartResult.copyPartResult!.etag, isNotNull);
      expect(copyPartResult.copyPartResult!.etag, isNotEmpty);

      // Complete the multipart upload
      final completeRequest = CompleteMultipartUploadRequest(
        bucket: bucketName,
        key: destKey,
        uploadId: initResult.uploadId,
        completeMultipartUpload: CompleteMultipartUpload(
          parts: [
            UploadPart(
              partNumber: 1,
              etag: copyPartResult.copyPartResult!.etag,
            ),
          ],
        ),
      );
      final completeResult = await client.completeMultipartUpload(
        completeRequest,
      );
      expect(completeResult.statusCode, equals(200));

      // Verify the destination object exists
      final exists = await client.isObjectExist(bucketName, destKey);
      expect(exists, isTrue);
    });

    test('testMultipartUploadFull', () async {
      final objectKey = testCase.randomObjectName();
      const totalSize = 200 * 1024; // 200KB
      const partSize = 100 * 1024; // 100KB

      // Create 200KB data
      final fullData = _generateRandomData(totalSize);

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.statusCode, equals(200));
      expect(initResult.uploadId, isNotNull);

      // Upload 2 parts of 100KB each
      final parts = <UploadPart>[];
      final partCount = (totalSize / partSize).ceil();

      for (var i = 0; i < partCount; i++) {
        final start = i * partSize;
        final end = (start + partSize) > totalSize
            ? totalSize
            : (start + partSize);
        final partData = fullData.sublist(start, end);

        final uploadPartRequest = UploadPartRequest(
          bucket: bucketName,
          key: objectKey,
          partNumber: i + 1,
          uploadId: initResult.uploadId,
          body: ByteStream.fromData(Uint8List.fromList(partData)),
        );
        final uploadPartResult = await client.uploadPart(uploadPartRequest);
        expect(uploadPartResult.statusCode, equals(200));
        expect(uploadPartResult.etag, isNotNull);

        parts.add(UploadPart(partNumber: i + 1, etag: uploadPartResult.etag));
      }

      // Complete multipart upload
      final completeRequest = CompleteMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
        completeMultipartUpload: CompleteMultipartUpload(parts: parts),
      );
      final completeResult = await client.completeMultipartUpload(
        completeRequest,
      );
      expect(completeResult.statusCode, equals(200));
      expect(completeResult.etag, isNotNull);

      // Download and verify content length
      final getRequest = GetObjectRequest(bucket: bucketName, key: objectKey);
      final getResult = await client.getObject(getRequest);
      expect(getResult.statusCode, equals(200));
      expect(getResult.contentLength, equals(totalSize));

      // Read the body and verify the data length
      final bodyData = await getResult.body?.readData();
      expect(bodyData, isNotNull);
      expect(bodyData!.length, equals(totalSize));

      // Verify the downloaded data matches the original data
      for (var i = 0; i < totalSize; i++) {
        expect(bodyData[i], equals(fullData[i]));
      }
    });

    // =========================================================================
    // Initiate Options (3)
    // =========================================================================

    test('testInitiateMultipartUploadWithOverwrite', () async {
      final objectKey = testCase.randomObjectName();

      // First, put an existing object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(_generateRandomData(1024)),
      );
      await client.putObject(putRequest);

      // Initiate multipart upload with forbidOverwrite=true should fail
      // because the object already exists
      await expectAsyncError(
        () async {
          final initRequest = InitiateMultipartUploadRequest(
            bucket: bucketName,
            key: objectKey,
            forbidOverwrite: true,
          );
          await client.initiateMultipartUpload(initRequest);
        },
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(409));
        },
      );
    });

    test('testInitiateMultipartUploadWithStorageClass', () async {
      final objectKey = testCase.randomObjectName();

      // Initiate multipart upload with IA storage class
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        storageClass: 'IA',
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.statusCode, equals(200));
      expect(initResult.uploadId, isNotNull);
      expect(initResult.uploadId, isNotEmpty);

      // Upload a part and complete to verify the storage class is set
      final partData = _generateRandomData(100 * 1024);
      final uploadPartRequest = UploadPartRequest(
        bucket: bucketName,
        key: objectKey,
        partNumber: 1,
        uploadId: initResult.uploadId,
        body: ByteStream.fromData(partData),
      );
      final uploadPartResult = await client.uploadPart(uploadPartRequest);
      expect(uploadPartResult.etag, isNotNull);

      // Complete the multipart upload
      final completeRequest = CompleteMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
        completeMultipartUpload: CompleteMultipartUpload(
          parts: [UploadPart(partNumber: 1, etag: uploadPartResult.etag)],
        ),
      );
      final completeResult = await client.completeMultipartUpload(
        completeRequest,
      );
      expect(completeResult.statusCode, equals(200));

      // Verify the object's storage class via HeadObject
      final headRequest = HeadObjectRequest(bucket: bucketName, key: objectKey);
      final headResult = await client.headObject(headRequest);
      expect(headResult.statusCode, equals(200));
      // IA storage class should be reflected
      expect(headResult.storageClass, equals('IA'));
    });

    test('testInitiateMultipartUploadWithMetadata', () async {
      final objectKey = testCase.randomObjectName();

      // Initiate multipart upload with custom metadata
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      initRequest.addHeader('x-oss-meta-custom-key', 'custom-value');
      initRequest.addHeader('x-oss-meta-author', 'dart-sdk-test');

      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.statusCode, equals(200));
      expect(initResult.uploadId, isNotNull);

      // Upload a part and complete
      final partData = _generateRandomData(100 * 1024);
      final uploadPartRequest = UploadPartRequest(
        bucket: bucketName,
        key: objectKey,
        partNumber: 1,
        uploadId: initResult.uploadId,
        body: ByteStream.fromData(partData),
      );
      final uploadPartResult = await client.uploadPart(uploadPartRequest);
      expect(uploadPartResult.etag, isNotNull);

      final completeRequest = CompleteMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
        completeMultipartUpload: CompleteMultipartUpload(
          parts: [UploadPart(partNumber: 1, etag: uploadPartResult.etag)],
        ),
      );
      final completeResult = await client.completeMultipartUpload(
        completeRequest,
      );
      expect(completeResult.statusCode, equals(200));

      // Verify metadata via HeadObject
      final headRequest = HeadObjectRequest(bucket: bucketName, key: objectKey);
      final headResult = await client.headObject(headRequest);
      expect(headResult.statusCode, equals(200));
      expect(headResult.metadata?['custom-key'], equals('custom-value'));
      expect(headResult.metadata?['author'], equals('dart-sdk-test'));
    });

    // =========================================================================
    // UploadPart Extensions (3)
    // =========================================================================

    test('testUploadPartError', () async {
      final objectKey = testCase.randomObjectName();

      // Upload a part with invalid uploadId should fail
      await expectAsyncError(() async {
        final partData = _generateRandomData(100 * 1024);
        final uploadPartRequest = UploadPartRequest(
          bucket: bucketName,
          key: objectKey,
          partNumber: 1,
          uploadId: 'invalid-upload-id-12345',
          body: ByteStream.fromData(partData),
        );
        await client.uploadPart(uploadPartRequest);
      });
    });

    test('testUploadPartWithProgress', () async {
      final objectKey = testCase.randomObjectName();

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.uploadId, isNotNull);

      // Upload a part with progress tracking
      final partData = _generateRandomData(100 * 1024);
      var progressCalled = false;
      var lastBytesTransferred = 0;

      final progressDelegate = ProgressClosure((
        int bytesIncrement,
        int totalBytesTransferred,
        int totalBytesExpected,
      ) {
        progressCalled = true;
        expect(
          totalBytesTransferred,
          greaterThanOrEqualTo(lastBytesTransferred),
        );
        lastBytesTransferred = totalBytesTransferred;
      });

      final uploadPartRequest = UploadPartRequest(
        bucket: bucketName,
        key: objectKey,
        partNumber: 1,
        uploadId: initResult.uploadId,
        body: ByteStream.fromData(partData),
        progress: progressDelegate,
      );
      final uploadPartResult = await client.uploadPart(uploadPartRequest);

      // Verify
      expect(uploadPartResult.statusCode, equals(200));
      expect(uploadPartResult.etag, isNotNull);
      expect(progressCalled, isTrue);
      expect(lastBytesTransferred, greaterThan(0));

      // Cleanup: abort the upload
      final abortRequest = AbortMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
      );
      await client.abortMultipartUpload(abortRequest);
    });

    test('testAbortMultipartUploadError', () async {
      final objectKey = testCase.randomObjectName();

      // Abort with invalid uploadId should fail
      await expectAsyncError(() async {
        final abortRequest = AbortMultipartUploadRequest(
          bucket: bucketName,
          key: objectKey,
          uploadId: 'invalid-upload-id-12345',
        );
        await client.abortMultipartUpload(abortRequest);
      });
    });

    // =========================================================================
    // Complete Options (5)
    // =========================================================================

    test(
      'testCompleteMultipartUploadWithCallback',
      () async {
        // Callback headers are now supported by the SDK, but this integration
        // test still requires a reachable callback service endpoint and a
        // deterministic response contract.
      },
      skip: 'Callback integration requires a dedicated callback service',
    );

    test('testCompleteMultipartUploadWithDisorganizedParts', () async {
      final objectKey = testCase.randomObjectName();

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.uploadId, isNotNull);

      // Upload 3 parts
      final etags = <int, String?>{};
      for (var i = 1; i <= 3; i++) {
        final partData = _generateRandomData(100 * 1024);
        final uploadPartRequest = UploadPartRequest(
          bucket: bucketName,
          key: objectKey,
          partNumber: i,
          uploadId: initResult.uploadId,
          body: ByteStream.fromData(partData),
        );
        final uploadPartResult = await client.uploadPart(uploadPartRequest);
        expect(uploadPartResult.etag, isNotNull);
        etags[i] = uploadPartResult.etag;
      }

      // Complete with disorganized part numbers (3, 1, 2)
      // OSS requires parts to be in ascending order by partNumber
      // and returns InvalidPartOrder error for disordered parts
      await expectAsyncError(
        () async {
          final completeRequest = CompleteMultipartUploadRequest(
            bucket: bucketName,
            key: objectKey,
            uploadId: initResult.uploadId,
            completeMultipartUpload: CompleteMultipartUpload(
              parts: [
                UploadPart(partNumber: 3, etag: etags[3]),
                UploadPart(partNumber: 1, etag: etags[1]),
                UploadPart(partNumber: 2, etag: etags[2]),
              ],
            ),
          );
          await client.completeMultipartUpload(completeRequest);
        },
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(400));
          expect(serverError.code, equals('InvalidPartOrder'));
        },
      );

      // Cleanup: abort the upload
      final abortRequest = AbortMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
      );
      try {
        await client.abortMultipartUpload(abortRequest);
      } catch (_) {}
    });

    test('testCompleteMultipartUploadWithOverwrite', () async {
      final objectKey = testCase.randomObjectName();

      // First, put an existing object
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: objectKey,
        body: ByteStream.fromData(_generateRandomData(1024)),
      );
      await client.putObject(putRequest);

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.uploadId, isNotNull);

      // Upload a part
      final partData = _generateRandomData(100 * 1024);
      final uploadPartRequest = UploadPartRequest(
        bucket: bucketName,
        key: objectKey,
        partNumber: 1,
        uploadId: initResult.uploadId,
        body: ByteStream.fromData(partData),
      );
      final uploadPartResult = await client.uploadPart(uploadPartRequest);
      expect(uploadPartResult.etag, isNotNull);

      // Complete with forbidOverwrite=true should fail
      await expectAsyncError(() async {
        final completeRequest = CompleteMultipartUploadRequest(
          bucket: bucketName,
          key: objectKey,
          uploadId: initResult.uploadId,
          forbidOverwrite: true,
          completeMultipartUpload: CompleteMultipartUpload(
            parts: [UploadPart(partNumber: 1, etag: uploadPartResult.etag)],
          ),
        );
        await client.completeMultipartUpload(completeRequest);
      });

      // Cleanup
      final abortRequest = AbortMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
      );
      try {
        await client.abortMultipartUpload(abortRequest);
      } catch (_) {}
    });

    test('testCompleteMultipartUploadWithPartialParts', () async {
      final objectKey = testCase.randomObjectName();

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.uploadId, isNotNull);

      // Upload 3 parts
      final etags = <int, String?>{};
      for (var i = 1; i <= 3; i++) {
        final partData = _generateRandomData(100 * 1024);
        final uploadPartRequest = UploadPartRequest(
          bucket: bucketName,
          key: objectKey,
          partNumber: i,
          uploadId: initResult.uploadId,
          body: ByteStream.fromData(partData),
        );
        final uploadPartResult = await client.uploadPart(uploadPartRequest);
        expect(uploadPartResult.etag, isNotNull);
        etags[i] = uploadPartResult.etag;
      }

      // Complete with only part 1 and part 3 (skip part 2)
      final completeRequest = CompleteMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
        completeMultipartUpload: CompleteMultipartUpload(
          parts: [
            UploadPart(partNumber: 1, etag: etags[1]),
            UploadPart(partNumber: 3, etag: etags[3]),
          ],
        ),
      );
      final completeResult = await client.completeMultipartUpload(
        completeRequest,
      );
      expect(completeResult.statusCode, equals(200));
      expect(completeResult.etag, isNotNull);

      // Verify the object exists with only 2 parts' data (200KB)
      final getRequest = GetObjectRequest(bucket: bucketName, key: objectKey);
      final getResult = await client.getObject(getRequest);
      expect(getResult.statusCode, equals(200));
      expect(getResult.contentLength, equals(200 * 1024));
    });

    test('testCompleteMultipartUploadWithParts', () async {
      final objectKey = testCase.randomObjectName();

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.uploadId, isNotNull);

      // Upload 5 parts of 100KB each
      final parts = <UploadPart>[];
      for (var i = 1; i <= 5; i++) {
        final partData = _generateRandomData(100 * 1024);
        final uploadPartRequest = UploadPartRequest(
          bucket: bucketName,
          key: objectKey,
          partNumber: i,
          uploadId: initResult.uploadId,
          body: ByteStream.fromData(partData),
        );
        final uploadPartResult = await client.uploadPart(uploadPartRequest);
        expect(uploadPartResult.etag, isNotNull);
        parts.add(UploadPart(partNumber: i, etag: uploadPartResult.etag));
      }

      // Complete with all 5 parts
      final completeRequest = CompleteMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
        completeMultipartUpload: CompleteMultipartUpload(parts: parts),
      );
      final completeResult = await client.completeMultipartUpload(
        completeRequest,
      );
      expect(completeResult.statusCode, equals(200));
      expect(completeResult.etag, isNotNull);
      expect(completeResult.bucket, equals(bucketName));
      expect(completeResult.key, equals(objectKey));

      // Verify the object size (500KB)
      final getRequest = GetObjectRequest(bucket: bucketName, key: objectKey);
      final getResult = await client.getObject(getRequest);
      expect(getResult.statusCode, equals(200));
      expect(getResult.contentLength, equals(500 * 1024));
    });

    // =========================================================================
    // ListUploads Parameters (5)
    // =========================================================================

    test('testListMultipartUploadsWithDelimiter', () async {
      final prefix = 'delimiter-test-${BaseTestCase.randomStr(6)}/';
      final uploadIds = <String>[];
      final keys = <String>[];

      // Create uploads with hierarchical keys
      final keysToCreate = [
        '${prefix}dir1/obj1',
        '${prefix}dir1/obj2',
        '${prefix}dir2/obj3',
        '${prefix}root-obj',
      ];

      for (final key in keysToCreate) {
        final initRequest = InitiateMultipartUploadRequest(
          bucket: bucketName,
          key: key,
        );
        final initResult = await client.initiateMultipartUpload(initRequest);
        expect(initResult.uploadId, isNotNull);
        uploadIds.add(initResult.uploadId!);
        keys.add(key);
      }

      // List with delimiter='/'
      final listRequest = ListMultipartUploadsRequest(
        bucket: bucketName,
        prefix: prefix,
        delimiter: '/',
      );
      final listResult = await client.listMultipartUploads(listRequest);
      expect(listResult.statusCode, equals(200));

      // Should have commonPrefixes for dir1/ and dir2/
      expect(listResult.commonPrefixes, isNotNull);
      expect(listResult.commonPrefixes!.length, equals(2));

      // Should have 1 direct upload (root-obj)
      expect(listResult.uploads, isNotNull);
      expect(listResult.uploads!.length, equals(1));

      // Cleanup
      for (var i = 0; i < keys.length; i++) {
        final abortRequest = AbortMultipartUploadRequest(
          bucket: bucketName,
          key: keys[i],
          uploadId: uploadIds[i],
        );
        try {
          await client.abortMultipartUpload(abortRequest);
        } catch (_) {}
      }
    });

    test('testListMultipartUploadsWithKeyMarker', () async {
      final prefix = 'keymarker-test-${BaseTestCase.randomStr(6)}/';
      final uploadIds = <String>[];

      // Create 3 uploads with sorted keys
      final sortedKeys = ['${prefix}aaa', '${prefix}bbb', '${prefix}ccc'];

      for (final key in sortedKeys) {
        final initRequest = InitiateMultipartUploadRequest(
          bucket: bucketName,
          key: key,
        );
        final initResult = await client.initiateMultipartUpload(initRequest);
        expect(initResult.uploadId, isNotNull);
        uploadIds.add(initResult.uploadId!);
      }

      // List with keyMarker set to the first key
      final listRequest = ListMultipartUploadsRequest(
        bucket: bucketName,
        prefix: prefix,
        keyMarker: sortedKeys[0],
      );
      final listResult = await client.listMultipartUploads(listRequest);
      expect(listResult.statusCode, equals(200));
      expect(listResult.uploads, isNotNull);
      // Should return uploads after 'aaa' (i.e., 'bbb' and 'ccc')
      expect(listResult.uploads!.length, equals(2));

      // Cleanup
      for (var i = 0; i < sortedKeys.length; i++) {
        final abortRequest = AbortMultipartUploadRequest(
          bucket: bucketName,
          key: sortedKeys[i],
          uploadId: uploadIds[i],
        );
        try {
          await client.abortMultipartUpload(abortRequest);
        } catch (_) {}
      }
    });

    test('testListMultipartUploadsWithMaxUploads', () async {
      final prefix = 'maxuploads-test-${BaseTestCase.randomStr(6)}/';
      final uploadIds = <String>[];
      final keys = <String>[];

      // Create 5 uploads
      for (var i = 0; i < 5; i++) {
        final key = '${prefix}object-$i';
        final initRequest = InitiateMultipartUploadRequest(
          bucket: bucketName,
          key: key,
        );
        final initResult = await client.initiateMultipartUpload(initRequest);
        expect(initResult.uploadId, isNotNull);
        uploadIds.add(initResult.uploadId!);
        keys.add(key);
      }

      // List with maxUploads=2
      final listRequest = ListMultipartUploadsRequest(
        bucket: bucketName,
        prefix: prefix,
        maxUploads: 2,
      );
      final listResult = await client.listMultipartUploads(listRequest);
      expect(listResult.statusCode, equals(200));
      expect(listResult.uploads, isNotNull);
      expect(listResult.uploads!.length, equals(2));
      expect(listResult.isTruncated, isTrue);

      // Cleanup
      for (var i = 0; i < keys.length; i++) {
        final abortRequest = AbortMultipartUploadRequest(
          bucket: bucketName,
          key: keys[i],
          uploadId: uploadIds[i],
        );
        try {
          await client.abortMultipartUpload(abortRequest);
        } catch (_) {}
      }
    });

    test('testListMultipartUploadsWithPrefix', () async {
      final prefix1 = 'prefix-test-${BaseTestCase.randomStr(6)}-group1/';
      final prefix2 = 'prefix-test-${BaseTestCase.randomStr(6)}-group2/';
      final allUploadIds = <String>[];
      final allKeys = <String>[];

      // Create 2 uploads under prefix1
      for (var i = 0; i < 2; i++) {
        final key = '${prefix1}object-$i';
        final initRequest = InitiateMultipartUploadRequest(
          bucket: bucketName,
          key: key,
        );
        final initResult = await client.initiateMultipartUpload(initRequest);
        expect(initResult.uploadId, isNotNull);
        allUploadIds.add(initResult.uploadId!);
        allKeys.add(key);
      }

      // Create 3 uploads under prefix2
      for (var i = 0; i < 3; i++) {
        final key = '${prefix2}object-$i';
        final initRequest = InitiateMultipartUploadRequest(
          bucket: bucketName,
          key: key,
        );
        final initResult = await client.initiateMultipartUpload(initRequest);
        expect(initResult.uploadId, isNotNull);
        allUploadIds.add(initResult.uploadId!);
        allKeys.add(key);
      }

      // List with prefix1
      final listRequest1 = ListMultipartUploadsRequest(
        bucket: bucketName,
        prefix: prefix1,
      );
      final listResult1 = await client.listMultipartUploads(listRequest1);
      expect(listResult1.statusCode, equals(200));
      expect(listResult1.uploads, isNotNull);
      expect(listResult1.uploads!.length, equals(2));

      // List with prefix2
      final listRequest2 = ListMultipartUploadsRequest(
        bucket: bucketName,
        prefix: prefix2,
      );
      final listResult2 = await client.listMultipartUploads(listRequest2);
      expect(listResult2.statusCode, equals(200));
      expect(listResult2.uploads, isNotNull);
      expect(listResult2.uploads!.length, equals(3));

      // Cleanup
      for (var i = 0; i < allKeys.length; i++) {
        final abortRequest = AbortMultipartUploadRequest(
          bucket: bucketName,
          key: allKeys[i],
          uploadId: allUploadIds[i],
        );
        try {
          await client.abortMultipartUpload(abortRequest);
        } catch (_) {}
      }
    });

    test('testListMultipartUploadsWithUploadIdMarker', () async {
      final objectKey = 'uploadid-marker-test-${BaseTestCase.randomStr(6)}';
      final uploadIds = <String>[];

      // Create 3 uploads for the same key
      for (var i = 0; i < 3; i++) {
        final initRequest = InitiateMultipartUploadRequest(
          bucket: bucketName,
          key: objectKey,
        );
        final initResult = await client.initiateMultipartUpload(initRequest);
        expect(initResult.uploadId, isNotNull);
        uploadIds.add(initResult.uploadId!);
      }

      // Sort upload IDs to know which ones come after the marker
      uploadIds.sort();

      // List with keyMarker and uploadIdMarker
      final listRequest = ListMultipartUploadsRequest(
        bucket: bucketName,
        keyMarker: objectKey,
        uploadIdMarker: uploadIds[0],
      );
      final listResult = await client.listMultipartUploads(listRequest);
      expect(listResult.statusCode, equals(200));
      expect(listResult.uploads, isNotNull);
      // Should return uploads with uploadId > uploadIds[0]
      expect(listResult.uploads!.length, equals(2));

      // Cleanup
      for (final uploadId in uploadIds) {
        final abortRequest = AbortMultipartUploadRequest(
          bucket: bucketName,
          key: objectKey,
          uploadId: uploadId,
        );
        try {
          await client.abortMultipartUpload(abortRequest);
        } catch (_) {}
      }
    });

    // =========================================================================
    // ListParts/PartCopy (3)
    // =========================================================================

    test('testListPartWithMaxParts', () async {
      final objectKey = testCase.randomObjectName();

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.uploadId, isNotNull);

      // Upload 5 parts
      for (var i = 1; i <= 5; i++) {
        final partData = _generateRandomData(100 * 1024);
        final uploadPartRequest = UploadPartRequest(
          bucket: bucketName,
          key: objectKey,
          partNumber: i,
          uploadId: initResult.uploadId,
          body: ByteStream.fromData(partData),
        );
        final uploadPartResult = await client.uploadPart(uploadPartRequest);
        expect(uploadPartResult.etag, isNotNull);
      }

      // List parts with maxParts=2
      final listPartsRequest = ListPartsRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
        maxParts: 2,
      );
      final listPartsResult = await client.listParts(listPartsRequest);
      expect(listPartsResult.statusCode, equals(200));
      expect(listPartsResult.parts, isNotNull);
      expect(listPartsResult.parts!.length, equals(2));
      expect(listPartsResult.isTruncated, isTrue);

      // Cleanup
      final abortRequest = AbortMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
      );
      await client.abortMultipartUpload(abortRequest);
    });

    test('testListPartWithPartNumberMarker', () async {
      final objectKey = testCase.randomObjectName();

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.uploadId, isNotNull);

      // Upload 5 parts
      for (var i = 1; i <= 5; i++) {
        final partData = _generateRandomData(100 * 1024);
        final uploadPartRequest = UploadPartRequest(
          bucket: bucketName,
          key: objectKey,
          partNumber: i,
          uploadId: initResult.uploadId,
          body: ByteStream.fromData(partData),
        );
        final uploadPartResult = await client.uploadPart(uploadPartRequest);
        expect(uploadPartResult.etag, isNotNull);
      }

      // List parts with partNumberMarker=2 (should return parts 3, 4, 5)
      final listPartsRequest = ListPartsRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
        partNumberMarker: 2,
      );
      final listPartsResult = await client.listParts(listPartsRequest);
      expect(listPartsResult.statusCode, equals(200));
      expect(listPartsResult.parts, isNotNull);
      expect(listPartsResult.parts!.length, equals(3));
      expect(listPartsResult.parts![0].partNumber, equals(3));
      expect(listPartsResult.parts![1].partNumber, equals(4));
      expect(listPartsResult.parts![2].partNumber, equals(5));

      // Cleanup
      final abortRequest = AbortMultipartUploadRequest(
        bucket: bucketName,
        key: objectKey,
        uploadId: initResult.uploadId,
      );
      await client.abortMultipartUpload(abortRequest);
    });

    test('testUploadPartCopyWithSourceRange', () async {
      final sourceKey = testCase.randomObjectName();
      final destKey = testCase.randomObjectName();

      // Upload a source object (300KB)
      final sourceData = _generateRandomData(300 * 1024);
      final putRequest = PutObjectRequest(
        bucket: bucketName,
        key: sourceKey,
        body: ByteStream.fromData(sourceData),
      );
      await client.putObject(putRequest);

      // Initiate multipart upload for destination
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: destKey,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      expect(initResult.uploadId, isNotNull);

      // Copy first 100KB as part 1 (bytes 0-102399)
      final copyPart1Request = UploadPartCopyRequest(
        bucket: bucketName,
        key: destKey,
        sourceBucket: bucketName,
        sourceKey: sourceKey,
        partNumber: 1,
        uploadId: initResult.uploadId,
        copySourceRange: 'bytes=0-102399',
      );
      final copyPart1Result = await client.uploadPartCopy(copyPart1Request);
      expect(copyPart1Result.statusCode, equals(200));
      expect(copyPart1Result.copyPartResult, isNotNull);
      expect(copyPart1Result.copyPartResult!.etag, isNotNull);

      // Copy next 100KB as part 2 (bytes 102400-204799)
      final copyPart2Request = UploadPartCopyRequest(
        bucket: bucketName,
        key: destKey,
        sourceBucket: bucketName,
        sourceKey: sourceKey,
        partNumber: 2,
        uploadId: initResult.uploadId,
        copySourceRange: 'bytes=102400-204799',
      );
      final copyPart2Result = await client.uploadPartCopy(copyPart2Request);
      expect(copyPart2Result.statusCode, equals(200));
      expect(copyPart2Result.copyPartResult, isNotNull);
      expect(copyPart2Result.copyPartResult!.etag, isNotNull);

      // Complete with both parts
      final completeRequest = CompleteMultipartUploadRequest(
        bucket: bucketName,
        key: destKey,
        uploadId: initResult.uploadId,
        completeMultipartUpload: CompleteMultipartUpload(
          parts: [
            UploadPart(
              partNumber: 1,
              etag: copyPart1Result.copyPartResult!.etag,
            ),
            UploadPart(
              partNumber: 2,
              etag: copyPart2Result.copyPartResult!.etag,
            ),
          ],
        ),
      );
      final completeResult = await client.completeMultipartUpload(
        completeRequest,
      );
      expect(completeResult.statusCode, equals(200));

      // Verify the destination object size (200KB, not 300KB)
      final getRequest = GetObjectRequest(bucket: bucketName, key: destKey);
      final getResult = await client.getObject(getRequest);
      expect(getResult.statusCode, equals(200));
      expect(getResult.contentLength, equals(200 * 1024));
    });
  }, skip: BaseTestCase.skipReason);
}

/// Generates random data of the specified size in bytes.
Uint8List _generateRandomData(int size) {
  final random = Random();
  final data = Uint8List(size);
  for (var i = 0; i < size; i++) {
    data[i] = random.nextInt(256);
  }
  return data;
}
