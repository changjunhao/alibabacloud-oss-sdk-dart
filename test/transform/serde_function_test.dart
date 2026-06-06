import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_extensions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';
import '../fixtures/put_api_types.dart';

void main() {
  group('Serde Function Tests', () {
    test('testSerializeInput', () async {
      // Create request
      final request = PutApiRequest(
        bucket: 'bucket',
        key: 'key',
        acl: 'private',
        metadata: {'key': 'value', 'key2': 'value2'},
      );

      // Add headers and parameters to request
      request.commonProp.headers = {'x-oss-test-request': 'request-test-123'};
      request.commonProp.parameters = {'param-request': 'request-param-123'};

      // Create operation input
      final input = OperationInput(
        operationName: 'PutApi',
        method: 'PUT',
        headers: {'x-oss-test-input': 'input-test-123'},
        parameters: {'param-input': 'input-param-123'},
      );
      input.bucket = 'bucket';
      input.key = 'key';

      // Define custom serializers
      final customSerializers = <SerdeSerializeDelegate<PutApiRequest>>[
        (request, input) async {
          if (request.acl != null) {
            input.headers['x-oss-acl'] = request.acl!;
          }
          request.metadata?.forEach((key, value) {
            input.headers['x-oss-meta-$key'] = value;
          });
        },
      ];

      // Serialize input using Serde.serializeInput
      await Serde.serializeInput(
        request,
        input,
        customSerializers: customSerializers,
      );

      // Assertions
      expect(input.operationName, equals('PutApi'));
      expect(input.bucket, equals('bucket'));
      expect(input.key, equals('key'));
      expect(input.headers['x-oss-test-input'], equals('input-test-123'));
      expect(input.headers['x-oss-acl'], equals('private'));
      expect(input.headers['x-oss-meta-key'], equals('value'));
      expect(input.headers['x-oss-meta-key2'], equals('value2'));
      expect(input.headers['x-oss-test-request'], equals('request-test-123'));
      expect(input.parameters['param-request'], equals('request-param-123'));
      expect(input.parameters['param-input'], equals('input-param-123'));
      expect(input.body, isNull);
    });

    test('testDeserializeOutput', () async {
      // Create XML response
      const xml = '''
<OutputXml>
    <StrValue>value1</StrValue>
    <StrValue1>12345</StrValue1>
</OutputXml>
''';

      // Create operation output
      final output = OperationOutput(
        statusCode: 200,
        headers: {
          'x-oss-header-str': 'str-123',
          'x-oss-header-int': '123',
          'x-oss-header-bool': 'true',
          'x-oss-request-id': 'id-123',
        },
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );

      final result = PutApiResult();

      // Define custom deserializers
      final customDeserializers = <SerdeDeserializeDelegate<PutApiResult>>[
        (result, output) async {
          if (output.body != null) {
            try {
              final body =
                  await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
                    output.body,
                    'OutputXml',
                  );
              result.xmlResult = PutApiXmlResult(
                strValue: body['StrValue'] as String?,
                strValue1: body['StrValue1'] as String?,
              );
            } catch (e) {
              // Handle parsing errors gracefully
            }
          }
        },
      ];

      // Deserialize output using Serde.deserializeOutput
      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: customDeserializers,
      );

      // Assertions
      expect(result.statusCode, equals(200));
      expect(result.headers, isNotNull);
      expect(result.headerStr, equals('str-123'));
      expect(result.headerInt, equals(123));
      expect(result.headerBool, equals(true));
      expect(result.requestId, equals('id-123'));
      expect(result.xmlResult, isNotNull);
      expect(result.xmlResult?.strValue, equals('value1'));
      expect(result.xmlResult?.strValue1, equals('12345'));
    });

    test('testCaseInsensitiveKeyDictionary', () {
      final dict = <String, String>{'key1': 'value1', 'Content-Type': 'value2'};

      // Test normal access
      expect(dict['key1'], equals('value1'));
      expect(dict['Content-Type'], equals('value2'));
      expect(dict['Key1'], isNull);
      expect(dict['content-type'], isNull);

      // Test case-insensitive access
      expect(dict.getCaseInsensitive('key1'), equals('value1'));
      expect(dict.getCaseInsensitive('Content-Type'), equals('value2'));
      expect(dict.getCaseInsensitive('Key1'), equals('value1'));
      expect(dict.getCaseInsensitive('content-type'), equals('value2'));
      expect(dict.getCaseInsensitive('no-exist-key'), isNull);
    });

    test('testDeserializeXmlSuccess', () async {
      const xml = '''
<OutputXml>
    <StrValue>value1</StrValue>
    <StrValue1>12345</StrValue1>
</OutputXml>
''';

      // Test deserializeXmlWithRoot
      expect(() async {
        await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
          ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
          'OutputXml',
        );
      }, returnsNormally);

      // Test deserializeXml
      expect(() async {
        await Serde.deserializeXml(
          ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
        );
      }, returnsNormally);
    });

    test('testDeserializeXmlFail', () async {
      const xml = '''
<OutputXml>
    <StrValue>value1</StrValue>
    <StrValue1>12345</StrValue1>
</OutputXml>
''';

      const invalidXml = '''
<OutputXml>
    <StrValue>value1</StrValue>
    <StrValue1>12345</StrValue1>
''';

      // Test null ByteStream
      try {
        await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(null, 'Root');
        fail('Expected ClientError to be thrown');
      } catch (e) {
        expect(e, isA<ClientError>());
        final clientError = e as ClientError;
        expect(
          clientError.message.contains('Can not get response body.'),
          isTrue,
        );
      }

      try {
        await Serde.deserializeXml(null);
        fail('Expected ClientError to be thrown');
      } catch (e) {
        expect(e, isA<ClientError>());
        final clientError = e as ClientError;
        expect(
          clientError.message.contains('Can not get response body.'),
          isTrue,
        );
      }

      // Test empty ByteStream
      try {
        await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
          ByteStream.fromData(Uint8List(0)),
          'Root',
        );
        fail('Expected ClientError to be thrown');
      } catch (e) {
        expect(e, isA<ClientError>());
        final clientError = e as ClientError;
        expect(
          clientError.message.contains('Parse response body fail.'),
          isTrue,
        );
      }

      // Test empty root element
      try {
        await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
          ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
          '',
        );
        fail('Expected ClientError to be thrown');
      } catch (e) {
        expect(e, isA<ClientError>());
        final clientError = e as ClientError;
        expect(
          clientError.message.contains('Null or empty field, xmlRoot.'),
          isTrue,
        );
      }

      // Test invalid XML
      try {
        await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
          ByteStream.fromData(Uint8List.fromList(utf8.encode(invalidXml))),
          'OutputXml',
        );
        fail('Expected ClientError to be thrown');
      } catch (e) {
        expect(e, isA<ClientError>());
        final clientError = e as ClientError;
        expect(
          clientError.message.contains('Parse response body fail.'),
          isTrue,
        );
      }
    });
  });
}
