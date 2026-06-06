import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_cors.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_cors.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketCors Tests', () {
    test('testSerializePutBucketCors - empty configuration', () async {
      var input = OperationInput(operationName: 'PutBucketCors', method: 'PUT');

      // Test with empty CORSConfiguration (no rules)
      var request = PutBucketCorsRequest(
        corsConfiguration: CORSConfiguration(),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketCors.serializePutBucketCors],
      );

      final bodyData = await input.body?.readData();
      final bodyStr = utf8.decode(bodyData!);
      expect(
        bodyStr,
        equals(
          '<?xml version="1.0" encoding="UTF-8"?><CORSConfiguration></CORSConfiguration>',
        ),
      );
    });

    test('testSerializePutBucketCors - with rules', () async {
      var input = OperationInput(operationName: 'PutBucketCors', method: 'PUT');

      final corsRules = [
        CORSRule(
          allowedOrigins: ['a1', 'b1'],
          allowedMethods: ['c1'],
          allowedHeaders: ['d1'],
          exposeHeaders: ['e1'],
          maxAgeSeconds: 1000,
        ),
        CORSRule(
          allowedOrigins: ['a2', 'b2'],
          allowedMethods: ['c2'],
          allowedHeaders: ['d2'],
          exposeHeaders: ['e2'],
          maxAgeSeconds: 2000,
        ),
      ];

      var request = PutBucketCorsRequest(
        corsConfiguration: CORSConfiguration(corsRules: corsRules),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketCors.serializePutBucketCors],
      );

      final bodyData = await input.body?.readData();
      final bodyStr = utf8.decode(bodyData!);

      final expectedXml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<CORSConfiguration>'
          '<CORSRule>'
          '<AllowedOrigin>a1</AllowedOrigin>'
          '<AllowedOrigin>b1</AllowedOrigin>'
          '<AllowedMethod>c1</AllowedMethod>'
          '<AllowedHeader>d1</AllowedHeader>'
          '<ExposeHeader>e1</ExposeHeader>'
          '<MaxAgeSeconds>1000</MaxAgeSeconds>'
          '</CORSRule>'
          '<CORSRule>'
          '<AllowedOrigin>a2</AllowedOrigin>'
          '<AllowedOrigin>b2</AllowedOrigin>'
          '<AllowedMethod>c2</AllowedMethod>'
          '<AllowedHeader>d2</AllowedHeader>'
          '<ExposeHeader>e2</ExposeHeader>'
          '<MaxAgeSeconds>2000</MaxAgeSeconds>'
          '</CORSRule>'
          '</CORSConfiguration>';

      expect(bodyStr, equals(expectedXml));
    });

    test('testSerializePutBucketCors - with responseVary', () async {
      var input = OperationInput(operationName: 'PutBucketCors', method: 'PUT');

      final corsRules = [
        CORSRule(
          allowedOrigins: ['a1', 'b1'],
          allowedMethods: ['c1'],
          allowedHeaders: ['d1'],
          exposeHeaders: ['e1'],
          maxAgeSeconds: 1000,
        ),
        CORSRule(
          allowedOrigins: ['a2', 'b2'],
          allowedMethods: ['c2'],
          allowedHeaders: ['d2'],
          exposeHeaders: ['e2'],
          maxAgeSeconds: 2000,
        ),
      ];

      var request = PutBucketCorsRequest(
        corsConfiguration: CORSConfiguration(
          corsRules: corsRules,
          responseVary: true,
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketCors.serializePutBucketCors],
      );

      final bodyData = await input.body?.readData();
      final bodyStr = utf8.decode(bodyData!);

      final expectedXml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<CORSConfiguration>'
          '<CORSRule>'
          '<AllowedOrigin>a1</AllowedOrigin>'
          '<AllowedOrigin>b1</AllowedOrigin>'
          '<AllowedMethod>c1</AllowedMethod>'
          '<AllowedHeader>d1</AllowedHeader>'
          '<ExposeHeader>e1</ExposeHeader>'
          '<MaxAgeSeconds>1000</MaxAgeSeconds>'
          '</CORSRule>'
          '<CORSRule>'
          '<AllowedOrigin>a2</AllowedOrigin>'
          '<AllowedOrigin>b2</AllowedOrigin>'
          '<AllowedMethod>c2</AllowedMethod>'
          '<AllowedHeader>d2</AllowedHeader>'
          '<ExposeHeader>e2</ExposeHeader>'
          '<MaxAgeSeconds>2000</MaxAgeSeconds>'
          '</CORSRule>'
          '<ResponseVary>true</ResponseVary>'
          '</CORSConfiguration>';

      expect(bodyStr, equals(expectedXml));
    });

    test('testDeserializeGetBucketCors - null body throws', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketCorsResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketCors.deserializeGetBucketCors],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketCors - unexpected body throws', () async {
      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
      );
      var result = GetBucketCorsResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketCors.deserializeGetBucketCors],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketCors - normal response', () async {
      final xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<CORSConfiguration>'
          '<CORSRule>'
          '<AllowedOrigin>*</AllowedOrigin>'
          '<AllowedOrigin>http://www.example.com</AllowedOrigin>'
          '<AllowedMethod>GET</AllowedMethod>'
          '<AllowedMethod>PUT</AllowedMethod>'
          '<AllowedHeader>*</AllowedHeader>'
          '<AllowedHeader>x-oss-header</AllowedHeader>'
          '<ExposeHeader>x-oss-test</ExposeHeader>'
          '<ExposeHeader>x-oss-test2</ExposeHeader>'
          '<MaxAgeSeconds>100</MaxAgeSeconds>'
          '</CORSRule>'
          '<CORSRule>'
          '<AllowedOrigin>http://example.com</AllowedOrigin>'
          '<AllowedOrigin>http://example.org</AllowedOrigin>'
          '<AllowedMethod>POST</AllowedMethod>'
          '<AllowedMethod>DELETE</AllowedMethod>'
          '<AllowedHeader>x-oss-a</AllowedHeader>'
          '<AllowedHeader>x-oss-b</AllowedHeader>'
          '<ExposeHeader>x-oss-expose</ExposeHeader>'
          '<ExposeHeader>x-oss-expose2</ExposeHeader>'
          '<MaxAgeSeconds>200</MaxAgeSeconds>'
          '</CORSRule>'
          '<ResponseVary>false</ResponseVary>'
          '</CORSConfiguration>';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      var result = GetBucketCorsResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketCors.deserializeGetBucketCors],
      );

      expect(result.corsConfiguration, isNotNull);
      expect(result.corsConfiguration!.corsRules, isNotNull);
      expect(result.corsConfiguration!.corsRules!.length, equals(2));

      final rule = result.corsConfiguration!.corsRules!.first;
      expect(rule.allowedOrigins, contains('*'));
      expect(rule.allowedOrigins, contains('http://www.example.com'));
      expect(rule.allowedMethods, contains('GET'));
      expect(rule.allowedMethods, contains('PUT'));
      expect(rule.allowedHeaders, contains('*'));
      expect(rule.allowedHeaders, contains('x-oss-header'));
      expect(rule.exposeHeaders, contains('x-oss-test'));
      expect(rule.exposeHeaders, contains('x-oss-test2'));
      expect(rule.maxAgeSeconds, equals(100));

      final rule2 = result.corsConfiguration!.corsRules!.last;
      expect(rule2.allowedOrigins, contains('http://example.com'));
      expect(rule2.allowedOrigins, contains('http://example.org'));
      expect(rule2.allowedMethods, contains('POST'));
      expect(rule2.allowedMethods, contains('DELETE'));
      expect(rule2.allowedHeaders, contains('x-oss-a'));
      expect(rule2.allowedHeaders, contains('x-oss-b'));
      expect(rule2.exposeHeaders, contains('x-oss-expose'));
      expect(rule2.exposeHeaders, contains('x-oss-expose2'));
      expect(rule2.maxAgeSeconds, equals(200));

      expect(result.corsConfiguration!.responseVary, equals(false));
    });

    test('testSerializeOptionObject - empty request', () async {
      var input = OperationInput(
        operationName: 'OptionObject',
        method: 'OPTIONS',
      );

      var request = OptionObjectRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketCors.serializeOptionObject],
      );

      expect(input.headers['Origin'], isNull);
      expect(input.headers['Access-Control-Request-Method'], isNull);
      expect(input.headers['Access-Control-Request-Headers'], isNull);
    });

    test('testSerializeOptionObject - with values', () async {
      var input = OperationInput(
        operationName: 'OptionObject',
        method: 'OPTIONS',
      );

      var request = OptionObjectRequest(
        origin: 'origin',
        accessControlRequestMethod: 'GET',
        accessControlRequestHeaders: '*',
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketCors.serializeOptionObject],
      );

      expect(input.headers['Origin'], equals('origin'));
      expect(input.headers['Access-Control-Request-Method'], equals('GET'));
      expect(input.headers['Access-Control-Request-Headers'], equals('*'));
    });
  });
}
