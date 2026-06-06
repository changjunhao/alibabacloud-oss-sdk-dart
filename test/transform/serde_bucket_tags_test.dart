import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_tags.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_object_tagging.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_tags.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketTags Tests', () {
    test('testSerializePutBucketTags - empty tagging', () async {
      var input = OperationInput(operationName: 'PutBucketTags', method: 'PUT');

      // Test with empty Tagging (no tags)
      var request = PutBucketTagsRequest(tagging: Tagging());
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketTags.serializePutBucketTags],
      );

      final bodyData = await input.body?.readData();
      final bodyStr = utf8.decode(bodyData!);
      expect(
        bodyStr,
        equals(
          '<?xml version="1.0" encoding="UTF-8"?><Tagging><TagSet></TagSet></Tagging>',
        ),
      );
    });

    test('testSerializePutBucketTags - with tags', () async {
      var input = OperationInput(operationName: 'PutBucketTags', method: 'PUT');

      final tags = [
        Tag(key: 'key1', value: 'value1'),
        Tag(key: 'key2', value: 'value2'),
      ];
      var request = PutBucketTagsRequest(
        tagging: Tagging(tagSet: TagSet(tags: tags)),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketTags.serializePutBucketTags],
      );

      final bodyData = await input.body?.readData();
      final bodyStr = utf8.decode(bodyData!);

      final expectedXml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<Tagging>'
          '<TagSet>'
          '<Tag>'
          '<Key>key1</Key>'
          '<Value>value1</Value>'
          '</Tag>'
          '<Tag>'
          '<Key>key2</Key>'
          '<Value>value2</Value>'
          '</Tag>'
          '</TagSet>'
          '</Tagging>';

      expect(bodyStr, equals(expectedXml));
    });

    test('testDeserializeGetBucketTags - null body throws', () async {
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = GetBucketTagsResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketTags.deserializeGetBucketTags],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketTags - unexpected body throws', () async {
      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
      );
      var result = GetBucketTagsResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketTags.deserializeGetBucketTags],
        ),
        throwsA(isA<ClientError>()),
      );
    });

    test('testDeserializeGetBucketTags - normal response', () async {
      final xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<Tagging>'
          '<TagSet>'
          '<Tag>'
          '<Key>key1</Key>'
          '<Value>value1</Value>'
          '</Tag>'
          '<Tag>'
          '<Key>key2</Key>'
          '<Value>value2</Value>'
          '</Tag>'
          '</TagSet>'
          '</Tagging>';

      var output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      var result = GetBucketTagsResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketTags.deserializeGetBucketTags],
      );

      expect(result.tagging, isNotNull);
      expect(result.tagging!.tagSet, isNotNull);
      expect(result.tagging!.tagSet!.tags, isNotNull);
      expect(result.tagging!.tagSet!.tags!.length, equals(2));
      expect(result.tagging!.tagSet!.tags!.first.key, equals('key1'));
      expect(result.tagging!.tagSet!.tags!.first.value, equals('value1'));
      expect(result.tagging!.tagSet!.tags!.last.key, equals('key2'));
      expect(result.tagging!.tagSet!.tags!.last.value, equals('value2'));
    });

    test('testDeserializeGetBucketTags - single tag response', () async {
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
      var result = GetBucketTagsResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketTags.deserializeGetBucketTags],
      );

      expect(result.tagging, isNotNull);
      expect(result.tagging!.tagSet, isNotNull);
      expect(result.tagging!.tagSet!.tags, isNotNull);
      expect(result.tagging!.tagSet!.tags!.length, equals(1));
      expect(result.tagging!.tagSet!.tags!.first.key, equals('singleKey'));
      expect(result.tagging!.tagSet!.tags!.first.value, equals('singleValue'));
    });
  });
}
