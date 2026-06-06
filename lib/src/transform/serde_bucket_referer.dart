import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_referer.dart';
import '../transform/serde_functions.dart';

/// Extension for bucket Referer operations serialization and deserialization
extension SerdeBucketReferer on Serde {
  // MARK: - PutBucketReferer

  /// Serialize PutBucketReferer request
  static Future<void> serializePutBucketReferer(
    PutBucketRefererRequest request,
    OperationInput input,
  ) async {
    if (request.refererConfiguration != null) {
      final xmlData = _refererConfigurationToXml(request.refererConfiguration!);
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize PutBucketReferer result
  static Future<void> deserializePutBucketReferer(
    PutBucketRefererResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutBucketReferer
  }

  // MARK: - GetBucketReferer

  /// Serialize GetBucketReferer request
  static Future<void> serializeGetBucketReferer(
    GetBucketRefererRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketReferer
  }

  /// Deserialize GetBucketReferer result
  static Future<void> deserializeGetBucketReferer(
    GetBucketRefererResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'RefererConfiguration',
    );
    result.refererConfiguration = RefererConfiguration.fromJson(body);
  }

  // MARK: - Helper Methods

  /// Convert RefererConfiguration to XML data
  static Uint8List _refererConfigurationToXml(RefererConfiguration config) {
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<RefererConfiguration>';

    if (config.allowEmptyReferer != null) {
      xmlBody +=
          '<AllowEmptyReferer>${config.allowEmptyReferer}</AllowEmptyReferer>';
    }

    if (config.allowTruncateQueryString != null) {
      xmlBody +=
          '<AllowTruncateQueryString>${config.allowTruncateQueryString}</AllowTruncateQueryString>';
    }

    if (config.truncatePath != null) {
      xmlBody += '<TruncatePath>${config.truncatePath}</TruncatePath>';
    }

    if (config.refererList != null && config.refererList!.referers != null) {
      xmlBody += '<RefererList>';
      for (final referer in config.refererList!.referers!) {
        xmlBody += '<Referer>$referer</Referer>';
      }
      xmlBody += '</RefererList>';
    }

    if (config.refererBlacklist != null &&
        config.refererBlacklist!.referers != null) {
      xmlBody += '<RefererBlacklist>';
      for (final referer in config.refererBlacklist!.referers!) {
        xmlBody += '<Referer>$referer</Referer>';
      }
      xmlBody += '</RefererBlacklist>';
    }

    xmlBody += '</RefererConfiguration>';
    return Uint8List.fromList(utf8.encode(xmlBody));
  }
}
