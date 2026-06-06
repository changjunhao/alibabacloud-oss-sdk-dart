import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientObjectSymlink Tests', () {
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

    // ===== putSymlink =====
    test('testPutSymlink - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutSymlinkRequest(
        bucket: 'test-bucket',
        key: 'symlink-key',
        symlinkTarget: 'target-object',
      );
      final result = await client.putSymlink(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
    });

    test('testPutSymlink - missing bucket', () async {
      final request = PutSymlinkRequest(
        key: 'symlink-key',
        symlinkTarget: 'target-object',
      );

      expect(
        () async => await client.putSymlink(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutSymlink - missing key', () async {
      final request = PutSymlinkRequest(
        bucket: 'test-bucket',
        symlinkTarget: 'target-object',
      );

      expect(
        () async => await client.putSymlink(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutSymlink - server error', () async {
      mock.addResponse(make403Response());

      final request = PutSymlinkRequest(
        bucket: 'test-bucket',
        key: 'symlink-key',
        symlinkTarget: 'target-object',
      );

      expect(
        () async => await client.putSymlink(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getSymlink =====
    test('testGetSymlink - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {
            'x-oss-request-id': 'req-123',
            'x-oss-symlink-target': 'target-object',
          },
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = GetSymlinkRequest(
        bucket: 'test-bucket',
        key: 'symlink-key',
      );
      final result = await client.getSymlink(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetSymlink - missing bucket', () async {
      final request = GetSymlinkRequest(key: 'symlink-key');

      expect(
        () async => await client.getSymlink(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetSymlink - missing key', () async {
      final request = GetSymlinkRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getSymlink(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetSymlink - server error', () async {
      mock.addResponse(make403Response());

      final request = GetSymlinkRequest(
        bucket: 'test-bucket',
        key: 'symlink-key',
      );

      expect(
        () async => await client.getSymlink(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
