import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'client_mock_test.dart';

void main() {
  group('ClientRegion Tests', () {
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

    // ===== describeRegions =====
    test('testDescribeRegions - success single region', () async {
      final xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<RegionInfoList>'
          '<RegionInfo>'
          '<Region>oss-cn-hangzhou</Region>'
          '<InternetEndpoint>oss-cn-hangzhou.aliyuncs.com</InternetEndpoint>'
          '<InternalEndpoint>oss-cn-hangzhou-internal.aliyuncs.com</InternalEndpoint>'
          '<AccelerateEndpoint>oss-accelerate.aliyuncs.com</AccelerateEndpoint>'
          '</RegionInfo>'
          '</RegionInfoList>';
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

      final request = DescribeRegionsRequest();
      final result = await client.describeRegions(request);

      expect(result, isNotNull);
      expect(result.regionInfoList, isNotNull);
      expect(result.regionInfoList!.regionInfos, isNotNull);
      expect(result.regionInfoList!.regionInfos!.length, 1);

      final region = result.regionInfoList!.regionInfos![0];
      expect(region.region, equals('oss-cn-hangzhou'));
      expect(region.internetEndpoint, equals('oss-cn-hangzhou.aliyuncs.com'));
      expect(
        region.internalEndpoint,
        equals('oss-cn-hangzhou-internal.aliyuncs.com'),
      );
      expect(region.accelerateEndpoint, equals('oss-accelerate.aliyuncs.com'));
      expect(mock.requests.length, 1);
      expect(mock.requests[0].method, 'GET');
    });

    test('testDescribeRegions - success multiple regions', () async {
      final xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<RegionInfoList>'
          '<RegionInfo>'
          '<Region>oss-cn-hangzhou</Region>'
          '<InternetEndpoint>oss-cn-hangzhou.aliyuncs.com</InternetEndpoint>'
          '<InternalEndpoint>oss-cn-hangzhou-internal.aliyuncs.com</InternalEndpoint>'
          '<AccelerateEndpoint>oss-accelerate.aliyuncs.com</AccelerateEndpoint>'
          '</RegionInfo>'
          '<RegionInfo>'
          '<Region>oss-cn-shanghai</Region>'
          '<InternetEndpoint>oss-cn-shanghai.aliyuncs.com</InternetEndpoint>'
          '<InternalEndpoint>oss-cn-shanghai-internal.aliyuncs.com</InternalEndpoint>'
          '<AccelerateEndpoint>oss-accelerate.aliyuncs.com</AccelerateEndpoint>'
          '</RegionInfo>'
          '</RegionInfoList>';
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

      final request = DescribeRegionsRequest();
      final result = await client.describeRegions(request);

      expect(result, isNotNull);
      expect(result.regionInfoList, isNotNull);
      expect(result.regionInfoList!.regionInfos!.length, 2);
      expect(
        result.regionInfoList!.regionInfos![0].region,
        equals('oss-cn-hangzhou'),
      );
      expect(
        result.regionInfoList!.regionInfos![1].region,
        equals('oss-cn-shanghai'),
      );
      expect(mock.requests.length, 1);
    });

    test('testDescribeRegions - with regions filter', () async {
      final xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<RegionInfoList>'
          '<RegionInfo>'
          '<Region>oss-cn-hangzhou</Region>'
          '<InternetEndpoint>oss-cn-hangzhou.aliyuncs.com</InternetEndpoint>'
          '<InternalEndpoint>oss-cn-hangzhou-internal.aliyuncs.com</InternalEndpoint>'
          '<AccelerateEndpoint>oss-accelerate.aliyuncs.com</AccelerateEndpoint>'
          '</RegionInfo>'
          '</RegionInfoList>';
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

      final request = DescribeRegionsRequest(regions: 'oss-cn-hangzhou');
      final result = await client.describeRegions(request);

      expect(result, isNotNull);
      expect(result.regionInfoList, isNotNull);
      expect(result.regionInfoList!.regionInfos!.length, 1);
      expect(
        result.regionInfoList!.regionInfos![0].region,
        equals('oss-cn-hangzhou'),
      );
      expect(mock.requests.length, 1);
    });

    test('testDescribeRegions - server error', () async {
      mock.addResponse(make403Response());

      final request = DescribeRegionsRequest();

      expect(
        () async => await client.describeRegions(request),
        throwsA(isA<ServerError>()),
      );
    });
  });
}
