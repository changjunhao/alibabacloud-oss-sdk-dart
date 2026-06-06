import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_object_tagging.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_object_tagging.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeObjectTagging Tests', () {
    test('testSerializePutObjectTagging - with tags and versionId', () async {
      var input = OperationInput(
        operationName: 'PutObjectTagging',
        method: 'PUT',
      );

      final tags = [
        Tag(key: 'environment', value: 'production'),
        Tag(key: 'team', value: 'backend'),
      ];
      var request = PutObjectTaggingRequest(
        bucket: 'test-bucket',
        key: 'test-object',
        versionId: 'CAEQNRiBgMClj7qD0BYiIDQ5Y2QyMjc3',
        tagging: Tagging(tagSet: TagSet(tags: tags)),
      );

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectTagging.serializePutObjectTagging],
      );

      // Verify versionId parameter
      expect(
        input.parameters['versionId'],
        equals('CAEQNRiBgMClj7qD0BYiIDQ5Y2QyMjc3'),
      );

      // Verify XML body
      final bodyData = await input.body?.readData();
      final bodyStr = utf8.decode(bodyData!);

      final expectedXml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<Tagging>'
          '<TagSet>'
          '<Tag>'
          '<Key>environment</Key>'
          '<Value>production</Value>'
          '</Tag>'
          '<Tag>'
          '<Key>team</Key>'
          '<Value>backend</Value>'
          '</Tag>'
          '</TagSet>'
          '</Tagging>';

      expect(bodyStr, equals(expectedXml));
    });

    test('testSerializePutObjectTagging - empty tagging', () async {
      var input = OperationInput(
        operationName: 'PutObjectTagging',
        method: 'PUT',
      );

      var request = PutObjectTaggingRequest(
        bucket: 'test-bucket',
        key: 'test-object',
        tagging: Tagging(),
      );

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectTagging.serializePutObjectTagging],
      );

      // Verify no versionId parameter
      expect(input.parameters.containsKey('versionId'), isFalse);

      // Verify XML body
      final bodyData = await input.body?.readData();
      final bodyStr = utf8.decode(bodyData!);
      expect(
        bodyStr,
        equals(
          '<?xml version="1.0" encoding="UTF-8"?><Tagging><TagSet></TagSet></Tagging>',
        ),
      );
    });

    test('testDeserializeGetObjectTagging - null body throws', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetObjectTaggingResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeObjectTagging.deserializeGetObjectTagging],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetObjectTagging - unexpected body throws', () async {
      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
      );
      var result = GetObjectTaggingResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeObjectTagging.deserializeGetObjectTagging],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetObjectTagging - multiple tags', () async {
      final xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<Tagging>'
          '<TagSet>'
          '<Tag>'
          '<Key>environment</Key>'
          '<Value>production</Value>'
          '</Tag>'
          '<Tag>'
          '<Key>team</Key>'
          '<Value>backend</Value>'
          '</Tag>'
          '</TagSet>'
          '</Tagging>';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      var result = GetObjectTaggingResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeObjectTagging.deserializeGetObjectTagging],
      );

      expect(result.tagging, isNotNull);
      expect(result.tagging!.tagSet, isNotNull);
      expect(result.tagging!.tagSet!.tags, isNotNull);
      expect(result.tagging!.tagSet!.tags!.length, equals(2));
      expect(result.tagging!.tagSet!.tags![0].key, equals('environment'));
      expect(result.tagging!.tagSet!.tags![0].value, equals('production'));
      expect(result.tagging!.tagSet!.tags![1].key, equals('team'));
      expect(result.tagging!.tagSet!.tags![1].value, equals('backend'));
    });

    test('testDeserializeGetObjectTagging - single tag', () async {
      final xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<Tagging>'
          '<TagSet>'
          '<Tag>'
          '<Key>singleKey</Key>'
          '<Value>singleValue</Value>'
          '</Tag>'
          '</TagSet>'
          '</Tagging>';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      var result = GetObjectTaggingResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeObjectTagging.deserializeGetObjectTagging],
      );

      expect(result.tagging, isNotNull);
      expect(result.tagging!.tagSet, isNotNull);
      expect(result.tagging!.tagSet!.tags, isNotNull);
      expect(result.tagging!.tagSet!.tags!.length, equals(1));
      expect(result.tagging!.tagSet!.tags![0].key, equals('singleKey'));
      expect(result.tagging!.tagSet!.tags![0].value, equals('singleValue'));
    });

    test('testSerializeGetObjectTagging - with versionId', () async {
      var input = OperationInput(
        operationName: 'GetObjectTagging',
        method: 'GET',
      );

      var request = GetObjectTaggingRequest(
        bucket: 'test-bucket',
        key: 'test-object',
        versionId: 'CAEQNRiBgMClj7qD0BYiIDQ5Y2QyMjc3',
      );

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectTagging.serializeGetObjectTagging],
      );

      expect(
        input.parameters['versionId'],
        equals('CAEQNRiBgMClj7qD0BYiIDQ5Y2QyMjc3'),
      );
    });

    test('testSerializeGetObjectTagging - without versionId', () async {
      var input = OperationInput(
        operationName: 'GetObjectTagging',
        method: 'GET',
      );

      var request = GetObjectTaggingRequest(
        bucket: 'test-bucket',
        key: 'test-object',
      );

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectTagging.serializeGetObjectTagging],
      );

      expect(input.parameters.containsKey('versionId'), isFalse);
    });

    test('testSerializeDeleteObjectTagging - with versionId', () async {
      var input = OperationInput(
        operationName: 'DeleteObjectTagging',
        method: 'DELETE',
      );

      var request = DeleteObjectTaggingRequest(
        bucket: 'test-bucket',
        key: 'test-object',
        versionId: 'CAEQNRiBgMClj7qD0BYiIDQ5Y2QyMjc3',
      );

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectTagging.serializeDeleteObjectTagging],
      );

      expect(
        input.parameters['versionId'],
        equals('CAEQNRiBgMClj7qD0BYiIDQ5Y2QyMjc3'),
      );
    });

    test('testSerializeDeleteObjectTagging - without versionId', () async {
      var input = OperationInput(
        operationName: 'DeleteObjectTagging',
        method: 'DELETE',
      );

      var request = DeleteObjectTaggingRequest(
        bucket: 'test-bucket',
        key: 'test-object',
      );

      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectTagging.serializeDeleteObjectTagging],
      );

      expect(input.parameters.containsKey('versionId'), isFalse);
    });
  });
}
