import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_region.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_region.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeRegion Tests', () {
    test('testSerializeDescribeRegions - with regions parameter', () async {
      var input = OperationInput(
        operationName: 'DescribeRegions',
        method: 'GET',
      );

      var request = DescribeRegionsRequest(regions: 'oss-cn-hangzhou');

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeRegion.serializeDescribeRegions],
      );

      expect(input.parameters['regions'], equals('oss-cn-hangzhou'));
    });

    test('testSerializeDescribeRegions - without regions parameter', () async {
      var input = OperationInput(
        operationName: 'DescribeRegions',
        method: 'GET',
      );

      var request = DescribeRegionsRequest();

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeRegion.serializeDescribeRegions],
      );

      expect(input.parameters.containsKey('regions'), isFalse);
    });

    test('testDeserializeDescribeRegions - null body throws', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = DescribeRegionsResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeRegion.deserializeDescribeRegions],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeDescribeRegions - unexpected body throws', () async {
      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
      );
      var result = DescribeRegionsResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeRegion.deserializeDescribeRegions],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeDescribeRegions - single region', () async {
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

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      var result = DescribeRegionsResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeRegion.deserializeDescribeRegions],
      );

      expect(result.regionInfoList, isNotNull);
      expect(result.regionInfoList!.regionInfos, isNotNull);
      expect(result.regionInfoList!.regionInfos!.length, equals(1));

      final region = result.regionInfoList!.regionInfos![0];
      expect(region.region, equals('oss-cn-hangzhou'));
      expect(region.internetEndpoint, equals('oss-cn-hangzhou.aliyuncs.com'));
      expect(
        region.internalEndpoint,
        equals('oss-cn-hangzhou-internal.aliyuncs.com'),
      );
      expect(region.accelerateEndpoint, equals('oss-accelerate.aliyuncs.com'));
    });

    test('testDeserializeDescribeRegions - multiple regions', () async {
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

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      var result = DescribeRegionsResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeRegion.deserializeDescribeRegions],
      );

      expect(result.regionInfoList, isNotNull);
      expect(result.regionInfoList!.regionInfos, isNotNull);
      expect(result.regionInfoList!.regionInfos!.length, equals(2));

      final region1 = result.regionInfoList!.regionInfos![0];
      expect(region1.region, equals('oss-cn-hangzhou'));
      expect(region1.internetEndpoint, equals('oss-cn-hangzhou.aliyuncs.com'));
      expect(
        region1.internalEndpoint,
        equals('oss-cn-hangzhou-internal.aliyuncs.com'),
      );
      expect(region1.accelerateEndpoint, equals('oss-accelerate.aliyuncs.com'));

      final region2 = result.regionInfoList!.regionInfos![1];
      expect(region2.region, equals('oss-cn-shanghai'));
      expect(region2.internetEndpoint, equals('oss-cn-shanghai.aliyuncs.com'));
      expect(
        region2.internalEndpoint,
        equals('oss-cn-shanghai-internal.aliyuncs.com'),
      );
      expect(region2.accelerateEndpoint, equals('oss-accelerate.aliyuncs.com'));
    });
  });
}
