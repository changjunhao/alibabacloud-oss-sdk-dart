import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketResourceGroup Tests', () {
    late MockSendRequest mock;
    late Client client;

    setUp(() {
      mock = MockSendRequest();
      final config = Configuration.defaultConfig()
          .withRegion('cn-hangzhou')
          .withCredentialsProvider(
            StaticCredentialsProvider(accessKeyId: 'ak', accessKeySecret: 'sk'),
          )
          .withRetryer(NopRetryer());
      client = Client(config, [(options) => options.executeMW = mock]);
    });

    // ===== putBucketResourceGroup =====
    test('testPutBucketResourceGroup - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketResourceGroupRequest(
        bucket: 'test-bucket',
        bucketResourceGroupConfiguration: BucketResourceGroupConfiguration(
          resourceGroupId: 'rg-aek27tc********',
        ),
      );
      final result = await client.putBucketResourceGroup(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(mock.requests[0].requestUri.toString(), contains('resourceGroup'));
    });

    test('testPutBucketResourceGroup - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketResourceGroupRequest(
        bucketResourceGroupConfiguration: BucketResourceGroupConfiguration(
          resourceGroupId: 'rg-aek27tc********',
        ),
      );

      expect(
        () async => await client.putBucketResourceGroup(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketResourceGroup - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketResourceGroupRequest(
        bucket: 'test-bucket',
        bucketResourceGroupConfiguration: BucketResourceGroupConfiguration(
          resourceGroupId: 'rg-aek27tc********',
        ),
      );

      expect(
        () async => await client.putBucketResourceGroup(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketResourceGroup =====
    test('testGetBucketResourceGroup - success', () async {
      final xml = '''<BucketResourceGroupConfiguration>
    <ResourceGroupId>rg-aek27tc********</ResourceGroupId>
</BucketResourceGroupConfiguration>''';
      final data = Uint8List.fromList(utf8.encode(xml));
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {
            'x-oss-request-id': 'req-123',
            'content-type': 'application/xml',
          },
          content: ByteStream.fromData(data),
        ),
      );

      final request = GetBucketResourceGroupRequest(bucket: 'test-bucket');
      final result = await client.getBucketResourceGroup(request);

      expect(result, isNotNull);
      expect(result.bucketResourceGroupConfiguration, isNotNull);
      expect(
        result.bucketResourceGroupConfiguration!.resourceGroupId,
        'rg-aek27tc********',
      );
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketResourceGroup - missing bucket', () async {
      final request = GetBucketResourceGroupRequest();

      expect(
        () async => await client.getBucketResourceGroup(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketResourceGroup - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketResourceGroupRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketResourceGroup(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
