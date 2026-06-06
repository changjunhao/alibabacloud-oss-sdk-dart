import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketWorm Tests', () {
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

    // ===== initiateBucketWorm =====
    test('testInitiateBucketWorm - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {
            'x-oss-request-id': 'req-123',
            'x-oss-worm-id': 'worm-id-001',
          },
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = InitiateBucketWormRequest(
        bucket: 'test-bucket',
        initiateWormConfiguration: InitiateWormConfiguration(
          retentionPeriodInDays: 30,
        ),
      );
      final result = await client.initiateBucketWorm(request);

      expect(result, isNotNull);
      expect(result.wormId, 'worm-id-001');
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'POST');
      expect(mock.requests[0].requestUri.toString(), contains('worm'));
    });

    test('testInitiateBucketWorm - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = InitiateBucketWormRequest(
        initiateWormConfiguration: InitiateWormConfiguration(
          retentionPeriodInDays: 30,
        ),
      );

      expect(
        () async => await client.initiateBucketWorm(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testInitiateBucketWorm - server error', () async {
      mock.addResponse(make403Response());

      final request = InitiateBucketWormRequest(
        bucket: 'test-bucket',
        initiateWormConfiguration: InitiateWormConfiguration(
          retentionPeriodInDays: 30,
        ),
      );

      expect(
        () async => await client.initiateBucketWorm(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== abortBucketWorm =====
    test('testAbortBucketWorm - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = AbortBucketWormRequest(bucket: 'test-bucket');
      final result = await client.abortBucketWorm(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testAbortBucketWorm - missing bucket', () async {
      final request = AbortBucketWormRequest();

      expect(
        () async => await client.abortBucketWorm(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testAbortBucketWorm - server error', () async {
      mock.addResponse(make403Response());

      final request = AbortBucketWormRequest(bucket: 'test-bucket');

      expect(
        () async => await client.abortBucketWorm(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== completeBucketWorm =====
    test('testCompleteBucketWorm - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = CompleteBucketWormRequest(
        bucket: 'test-bucket',
        wormId: 'worm-id-001',
      );
      final result = await client.completeBucketWorm(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'POST');
    });

    test('testCompleteBucketWorm - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = CompleteBucketWormRequest(wormId: 'worm-id-001');

      expect(
        () async => await client.completeBucketWorm(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testCompleteBucketWorm - missing wormId', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = CompleteBucketWormRequest(bucket: 'test-bucket');

      expect(
        () async => await client.completeBucketWorm(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testCompleteBucketWorm - server error', () async {
      mock.addResponse(make403Response());

      final request = CompleteBucketWormRequest(
        bucket: 'test-bucket',
        wormId: 'worm-id-001',
      );

      expect(
        () async => await client.completeBucketWorm(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== extendBucketWorm =====
    test('testExtendBucketWorm - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = ExtendBucketWormRequest(
        bucket: 'test-bucket',
        wormId: 'worm-id-001',
        extendWormConfiguration: ExtendWormConfiguration(
          retentionPeriodInDays: 60,
        ),
      );
      final result = await client.extendBucketWorm(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'POST');
      expect(mock.requests[0].requestUri.toString(), contains('wormExtend'));
    });

    test('testExtendBucketWorm - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = ExtendBucketWormRequest(
        wormId: 'worm-id-001',
        extendWormConfiguration: ExtendWormConfiguration(
          retentionPeriodInDays: 60,
        ),
      );

      expect(
        () async => await client.extendBucketWorm(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testExtendBucketWorm - missing wormId', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = ExtendBucketWormRequest(
        bucket: 'test-bucket',
        extendWormConfiguration: ExtendWormConfiguration(
          retentionPeriodInDays: 60,
        ),
      );

      expect(
        () async => await client.extendBucketWorm(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testExtendBucketWorm - server error', () async {
      mock.addResponse(make403Response());

      final request = ExtendBucketWormRequest(
        bucket: 'test-bucket',
        wormId: 'worm-id-001',
        extendWormConfiguration: ExtendWormConfiguration(
          retentionPeriodInDays: 60,
        ),
      );

      expect(
        () async => await client.extendBucketWorm(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketWorm =====
    test('testGetBucketWorm - success', () async {
      final xml = '''<WormConfiguration>
    <WormId>worm-id-001</WormId>
    <State>Locked</State>
    <RetentionPeriodInDays>30</RetentionPeriodInDays>
    <CreationDate>2023-01-01T00:00:00.000Z</CreationDate>
    <ExpirationDate>2023-02-01T00:00:00.000Z</ExpirationDate>
</WormConfiguration>''';
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

      final request = GetBucketWormRequest(bucket: 'test-bucket');
      final result = await client.getBucketWorm(request);

      expect(result, isNotNull);
      expect(result.wormConfiguration?.wormId, 'worm-id-001');
      expect(result.wormConfiguration?.retentionPeriodInDays, 30);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketWorm - missing bucket', () async {
      final request = GetBucketWormRequest();

      expect(
        () async => await client.getBucketWorm(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketWorm - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketWormRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketWorm(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
