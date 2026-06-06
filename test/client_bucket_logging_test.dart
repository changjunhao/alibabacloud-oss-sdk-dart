import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketLogging Tests', () {
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

    // ===== putBucketLogging =====
    test('testPutBucketLogging - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketLoggingRequest(
        bucket: 'test-bucket',
        bucketLoggingStatus: BucketLoggingStatus(
          loggingEnabled: LoggingEnabled(
            targetBucket: 'log-bucket',
            targetPrefix: 'log-prefix/',
          ),
        ),
      );
      final result = await client.putBucketLogging(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(mock.requests[0].requestUri.toString(), contains('logging'));
    });

    test('testPutBucketLogging - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketLoggingRequest(
        bucketLoggingStatus: BucketLoggingStatus(),
      );

      expect(
        () async => await client.putBucketLogging(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketLogging - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketLoggingRequest(
        bucket: 'test-bucket',
        bucketLoggingStatus: BucketLoggingStatus(),
      );

      expect(
        () async => await client.putBucketLogging(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketLogging =====
    test('testGetBucketLogging - success', () async {
      final xml = '''<BucketLoggingStatus>
    <LoggingEnabled>
        <TargetBucket>targetBucket</TargetBucket>
        <TargetPrefix>targetPrefix</TargetPrefix>
    </LoggingEnabled>
</BucketLoggingStatus>''';
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

      final request = GetBucketLoggingRequest(bucket: 'test-bucket');
      final result = await client.getBucketLogging(request);

      expect(result, isNotNull);
      expect(
        result.bucketLoggingStatus?.loggingEnabled?.targetBucket,
        'targetBucket',
      );
      expect(
        result.bucketLoggingStatus?.loggingEnabled?.targetPrefix,
        'targetPrefix',
      );
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketLogging - missing bucket', () async {
      final request = GetBucketLoggingRequest();

      expect(
        () async => await client.getBucketLogging(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketLogging - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketLoggingRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketLogging(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== deleteBucketLogging =====
    test('testDeleteBucketLogging - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = DeleteBucketLoggingRequest(bucket: 'test-bucket');
      final result = await client.deleteBucketLogging(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testDeleteBucketLogging - missing bucket', () async {
      final request = DeleteBucketLoggingRequest();

      expect(
        () async => await client.deleteBucketLogging(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteBucketLogging - server error', () async {
      mock.addResponse(make403Response());

      final request = DeleteBucketLoggingRequest(bucket: 'test-bucket');

      expect(
        () async => await client.deleteBucketLogging(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== putUserDefinedLogFieldsConfig =====
    test('testPutUserDefinedLogFieldsConfig - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutUserDefinedLogFieldsConfigRequest(
        bucket: 'test-bucket',
        userDefinedLogFieldsConfiguration: UserDefinedLogFieldsConfiguration(
          headerSet: HeaderSet(headers: ['header1', 'header2']),
          paramSet: ParamSet(parameters: ['param1']),
        ),
      );
      final result = await client.putUserDefinedLogFieldsConfig(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(
        mock.requests[0].requestUri.toString(),
        contains('userDefinedLogFieldsConfig'),
      );
    });

    test('testPutUserDefinedLogFieldsConfig - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutUserDefinedLogFieldsConfigRequest(
        userDefinedLogFieldsConfiguration: UserDefinedLogFieldsConfiguration(),
      );

      expect(
        () async => await client.putUserDefinedLogFieldsConfig(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutUserDefinedLogFieldsConfig - server error', () async {
      mock.addResponse(make403Response());

      final request = PutUserDefinedLogFieldsConfigRequest(
        bucket: 'test-bucket',
        userDefinedLogFieldsConfiguration: UserDefinedLogFieldsConfiguration(),
      );

      expect(
        () async => await client.putUserDefinedLogFieldsConfig(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getUserDefinedLogFieldsConfig =====
    test('testGetUserDefinedLogFieldsConfig - success', () async {
      final xml = '''<UserDefinedLogFieldsConfiguration>
    <HeaderSet>
        <header>header1</header>
        <header>header2</header>
    </HeaderSet>
    <ParamSet>
        <parameter>param1</parameter>
        <parameter>param2</parameter>
    </ParamSet>
</UserDefinedLogFieldsConfiguration>''';
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

      final request = GetUserDefinedLogFieldsConfigRequest(
        bucket: 'test-bucket',
      );
      final result = await client.getUserDefinedLogFieldsConfig(request);

      expect(result, isNotNull);
      expect(
        result.userDefinedLogFieldsConfiguration?.headerSet?.headers,
        equals(['header1', 'header2']),
      );
      expect(
        result.userDefinedLogFieldsConfiguration?.paramSet?.parameters,
        equals(['param1', 'param2']),
      );
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetUserDefinedLogFieldsConfig - missing bucket', () async {
      final request = GetUserDefinedLogFieldsConfigRequest();

      expect(
        () async => await client.getUserDefinedLogFieldsConfig(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetUserDefinedLogFieldsConfig - server error', () async {
      mock.addResponse(make403Response());

      final request = GetUserDefinedLogFieldsConfigRequest(
        bucket: 'test-bucket',
      );

      expect(
        () async => await client.getUserDefinedLogFieldsConfig(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== deleteUserDefinedLogFieldsConfig =====
    test('testDeleteUserDefinedLogFieldsConfig - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 204,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = DeleteUserDefinedLogFieldsConfigRequest(
        bucket: 'test-bucket',
      );
      final result = await client.deleteUserDefinedLogFieldsConfig(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'DELETE');
    });

    test('testDeleteUserDefinedLogFieldsConfig - missing bucket', () async {
      final request = DeleteUserDefinedLogFieldsConfigRequest();

      expect(
        () async => await client.deleteUserDefinedLogFieldsConfig(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeleteUserDefinedLogFieldsConfig - server error', () async {
      mock.addResponse(make403Response());

      final request = DeleteUserDefinedLogFieldsConfigRequest(
        bucket: 'test-bucket',
      );

      expect(
        () async => await client.deleteUserDefinedLogFieldsConfig(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
