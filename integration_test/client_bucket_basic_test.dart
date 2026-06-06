import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketBasicTests', () {
    late BaseTestCase baseTestCase;
    late Client client;
    late String bucketName;

    setUp(() async {
      baseTestCase = BaseTestCase();
      client = baseTestCase.getDefaultClient();
      bucketName = baseTestCase.randomBucketName();
      await baseTestCase.createBucket(client, bucketName);
    });

    tearDown(() async {
      await baseTestCase.cleanBucket(client, bucketName);
    });

    test('testPutBucket', () async {
      final newBucket = baseTestCase.randomBucketName();
      try {
        final request = PutBucketRequest(bucket: newBucket);
        final result = await client.putBucket(request);
        expect(result.statusCode, equals(200));
      } finally {
        await baseTestCase.cleanBucket(client, newBucket);
      }
    });

    test('testPutBucketWithAcl', () async {
      final newBucket = baseTestCase.randomBucketName();
      try {
        final request = PutBucketRequest(bucket: newBucket, acl: 'public-read');
        final result = await client.putBucket(request);
        expect(result.statusCode, equals(200));

        // Verify the ACL was set
        final infoRequest = GetBucketInfoRequest(bucket: newBucket);
        final infoResult = await client.getBucketInfo(infoRequest);
        expect(
          infoResult.bucketInfo?.bucket?.accessControlList?.grant,
          equals('public-read'),
        );
      } finally {
        await baseTestCase.cleanBucket(client, newBucket);
      }
    });

    test('testPutBucketWithStorageClass', () async {
      final newBucket = baseTestCase.randomBucketName();
      try {
        final request = PutBucketRequest(
          bucket: newBucket,
          createBucketConfiguration: CreateBucketConfiguration(
            storageClass: 'IA',
          ),
        );
        final result = await client.putBucket(request);
        expect(result.statusCode, equals(200));

        // Verify the storage class was set
        final infoRequest = GetBucketInfoRequest(bucket: newBucket);
        final infoResult = await client.getBucketInfo(infoRequest);
        expect(infoResult.bucketInfo?.bucket?.storageClass, equals('IA'));
      } finally {
        await baseTestCase.cleanBucket(client, newBucket);
      }
    });

    test('testDeleteBucket', () async {
      final newBucket = baseTestCase.randomBucketName();
      await baseTestCase.createBucket(client, newBucket);

      final deleteRequest = DeleteBucketRequest(bucket: newBucket);
      final result = await client.deleteBucket(deleteRequest);
      expect(result.statusCode, equals(204));
    });

    test('testDeleteBucketFail', () async {
      await expectAsyncError(
        () async {
          final deleteRequest = DeleteBucketRequest(
            bucket: 'non-existent-bucket-${BaseTestCase.randomStr(8)}',
          );
          await client.deleteBucket(deleteRequest);
        },
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
          expect(serverError.code, equals('NoSuchBucket'));
        },
      );
    });

    test('testGetBucketInfo', () async {
      final infoRequest = GetBucketInfoRequest(bucket: bucketName);
      final result = await client.getBucketInfo(infoRequest);

      expect(result.statusCode, equals(200));
      expect(result.bucketInfo, isNotNull);
      expect(result.bucketInfo?.bucket, isNotNull);
      expect(result.bucketInfo?.bucket?.name, equals(bucketName));
      expect(result.bucketInfo?.bucket?.location, isNotNull);
      expect(result.bucketInfo?.bucket?.location, startsWith('oss-'));
      expect(result.bucketInfo?.bucket?.creationDate, isNotNull);
      expect(result.bucketInfo?.bucket?.storageClass, isNotNull);
      expect(result.bucketInfo?.bucket?.extranetEndpoint, isNotNull);
      expect(result.bucketInfo?.bucket?.intranetEndpoint, isNotNull);
      expect(result.bucketInfo?.bucket?.owner, isNotNull);
      expect(result.bucketInfo?.bucket?.owner?.id, isNotNull);
    });

    test('testGetBucketLocation', () async {
      final request = GetBucketLocationRequest(bucket: bucketName);
      final result = await client.getBucketLocation(request);

      expect(result.statusCode, equals(200));
      expect(result.locationConstraint, isNotNull);
      expect(result.locationConstraint, equals('oss-${baseTestCase.region}'));
    });

    test('testGetBucketStat', () async {
      final request = GetBucketStatRequest(bucket: bucketName);
      final result = await client.getBucketStat(request);

      expect(result.statusCode, equals(200));
      expect(result.bucketStat, isNotNull);
      expect(result.bucketStat?.storage, isNotNull);
      expect(result.bucketStat?.objectCount, isNotNull);
      expect(result.bucketStat?.multipartUploadCount, isNotNull);
      expect(result.bucketStat?.liveChannelCount, isNotNull);
      expect(result.bucketStat?.standardStorage, isNotNull);
      expect(result.bucketStat?.standardObjectCount, isNotNull);
      expect(result.bucketStat?.infrequentAccessStorage, isNotNull);
      expect(result.bucketStat?.infrequentAccessObjectCount, isNotNull);
      expect(result.bucketStat?.archiveStorage, isNotNull);
      expect(result.bucketStat?.archiveObjectCount, isNotNull);
      expect(result.bucketStat?.coldArchiveStorage, isNotNull);
      expect(result.bucketStat?.coldArchiveObjectCount, isNotNull);
    });

    test('testListObjects', () async {
      // Upload some objects
      final content = Uint8List.fromList(utf8.encode('hello oss'));
      final objectKeys = <String>[];
      for (var i = 0; i < 3; i++) {
        final key = 'test-list-objects-${baseTestCase.randomObjectName()}';
        final putRequest = PutObjectRequest(
          bucket: bucketName,
          key: key,
          body: ByteStream.fromData(content),
        );
        await client.putObject(putRequest);
        objectKeys.add(key);
      }

      // List objects
      final listRequest = ListObjectsRequest(bucket: bucketName);
      final result = await client.listObjects(listRequest);

      expect(result.statusCode, equals(200));
      expect(result.name, equals(bucketName));
      expect(result.contents, isNotNull);
      expect(result.contents!.length, greaterThanOrEqualTo(3));

      // Verify uploaded objects are in the list
      final returnedKeys = result.contents!.map((c) => c.key).toList();
      for (final key in objectKeys) {
        expect(returnedKeys, contains(key));
      }

      // Verify object properties
      for (final obj in result.contents!) {
        expect(obj.key, isNotNull);
        expect(obj.lastModified, isNotNull);
        expect(obj.etag, isNotNull);
        expect(obj.size, isNotNull);
        expect(obj.storageClass, isNotNull);
      }
    });

    test('testListObjectsV2', () async {
      // Upload some objects
      final content = Uint8List.fromList(utf8.encode('hello oss v2'));
      final objectKeys = <String>[];
      for (var i = 0; i < 3; i++) {
        final key = 'test-list-objects-v2-${baseTestCase.randomObjectName()}';
        final putRequest = PutObjectRequest(
          bucket: bucketName,
          key: key,
          body: ByteStream.fromData(content),
        );
        await client.putObject(putRequest);
        objectKeys.add(key);
      }

      // List objects v2
      final listRequest = ListObjectsV2Request(bucket: bucketName);
      final result = await client.listObjectsV2(listRequest);

      expect(result.statusCode, equals(200));
      expect(result.name, equals(bucketName));
      expect(result.contents, isNotNull);
      expect(result.contents!.length, greaterThanOrEqualTo(3));
      expect(result.keyCount, greaterThanOrEqualTo(3));
      expect(result.maxKeys, isNotNull);

      // Verify uploaded objects are in the list
      final returnedKeys = result.contents!.map((c) => c.key).toList();
      for (final key in objectKeys) {
        expect(returnedKeys, contains(key));
      }

      // Verify object properties
      for (final obj in result.contents!) {
        expect(obj.key, isNotNull);
        expect(obj.lastModified, isNotNull);
        expect(obj.etag, isNotNull);
        expect(obj.size, isNotNull);
        expect(obj.storageClass, isNotNull);
      }
    });

    test('testListObjectVersions', () async {
      final listVersionsRequest = ListObjectVersionsRequest(bucket: bucketName);
      final result = await client.listObjectVersions(listVersionsRequest);

      expect(result.statusCode, equals(200));
      expect(result.name, equals(bucketName));
      expect(result.maxKeys, isNotNull);
      expect(result.isTruncated, isNotNull);
    });

    test('testIsBucketExist', () async {
      // Test existing bucket
      final exists = await client.isBucketExist(bucketName);
      expect(exists, isTrue);

      // Test non-existing bucket
      final notExists = await client.isBucketExist(
        'non-existent-bucket-${BaseTestCase.randomStr(8)}',
      );
      expect(notExists, isFalse);
    });

    test('testListBuckets', () async {
      final request = ListBucketsRequest();
      final result = await client.listBuckets(request);

      expect(result.statusCode, equals(200));
      expect(result.buckets, isNotNull);
      expect(result.buckets!.length, greaterThan(0));

      // Verify our test bucket is in the list
      final bucketNames = result.buckets!.map((b) => b.name).toList();
      expect(bucketNames, contains(bucketName));
    });

    test('testDescribeRegions', () async {
      final request = DescribeRegionsRequest();
      final result = await client.describeRegions(request);

      expect(result.statusCode, equals(200));
      expect(result.regionInfoList, isNotNull);
      expect(result.regionInfoList?.regionInfos, isNotNull);
      expect(result.regionInfoList!.regionInfos!.length, greaterThan(0));

      // Verify each region info has expected fields
      for (final regionInfo in result.regionInfoList!.regionInfos!) {
        expect(regionInfo.region, isNotNull);
        expect(regionInfo.internetEndpoint, isNotNull);
        expect(regionInfo.internalEndpoint, isNotNull);
        // accelerateEndpoint may be null for some regions
      }
    });
  }, skip: BaseTestCase.skipReason);
}
