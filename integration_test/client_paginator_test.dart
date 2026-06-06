import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

import 'base_test_case.dart';

void main() {
  group('ClientPaginatorTests', () {
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

    test('testListObjectsPaginator', () async {
      final baseKey = testCase.randomObjectName();
      final content = Uint8List.fromList('hello oss'.codeUnits);

      // Upload 5 objects
      final objects = <String>[];
      for (var i = 0; i < 5; i++) {
        final key = '$baseKey-$i';
        final request = PutObjectRequest(
          bucket: bucketName,
          key: key,
          body: ByteStream.fromData(content),
        );
        await client.putObject(request);
        objects.add(key);
      }

      // Use paginator with maxKeys=2 to trigger pagination
      final request = ListObjectsRequest(bucket: bucketName, prefix: baseKey);
      final paginator = client.listObjectsPaginator(
        request,
        paginatorOptions: PaginatorOptions(limit: 2),
      );

      final listResultObjects = <String>[];
      var pageCount = 0;
      await for (final result in paginator.stream) {
        pageCount++;
        if (result.contents != null) {
          for (final obj in result.contents!) {
            listResultObjects.add(obj.key!);
          }
        }
      }

      // Verify all objects are retrieved
      expect(listResultObjects.length, equals(objects.length));
      for (final obj in objects) {
        expect(listResultObjects, contains(obj));
      }
      // Verify pagination happened (at least 3 pages for 5 objects with limit=2)
      expect(pageCount, greaterThanOrEqualTo(3));
    });

    test('testListObjectsV2Paginator', () async {
      final baseKey = testCase.randomObjectName();
      final content = Uint8List.fromList('hello oss'.codeUnits);

      // Upload 5 objects
      final objects = <String>[];
      for (var i = 0; i < 5; i++) {
        final key = '$baseKey-$i';
        final request = PutObjectRequest(
          bucket: bucketName,
          key: key,
          body: ByteStream.fromData(content),
        );
        await client.putObject(request);
        objects.add(key);
      }

      // Use paginator with maxKeys=2 to trigger pagination
      final request = ListObjectsV2Request(bucket: bucketName, prefix: baseKey);
      final paginator = client.listObjectsV2Paginator(
        request,
        paginatorOptions: PaginatorOptions(limit: 2),
      );

      final listResultObjects = <String>[];
      var pageCount = 0;
      await for (final result in paginator.stream) {
        pageCount++;
        if (result.contents != null) {
          for (final obj in result.contents!) {
            listResultObjects.add(obj.key!);
          }
        }
      }

      // Verify all objects are retrieved
      expect(listResultObjects.length, equals(objects.length));
      for (final obj in objects) {
        expect(listResultObjects, contains(obj));
      }
      // Verify pagination happened (at least 3 pages for 5 objects with limit=2)
      expect(pageCount, greaterThanOrEqualTo(3));
    });

    test('testListPartsPaginator', () async {
      final key = testCase.randomObjectName();
      final content = Uint8List.fromList('hello oss'.codeUnits);

      // Initiate multipart upload
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: key,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      final uploadId = initResult.uploadId!;

      // Upload 5 parts
      final parts = <int>[];
      for (var i = 1; i <= 5; i++) {
        final uploadPartRequest = UploadPartRequest(
          bucket: bucketName,
          key: key,
          partNumber: i,
          uploadId: uploadId,
          body: ByteStream.fromData(content),
        );
        await client.uploadPart(uploadPartRequest);
        parts.add(i);
      }

      // Use paginator with maxParts=2 to trigger pagination
      final listRequest = ListPartsRequest(
        bucket: bucketName,
        key: key,
        uploadId: uploadId,
      );
      final paginator = client.listPartsPaginator(
        listRequest,
        paginatorOptions: PaginatorOptions(limit: 2),
      );

      final listResultParts = <int>[];
      var pageCount = 0;
      await for (final result in paginator.stream) {
        pageCount++;
        if (result.parts != null) {
          for (final part in result.parts!) {
            listResultParts.add(part.partNumber!);
          }
        }
      }

      // Verify all parts are retrieved
      expect(listResultParts.length, equals(parts.length));
      for (final part in parts) {
        expect(listResultParts, contains(part));
      }
      // Verify pagination happened (at least 3 pages for 5 parts with limit=2)
      expect(pageCount, greaterThanOrEqualTo(3));
    });

    test('testListBucketsPaginatorSuccess', () async {
      final baseBucket = testCase.randomBucketName();
      final buckets = <String>[];

      // Create 5 buckets
      for (var i = 0; i < 5; i++) {
        final name = '$baseBucket-$i';
        await testCase.createBucket(client, name);
        buckets.add(name);
      }

      try {
        // Use paginator with prefix filter
        final request = ListBucketsRequest(prefix: baseBucket);
        final paginator = client.listBucketsPaginator(
          request,
          paginatorOptions: PaginatorOptions(limit: 2),
        );

        final listResultBuckets = <String>[];
        var pageCount = 0;
        await for (final result in paginator.stream) {
          pageCount++;
          if (result.buckets != null) {
            for (final bucket in result.buckets!) {
              if (bucket.name != null && bucket.name!.startsWith(baseBucket)) {
                listResultBuckets.add(bucket.name!);
              }
            }
          }
        }

        // Verify all buckets are retrieved
        expect(listResultBuckets.length, equals(buckets.length));
        for (final bucket in buckets) {
          expect(listResultBuckets, contains(bucket));
        }
        // Verify pagination happened
        expect(pageCount, greaterThanOrEqualTo(3));
      } finally {
        // Clean up created buckets
        for (final bucket in buckets) {
          await testCase.cleanBucket(client, bucket);
        }
      }
    });

    test('testListBucketsPaginatorFail', () async {
      // Use invalid credentials client
      final invalidClient = testCase.getInvalidAkClient();

      final request = ListBucketsRequest();
      final paginator = invalidClient.listBucketsPaginator(request);

      try {
        await for (final _ in paginator.stream) {
          fail('should throw an error');
        }
      } catch (e) {
        expect(e, isA<ServerError>());
        final serverError = e as ServerError;
        expect(serverError.statusCode, equals(403));
        expect(serverError.code, equals('InvalidAccessKeyId'));
      }
    });

    test('testListObjectsPaginatorFail', () async {
      // Use invalid credentials client to trigger server error
      final invalidClient = testCase.getInvalidAkClient();

      final request = ListObjectsRequest(bucket: bucketName);
      final paginator = invalidClient.listObjectsPaginator(request);

      try {
        await for (final _ in paginator.stream) {
          fail('should throw an error');
        }
      } catch (e) {
        expect(e, isA<ServerError>());
        final serverError = e as ServerError;
        expect(serverError.statusCode, equals(403));
        expect(serverError.code, equals('InvalidAccessKeyId'));
      }
    });

    test('testListObjectsV2PaginatorFail', () async {
      // Use invalid credentials client to trigger server error
      final invalidClient = testCase.getInvalidAkClient();

      final request = ListObjectsV2Request(bucket: bucketName);
      final paginator = invalidClient.listObjectsV2Paginator(request);

      try {
        await for (final _ in paginator.stream) {
          fail('should throw an error');
        }
      } catch (e) {
        expect(e, isA<ServerError>());
        final serverError = e as ServerError;
        expect(serverError.statusCode, equals(403));
        expect(serverError.code, equals('InvalidAccessKeyId'));
      }
    });

    test('testListObjectVersionsPaginatorSuccess', () async {
      // Enable versioning
      await client.putBucketVersioning(
        PutBucketVersioningRequest(
          bucket: bucketName,
          versioningConfiguration: const VersioningConfiguration(
            status: 'Enabled',
          ),
        ),
      );

      final baseKey = testCase.randomObjectName();
      final content = Uint8List.fromList('hello oss'.codeUnits);

      // Upload 5 objects, then delete 2 to create delete markers
      final objects = <String>[];
      final deleteMarkers = <String>[];
      for (var i = 0; i < 5; i++) {
        final key = '$baseKey-$i';
        final request = PutObjectRequest(
          bucket: bucketName,
          key: key,
          body: ByteStream.fromData(content),
        );
        await client.putObject(request);
        objects.add(key);
        if (i >= 3) {
          await client.deleteObject(
            DeleteObjectRequest(bucket: bucketName, key: key),
          );
          deleteMarkers.add(key);
        }
      }

      // Use paginator with limit=2
      final request = ListObjectVersionsRequest(
        bucket: bucketName,
        prefix: baseKey,
      );
      final paginator = client.listObjectVersionsPaginator(
        request,
        paginatorOptions: PaginatorOptions(limit: 2),
      );

      final listResultVersions = <String>[];
      final listResultMarkers = <String>[];
      var pageCount = 0;
      await for (final result in paginator.stream) {
        pageCount++;
        if (result.versions != null) {
          for (final version in result.versions!) {
            listResultVersions.add(version.key!);
          }
        }
        if (result.deleteMarkers != null) {
          for (final marker in result.deleteMarkers!) {
            listResultMarkers.add(marker.key!);
          }
        }
      }

      // Verify all versions and delete markers are retrieved
      expect(listResultVersions.length, equals(objects.length));
      expect(listResultMarkers.length, equals(deleteMarkers.length));
      for (final obj in objects) {
        expect(listResultVersions, contains(obj));
      }
      for (final marker in deleteMarkers) {
        expect(listResultMarkers, contains(marker));
      }
      // Verify pagination happened
      expect(pageCount, greaterThanOrEqualTo(2));
    });

    test('testListObjectVersionsPaginatorFail', () async {
      // Use invalid credentials client to trigger server error
      final invalidClient = testCase.getInvalidAkClient();

      final request = ListObjectVersionsRequest(bucket: bucketName);
      final paginator = invalidClient.listObjectVersionsPaginator(request);

      try {
        await for (final _ in paginator.stream) {
          fail('should throw an error');
        }
      } catch (e) {
        expect(e, isA<ServerError>());
        final serverError = e as ServerError;
        expect(serverError.statusCode, equals(403));
        expect(serverError.code, equals('InvalidAccessKeyId'));
      }
    });

    test('testListPartsPaginatorFail', () async {
      // Use invalid credentials client to trigger server error
      final key = testCase.randomObjectName();

      // Initiate multipart upload to get a valid uploadId
      final initRequest = InitiateMultipartUploadRequest(
        bucket: bucketName,
        key: key,
      );
      final initResult = await client.initiateMultipartUpload(initRequest);
      final uploadId = initResult.uploadId!;

      final invalidClient = testCase.getInvalidAkClient();
      final request = ListPartsRequest(
        bucket: bucketName,
        key: key,
        uploadId: uploadId,
      );
      final paginator = invalidClient.listPartsPaginator(request);

      try {
        await for (final _ in paginator.stream) {
          fail('should throw an error');
        }
      } catch (e) {
        expect(e, isA<ServerError>());
        final serverError = e as ServerError;
        expect(serverError.statusCode, equals(403));
        expect(serverError.code, equals('InvalidAccessKeyId'));
      }
    });

    test('testListMultipartUploadsPaginatorSuccess', () async {
      final baseKey = testCase.randomObjectName();

      // Initiate 5 multipart uploads
      final uploads = <String>[];
      for (var i = 0; i < 5; i++) {
        final key = '$baseKey-$i';
        final initRequest = InitiateMultipartUploadRequest(
          bucket: bucketName,
          key: key,
        );
        final initResult = await client.initiateMultipartUpload(initRequest);
        uploads.add(initResult.uploadId!);
      }

      // Use paginator with limit=2
      final request = ListMultipartUploadsRequest(
        bucket: bucketName,
        prefix: baseKey,
      );
      final paginator = client.listMultipartUploadsPaginator(
        request,
        paginatorOptions: PaginatorOptions(limit: 2),
      );

      final listResultUploads = <String>[];
      var pageCount = 0;
      await for (final result in paginator.stream) {
        pageCount++;
        if (result.uploads != null) {
          for (final upload in result.uploads!) {
            listResultUploads.add(upload.uploadId!);
          }
        }
      }

      // Verify all uploads are retrieved
      expect(listResultUploads.length, equals(uploads.length));
      for (final upload in uploads) {
        expect(listResultUploads, contains(upload));
      }
      // Verify pagination happened
      expect(pageCount, greaterThanOrEqualTo(3));
    });

    test('testListMultipartUploadsPaginatorFail', () async {
      // Use invalid credentials client to trigger server error
      final invalidClient = testCase.getInvalidAkClient();

      final request = ListMultipartUploadsRequest(bucket: bucketName);
      final paginator = invalidClient.listMultipartUploadsPaginator(request);

      try {
        await for (final _ in paginator.stream) {
          fail('should throw an error');
        }
      } catch (e) {
        expect(e, isA<ServerError>());
        final serverError = e as ServerError;
        expect(serverError.statusCode, equals(403));
        expect(serverError.code, equals('InvalidAccessKeyId'));
      }
    });
  }, skip: BaseTestCase.skipReason);
}
