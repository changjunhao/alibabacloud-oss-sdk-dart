import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketVersioning Tests', () {
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

    // ===== putBucketVersioning =====
    test('testPutBucketVersioning - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketVersioningRequest(
        bucket: 'test-bucket',
        versioningConfiguration: VersioningConfiguration(status: 'Enabled'),
      );
      final result = await client.putBucketVersioning(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
    });

    test('testPutBucketVersioning - missing bucket', () async {
      final request = PutBucketVersioningRequest(
        versioningConfiguration: VersioningConfiguration(status: 'Enabled'),
      );

      expect(
        () async => await client.putBucketVersioning(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketVersioning - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketVersioningRequest(
        bucket: 'test-bucket',
        versioningConfiguration: VersioningConfiguration(status: 'Enabled'),
      );

      expect(
        () async => await client.putBucketVersioning(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketVersioning =====
    test('testGetBucketVersioning - success', () async {
      final xml = '''<VersioningConfiguration>
  <Status>Enabled</Status>
</VersioningConfiguration>''';
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

      final request = GetBucketVersioningRequest(bucket: 'test-bucket');
      final result = await client.getBucketVersioning(request);

      expect(result, isNotNull);
      expect(result.versioningConfiguration, isNotNull);
      expect(result.versioningConfiguration!.status, equals('Enabled'));
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketVersioning - missing bucket', () async {
      final request = GetBucketVersioningRequest();

      expect(
        () async => await client.getBucketVersioning(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketVersioning - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketVersioningRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketVersioning(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== listObjectVersions =====
    test('testListObjectVersions - success', () async {
      final xml = '''<ListVersionsResult>
  <Name>examplebucket</Name>
  <Prefix></Prefix>
  <KeyMarker></KeyMarker>
  <NextKeyMarker>next-key-marker</NextKeyMarker>
  <MaxKeys>100</MaxKeys>
  <IsTruncated>false</IsTruncated>
  <Version>
    <Key>example-object-1.jpg</Key>
    <VersionId>CAEQNhiBgMDJgZCA0BYiIDc4MGZjZGI2****</VersionId>
    <IsLatest>true</IsLatest>
    <LastModified>2019-04-09T07:27:28.000Z</LastModified>
    <ETag>"250F8A0AE989679A22926A875F0A2****"</ETag>
    <Size>93731</Size>
    <StorageClass>Standard</StorageClass>
  </Version>
</ListVersionsResult>''';
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

      final request = ListObjectVersionsRequest(bucket: 'test-bucket');
      final result = await client.listObjectVersions(request);

      expect(result, isNotNull);
      expect(result.name, equals('examplebucket'));
      expect(result.versions, isNotNull);
      expect(result.versions!.length, equals(1));
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testListObjectVersions - missing bucket', () async {
      final request = ListObjectVersionsRequest();

      expect(
        () async => await client.listObjectVersions(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testListObjectVersions - server error', () async {
      mock.addResponse(make403Response());

      final request = ListObjectVersionsRequest(bucket: 'test-bucket');

      expect(
        () async => await client.listObjectVersions(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
