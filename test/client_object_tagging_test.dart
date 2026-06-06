import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientObjectTagging Tests', () {
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

    // ===== putObjectTagging =====
    test('testPutObjectTagging - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutObjectTaggingRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        tagging: Tagging(
          tagSet: TagSet(
            tags: [
              Tag(key: 'env', value: 'prod'),
              Tag(key: 'team', value: 'dev'),
            ],
          ),
        ),
      );
      final result = await client.putObjectTagging(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
    });

    test('testPutObjectTagging - missing bucket', () async {
      final request = PutObjectTaggingRequest(key: 'test-key');

      expect(
        () async => await client.putObjectTagging(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutObjectTagging - missing key', () async {
      final request = PutObjectTaggingRequest(bucket: 'test-bucket');

      expect(
        () async => await client.putObjectTagging(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutObjectTagging - server error', () async {
      mock.addResponse(make403Response());

      final request = PutObjectTaggingRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        tagging: Tagging(
          tagSet: TagSet(
            tags: [Tag(key: 'env', value: 'prod')],
          ),
        ),
      );

      expect(
        () async => await client.putObjectTagging(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getObjectTagging =====
    test('testGetObjectTagging - success', () async {
      final xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<Tagging>'
          '<TagSet>'
          '<Tag>'
          '<Key>env</Key>'
          '<Value>prod</Value>'
          '</Tag>'
          '<Tag>'
          '<Key>team</Key>'
          '<Value>dev</Value>'
          '</Tag>'
          '</TagSet>'
          '</Tagging>';
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

      final request = GetObjectTaggingRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );
      final result = await client.getObjectTagging(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetObjectTagging - missing bucket', () async {
      final request = GetObjectTaggingRequest(key: 'test-key');

      expect(
        () async => await client.getObjectTagging(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetObjectTagging - missing key', () async {
      final request = GetObjectTaggingRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getObjectTagging(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetObjectTagging - server error', () async {
      mock.addResponse(make403Response());

      final request = GetObjectTaggingRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );

      expect(
        () async => await client.getObjectTagging(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== deleteObjectTagging =====
    test('testDeleteObjectTagging - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = DeleteObjectTaggingRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );
      final result = await client.deleteObjectTagging(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testDeleteObjectTagging - missing bucket', () async {
      final request = DeleteObjectTaggingRequest(key: 'test-key');

      expect(
        () async => await client.deleteObjectTagging(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteObjectTagging - missing key', () async {
      final request = DeleteObjectTaggingRequest(bucket: 'test-bucket');

      expect(
        () async => await client.deleteObjectTagging(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteObjectTagging - server error', () async {
      mock.addResponse(make403Response());

      final request = DeleteObjectTaggingRequest(
        bucket: 'test-bucket',
        key: 'test-key',
      );

      expect(
        () async => await client.deleteObjectTagging(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
