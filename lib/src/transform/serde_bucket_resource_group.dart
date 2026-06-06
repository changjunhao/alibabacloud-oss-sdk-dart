import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_resource_group.dart';
import '../transform/serde_functions.dart';

/// Extension for bucket resource group operations serialization and deserialization
extension SerdeBucketResourceGroup on Serde {
  // MARK: - GetBucketResourceGroup

  /// Serialize GetBucketResourceGroup request
  static Future<void> serializeGetBucketResourceGroup(
    GetBucketResourceGroupRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketResourceGroup
  }

  /// Deserialize GetBucketResourceGroup result
  static Future<void> deserializeGetBucketResourceGroup(
    GetBucketResourceGroupResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'BucketResourceGroupConfiguration',
    );
    result.bucketResourceGroupConfiguration =
        BucketResourceGroupConfiguration.fromJson(body);
  }

  // MARK: - PutBucketResourceGroup

  /// Serialize PutBucketResourceGroup request
  static Future<void> serializePutBucketResourceGroup(
    PutBucketResourceGroupRequest request,
    OperationInput input,
  ) async {
    if (request.bucketResourceGroupConfiguration != null) {
      final xmlData = await _bucketResourceGroupConfigurationToXml(
        request.bucketResourceGroupConfiguration!,
      );
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize PutBucketResourceGroup result
  static Future<void> deserializePutBucketResourceGroup(
    PutBucketResourceGroupResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutBucketResourceGroup
  }

  // MARK: - Helper Methods

  /// Convert BucketResourceGroupConfiguration to XML data
  static Future<Uint8List> _bucketResourceGroupConfigurationToXml(
    BucketResourceGroupConfiguration configuration,
  ) async {
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<BucketResourceGroupConfiguration>';

    if (configuration.resourceGroupId != null) {
      xmlBody +=
          '<ResourceGroupId>${configuration.resourceGroupId}</ResourceGroupId>';
    }

    xmlBody += '</BucketResourceGroupConfiguration>';

    return Uint8List.fromList(utf8.encode(xmlBody));
  }
}
