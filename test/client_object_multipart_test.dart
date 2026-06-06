import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientObjectMultipart Tests', () {
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

    // ===== initiateMultipartUpload =====
    test('testInitiateMultipartUpload - success', () async {
      const xml = '''<InitiateMultipartUploadResult>
  <Bucket>test-bucket</Bucket>
  <Key>test-key</Key>
  <UploadId>0004B9894A22E5B1888A1E29F823****</UploadId>
</InitiateMultipartUploadResult>''';
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

      final request = InitiateMultipartUploadRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );
      final result = await client.initiateMultipartUpload(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'POST');
    });

    test('testInitiateMultipartUpload - missing bucket', () async {
      final request = InitiateMultipartUploadRequest(key: 'test-key');

      expect(
        () async => await client.initiateMultipartUpload(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testInitiateMultipartUpload - missing key', () async {
      final request = InitiateMultipartUploadRequest(bucket: 'test-bucket');

      expect(
        () async => await client.initiateMultipartUpload(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testInitiateMultipartUpload - server error', () async {
      mock.addResponse(make403Response());

      final request = InitiateMultipartUploadRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );

      expect(
        () async => await client.initiateMultipartUpload(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== uploadPart =====
    test('testUploadPart - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123', 'etag': '"etag-part-1"'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = UploadPartRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        uploadId: '0004B9894A22E5B1888A1E29F823****',
        partNumber: 1,
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('part data'))),
      );
      final result = await client.uploadPart(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
    });

    test('testUploadPart - missing bucket', () async {
      final request = UploadPartRequest(
        key: 'test-key',
        uploadId: 'upload-id',
        partNumber: 1,
        body: ByteStream.fromData(Uint8List(0)),
      );

      expect(
        () async => await client.uploadPart(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testUploadPart - missing key', () async {
      final request = UploadPartRequest(
        bucket: 'test-bucket',
        uploadId: 'upload-id',
        partNumber: 1,
        body: ByteStream.fromData(Uint8List(0)),
      );

      expect(
        () async => await client.uploadPart(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testUploadPart - missing uploadId', () async {
      final request = UploadPartRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        partNumber: 1,
        body: ByteStream.fromData(Uint8List(0)),
      );

      expect(
        () async => await client.uploadPart(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testUploadPart - missing partNumber', () async {
      final request = UploadPartRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        uploadId: 'upload-id',
        body: ByteStream.fromData(Uint8List(0)),
      );

      expect(
        () async => await client.uploadPart(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testUploadPart - server error', () async {
      mock.addResponse(make403Response());

      final request = UploadPartRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        uploadId: 'upload-id',
        partNumber: 1,
        body: ByteStream.fromData(Uint8List(0)),
      );

      expect(
        () async => await client.uploadPart(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== uploadPartCopy =====
    test('testUploadPartCopy - success', () async {
      const xml = '''<CopyPartResult>
  <ETag>"3349DC700140D7F86A0784842780****"</ETag>
  <LastModified>2012-02-23T07:01:34.000Z</LastModified>
</CopyPartResult>''';
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

      final request = UploadPartCopyRequest(
        bucket: 'test-bucket',
        key: 'dest-key',
        uploadId: '0004B9894A22E5B1888A1E29F823****',
        partNumber: 1,
        sourceBucket: 'src-bucket',
        sourceKey: 'src-key',
      );
      final result = await client.uploadPartCopy(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
    });

    test('testUploadPartCopy - missing bucket', () async {
      final request = UploadPartCopyRequest(
        key: 'dest-key',
        uploadId: 'upload-id',
        partNumber: 1,
        sourceKey: 'src-key',
      );

      expect(
        () async => await client.uploadPartCopy(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testUploadPartCopy - missing key', () async {
      final request = UploadPartCopyRequest(
        bucket: 'test-bucket',
        uploadId: 'upload-id',
        partNumber: 1,
        sourceKey: 'src-key',
      );

      expect(
        () async => await client.uploadPartCopy(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testUploadPartCopy - missing uploadId', () async {
      final request = UploadPartCopyRequest(
        bucket: 'test-bucket',
        key: 'dest-key',
        partNumber: 1,
        sourceKey: 'src-key',
      );

      expect(
        () async => await client.uploadPartCopy(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testUploadPartCopy - missing partNumber', () async {
      final request = UploadPartCopyRequest(
        bucket: 'test-bucket',
        key: 'dest-key',
        uploadId: 'upload-id',
        sourceKey: 'src-key',
      );

      expect(
        () async => await client.uploadPartCopy(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testUploadPartCopy - server error', () async {
      mock.addResponse(make403Response());

      final request = UploadPartCopyRequest(
        bucket: 'test-bucket',
        key: 'dest-key',
        uploadId: 'upload-id',
        partNumber: 1,
        sourceBucket: 'src-bucket',
        sourceKey: 'src-key',
      );

      expect(
        () async => await client.uploadPartCopy(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== completeMultipartUpload =====
    test('testCompleteMultipartUpload - success', () async {
      const xml = '''<CompleteMultipartUploadResult>
  <Location>http://oss-example.oss-cn-hangzhou.aliyuncs.com/multipart.data</Location>
  <Bucket>oss-example</Bucket>
  <Key>multipart.data</Key>
  <ETag>"B864DB6A936D376F9F8D3ED3BBE540****"</ETag>
</CompleteMultipartUploadResult>''';
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

      final request = CompleteMultipartUploadRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        uploadId: '0004B9894A22E5B1888A1E29F823****',
        completeMultipartUpload: CompleteMultipartUpload(
          parts: [
            UploadPart(partNumber: 1, etag: '"etag-1"'),
            UploadPart(partNumber: 2, etag: '"etag-2"'),
          ],
        ),
      );
      final result = await client.completeMultipartUpload(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'POST');
    });

    test('testCompleteMultipartUpload - missing bucket', () async {
      final request = CompleteMultipartUploadRequest(
        key: 'test-key',
        uploadId: 'upload-id',
      );

      expect(
        () async => await client.completeMultipartUpload(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testCompleteMultipartUpload - missing key', () async {
      final request = CompleteMultipartUploadRequest(
        bucket: 'test-bucket',
        uploadId: 'upload-id',
      );

      expect(
        () async => await client.completeMultipartUpload(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testCompleteMultipartUpload - missing uploadId', () async {
      final request = CompleteMultipartUploadRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );

      expect(
        () async => await client.completeMultipartUpload(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testCompleteMultipartUpload - server error', () async {
      mock.addResponse(make403Response());

      final request = CompleteMultipartUploadRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        uploadId: 'upload-id',
      );

      expect(
        () async => await client.completeMultipartUpload(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== abortMultipartUpload =====
    test('testAbortMultipartUpload - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = AbortMultipartUploadRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        uploadId: '0004B9894A22E5B1888A1E29F823****',
      );
      final result = await client.abortMultipartUpload(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testAbortMultipartUpload - missing bucket', () async {
      final request = AbortMultipartUploadRequest(
        key: 'test-key',
        uploadId: 'upload-id',
      );

      expect(
        () async => await client.abortMultipartUpload(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testAbortMultipartUpload - missing key', () async {
      final request = AbortMultipartUploadRequest(
        bucket: 'test-bucket',
        uploadId: 'upload-id',
      );

      expect(
        () async => await client.abortMultipartUpload(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testAbortMultipartUpload - missing uploadId', () async {
      final request = AbortMultipartUploadRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );

      expect(
        () async => await client.abortMultipartUpload(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testAbortMultipartUpload - server error', () async {
      mock.addResponse(make403Response());

      final request = AbortMultipartUploadRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        uploadId: 'upload-id',
      );

      expect(
        () async => await client.abortMultipartUpload(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== listMultipartUploads =====
    test('testListMultipartUploads - success', () async {
      const xml = '''<ListMultipartUploadsResult>
  <Bucket>test-bucket</Bucket>
  <KeyMarker></KeyMarker>
  <UploadIdMarker></UploadIdMarker>
  <NextKeyMarker>oss.avi</NextKeyMarker>
  <NextUploadIdMarker>0004B99B8E707874FC2D692FA5D7****</NextUploadIdMarker>
  <MaxUploads>1000</MaxUploads>
  <IsTruncated>false</IsTruncated>
  <Upload>
    <Key>multipart.data</Key>
    <UploadId>0004B999EF518A1FE585B0C9360DC4****</UploadId>
    <Initiated>2012-02-23T04:18:23.000Z</Initiated>
  </Upload>
</ListMultipartUploadsResult>''';
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

      final request = ListMultipartUploadsRequest(bucket: 'test-bucket');
      final result = await client.listMultipartUploads(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testListMultipartUploads - missing bucket', () async {
      final request = ListMultipartUploadsRequest();

      expect(
        () async => await client.listMultipartUploads(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testListMultipartUploads - server error', () async {
      mock.addResponse(make403Response());

      final request = ListMultipartUploadsRequest(bucket: 'test-bucket');

      expect(
        () async => await client.listMultipartUploads(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== listParts =====
    test('testListParts - success', () async {
      const xml = '''<ListPartsResult>
  <Bucket>test-bucket</Bucket>
  <Key>test-key</Key>
  <UploadId>0004B999EF518A1FE585B0C9360DC4****</UploadId>
  <MaxParts>1000</MaxParts>
  <IsTruncated>false</IsTruncated>
  <Part>
    <PartNumber>1</PartNumber>
    <LastModified>2012-02-23T07:01:34.000Z</LastModified>
    <ETag>"3349DC700140D7F86A0784842780****"</ETag>
    <Size>6291456</Size>
  </Part>
</ListPartsResult>''';
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

      final request = ListPartsRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        uploadId: '0004B999EF518A1FE585B0C9360DC4****',
      );
      final result = await client.listParts(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testListParts - missing bucket', () async {
      final request = ListPartsRequest(key: 'test-key', uploadId: 'upload-id');

      expect(
        () async => await client.listParts(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testListParts - missing key', () async {
      final request = ListPartsRequest(
        bucket: 'test-bucket',
        uploadId: 'upload-id',
      );

      expect(
        () async => await client.listParts(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testListParts - missing uploadId', () async {
      final request = ListPartsRequest(bucket: 'test-bucket', key: 'test-key');

      expect(
        () async => await client.listParts(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testListParts - server error', () async {
      mock.addResponse(make403Response());

      final request = ListPartsRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        uploadId: 'upload-id',
      );

      expect(
        () async => await client.listParts(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
