import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketPublicAccessBlock Tests', () {
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

    // ===== putBucketPublicAccessBlock =====
    test('testPutBucketPublicAccessBlock - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketPublicAccessBlockRequest(
        bucket: 'test-bucket',
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: true,
        ),
      );
      final result = await client.putBucketPublicAccessBlock(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(
        mock.requests[0].requestUri.toString(),
        contains('publicAccessBlock'),
      );
    });

    test('testPutBucketPublicAccessBlock - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketPublicAccessBlockRequest(
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: true,
        ),
      );

      expect(
        () async => await client.putBucketPublicAccessBlock(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketPublicAccessBlock - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketPublicAccessBlockRequest(
        bucket: 'test-bucket',
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: true,
        ),
      );

      expect(
        () async => await client.putBucketPublicAccessBlock(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketPublicAccessBlock =====
    test('testGetBucketPublicAccessBlock - success', () async {
      final xml = '''<PublicAccessBlockConfiguration>
    <BlockPublicAccess>true</BlockPublicAccess>
</PublicAccessBlockConfiguration>''';
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

      final request = GetBucketPublicAccessBlockRequest(bucket: 'test-bucket');
      final result = await client.getBucketPublicAccessBlock(request);

      expect(result, isNotNull);
      expect(result.publicAccessBlockConfiguration, isNotNull);
      expect(result.publicAccessBlockConfiguration!.blockPublicAccess, true);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketPublicAccessBlock - missing bucket', () async {
      final request = GetBucketPublicAccessBlockRequest();

      expect(
        () async => await client.getBucketPublicAccessBlock(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketPublicAccessBlock - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketPublicAccessBlockRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketPublicAccessBlock(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== deleteBucketPublicAccessBlock =====
    test('testDeleteBucketPublicAccessBlock - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = DeleteBucketPublicAccessBlockRequest(
        bucket: 'test-bucket',
      );
      final result = await client.deleteBucketPublicAccessBlock(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testDeleteBucketPublicAccessBlock - missing bucket', () async {
      final request = DeleteBucketPublicAccessBlockRequest();

      expect(
        () async => await client.deleteBucketPublicAccessBlock(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteBucketPublicAccessBlock - server error', () async {
      mock.addResponse(make403Response());

      final request = DeleteBucketPublicAccessBlockRequest(
        bucket: 'test-bucket',
      );

      expect(
        () async => await client.deleteBucketPublicAccessBlock(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
