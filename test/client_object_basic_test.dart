import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientObjectBasic Tests', () {
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

    // ===== putObject =====
    test('testPutObject - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123', 'etag': '"etag-123"'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final body = ByteStream.fromData(
        Uint8List.fromList(utf8.encode('hello world')),
      );
      final request = PutObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        body: body,
      );
      final result = await client.putObject(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
    });

    test('testPutObject - missing bucket', () async {
      final request = PutObjectRequest(
        key: 'test-key',
        body: ByteStream.fromData(Uint8List(0)),
      );

      expect(
        () async => await client.putObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutObject - missing key', () async {
      final request = PutObjectRequest(
        bucket: 'test-bucket',
        body: ByteStream.fromData(Uint8List(0)),
      );

      expect(
        () async => await client.putObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutObject - server error', () async {
      mock.addResponse(make403Response());

      final request = PutObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        body: ByteStream.fromData(Uint8List(0)),
      );

      expect(
        () async => await client.putObject(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getObject =====
    test('testGetObject - success', () async {
      final bodyData = Uint8List.fromList(utf8.encode('file content'));
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {
            'x-oss-request-id': 'req-123',
            'content-type': 'application/octet-stream',
          },
          content: ByteStream.fromData(bodyData),
        ),
      );

      final request = GetObjectRequest(bucket: 'test-bucket', key: 'test-key');
      final result = await client.getObject(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetObject - missing bucket', () async {
      final request = GetObjectRequest(key: 'test-key');

      expect(
        () async => await client.getObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetObject - missing key', () async {
      final request = GetObjectRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetObject - server error', () async {
      mock.addResponse(make403Response());

      final request = GetObjectRequest(bucket: 'test-bucket', key: 'test-key');

      expect(
        () async => await client.getObject(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== copyObject =====
    test('testCopyObject - success', () async {
      final xml = '''<CopyObjectResult>
  <ETag>"5B3C1A2E053D763E1B002CC607C5A0FE1"</ETag>
  <LastModified>2024-01-01T12:00:00.000Z</LastModified>
</CopyObjectResult>''';
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

      final request = CopyObjectRequest(
        bucket: 'test-bucket',
        key: 'dest-key',
        sourceBucket: 'src-bucket',
        sourceKey: 'src-key',
      );
      final result = await client.copyObject(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
    });

    test('testCopyObject - missing bucket', () async {
      final request = CopyObjectRequest(key: 'dest-key');

      expect(
        () async => await client.copyObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testCopyObject - missing key', () async {
      final request = CopyObjectRequest(bucket: 'test-bucket');

      expect(
        () async => await client.copyObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testCopyObject - server error', () async {
      mock.addResponse(make403Response());

      final request = CopyObjectRequest(
        bucket: 'test-bucket',
        key: 'dest-key',
        sourceBucket: 'src-bucket',
        sourceKey: 'src-key',
      );

      expect(
        () async => await client.copyObject(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== appendObject =====
    test('testAppendObject - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {
            'x-oss-request-id': 'req-123',
            'x-oss-next-append-position': '11',
          },
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = AppendObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        position: 0,
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('hello'))),
      );
      final result = await client.appendObject(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'POST');
    });

    test('testAppendObject - missing bucket', () async {
      final request = AppendObjectRequest(
        key: 'test-key',
        position: 0,
        body: ByteStream.fromData(Uint8List(0)),
      );

      expect(
        () async => await client.appendObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testAppendObject - missing key', () async {
      final request = AppendObjectRequest(
        bucket: 'test-bucket',
        position: 0,
        body: ByteStream.fromData(Uint8List(0)),
      );

      expect(
        () async => await client.appendObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testAppendObject - server error', () async {
      mock.addResponse(make403Response());

      final request = AppendObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        position: 0,
        body: ByteStream.fromData(Uint8List(0)),
      );

      expect(
        () async => await client.appendObject(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== deleteObject =====
    test('testDeleteObject - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = DeleteObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );
      final result = await client.deleteObject(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testDeleteObject - missing bucket', () async {
      final request = DeleteObjectRequest(key: 'test-key');

      expect(
        () async => await client.deleteObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteObject - missing key', () async {
      final request = DeleteObjectRequest(bucket: 'test-bucket');

      expect(
        () async => await client.deleteObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteObject - server error', () async {
      mock.addResponse(make403Response());

      final request = DeleteObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );

      expect(
        () async => await client.deleteObject(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== deleteMultipleObjects =====
    test('testDeleteMultipleObjects - success', () async {
      final xml = '''<DeleteResult>
  <Deleted>
    <Key>key1</Key>
  </Deleted>
  <Deleted>
    <Key>key2</Key>
  </Deleted>
</DeleteResult>''';
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

      final request = DeleteMultipleObjectsRequest(
        bucket: 'test-bucket',
        objects: [
          DeleteObject(key: 'key1'),
          DeleteObject(key: 'key2'),
        ],
      );
      final result = await client.deleteMultipleObjects(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'POST');
    });

    test('testDeleteMultipleObjects - missing bucket', () async {
      final request = DeleteMultipleObjectsRequest(
        objects: [DeleteObject(key: 'key1')],
      );

      expect(
        () async => await client.deleteMultipleObjects(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteMultipleObjects - server error', () async {
      mock.addResponse(make403Response());

      final request = DeleteMultipleObjectsRequest(
        bucket: 'test-bucket',
        objects: [DeleteObject(key: 'key1')],
      );

      expect(
        () async => await client.deleteMultipleObjects(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== headObject =====
    test('testHeadObject - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {
            'x-oss-request-id': 'req-123',
            'content-length': '1024',
            'etag': '"etag-value"',
            'content-type': 'application/octet-stream',
          },
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = HeadObjectRequest(bucket: 'test-bucket', key: 'test-key');
      final result = await client.headObject(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'HEAD');
    });

    test('testHeadObject - missing bucket', () async {
      final request = HeadObjectRequest(key: 'test-key');

      expect(
        () async => await client.headObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testHeadObject - missing key', () async {
      final request = HeadObjectRequest(bucket: 'test-bucket');

      expect(
        () async => await client.headObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testHeadObject - server error', () async {
      mock.addResponse(make403Response());

      final request = HeadObjectRequest(bucket: 'test-bucket', key: 'test-key');

      expect(
        () async => await client.headObject(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getObjectMeta =====
    test('testGetObjectMeta - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {
            'x-oss-request-id': 'req-123',
            'content-length': '2048',
            'etag': '"etag-meta"',
            'last-modified': 'Thu, 01 Dec 2025 16:00:00 GMT',
          },
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = GetObjectMetaRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );
      final result = await client.getObjectMeta(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'HEAD');
    });

    test('testGetObjectMeta - missing bucket', () async {
      final request = GetObjectMetaRequest(key: 'test-key');

      expect(
        () async => await client.getObjectMeta(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetObjectMeta - missing key', () async {
      final request = GetObjectMetaRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getObjectMeta(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetObjectMeta - server error', () async {
      mock.addResponse(make403Response());

      final request = GetObjectMetaRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );

      expect(
        () async => await client.getObjectMeta(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== restoreObject =====
    test('testRestoreObject - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 202,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = RestoreObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );
      final result = await client.restoreObject(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'POST');
    });

    test('testRestoreObject - missing bucket', () async {
      final request = RestoreObjectRequest(key: 'test-key');

      expect(
        () async => await client.restoreObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testRestoreObject - missing key', () async {
      final request = RestoreObjectRequest(bucket: 'test-bucket');

      expect(
        () async => await client.restoreObject(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testRestoreObject - server error', () async {
      mock.addResponse(make403Response());

      final request = RestoreObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );

      expect(
        () async => await client.restoreObject(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== isObjectExist =====
    test('testIsObjectExist - exists', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {
            'x-oss-request-id': 'req-123',
            'content-length': '1024',
            'etag': '"etag-123"',
          },
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final result = await client.isObjectExist('test-bucket', 'test-key');

      expect(result, isTrue);
      expect(mock.requests.length, 1);
    });

    test('testIsObjectExist - not exists', () async {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<Error>
    <Code>NoSuchKey</Code>
    <Message>The specified key does not exist.</Message>
    <RequestId>id-1234</RequestId>
    <HostId>oss-cn-hangzhou.aliyuncs.com</HostId>
    <Key>test-key</Key>
    <EC>0026-00000001</EC>
</Error>''';
      final data = Uint8List.fromList(xml.codeUnits);
      mock.addResponse(
        ResponseMessage(
          statusCode: 404,
          headers: {
            'x-oss-request-id': 'req-id-123',
            'content-type': 'application/xml',
            'content-length': data.length.toString(),
          },
          content: ByteStream.fromData(data),
        ),
      );

      final result = await client.isObjectExist('test-bucket', 'test-key');

      expect(result, isFalse);
    });

    test('testIsObjectExist - server error', () async {
      mock.addResponse(make403Response());

      expect(
        () async => await client.isObjectExist('test-bucket', 'test-key'),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
