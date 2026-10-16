import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'agentic_test_support.dart';

void main() {
  group('Agentic addressing capabilities', () {
    late AgenticTestSupport support;
    late String parent;
    late String space;
    setUpAll(() async {
      support = AgenticTestSupport();
      parent = await support.createBucketFixture();
      space = await support.createSpaceFixture(parent);
    });
    tearDownAll(() => support.cleanup());

    test('alias management and BucketSpace routing', () async {
      expect(
        (await support
                .makeAgentic(alias: true)
                .getAgenticBucket(GetAgenticBucketRequest(bucket: parent)))
            .statusCode,
        200,
      );
      expect(
        (await support
                .makeSpaces(alias: true)
                .getBucketInfo(GetBucketInfoRequest(bucket: space)))
            .statusCode,
        200,
      );
    });

    test('AgenticBucket path-style', () async {
      try {
        expect(
          (await support
                  .makeAgentic(path: true)
                  .listBucketSpaces(ListBucketSpacesRequest(bucket: parent)))
              .statusCode,
          200,
        );
      } on ServerError catch (error) {
        if (error.code != 'SecondLevelDomainForbidden') rethrow;
        markTestSkipped(
          'Current AgenticBucket endpoint does not allow path-style',
        );
      }
    });

    test('BucketSpace path-style', () async {
      try {
        expect(
          (await support
                  .makeSpaces(path: true)
                  .getBucketInfo(GetBucketInfoRequest(bucket: space)))
              .statusCode,
          200,
        );
      } on ServerError catch (error) {
        if (error.code != 'SecondLevelDomainForbidden') rethrow;
        markTestSkipped(
          'Current BucketSpace endpoint does not allow path-style',
        );
      }
    });
  }, skip: AgenticTestSupport.agenticSkipReason);
}
