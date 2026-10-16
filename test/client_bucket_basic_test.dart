import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketBasic Tests', () {
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

    test(
      'PutBucket sends parent bucket header and omits unconfigured body',
      () async {
        mock.addResponse(ResponseMessage(statusCode: 200, headers: {}));
        await client.putBucket(
          PutBucketRequest(
            bucket: 'space',
            agenticBucket: 'parent-137-cn-hangzhou-ab-apsr',
          ),
        );
        final sent = mock.requests.single;
        expect(
          sent.headers['x-oss-agentic-bucket'],
          'parent-137-cn-hangzhou-ab-apsr',
        );
        expect(sent.content, isNull);
        expect(sent.headers['content-md5'], isNull);
      },
    );

    // ===== putBucket =====
    test('testPutBucket - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketRequest(bucket: 'test-bucket');
      final result = await client.putBucket(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
    });

    test('testPutBucket - missing bucket', () async {
      final request = PutBucketRequest();

      expect(
        () async => await client.putBucket(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucket - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketRequest(bucket: 'test-bucket');

      expect(
        () async => await client.putBucket(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== deleteBucket =====
    test('testDeleteBucket - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = DeleteBucketRequest(bucket: 'test-bucket');
      final result = await client.deleteBucket(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testDeleteBucket - missing bucket', () async {
      final request = DeleteBucketRequest();

      expect(
        () async => await client.deleteBucket(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteBucket - server error', () async {
      mock.addResponse(make403Response());

      final request = DeleteBucketRequest(bucket: 'test-bucket');

      expect(
        () async => await client.deleteBucket(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketInfo =====
    test('testGetBucketInfo - success', () async {
      final xml = '''<BucketInfo>
  <Bucket>
    <CreationDate>2013-07-31T10:56:21.000Z</CreationDate>
    <ExtranetEndpoint>oss-cn-hangzhou.aliyuncs.com</ExtranetEndpoint>
    <IntranetEndpoint>oss-cn-hangzhou-internal.aliyuncs.com</IntranetEndpoint>
    <Location>oss-cn-hangzhou</Location>
    <StorageClass>Standard</StorageClass>
    <Name>oss-example</Name>
    <Owner>
      <DisplayName>username</DisplayName>
      <ID>27183473914****</ID>
    </Owner>
    <AccessControlList>
      <Grant>private</Grant>
    </AccessControlList>
  </Bucket>
</BucketInfo>''';
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

      final request = GetBucketInfoRequest(bucket: 'test-bucket');
      final result = await client.getBucketInfo(request);

      expect(result, isNotNull);
      expect(result.bucketInfo, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketInfo - missing bucket', () async {
      final request = GetBucketInfoRequest();

      expect(
        () async => await client.getBucketInfo(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketInfo - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketInfoRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketInfo(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketLocation =====
    test('testGetBucketLocation - success', () async {
      final xml = '<LocationConstraint>oss-cn-hangzhou</LocationConstraint>';
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

      final request = GetBucketLocationRequest(bucket: 'test-bucket');
      final result = await client.getBucketLocation(request);

      expect(result, isNotNull);
      expect(result.locationConstraint, equals('oss-cn-hangzhou'));
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketLocation - missing bucket', () async {
      final request = GetBucketLocationRequest();

      expect(
        () async => await client.getBucketLocation(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketLocation - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketLocationRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketLocation(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketStat =====
    test('testGetBucketStat - success', () async {
      final xml = '''<BucketStat>
  <Storage>1600</Storage>
  <ObjectCount>230</ObjectCount>
  <MultipartUploadCount>40</MultipartUploadCount>
  <LiveChannelCount>4</LiveChannelCount>
  <LastModifiedTime>1643341269</LastModifiedTime>
  <StandardStorage>430</StandardStorage>
  <StandardObjectCount>66</StandardObjectCount>
  <InfrequentAccessStorage>2359296</InfrequentAccessStorage>
  <InfrequentAccessRealStorage>360</InfrequentAccessRealStorage>
  <InfrequentAccessObjectCount>China Chinese</InfrequentAccessObjectCount>
  <ArchiveStorage>2949120</ArchiveStorage>
  <ArchiveRealStorage>450</ArchiveRealStorage>
  <ArchiveObjectCount>China object</ArchiveObjectCount>
</BucketStat>''';
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

      final request = GetBucketStatRequest(bucket: 'test-bucket');
      final result = await client.getBucketStat(request);

      expect(result, isNotNull);
      expect(result.bucketStat, isNotNull);
      expect(result.bucketStat!.storage, equals(1600));
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketStat - missing bucket', () async {
      final request = GetBucketStatRequest();

      expect(
        () async => await client.getBucketStat(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketStat - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketStatRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketStat(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== listObjects =====
    test('testListObjects - success', () async {
      final xml = '''<ListBucketResult>
  <Name>examplebucket</Name>
  <Prefix></Prefix>
  <Marker></Marker>
  <MaxKeys>100</MaxKeys>
  <IsTruncated>false</IsTruncated>
  <Contents>
    <Key>fun/movie/001.avi</Key>
    <LastModified>2012-02-24T08:43:07.000Z</LastModified>
    <ETag>"5B3C1A2E053D763E1B002CC607C5A0FE1"</ETag>
    <Size>344606</Size>
    <StorageClass>Standard</StorageClass>
    <Type>Normal</Type>
  </Contents>
</ListBucketResult>''';
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

      final request = ListObjectsRequest(bucket: 'test-bucket');
      final result = await client.listObjects(request);

      expect(result, isNotNull);
      expect(result.name, equals('examplebucket'));
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testListObjects - missing bucket', () async {
      final request = ListObjectsRequest();

      expect(
        () async => await client.listObjects(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testListObjects - server error', () async {
      mock.addResponse(make403Response());

      final request = ListObjectsRequest(bucket: 'test-bucket');

      expect(
        () async => await client.listObjects(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== listObjectsV2 =====
    test('testListObjectsV2 - success', () async {
      final xml = '''<ListBucketResult>
  <Name>examplebucket</Name>
  <Prefix></Prefix>
  <MaxKeys>100</MaxKeys>
  <KeyCount>1</KeyCount>
  <IsTruncated>false</IsTruncated>
  <Contents>
    <Key>test.jpg</Key>
    <LastModified>2023-01-15T08:43:07.000Z</LastModified>
    <ETag>"A797938C31D59EDD08D86188F6D5B"</ETag>
    <Size>123456</Size>
    <StorageClass>Standard</StorageClass>
    <Type>Normal</Type>
  </Contents>
</ListBucketResult>''';
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

      final request = ListObjectsV2Request(bucket: 'test-bucket');
      final result = await client.listObjectsV2(request);

      expect(result, isNotNull);
      expect(result.name, equals('examplebucket'));
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testListObjectsV2 - missing bucket', () async {
      final request = ListObjectsV2Request();

      expect(
        () async => await client.listObjectsV2(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testListObjectsV2 - server error', () async {
      mock.addResponse(make403Response());

      final request = ListObjectsV2Request(bucket: 'test-bucket');

      expect(
        () async => await client.listObjectsV2(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== isBucketExist =====
    test('testIsBucketExist - exists', () async {
      final xml = '''<AccessControlPolicy>
  <Owner>
    <ID>0022012****</ID>
    <DisplayName>user_example</DisplayName>
  </Owner>
  <AccessControlList>
    <Grant>private</Grant>
  </AccessControlList>
</AccessControlPolicy>''';
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

      final result = await client.isBucketExist('test-bucket');

      expect(result, isTrue);
      expect(mock.requests.length, 1);
    });

    test('testIsBucketExist - not exists', () async {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<Error>
    <Code>NoSuchBucket</Code>
    <Message>The specified bucket does not exist.</Message>
    <RequestId>id-1234</RequestId>
    <HostId>oss-cn-hangzhou.aliyuncs.com</HostId>
    <BucketName>test-bucket</BucketName>
    <EC>0015-00000101</EC>
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

      final result = await client.isBucketExist('test-bucket');

      expect(result, isFalse);
    });

    test('testIsBucketExist - server error', () async {
      mock.addResponse(make403Response());

      expect(
        () async => await client.isBucketExist('test-bucket'),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
