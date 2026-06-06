import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

import 'base_test_case.dart';

void main() {
  group('ClientBucketRefererTests', () {
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

    test('testPutBucketReferer', () async {
      final request = PutBucketRefererRequest(
        bucket: bucketName,
        refererConfiguration: RefererConfiguration(
          allowEmptyReferer: false,
          allowTruncateQueryString: true,
          truncatePath: true,
          refererList: RefererList(
            referers: ['http://www.aliyun.com', 'https://www.aliyun.com'],
          ),
          refererBlacklist: RefererBlacklist(
            referers: ['http://www.refuse.com', 'https://*.hack.com'],
          ),
        ),
      );
      final result = await client.putBucketReferer(request);
      expect(result.statusCode, equals(200));
    });

    test('testGetBucketReferer', () async {
      // First set referer config
      final putRequest = PutBucketRefererRequest(
        bucket: bucketName,
        refererConfiguration: RefererConfiguration(
          allowEmptyReferer: false,
          allowTruncateQueryString: true,
          truncatePath: true,
          refererList: RefererList(
            referers: ['http://www.aliyun.com', 'https://www.aliyun.com'],
          ),
          refererBlacklist: RefererBlacklist(
            referers: ['http://www.refuse.com', 'https://*.hack.com'],
          ),
        ),
      );
      await client.putBucketReferer(putRequest);

      // Then get referer config
      final getRequest = GetBucketRefererRequest(bucket: bucketName);
      final result = await client.getBucketReferer(getRequest);
      expect(result.statusCode, equals(200));
      expect(result.refererConfiguration, isNotNull);
      expect(result.refererConfiguration?.allowEmptyReferer, equals(false));
      expect(
        result.refererConfiguration?.allowTruncateQueryString,
        equals(true),
      );
      expect(result.refererConfiguration?.truncatePath, equals(true));
      expect(
        result.refererConfiguration?.refererList?.referers,
        equals(['http://www.aliyun.com', 'https://www.aliyun.com']),
      );
      expect(
        result.refererConfiguration?.refererBlacklist?.referers,
        equals(['http://www.refuse.com', 'https://*.hack.com']),
      );
    });

    test('testGetBucketRefererFail', () async {
      await expectAsyncError(
        () async {
          final request = GetBucketRefererRequest(
            bucket: 'non-existent-bucket-${BaseTestCase.randomStr(8)}',
          );
          await client.getBucketReferer(request);
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
