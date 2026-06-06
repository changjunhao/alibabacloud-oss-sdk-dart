import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketVersioningTests', () {
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

    test('testPutBucketVersioningSuccess', () async {
      // Enable versioning
      final putResult = await client.putBucketVersioning(
        PutBucketVersioningRequest(
          bucket: bucketName,
          versioningConfiguration: const VersioningConfiguration(
            status: 'Enabled',
          ),
        ),
      );
      expect(putResult.statusCode, equals(200));

      // Verify versioning is enabled
      final getResult = await client.getBucketVersioning(
        GetBucketVersioningRequest(bucket: bucketName),
      );
      expect(getResult.statusCode, equals(200));
      expect(getResult.versioningConfiguration?.status, equals('Enabled'));

      // Suspend versioning
      final suspendResult = await client.putBucketVersioning(
        PutBucketVersioningRequest(
          bucket: bucketName,
          versioningConfiguration: const VersioningConfiguration(
            status: 'Suspended',
          ),
        ),
      );
      expect(suspendResult.statusCode, equals(200));

      // Verify versioning is suspended
      final getResult2 = await client.getBucketVersioning(
        GetBucketVersioningRequest(bucket: bucketName),
      );
      expect(getResult2.statusCode, equals(200));
      expect(getResult2.versioningConfiguration?.status, equals('Suspended'));
    });

    test('testPutBucketVersioningFail', () async {
      // Invalid versioning status should fail
      await expectAsyncError(
        () => client.putBucketVersioning(
          PutBucketVersioningRequest(
            bucket: bucketName,
            versioningConfiguration: const VersioningConfiguration(
              status: 'invalid-status',
            ),
          ),
        ),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(400));
          expect(serverError.code, equals('MalformedXML'));
        },
      );
    });

    test('testGetBucketVersioningSuccess', () async {
      // Get versioning on a new bucket (not yet enabled)
      final getResult = await client.getBucketVersioning(
        GetBucketVersioningRequest(bucket: bucketName),
      );
      expect(getResult.statusCode, equals(200));
      // Status should be null or empty for a new bucket
      expect(getResult.versioningConfiguration?.status, anyOf(isNull, isEmpty));
    });

    test('testGetBucketVersioningFail', () async {
      final nonExistentBucket = testCase.randomBucketName();

      // Get versioning on non-existent bucket should fail
      await expectAsyncError(
        () => client.getBucketVersioning(
          GetBucketVersioningRequest(bucket: nonExistentBucket),
        ),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });

    test('testListObjectVersionsSuccess', () async {
      final keyPrefix = 'listObjectVersionsSuccess';

      // Enable versioning
      await client.putBucketVersioning(
        PutBucketVersioningRequest(
          bucket: bucketName,
          versioningConfiguration: const VersioningConfiguration(
            status: 'Enabled',
          ),
        ),
      );

      // Initially no versions
      var listResult = await client.listObjectVersions(
        ListObjectVersionsRequest(bucket: bucketName),
      );
      expect(listResult.statusCode, equals(200));

      // Upload 10 objects
      for (var i = 0; i < 10; i++) {
        final data = Uint8List.fromList('hello oss version $i'.codeUnits);
        await client.putObject(
          PutObjectRequest(
            bucket: bucketName,
            key: '$keyPrefix-$i',
            body: ByteStream.fromData(data),
          ),
        );
      }

      // List object versions
      listResult = await client.listObjectVersions(
        ListObjectVersionsRequest(bucket: bucketName),
      );
      expect(listResult.statusCode, equals(200));
      expect(listResult.versions, isNotNull);
      expect(listResult.versions!.length, equals(10));

      for (final version in listResult.versions!) {
        expect(version.key, isNotNull);
        expect(version.key!.startsWith(keyPrefix), isTrue);
        expect(version.eTag, isNotNull);
        expect(version.lastModified, isNotNull);
        expect(version.size, isNotNull);
        expect(version.versionId, isNotNull);
      }
    });

    test('testListObjectVersionsFail', () async {
      // Missing required field (bucket) should throw client error
      await expectAsyncError(
        () => client.listObjectVersions(ListObjectVersionsRequest()),
        errorHandler: (error) {
          expect(error, isA<ClientError>());
          final clientError = error as ClientError;
          expect(clientError.message, contains('bucket'));
        },
      );

      // Invalid maxKeys (>999) should trigger server error
      await expectAsyncError(
        () => client.listObjectVersions(
          ListObjectVersionsRequest(bucket: bucketName, maxKeys: 10000),
        ),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(400));
          expect(serverError.code, equals('InvalidArgument'));
        },
      );
    });
  }, skip: BaseTestCase.skipReason);
}
