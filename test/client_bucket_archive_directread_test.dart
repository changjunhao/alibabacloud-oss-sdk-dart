import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketArchiveDirectread Tests', () {
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

    // ===== putBucketArchiveDirectRead =====
    test('testPutBucketArchiveDirectRead - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketArchiveDirectReadRequest(
        bucket: 'test-bucket',
        archiveDirectReadConfiguration: ArchiveDirectReadConfiguration(
          enabled: true,
        ),
      );
      final result = await client.putBucketArchiveDirectRead(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(
        mock.requests[0].requestUri.toString(),
        contains('bucketArchiveDirectRead'),
      );
    });

    test('testPutBucketArchiveDirectRead - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketArchiveDirectReadRequest(
        archiveDirectReadConfiguration: ArchiveDirectReadConfiguration(
          enabled: true,
        ),
      );

      expect(
        () async => await client.putBucketArchiveDirectRead(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketArchiveDirectRead - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketArchiveDirectReadRequest(
        bucket: 'test-bucket',
        archiveDirectReadConfiguration: ArchiveDirectReadConfiguration(
          enabled: true,
        ),
      );

      expect(
        () async => await client.putBucketArchiveDirectRead(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketArchiveDirectRead =====
    test('testGetBucketArchiveDirectRead - success', () async {
      final xml = '''<ArchiveDirectReadConfiguration>
    <Enabled>true</Enabled>
</ArchiveDirectReadConfiguration>''';
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

      final request = GetBucketArchiveDirectReadRequest(bucket: 'test-bucket');
      final result = await client.getBucketArchiveDirectRead(request);

      expect(result, isNotNull);
      expect(result.archiveDirectReadConfiguration, isNotNull);
      expect(result.archiveDirectReadConfiguration!.enabled, true);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketArchiveDirectRead - missing bucket', () async {
      final request = GetBucketArchiveDirectReadRequest();

      expect(
        () async => await client.getBucketArchiveDirectRead(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketArchiveDirectRead - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketArchiveDirectReadRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketArchiveDirectRead(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
