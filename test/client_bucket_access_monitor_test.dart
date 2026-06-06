import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketAccessMonitor Tests', () {
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

    // ===== putBucketAccessMonitor =====
    test('testPutBucketAccessMonitor - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketAccessMonitorRequest(
        bucket: 'test-bucket',
        accessMonitorConfiguration: AccessMonitorConfiguration(
          status: AccessMonitorStatus.enabled,
        ),
      );
      final result = await client.putBucketAccessMonitor(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(mock.requests[0].requestUri.toString(), contains('accessmonitor'));
    });

    test('testPutBucketAccessMonitor - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketAccessMonitorRequest(
        accessMonitorConfiguration: AccessMonitorConfiguration(
          status: AccessMonitorStatus.enabled,
        ),
      );

      expect(
        () async => await client.putBucketAccessMonitor(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketAccessMonitor - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketAccessMonitorRequest(
        bucket: 'test-bucket',
        accessMonitorConfiguration: AccessMonitorConfiguration(
          status: AccessMonitorStatus.enabled,
        ),
      );

      expect(
        () async => await client.putBucketAccessMonitor(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketAccessMonitor =====
    test('testGetBucketAccessMonitor - success', () async {
      final xml = '''<AccessMonitorConfiguration>
    <Status>Enabled</Status>
</AccessMonitorConfiguration>''';
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

      final request = GetBucketAccessMonitorRequest(bucket: 'test-bucket');
      final result = await client.getBucketAccessMonitor(request);

      expect(result, isNotNull);
      expect(result.accessMonitorConfiguration, isNotNull);
      expect(
        result.accessMonitorConfiguration!.status,
        AccessMonitorStatus.enabled,
      );
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketAccessMonitor - missing bucket', () async {
      final request = GetBucketAccessMonitorRequest();

      expect(
        () async => await client.getBucketAccessMonitor(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketAccessMonitor - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketAccessMonitorRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketAccessMonitor(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
