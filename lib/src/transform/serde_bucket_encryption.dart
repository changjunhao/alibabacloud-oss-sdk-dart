import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_encryption.dart';
import '../transform/serde_functions.dart';

/// Extension for bucket encryption operations serialization and deserialization
extension SerdeBucketEncryption on Serde {
  // MARK: - PutBucketEncryption

  /// Serialize PutBucketEncryption request
  static Future<void> serializePutBucketEncryption(
    PutBucketEncryptionRequest request,
    OperationInput input,
  ) async {
    if (request.serverSideEncryptionRule != null) {
      final xmlData = await _serverSideEncryptionRuleToXml(
        request.serverSideEncryptionRule!,
      );
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize PutBucketEncryption result
  static Future<void> deserializePutBucketEncryption(
    PutBucketEncryptionResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutBucketEncryption
  }

  // MARK: - GetBucketEncryption

  /// Serialize GetBucketEncryption request
  static Future<void> serializeGetBucketEncryption(
    GetBucketEncryptionRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketEncryption
  }

  /// Deserialize GetBucketEncryption result
  static Future<void> deserializeGetBucketEncryption(
    GetBucketEncryptionResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'ServerSideEncryptionRule',
    );
    result.serverSideEncryptionRule = ServerSideEncryptionRule.fromJson(body);
  }

  // MARK: - DeleteBucketEncryption

  /// Serialize DeleteBucketEncryption request
  static Future<void> serializeDeleteBucketEncryption(
    DeleteBucketEncryptionRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for DeleteBucketEncryption
  }

  /// Deserialize DeleteBucketEncryption result
  static Future<void> deserializeDeleteBucketEncryption(
    DeleteBucketEncryptionResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for DeleteBucketEncryption
  }

  // MARK: - Helper Methods

  /// Convert ServerSideEncryptionRule to XML data
  static Future<Uint8List> _serverSideEncryptionRuleToXml(
    ServerSideEncryptionRule rule,
  ) async {
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<ServerSideEncryptionRule>';

    if (rule.applyServerSideEncryptionByDefault != null) {
      final defaults = rule.applyServerSideEncryptionByDefault!;
      xmlBody += '<ApplyServerSideEncryptionByDefault>';

      if (defaults.sseAlgorithm != null) {
        xmlBody += '<SSEAlgorithm>${defaults.sseAlgorithm}</SSEAlgorithm>';
      }

      if (defaults.kmsMasterKeyId != null) {
        xmlBody +=
            '<KMSMasterKeyID>${defaults.kmsMasterKeyId}</KMSMasterKeyID>';
      }

      if (defaults.kmsDataEncryption != null) {
        xmlBody +=
            '<KMSDataEncryption>${defaults.kmsDataEncryption}</KMSDataEncryption>';
      }

      xmlBody += '</ApplyServerSideEncryptionByDefault>';
    }

    xmlBody += '</ServerSideEncryptionRule>';

    return Uint8List.fromList(utf8.encode(xmlBody));
  }
}
