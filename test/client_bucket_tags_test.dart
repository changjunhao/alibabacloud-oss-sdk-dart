import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketTags Tests', () {
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

    // ===== putBucketTags =====
    test('testPutBucketTags - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketTagsRequest(
        bucket: 'test-bucket',
        tagging: Tagging(
          tagSet: TagSet(
            tags: [
              Tag(key: 'env', value: 'production'),
              Tag(key: 'project', value: 'oss-sdk'),
            ],
          ),
        ),
      );
      final result = await client.putBucketTags(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(mock.requests[0].requestUri.toString(), contains('tagging'));
    });

    test('testPutBucketTags - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketTagsRequest(
        tagging: Tagging(
          tagSet: TagSet(
            tags: [Tag(key: 'env', value: 'production')],
          ),
        ),
      );

      expect(
        () async => await client.putBucketTags(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketTags - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketTagsRequest(
        bucket: 'test-bucket',
        tagging: Tagging(
          tagSet: TagSet(
            tags: [Tag(key: 'env', value: 'production')],
          ),
        ),
      );

      expect(
        () async => await client.putBucketTags(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketTags =====
    test('testGetBucketTags - success', () async {
      final xml = '''<Tagging>
    <TagSet>
        <Tag>
            <Key>env</Key>
            <Value>production</Value>
        </Tag>
        <Tag>
            <Key>project</Key>
            <Value>oss-sdk</Value>
        </Tag>
    </TagSet>
</Tagging>''';
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

      final request = GetBucketTagsRequest(bucket: 'test-bucket');
      final result = await client.getBucketTags(request);

      expect(result, isNotNull);
      expect(result.tagging, isNotNull);
      expect(result.tagging!.tagSet, isNotNull);
      expect(result.tagging!.tagSet!.tags, isNotNull);
      expect(result.tagging!.tagSet!.tags!.length, 2);
      expect(result.tagging!.tagSet!.tags![0].key, 'env');
      expect(result.tagging!.tagSet!.tags![0].value, 'production');
      expect(result.tagging!.tagSet!.tags![1].key, 'project');
      expect(result.tagging!.tagSet!.tags![1].value, 'oss-sdk');
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketTags - missing bucket', () async {
      final request = GetBucketTagsRequest();

      expect(
        () async => await client.getBucketTags(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketTags - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketTagsRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketTags(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== deleteBucketTags =====
    test('testDeleteBucketTags - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = DeleteBucketTagsRequest(bucket: 'test-bucket');
      final result = await client.deleteBucketTags(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testDeleteBucketTags - missing bucket', () async {
      final request = DeleteBucketTagsRequest();

      expect(
        () async => await client.deleteBucketTags(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteBucketTags - server error', () async {
      mock.addResponse(make403Response());

      final request = DeleteBucketTagsRequest(bucket: 'test-bucket');

      expect(
        () async => await client.deleteBucketTags(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
