import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'agentic_test_support.dart';

void main() {
  group('AgenticBucket two-phase deletion', () {
    late AgenticTestSupport support;
    setUp(() {
      support = AgenticTestSupport();
    });
    tearDown(() => support.cleanup());

    test('newly disabled bucket returns not ready, no 24h wait', () async {
      final bucket = await support.createBucketFixture();
      await support.disableBucket(bucket);
      await expectLater(
        support.agentic.deleteAgenticBucket(
          DeleteAgenticBucketRequest(bucket: bucket),
        ),
        throwsA(
          isA<ServerError>()
              .having((e) => e.statusCode, 'status', 409)
              .having((e) => e.code, 'code', 'AgenticBucketNotReady'),
        ),
      );
    });
  }, skip: AgenticTestSupport.agenticSkipReason);
}
