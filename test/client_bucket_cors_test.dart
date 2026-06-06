import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketCors Tests', () {
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

    // ===== putBucketCors =====
    test('testPutBucketCors - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketCorsRequest(
        bucket: 'test-bucket',
        corsConfiguration: CORSConfiguration(
          corsRules: [
            CORSRule(
              allowedOrigins: ['http://example.com'],
              allowedMethods: ['GET', 'PUT'],
              allowedHeaders: ['x-oss-test'],
              exposeHeaders: ['x-oss-request-id'],
              maxAgeSeconds: 100,
            ),
          ],
          responseVary: true,
        ),
      );
      final result = await client.putBucketCors(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(mock.requests[0].requestUri.toString(), contains('cors'));
    });

    test('testPutBucketCors - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketCorsRequest(
        corsConfiguration: CORSConfiguration(),
      );

      expect(
        () async => await client.putBucketCors(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketCors - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketCorsRequest(
        bucket: 'test-bucket',
        corsConfiguration: CORSConfiguration(),
      );

      expect(
        () async => await client.putBucketCors(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketCors =====
    test('testGetBucketCors - success', () async {
      final xml = '''<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration>
    <CORSRule>
        <AllowedOrigin>http://example.com</AllowedOrigin>
        <AllowedOrigin>http://example2.com</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>PUT</AllowedMethod>
        <AllowedHeader>x-oss-test</AllowedHeader>
        <ExposeHeader>x-oss-request-id</ExposeHeader>
        <MaxAgeSeconds>100</MaxAgeSeconds>
    </CORSRule>
    <ResponseVary>true</ResponseVary>
</CORSConfiguration>''';
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

      final request = GetBucketCorsRequest(bucket: 'test-bucket');
      final result = await client.getBucketCors(request);

      expect(result, isNotNull);
      expect(result.corsConfiguration, isNotNull);
      expect(result.corsConfiguration!.corsRules, isNotNull);
      expect(result.corsConfiguration!.corsRules!.length, 1);
      expect(
        result.corsConfiguration!.corsRules![0].allowedOrigins,
        contains('http://example.com'),
      );
      expect(result.corsConfiguration!.responseVary, true);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketCors - missing bucket', () async {
      final request = GetBucketCorsRequest();

      expect(
        () async => await client.getBucketCors(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketCors - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketCorsRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketCors(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== deleteBucketCors =====
    test('testDeleteBucketCors - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = DeleteBucketCorsRequest(bucket: 'test-bucket');
      final result = await client.deleteBucketCors(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testDeleteBucketCors - missing bucket', () async {
      final request = DeleteBucketCorsRequest();

      expect(
        () async => await client.deleteBucketCors(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteBucketCors - server error', () async {
      mock.addResponse(make403Response());

      final request = DeleteBucketCorsRequest(bucket: 'test-bucket');

      expect(
        () async => await client.deleteBucketCors(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== optionObject =====
    test('testOptionObject - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {
            'x-oss-request-id': 'req-123',
            'Access-Control-Allow-Origin': 'http://example.com',
            'Access-Control-Allow-Methods': 'GET, PUT',
            'Access-Control-Allow-Headers': 'x-oss-test',
            'Access-Control-Expose-Headers': 'x-oss-request-id',
            'Access-Control-Max-Age': '100',
          },
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = OptionObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        origin: 'http://example.com',
        accessControlRequestMethod: 'GET',
        accessControlRequestHeaders: 'x-oss-test',
      );
      final result = await client.optionObject(request);

      expect(result, isNotNull);
      expect(result.accessControlAllowOrigin, 'http://example.com');
      expect(result.accessControlAllowMethods, 'GET, PUT');
      expect(result.accessControlMaxAge, 100);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'OPTIONS');
    });

    test('testOptionObject - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = OptionObjectRequest(
        key: 'test-key',
        origin: 'http://example.com',
        accessControlRequestMethod: 'GET',
      );

      expect(
        () async => await client.optionObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testOptionObject - missing key', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = OptionObjectRequest(
        bucket: 'test-bucket',
        origin: 'http://example.com',
        accessControlRequestMethod: 'GET',
      );

      expect(
        () async => await client.optionObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testOptionObject - server error', () async {
      mock.addResponse(make403Response());

      final request = OptionObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        origin: 'http://example.com',
        accessControlRequestMethod: 'GET',
      );

      expect(
        () async => await client.optionObject(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
