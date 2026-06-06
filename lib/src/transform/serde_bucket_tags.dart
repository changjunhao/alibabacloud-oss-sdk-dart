import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_tags.dart';
import '../models/model_object_tagging.dart';
import 'serde_functions.dart';

/// Extension for bucket tags operations serialization and deserialization
extension SerdeBucketTags on Serde {
  // MARK: - PutBucketTags

  /// Serialize PutBucketTags request
  static Future<void> serializePutBucketTags(
    PutBucketTagsRequest request,
    OperationInput input,
  ) async {
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

  /// Deserialize PutBucketTags result
  static Future<void> deserializePutBucketTags(
    PutBucketTagsResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutBucketTags
  }

  // MARK: - GetBucketTags

  /// Serialize GetBucketTags request
  static Future<void> serializeGetBucketTags(
    GetBucketTagsRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketTags
  }

  /// Deserialize GetBucketTags result
  static Future<void> deserializeGetBucketTags(
    GetBucketTagsResult result,
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

  // MARK: - DeleteBucketTags

  /// Serialize DeleteBucketTags request
  static Future<void> serializeDeleteBucketTags(
    DeleteBucketTagsRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for DeleteBucketTags
  }

  /// Deserialize DeleteBucketTags result
  static Future<void> deserializeDeleteBucketTags(
    DeleteBucketTagsResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for DeleteBucketTags
  }
}
