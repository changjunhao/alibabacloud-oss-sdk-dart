import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketRequestPayment Tests', () {
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

    // ===== putBucketRequestPayment =====
    test('testPutBucketRequestPayment - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketRequestPaymentRequest(
        bucket: 'test-bucket',
        requestPaymentConfiguration: RequestPaymentConfiguration(
          payer: 'Requester',
        ),
      );
      final result = await client.putBucketRequestPayment(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(
        mock.requests[0].requestUri.toString(),
        contains('requestPayment'),
      );
    });

    test('testPutBucketRequestPayment - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketRequestPaymentRequest(
        requestPaymentConfiguration: RequestPaymentConfiguration(
          payer: 'Requester',
        ),
      );

      expect(
        () async => await client.putBucketRequestPayment(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketRequestPayment - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketRequestPaymentRequest(
        bucket: 'test-bucket',
        requestPaymentConfiguration: RequestPaymentConfiguration(
          payer: 'Requester',
        ),
      );

      expect(
        () async => await client.putBucketRequestPayment(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketRequestPayment =====
    test('testGetBucketRequestPayment - success', () async {
      final xml =
          '<RequestPaymentConfiguration>'
          '<Payer>Requester</Payer>'
          '</RequestPaymentConfiguration>';
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

      final request = GetBucketRequestPaymentRequest(bucket: 'test-bucket');
      final result = await client.getBucketRequestPayment(request);

      expect(result, isNotNull);
      expect(result.requestPaymentConfiguration, isNotNull);
      expect(result.requestPaymentConfiguration!.payer, 'Requester');
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketRequestPayment - missing bucket', () async {
      final request = GetBucketRequestPaymentRequest();

      expect(
        () async => await client.getBucketRequestPayment(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketRequestPayment - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketRequestPaymentRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketRequestPayment(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
