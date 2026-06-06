import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_access_monitor.dart';
import '../transform/serde_functions.dart';

/// Extension for bucket AccessMonitor operations serialization and deserialization
extension SerdeBucketAccessMonitor on Serde {
  // MARK: - PutBucketAccessMonitor

  /// Serialize PutBucketAccessMonitor request
  static Future<void> serializePutBucketAccessMonitor(
    PutBucketAccessMonitorRequest request,
    OperationInput input,
  ) async {
    if (request.accessMonitorConfiguration != null) {
      final xmlData = _accessMonitorConfigurationToXml(
        request.accessMonitorConfiguration!,
      );
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize PutBucketAccessMonitor result
  static Future<void> deserializePutBucketAccessMonitor(
    PutBucketAccessMonitorResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed
  }

  // MARK: - GetBucketAccessMonitor

  /// Serialize GetBucketAccessMonitor request
  static Future<void> serializeGetBucketAccessMonitor(
    GetBucketAccessMonitorRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed
  }

  /// Deserialize GetBucketAccessMonitor result
  static Future<void> deserializeGetBucketAccessMonitor(
    GetBucketAccessMonitorResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'AccessMonitorConfiguration',
    );
    result.accessMonitorConfiguration = AccessMonitorConfiguration.fromJson(
      body,
    );
  }

  // MARK: - Helper Methods

  /// Convert AccessMonitorConfiguration to XML data
  static Uint8List _accessMonitorConfigurationToXml(
    AccessMonitorConfiguration configuration,
  ) {
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<AccessMonitorConfiguration>';

    if (configuration.status != null) {
      xmlBody += '<Status>${configuration.status}</Status>';
    }

    xmlBody += '</AccessMonitorConfiguration>';

    return Uint8List.fromList(utf8.encode(xmlBody));
  }
}
