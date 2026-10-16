import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'agentic_test_support.dart';

void main() {
  group('Agentic server-side errors, no creation fixture', () {
    late AgenticTestSupport support;
    setUp(() {
      support = AgenticTestSupport();
    });
    tearDown(() => support.cleanup());

    test('non-existent AgenticBucket', () async {
      await expectLater(
        support.agentic.getAgenticBucket(
          GetAgenticBucketRequest(bucket: support.newPrefix()),
        ),
        throwsA(
          isA<ServerError>()
              .having((e) => e.statusCode, 'status', 404)
              .having((e) => e.code, 'code', 'NoSuchAgenticBucket')
              .having((e) => e.requestId, 'requestId', isNotEmpty),
        ),
      );
    });

    test('invalid credentials', () async {
      await expectLater(
        support
            .makeAgentic(invalidCredentials: true)
            .listAgenticBuckets(ListAgenticBucketsRequest()),
        throwsA(
          isA<ServerError>()
              .having((e) => e.statusCode, 'status', 403)
              .having((e) => e.code, 'code', 'InvalidAccessKeyId'),
        ),
      );
    });
  }, skip: AgenticTestSupport.agenticSkipReason);
}
