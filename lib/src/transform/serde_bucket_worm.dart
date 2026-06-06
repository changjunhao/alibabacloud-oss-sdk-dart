import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_worm.dart';
import '../transform/serde_functions.dart';

/// Extension for bucket WORM operations serialization and deserialization
extension SerdeBucketWorm on Serde {
  // MARK: - InitiateBucketWorm

  /// Serialize InitiateBucketWorm request
  static Future<void> serializeInitiateBucketWorm(
    InitiateBucketWormRequest request,
    OperationInput input,
  ) async {
    if (request.initiateWormConfiguration != null) {
      final xmlData = _initiateWormConfigurationToXml(
        request.initiateWormConfiguration!,
      );
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize InitiateBucketWorm result
  static Future<void> deserializeInitiateBucketWorm(
    InitiateBucketWormResult result,
    OperationOutput output,
  ) async {
    // wormId is obtained from commonProp.headers['x-oss-worm-id']
  }

  // MARK: - AbortBucketWorm

  /// Serialize AbortBucketWorm request
  static Future<void> serializeAbortBucketWorm(
    AbortBucketWormRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for AbortBucketWorm
  }

  /// Deserialize AbortBucketWorm result
  static Future<void> deserializeAbortBucketWorm(
    AbortBucketWormResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for AbortBucketWorm
  }

  // MARK: - CompleteBucketWorm

  /// Serialize CompleteBucketWorm request
  static Future<void> serializeCompleteBucketWorm(
    CompleteBucketWormRequest request,
    OperationInput input,
  ) async {
    if (request.wormId != null) {
      input.parameters['wormId'] = request.wormId!;
    }
  }

  /// Deserialize CompleteBucketWorm result
  static Future<void> deserializeCompleteBucketWorm(
    CompleteBucketWormResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for CompleteBucketWorm
  }

  // MARK: - ExtendBucketWorm

  /// Serialize ExtendBucketWorm request
  static Future<void> serializeExtendBucketWorm(
    ExtendBucketWormRequest request,
    OperationInput input,
  ) async {
    if (request.wormId != null) {
      input.parameters['wormId'] = request.wormId!;
    }
    if (request.extendWormConfiguration != null) {
      final xmlData = _extendWormConfigurationToXml(
        request.extendWormConfiguration!,
      );
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize ExtendBucketWorm result
  static Future<void> deserializeExtendBucketWorm(
    ExtendBucketWormResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for ExtendBucketWorm
  }

  // MARK: - GetBucketWorm

  /// Serialize GetBucketWorm request
  static Future<void> serializeGetBucketWorm(
    GetBucketWormRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketWorm
  }

  /// Deserialize GetBucketWorm result
  static Future<void> deserializeGetBucketWorm(
    GetBucketWormResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'WormConfiguration',
    );
    result.wormConfiguration = WormConfiguration.fromJson(body);
  }

  // MARK: - Helper Methods

  /// Convert InitiateWormConfiguration to XML data
  static Uint8List _initiateWormConfigurationToXml(
    InitiateWormConfiguration config,
  ) {
    var xmlBody = '<InitiateWormConfiguration>';
    if (config.retentionPeriodInDays != null) {
      xmlBody +=
          '<RetentionPeriodInDays>${config.retentionPeriodInDays}</RetentionPeriodInDays>';
    }
    xmlBody += '</InitiateWormConfiguration>';
    return Uint8List.fromList(utf8.encode(xmlBody));
  }

  /// Convert ExtendWormConfiguration to XML data
  static Uint8List _extendWormConfigurationToXml(
    ExtendWormConfiguration config,
  ) {
    var xmlBody = '<ExtendWormConfiguration>';
    if (config.retentionPeriodInDays != null) {
      xmlBody +=
          '<RetentionPeriodInDays>${config.retentionPeriodInDays}</RetentionPeriodInDays>';
    }
    xmlBody += '</ExtendWormConfiguration>';
    return Uint8List.fromList(utf8.encode(xmlBody));
  }
}
