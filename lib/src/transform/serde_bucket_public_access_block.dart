import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_public_access_block.dart';
import '../transform/serde_functions.dart';

/// Extension for bucket PublicAccessBlock operations serialization and deserialization
extension SerdeBucketPublicAccessBlock on Serde {
  // MARK: - PutBucketPublicAccessBlock

  /// Serialize PutBucketPublicAccessBlock request
  static Future<void> serializePutBucketPublicAccessBlock(
    PutBucketPublicAccessBlockRequest request,
    OperationInput input,
  ) async {
    if (request.publicAccessBlockConfiguration != null) {
      final xmlData = _publicAccessBlockConfigurationToXml(
        request.publicAccessBlockConfiguration!,
      );
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize PutBucketPublicAccessBlock result
  static Future<void> deserializePutBucketPublicAccessBlock(
    PutBucketPublicAccessBlockResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed
  }

  // MARK: - GetBucketPublicAccessBlock

  /// Serialize GetBucketPublicAccessBlock request
  static Future<void> serializeGetBucketPublicAccessBlock(
    GetBucketPublicAccessBlockRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed
  }

  /// Deserialize GetBucketPublicAccessBlock result
  static Future<void> deserializeGetBucketPublicAccessBlock(
    GetBucketPublicAccessBlockResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'PublicAccessBlockConfiguration',
    );
    result.publicAccessBlockConfiguration =
        PublicAccessBlockConfiguration.fromJson(body);
  }

  // MARK: - DeleteBucketPublicAccessBlock

  /// Serialize DeleteBucketPublicAccessBlock request
  static Future<void> serializeDeleteBucketPublicAccessBlock(
    DeleteBucketPublicAccessBlockRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed
  }

  /// Deserialize DeleteBucketPublicAccessBlock result
  static Future<void> deserializeDeleteBucketPublicAccessBlock(
    DeleteBucketPublicAccessBlockResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed
  }

  // MARK: - Helper Methods

  /// Convert PublicAccessBlockConfiguration to XML data
  static Uint8List _publicAccessBlockConfigurationToXml(
    PublicAccessBlockConfiguration configuration,
  ) {
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<PublicAccessBlockConfiguration>';

    if (configuration.blockPublicAccess != null) {
      xmlBody +=
          '<BlockPublicAccess>${configuration.blockPublicAccess}</BlockPublicAccess>';
    }

    xmlBody += '</PublicAccessBlockConfiguration>';

    return Uint8List.fromList(utf8.encode(xmlBody));
  }
}
