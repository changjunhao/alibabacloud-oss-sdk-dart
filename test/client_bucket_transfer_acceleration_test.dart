import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketTransferAcceleration Tests', () {
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

    // ===== putBucketTransferAcceleration =====
    test('testPutBucketTransferAcceleration - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketTransferAccelerationRequest(
        bucket: 'test-bucket',
        transferAccelerationConfiguration: TransferAccelerationConfiguration(
          enabled: true,
        ),
      );
      final result = await client.putBucketTransferAcceleration(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(
        mock.requests[0].requestUri.toString(),
        contains('transferAcceleration'),
      );
    });

    test('testPutBucketTransferAcceleration - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketTransferAccelerationRequest(
        transferAccelerationConfiguration: TransferAccelerationConfiguration(
          enabled: true,
        ),
      );

      expect(
        () async => await client.putBucketTransferAcceleration(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketTransferAcceleration - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketTransferAccelerationRequest(
        bucket: 'test-bucket',
        transferAccelerationConfiguration: TransferAccelerationConfiguration(
          enabled: true,
        ),
      );

      expect(
        () async => await client.putBucketTransferAcceleration(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketTransferAcceleration =====
    test('testGetBucketTransferAcceleration - success', () async {
      final xml = '''<TransferAccelerationConfiguration>
    <Enabled>true</Enabled>
</TransferAccelerationConfiguration>''';
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

      final request = GetBucketTransferAccelerationRequest(
        bucket: 'test-bucket',
      );
      final result = await client.getBucketTransferAcceleration(request);

      expect(result, isNotNull);
      expect(result.transferAccelerationConfiguration, isNotNull);
      expect(result.transferAccelerationConfiguration!.enabled, true);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketTransferAcceleration - missing bucket', () async {
      final request = GetBucketTransferAccelerationRequest();

      expect(
        () async => await client.getBucketTransferAcceleration(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketTransferAcceleration - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketTransferAccelerationRequest(
        bucket: 'test-bucket',
      );

      expect(
        () async => await client.getBucketTransferAcceleration(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
