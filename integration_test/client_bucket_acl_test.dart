import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketAclTests', () {
    late BaseTestCase testCase;
    late Client client;

    setUp(() {
      testCase = BaseTestCase();
      client = testCase.getDefaultClient();
    });

    test('testBucketAclSuccess', () async {
      final bucketName = testCase.randomBucketName();

      // Create bucket
      final putBucketResult = await client.putBucket(
        PutBucketRequest(bucket: bucketName),
      );
      expect(putBucketResult.statusCode, equals(200));

      try {
        // Get bucket ACL - should be private by default
        var getBucketAclResult = await client.getBucketAcl(
          GetBucketAclRequest(bucket: bucketName),
        );
        expect(getBucketAclResult.statusCode, equals(200));
        expect(
          getBucketAclResult.accessControlPolicy?.accessControlList?.grant,
          equals('private'),
        );

        // Put bucket ACL - set to private (test account does not allow public ACLs)
        final putBucketAclResult = await client.putBucketAcl(
          PutBucketAclRequest(bucket: bucketName, acl: 'private'),
        );
        expect(putBucketAclResult.statusCode, equals(200));

        // Get bucket ACL - verify it remains private
        getBucketAclResult = await client.getBucketAcl(
          GetBucketAclRequest(bucket: bucketName),
        );
        expect(getBucketAclResult.statusCode, equals(200));
        expect(
          getBucketAclResult.accessControlPolicy?.accessControlList?.grant,
          equals('private'),
        );
      } finally {
        await testCase.cleanBucket(client, bucketName);
      }
    });

    test('testBucketAclFail', () async {
      final bucketName = testCase.randomBucketName();

      // Get ACL on non-existent bucket should fail
      await expectAsyncError(
        () => client.getBucketAcl(GetBucketAclRequest(bucket: bucketName)),
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
          expect(serverError.code, equals('NoSuchBucket'));
        },
      );

      // Create bucket for invalid ACL test
      await testCase.createBucket(client, bucketName);

      try {
        // Put invalid ACL should fail
        await expectAsyncError(
          () => client.putBucketAcl(
            PutBucketAclRequest(bucket: bucketName, acl: 'invalid-acl'),
          ),
          errorHandler: (error) {
            expect(error, isA<ServerError>());
            final serverError = error as ServerError;
            expect(serverError.statusCode, equals(400));
            expect(serverError.code, equals('InvalidArgument'));
          },
        );
      } finally {
        await testCase.cleanBucket(client, bucketName);
      }
    });
  }, skip: BaseTestCase.skipReason);
}
