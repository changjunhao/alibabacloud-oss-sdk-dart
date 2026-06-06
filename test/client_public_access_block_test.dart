import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientPublicAccessBlock Tests', () {
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

    // ===== putPublicAccessBlock =====
    test('testPutPublicAccessBlock - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutPublicAccessBlockRequest(
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: true,
        ),
      );
      final result = await client.putPublicAccessBlock(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(
        mock.requests[0].requestUri.toString(),
        contains('publicAccessBlock'),
      );
    });

    test('testPutPublicAccessBlock - missing configuration', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutPublicAccessBlockRequest();

      expect(
        () async => await client.putPublicAccessBlock(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutPublicAccessBlock - server error', () async {
      mock.addResponse(make403Response());

      final request = PutPublicAccessBlockRequest(
        publicAccessBlockConfiguration: PublicAccessBlockConfiguration(
          blockPublicAccess: true,
        ),
      );

      expect(
        () async => await client.putPublicAccessBlock(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getPublicAccessBlock =====
    test('testGetPublicAccessBlock - success', () async {
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

      final request = GetPublicAccessBlockRequest();
      final result = await client.getPublicAccessBlock(request);

      expect(result, isNotNull);
      expect(result.publicAccessBlockConfiguration, isNotNull);
      expect(result.publicAccessBlockConfiguration!.blockPublicAccess, true);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetPublicAccessBlock - server error', () async {
      mock.addResponse(make403Response());

      final request = GetPublicAccessBlockRequest();

      expect(
        () async => await client.getPublicAccessBlock(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== deletePublicAccessBlock =====
    test('testDeletePublicAccessBlock - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = DeletePublicAccessBlockRequest();
      final result = await client.deletePublicAccessBlock(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testDeletePublicAccessBlock - server error', () async {
      mock.addResponse(make403Response());

      final request = DeletePublicAccessBlockRequest();

      expect(
        () async => await client.deletePublicAccessBlock(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
