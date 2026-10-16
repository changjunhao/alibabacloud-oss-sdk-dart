import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';

void main() {
  final info = AgenticBucketInfo(
    name: 'physical',
    owner: '00137',
    region: 'cn-hangzhou',
    storageClass: 'IA',
    dataRedundancyType: 'ZRS',
    status: 'Enabled',
    bucketResourceType: 'agentic',
    createTime: 'raw-time',
    acl: 'private',
    publicAccessBlock: 'true',
    versioning: 'Enabled',
    bucketPolicy: '{}',
    serverSideEncryptionRule: ServerSideEncryptionRule(
      sseAlgorithm: 'KMS',
      kmsMasterKeyId: 'key',
      kmsDataEncryption: 'SM4',
    ),
  );
  final cases =
      <
        (
          String,
          Map<String, dynamic>,
          Map<String, dynamic> Function(Map<String, dynamic>),
        )
      >[
        (
          'configuration',
          CreateAgenticBucketConfiguration(
            storageClass: 'IA',
            dataRedundancyType: 'ZRS',
          ).toJson(),
          (j) => CreateAgenticBucketConfiguration.fromJson(j).toJson(),
        ),
        ('info', info.toJson(), (j) => AgenticBucketInfo.fromJson(j).toJson()),
        (
          'summary',
          AgenticBucketSummary(
            name: 'name',
            storageClass: 'IA',
            dataRedundancyType: 'ZRS',
            createTime: 'raw',
          ).toJson(),
          (j) => AgenticBucketSummary.fromJson(j).toJson(),
        ),
        (
          'space summary',
          BucketSpaceSummary(
            name: 'name',
            location: 'location',
            creationDate: 'raw',
            storageClass: 'IA',
          ).toJson(),
          (j) => BucketSpaceSummary.fromJson(j).toJson(),
        ),
        (
          'create request',
          CreateAgenticBucketRequest(
            bucket: 'prefix',
            createAgenticBucketConfiguration: CreateAgenticBucketConfiguration(
              storageClass: 'IA',
            ),
          ).toJson(),
          (j) => CreateAgenticBucketRequest.fromJson(j).toJson(),
        ),
        (
          'create result',
          CreateAgenticBucketResult().toJson(),
          (j) => CreateAgenticBucketResult.fromJson(j).toJson(),
        ),
        (
          'delete request',
          DeleteAgenticBucketRequest(bucket: 'prefix').toJson(),
          (j) => DeleteAgenticBucketRequest.fromJson(j).toJson(),
        ),
        (
          'delete result',
          DeleteAgenticBucketResult().toJson(),
          (j) => DeleteAgenticBucketResult.fromJson(j).toJson(),
        ),
        (
          'get request',
          GetAgenticBucketRequest(bucket: 'prefix').toJson(),
          (j) => GetAgenticBucketRequest.fromJson(j).toJson(),
        ),
        (
          'get result',
          GetAgenticBucketResult(agenticBucketInfo: info).toJson(),
          (j) => GetAgenticBucketResult.fromJson(j).toJson(),
        ),
        (
          'list request',
          ListAgenticBucketsRequest(
            continuationToken: 'token',
            maxKeys: 1,
          ).toJson(),
          (j) => ListAgenticBucketsRequest.fromJson(j).toJson(),
        ),
        (
          'list result',
          ListAgenticBucketsResult(
            region: 'cn-hangzhou',
            owner: '00137',
            continuationToken: 'a',
            nextContinuationToken: 'b',
            isTruncated: true,
            agenticBuckets: [AgenticBucketSummary(name: 'one')],
          ).toJson(),
          (j) => ListAgenticBucketsResult.fromJson(j).toJson(),
        ),
        (
          'status request',
          PutAgenticBucketStatusRequest(
            bucket: 'prefix',
            status: 'Disabled',
          ).toJson(),
          (j) => PutAgenticBucketStatusRequest.fromJson(j).toJson(),
        ),
        (
          'status result',
          PutAgenticBucketStatusResult().toJson(),
          (j) => PutAgenticBucketStatusResult.fromJson(j).toJson(),
        ),
        (
          'spaces request',
          ListBucketSpacesRequest(
            bucket: 'parent',
            prefix: 'foo',
            startAfter: 'first',
            continuationToken: 'a',
            maxKeys: 2,
          ).toJson(),
          (j) => ListBucketSpacesRequest.fromJson(j).toJson(),
        ),
        (
          'spaces result',
          ListBucketSpacesResult(
            owner: Owner(id: '137', displayName: 'account'),
            prefix: 'foo',
            maxKeys: 2,
            continuationToken: 'a',
            nextContinuationToken: 'b',
            startAfter: 'first',
            isTruncated: true,
            bucketSpaces: [BucketSpaceSummary(name: 'one')],
          ).toJson(),
          (j) => ListBucketSpacesResult.fromJson(j).toJson(),
        ),
      ];
  for (final entry in cases) {
    test('${entry.$1} JSON round-trip and nullable fields', () {
      expect(entry.$3(entry.$2), entry.$2);
      final empty = entry.$3({});
      expect(entry.$3(empty), empty);
    });
  }
  test(
    'request common properties isolated per instance, result reuses common metadata',
    () {
      final a = CreateAgenticBucketRequest();
      final b = CreateAgenticBucketRequest();
      a.addHeader('X-Test', 'value');
      a.addParameter('query', null);
      expect(a.commonProp.headers, {'x-test': 'value'});
      expect(b.commonProp.headers, isNull);
      final prop = ResultModelProp()
        ..statusCode = 204
        ..headers = {'X-Oss-Request-Id': 'id'};
      final result = DeleteAgenticBucketResult(commonProp: prop);
      expect(result.statusCode, 204);
      expect(result.requestId, 'id');
      expect(result.headers, prop.headers);
    },
  );
}
