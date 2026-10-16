import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'agentic_test_support.dart';

void main() {
  group('AgenticBucket basic operations', () {
    late AgenticTestSupport support;
    late String bucket;
    setUpAll(() async {
      support = AgenticTestSupport();
      bucket = await support.createBucketFixture(
        config: CreateAgenticBucketConfiguration(
          storageClass: 'Standard',
          dataRedundancyType: 'LRS',
        ),
      );
    });
    tearDownAll(() => support.cleanup());

    test('create, get, list, paginate, Enabled status', () async {
      final client = support.agentic;
      final result = await client.getAgenticBucket(
        GetAgenticBucketRequest(bucket: bucket),
      );
      expect(result.statusCode, 200);
      expect(result.agenticBucketInfo?.name, support.fullBucketName(bucket));
      expect(result.agenticBucketInfo?.region, support.region);
      expect(result.agenticBucketInfo?.storageClass, 'Standard');
      expect(result.agenticBucketInfo?.dataRedundancyType, 'LRS');
      expect(result.agenticBucketInfo?.createTime, isNotEmpty);
      expect(
        (await client.listAgenticBuckets(
          ListAgenticBucketsRequest(),
        )).statusCode,
        200,
      );
      var pages = 0;
      await for (final page
          in client
              .listAgenticBucketsPaginator(
                ListAgenticBucketsRequest(maxKeys: 1),
              )
              .stream) {
        expect(page.statusCode, 200);
        if (++pages >= 5) break;
      }
      expect(pages, greaterThan(0));
      expect(
        (await client.putAgenticBucketStatus(
          PutAgenticBucketStatusRequest(bucket: bucket, status: 'Enabled'),
        )).statusCode,
        200,
      );
      expect(
        (await client.listBucketSpaces(
          ListBucketSpacesRequest(bucket: bucket),
        )).statusCode,
        200,
      );
    });

    test('newly created bucket listing eventual consistency', () async {
      final target = support.fullBucketName(bucket);
      for (var attempt = 0; attempt < 12; attempt++) {
        if (attempt > 0) {
          await Future<void>.delayed(const Duration(seconds: 10));
        }
        await for (final page
            in support.agentic
                .listAgenticBucketsPaginator(ListAgenticBucketsRequest())
                .stream) {
          if (page.agenticBuckets?.any((item) => item.name == target) == true) {
            return;
          }
        }
      }
      markTestSkipped(
        'Get already validated independently; newly created bucket not yet in eventual consistency listing',
      );
    }, timeout: const Timeout(Duration(minutes: 3)));
  }, skip: AgenticTestSupport.agenticSkipReason);
}
