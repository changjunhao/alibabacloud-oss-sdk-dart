import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart'
    as core;
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart'
    as ext;
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart'
    as agentic;

void main() {
  test(
    'three public entry points share core types and Agentic can be consumed independently',
    () {
      final config = agentic.Configuration(
        region: 'cn-hangzhou',
        accountId: '137',
      );
      expect(config, isA<core.Configuration>());
      final client = agentic.BucketSpaceClient.make(config);
      addTearDown(client.dispose);
      expect(client, isA<core.Client>());
      expect(
        agentic.PutBucketRequest(agenticBucket: 'parent'),
        isA<core.PutBucketRequest>(),
      );
      expect(ext.PutBucketCorsRequest(), isA<core.RequestModel>());
      expect(agentic.CreateAgenticBucketRequest(), isA<core.RequestModel>());
      expect(
        core.BucketSpaceHelper.fromConfiguration(config).toBucketName('space'),
        'space-137-cn-hangzhou-bs-apsr',
      );
      final manager = agentic.AgenticBucketClient(config);
      addTearDown(manager.dispose);
      expect(
        manager.listAgenticBucketsPaginator(
          agentic.ListAgenticBucketsRequest(),
        ),
        isA<agentic.ListAgenticBucketsPaginator>(),
      );
      expect(
        manager.listBucketSpacesPaginator(
          agentic.ListBucketSpacesRequest(bucket: 'parent'),
        ),
        isA<agentic.ListBucketSpacesPaginator>(),
      );
    },
  );
}
