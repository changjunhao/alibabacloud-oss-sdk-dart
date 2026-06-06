import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_public_access_block.dart';
import '../models/model_public_access_block.dart';
import '../transform/serde_functions.dart';

/// Extension for account-level PublicAccessBlock operations serialization and deserialization
extension SerdePublicAccessBlock on Serde {
  // MARK: - PutPublicAccessBlock

  /// Serialize PutPublicAccessBlock request
  static Future<void> serializePutPublicAccessBlock(
    PutPublicAccessBlockRequest request,
    OperationInput input,
  ) async {
    if (request.publicAccessBlockConfiguration != null) {
      final xmlData = _publicAccessBlockConfigurationToXml(
        request.publicAccessBlockConfiguration!,
      );
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize PutPublicAccessBlock result
  static Future<void> deserializePutPublicAccessBlock(
    PutPublicAccessBlockResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed
  }

  // MARK: - GetPublicAccessBlock

  /// Serialize GetPublicAccessBlock request
  static Future<void> serializeGetPublicAccessBlock(
    GetPublicAccessBlockRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed
  }

  /// Deserialize GetPublicAccessBlock result
  static Future<void> deserializeGetPublicAccessBlock(
    GetPublicAccessBlockResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'PublicAccessBlockConfiguration',
    );
    result.publicAccessBlockConfiguration =
        PublicAccessBlockConfiguration.fromJson(body);
  }

  // MARK: - DeletePublicAccessBlock

  /// Serialize DeletePublicAccessBlock request
  static Future<void> serializeDeletePublicAccessBlock(
    DeletePublicAccessBlockRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed
  }

  /// Deserialize DeletePublicAccessBlock result
  static Future<void> deserializeDeletePublicAccessBlock(
    DeletePublicAccessBlockResult result,
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
