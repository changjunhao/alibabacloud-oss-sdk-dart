import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketPolicy Tests', () {
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

    // ===== putBucketPolicy =====
    test('testPutBucketPolicy - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      const policyJson =
          '{"Version":"1","Statement":[{"Effect":"Allow","Action":["oss:GetObject"],"Principal":["*"],"Resource":["acs:oss:*:*:mybucket/*"]}]}';

      final request = PutBucketPolicyRequest(
        bucket: 'test-bucket',
        body: policyJson,
      );
      final result = await client.putBucketPolicy(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(mock.requests[0].requestUri.toString(), contains('policy'));
    });

    test('testPutBucketPolicy - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketPolicyRequest(body: '{}');

      expect(
        () async => await client.putBucketPolicy(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketPolicy - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketPolicyRequest(bucket: 'test-bucket', body: '{}');

      expect(
        () async => await client.putBucketPolicy(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketPolicy =====
    test('testGetBucketPolicy - success', () async {
      const policyJson =
          '{"Version":"1","Statement":[{"Effect":"Allow","Action":["oss:GetObject"],"Principal":["*"],"Resource":["acs:oss:*:*:mybucket/*"]}]}';
      final data = Uint8List.fromList(utf8.encode(policyJson));
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {
            'x-oss-request-id': 'req-123',
            'content-type': 'application/json',
          },
          content: ByteStream.fromData(data),
        ),
      );

      final request = GetBucketPolicyRequest(bucket: 'test-bucket');
      final result = await client.getBucketPolicy(request);

      expect(result, isNotNull);
      expect(result.body, equals(policyJson));
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketPolicy - missing bucket', () async {
      final request = GetBucketPolicyRequest();

      expect(
        () async => await client.getBucketPolicy(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketPolicy - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketPolicyRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketPolicy(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== deleteBucketPolicy =====
    test('testDeleteBucketPolicy - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = DeleteBucketPolicyRequest(bucket: 'test-bucket');
      final result = await client.deleteBucketPolicy(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testDeleteBucketPolicy - missing bucket', () async {
      final request = DeleteBucketPolicyRequest();

      expect(
        () async => await client.deleteBucketPolicy(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteBucketPolicy - server error', () async {
      mock.addResponse(make403Response());

      final request = DeleteBucketPolicyRequest(bucket: 'test-bucket');

      expect(
        () async => await client.deleteBucketPolicy(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketPolicyStatus =====
    test('testGetBucketPolicyStatus - success', () async {
      final xml = '''<PolicyStatus>
    <IsPublic>true</IsPublic>
</PolicyStatus>''';
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

      final request = GetBucketPolicyStatusRequest(bucket: 'test-bucket');
      final result = await client.getBucketPolicyStatus(request);

      expect(result, isNotNull);
      expect(result.policyStatus?.isPublic, true);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
      expect(mock.requests[0].requestUri.toString(), contains('policyStatus'));
    });

    test('testGetBucketPolicyStatus - missing bucket', () async {
      final request = GetBucketPolicyStatusRequest();

      expect(
        () async => await client.getBucketPolicyStatus(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketPolicyStatus - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketPolicyStatusRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketPolicyStatus(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
