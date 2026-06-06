import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart'
    hide ServerSideEncryptionRule;
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketEncryption Tests', () {
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

    // ===== putBucketEncryption =====
    test('testPutBucketEncryption - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketEncryptionRequest(
        bucket: 'test-bucket',
        serverSideEncryptionRule: ServerSideEncryptionRule(
          applyServerSideEncryptionByDefault:
              ApplyServerSideEncryptionByDefault(sseAlgorithm: 'AES256'),
        ),
      );
      final result = await client.putBucketEncryption(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(mock.requests[0].requestUri.toString(), contains('encryption'));
    });

    test('testPutBucketEncryption - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketEncryptionRequest(
        serverSideEncryptionRule: ServerSideEncryptionRule(
          applyServerSideEncryptionByDefault:
              ApplyServerSideEncryptionByDefault(sseAlgorithm: 'AES256'),
        ),
      );

      expect(
        () async => await client.putBucketEncryption(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketEncryption - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketEncryptionRequest(
        bucket: 'test-bucket',
        serverSideEncryptionRule: ServerSideEncryptionRule(
          applyServerSideEncryptionByDefault:
              ApplyServerSideEncryptionByDefault(sseAlgorithm: 'AES256'),
        ),
      );

      expect(
        () async => await client.putBucketEncryption(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketEncryption =====
    test('testGetBucketEncryption - success', () async {
      final xml = '''<ServerSideEncryptionRule>
    <ApplyServerSideEncryptionByDefault>
        <SSEAlgorithm>KMS</SSEAlgorithm>
        <KMSMasterKeyID>kms-key-001</KMSMasterKeyID>
        <KMSDataEncryption>SM4</KMSDataEncryption>
    </ApplyServerSideEncryptionByDefault>
</ServerSideEncryptionRule>''';
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

      final request = GetBucketEncryptionRequest(bucket: 'test-bucket');
      final result = await client.getBucketEncryption(request);

      expect(result, isNotNull);
      expect(result.serverSideEncryptionRule, isNotNull);
      expect(
        result
            .serverSideEncryptionRule!
            .applyServerSideEncryptionByDefault
            ?.sseAlgorithm,
        'KMS',
      );
      expect(
        result
            .serverSideEncryptionRule!
            .applyServerSideEncryptionByDefault
            ?.kmsMasterKeyId,
        'kms-key-001',
      );
      expect(
        result
            .serverSideEncryptionRule!
            .applyServerSideEncryptionByDefault
            ?.kmsDataEncryption,
        'SM4',
      );
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketEncryption - missing bucket', () async {
      final request = GetBucketEncryptionRequest();

      expect(
        () async => await client.getBucketEncryption(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketEncryption - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketEncryptionRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketEncryption(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== deleteBucketEncryption =====
    test('testDeleteBucketEncryption - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = DeleteBucketEncryptionRequest(bucket: 'test-bucket');
      final result = await client.deleteBucketEncryption(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testDeleteBucketEncryption - missing bucket', () async {
      final request = DeleteBucketEncryptionRequest();

      expect(
        () async => await client.deleteBucketEncryption(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteBucketEncryption - server error', () async {
      mock.addResponse(make403Response());

      final request = DeleteBucketEncryptionRequest(bucket: 'test-bucket');

      expect(
        () async => await client.deleteBucketEncryption(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
