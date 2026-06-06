import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_transfer_acceleration.dart';
import '../transform/serde_functions.dart';

/// Extension for bucket transfer acceleration operations serialization and deserialization
extension SerdeBucketTransferAcceleration on Serde {
  // MARK: - PutBucketTransferAcceleration

  /// Serialize PutBucketTransferAcceleration request
  static Future<void> serializePutBucketTransferAcceleration(
    PutBucketTransferAccelerationRequest request,
    OperationInput input,
  ) async {
    if (request.transferAccelerationConfiguration != null) {
      final xmlData = _transferAccelerationConfigurationToXml(
        request.transferAccelerationConfiguration!,
      );
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize PutBucketTransferAcceleration result
  static Future<void> deserializePutBucketTransferAcceleration(
    PutBucketTransferAccelerationResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutBucketTransferAcceleration
  }

  // MARK: - GetBucketTransferAcceleration

  /// Serialize GetBucketTransferAcceleration request
  static Future<void> serializeGetBucketTransferAcceleration(
    GetBucketTransferAccelerationRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketTransferAcceleration
  }

  /// Deserialize GetBucketTransferAcceleration result
  static Future<void> deserializeGetBucketTransferAcceleration(
    GetBucketTransferAccelerationResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'TransferAccelerationConfiguration',
    );
    result.transferAccelerationConfiguration =
        TransferAccelerationConfiguration.fromJson(body);
  }

  // MARK: - Helper Methods

  /// Convert TransferAccelerationConfiguration to XML data
  static Uint8List _transferAccelerationConfigurationToXml(
    TransferAccelerationConfiguration config,
  ) {
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<TransferAccelerationConfiguration>';

    if (config.enabled != null) {
      xmlBody += '<Enabled>${config.enabled! ? "true" : "false"}</Enabled>';
    }

    xmlBody += '</TransferAccelerationConfiguration>';

    return Uint8List.fromList(utf8.encode(xmlBody));
  }
}
