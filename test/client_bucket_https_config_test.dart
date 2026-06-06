import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketHttpsConfig Tests', () {
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

    // ===== putBucketHttpsConfig =====
    test('testPutBucketHttpsConfig - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketHttpsConfigRequest(
        bucket: 'test-bucket',
        httpsConfiguration: HttpsConfiguration(
          tls: TLS(enable: true, tlsVersions: ['TLSv1.2', 'TLSv1.3']),
        ),
      );
      final result = await client.putBucketHttpsConfig(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(mock.requests[0].requestUri.toString(), contains('httpsConfig'));
    });

    test('testPutBucketHttpsConfig - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketHttpsConfigRequest(
        httpsConfiguration: HttpsConfiguration(
          tls: TLS(enable: true, tlsVersions: ['TLSv1.2']),
        ),
      );

      expect(
        () async => await client.putBucketHttpsConfig(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketHttpsConfig - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketHttpsConfigRequest(
        bucket: 'test-bucket',
        httpsConfiguration: HttpsConfiguration(
          tls: TLS(enable: true, tlsVersions: ['TLSv1.2']),
        ),
      );

      expect(
        () async => await client.putBucketHttpsConfig(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketHttpsConfig =====
    test('testGetBucketHttpsConfig - success', () async {
      final xml = '''<HttpsConfiguration>
    <TLS>
        <Enable>true</Enable>
        <TLSVersion>TLSv1.2</TLSVersion>
        <TLSVersion>TLSv1.3</TLSVersion>
    </TLS>
</HttpsConfiguration>''';
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

      final request = GetBucketHttpsConfigRequest(bucket: 'test-bucket');
      final result = await client.getBucketHttpsConfig(request);

      expect(result, isNotNull);
      expect(result.httpsConfiguration, isNotNull);
      expect(result.httpsConfiguration!.tls, isNotNull);
      expect(result.httpsConfiguration!.tls!.enable, true);
      expect(result.httpsConfiguration!.tls!.tlsVersions, isNotNull);
      expect(
        result.httpsConfiguration!.tls!.tlsVersions!.contains('TLSv1.2'),
        true,
      );
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketHttpsConfig - missing bucket', () async {
      final request = GetBucketHttpsConfigRequest();

      expect(
        () async => await client.getBucketHttpsConfig(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketHttpsConfig - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketHttpsConfigRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketHttpsConfig(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== deleteBucketHttpsConfig =====
    test('testDeleteBucketHttpsConfig - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = DeleteBucketHttpsConfigRequest(bucket: 'test-bucket');
      final result = await client.deleteBucketHttpsConfig(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testDeleteBucketHttpsConfig - missing bucket', () async {
      final request = DeleteBucketHttpsConfigRequest();

      expect(
        () async => await client.deleteBucketHttpsConfig(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteBucketHttpsConfig - server error', () async {
      mock.addResponse(make403Response());

      final request = DeleteBucketHttpsConfigRequest(bucket: 'test-bucket');

      expect(
        () async => await client.deleteBucketHttpsConfig(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
