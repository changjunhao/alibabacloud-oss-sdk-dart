import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientBucketReferer Tests', () {
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

    // ===== putBucketReferer =====
    test('testPutBucketReferer - success', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketRefererRequest(
        bucket: 'test-bucket',
        refererConfiguration: RefererConfiguration(
          allowEmptyReferer: false,
          allowTruncateQueryString: true,
          truncatePath: false,
          refererList: RefererList(
            referers: ['http://www.aliyun.com', 'https://www.aliyun.com'],
          ),
        ),
      );
      final result = await client.putBucketReferer(request);

      expect(result, isNotNull);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'PUT');
      expect(mock.requests[0].requestUri.toString(), contains('referer'));
    });

    test('testPutBucketReferer - missing bucket', () async {
      mock.addResponse(
        ResponseMessage(
          statusCode: 200,
          headers: {'x-oss-request-id': 'req-123'},
          content: ByteStream.fromData(Uint8List(0)),
        ),
      );

      final request = PutBucketRefererRequest(
        refererConfiguration: RefererConfiguration(allowEmptyReferer: true),
      );

      expect(
        () async => await client.putBucketReferer(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testPutBucketReferer - server error', () async {
      mock.addResponse(make403Response());

      final request = PutBucketRefererRequest(
        bucket: 'test-bucket',
        refererConfiguration: RefererConfiguration(allowEmptyReferer: true),
      );

      expect(
        () async => await client.putBucketReferer(request),
        throwsA(isA<ServerError>()),
      );
    });

    // ===== getBucketReferer =====
    test('testGetBucketReferer - success', () async {
      final xml = '''<RefererConfiguration>
    <AllowEmptyReferer>false</AllowEmptyReferer>
    <AllowTruncateQueryString>true</AllowTruncateQueryString>
    <TruncatePath>true</TruncatePath>
    <RefererList>
        <Referer>http://www.aliyun.com</Referer>
        <Referer>https://www.aliyun.com</Referer>
    </RefererList>
    <RefererBlacklist>
        <Referer>http://www.refuse.com</Referer>
        <Referer>https://*.hack.com</Referer>
    </RefererBlacklist>
</RefererConfiguration>''';
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

      final request = GetBucketRefererRequest(bucket: 'test-bucket');
      final result = await client.getBucketReferer(request);

      expect(result, isNotNull);
      expect(result.refererConfiguration, isNotNull);
      expect(result.refererConfiguration!.allowEmptyReferer, false);
      expect(result.refererConfiguration!.allowTruncateQueryString, true);
      expect(result.refererConfiguration!.truncatePath, true);
      expect(result.refererConfiguration!.refererList?.referers, [
        'http://www.aliyun.com',
        'https://www.aliyun.com',
      ]);
      expect(result.refererConfiguration!.refererBlacklist?.referers, [
        'http://www.refuse.com',
        'https://*.hack.com',
      ]);
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testGetBucketReferer - missing bucket', () async {
      final request = GetBucketRefererRequest();

      expect(
        () async => await client.getBucketReferer(request),
        throwsA(isA<ClientError>()),
      );
    });

    test('testGetBucketReferer - server error', () async {
      mock.addResponse(make403Response());

      final request = GetBucketRefererRequest(bucket: 'test-bucket');

      expect(
        () async => await client.getBucketReferer(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
