import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketResourceGroupTests', () {
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

    test('testPutBucketResourceGroup', () async {
      // Get the current resource group ID from bucket info
      final infoRequest = GetBucketInfoRequest(bucket: bucketName);
      final infoResult = await client.getBucketInfo(infoRequest);
      final resourceGroupId = infoResult.bucketInfo?.bucket?.resourceGroupId;
      expect(resourceGroupId, isNotNull);

      // Put bucket resource group with the same resource group ID
      final request = PutBucketResourceGroupRequest(
        bucket: bucketName,
        bucketResourceGroupConfiguration: BucketResourceGroupConfiguration(
          resourceGroupId: resourceGroupId,
        ),
      );
      final result = await client.putBucketResourceGroup(request);
      expect(result.statusCode, equals(200));
    });

    test('testGetBucketResourceGroup', () async {
      final request = GetBucketResourceGroupRequest(bucket: bucketName);
      final result = await client.getBucketResourceGroup(request);
      expect(result.statusCode, equals(200));
      expect(result.bucketResourceGroupConfiguration, isNotNull);
      expect(
        result.bucketResourceGroupConfiguration?.resourceGroupId,
        isNotNull,
      );
    });

    test('testGetBucketResourceGroupFail', () async {
      await expectAsyncError(
        () async {
          final request = GetBucketResourceGroupRequest(
            bucket: 'non-existent-bucket-${BaseTestCase.randomStr(8)}',
          );
          await client.getBucketResourceGroup(request);
        },
        errorHandler: (error) {
          expect(error, isA<ServerError>());
          final serverError = error as ServerError;
          expect(serverError.statusCode, equals(404));
        },
      );
    });
  }, skip: BaseTestCase.skipReason);
}
