import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_object_tagging.dart';
import 'serde_functions.dart';

/// Serialization and deserialization for object tagging operations
class SerdeObjectTagging {
  /// Creates a SerdeObjectTagging instance.
  SerdeObjectTagging();

  // MARK: - PutObjectTagging

  /// Serialize PutObjectTagging request
  static Future<void> serializePutObjectTagging(
    PutObjectTaggingRequest request,
    OperationInput input,
  ) async {
    if (request.versionId != null) {
      input.parameters['versionId'] = request.versionId!;
    }

    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<Tagging>';
    xmlBody += '<TagSet>';
    if (request.tagging?.tagSet?.tags != null) {
      for (final tag in request.tagging!.tagSet!.tags!) {
        if (tag.key != null && tag.value != null) {
          xmlBody += '<Tag>';
          xmlBody += '<Key>${tag.key}</Key>';
          xmlBody += '<Value>${tag.value}</Value>';
          xmlBody += '</Tag>';
        }
      }
    }
    xmlBody += '</TagSet>';
    xmlBody += '</Tagging>';

    final xmlData = utf8.encode(xmlBody);
    input.body = ByteStream.fromData(Uint8List.fromList(xmlData));
  }

  /// Deserialize PutObjectTagging result
  static Future<void> deserializePutObjectTagging(
    PutObjectTaggingResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutObjectTagging
  }

  // MARK: - GetObjectTagging

  /// Serialize GetObjectTagging request
  static Future<void> serializeGetObjectTagging(
    GetObjectTaggingRequest request,
    OperationInput input,
  ) async {
    if (request.versionId != null) {
      input.parameters['versionId'] = request.versionId!;
    }
  }

  /// Deserialize GetObjectTagging result
  static Future<void> deserializeGetObjectTagging(
    GetObjectTaggingResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'Tagging',
    );

    final tags = <Tag>[];
    if (body['TagSet'] is Map<String, dynamic>) {
      final tagSet = body['TagSet'] as Map<String, dynamic>;
      final objects = <Map<String, dynamic>>[];

      if (tagSet['Tag'] is List) {
        // Multiple tags
        final tagList = tagSet['Tag'] as List;
        for (final item in tagList) {
          if (item is Map<String, dynamic>) {
            objects.add(item);
          }
        }
      } else if (tagSet['Tag'] is Map<String, dynamic>) {
        // Single tag
        objects.add(tagSet['Tag'] as Map<String, dynamic>);
      }

      for (final object in objects) {
        final tag = Tag(
          key: object['Key'] as String?,
          value: object['Value'] as String?,
        );
        tags.add(tag);
      }
    }

    result.tagging = Tagging(tagSet: TagSet(tags: tags));
  }

  // MARK: - DeleteObjectTagging

  /// Serialize DeleteObjectTagging request
  static Future<void> serializeDeleteObjectTagging(
    DeleteObjectTaggingRequest request,
    OperationInput input,
  ) async {
    if (request.versionId != null) {
      input.parameters['versionId'] = request.versionId!;
    }
  }

  /// Deserialize DeleteObjectTagging result
  static Future<void> deserializeDeleteObjectTagging(
    DeleteObjectTaggingResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for DeleteObjectTagging
  }
}
