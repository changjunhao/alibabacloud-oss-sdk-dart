import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_https_config.dart';
import '../transform/serde_functions.dart';

/// Extension for bucket HTTPS config operations serialization and deserialization
extension SerdeBucketHttpsConfig on Serde {
  // MARK: - PutBucketHttpsConfig

  /// Serialize PutBucketHttpsConfig request
  static Future<void> serializePutBucketHttpsConfig(
    PutBucketHttpsConfigRequest request,
    OperationInput input,
  ) async {
    if (request.httpsConfiguration != null) {
      final xmlData = _httpsConfigurationToXml(request.httpsConfiguration!);
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize PutBucketHttpsConfig result
  static Future<void> deserializePutBucketHttpsConfig(
    PutBucketHttpsConfigResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutBucketHttpsConfig
  }

  // MARK: - GetBucketHttpsConfig

  /// Serialize GetBucketHttpsConfig request
  static Future<void> serializeGetBucketHttpsConfig(
    GetBucketHttpsConfigRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketHttpsConfig
  }

  /// Deserialize GetBucketHttpsConfig result
  static Future<void> deserializeGetBucketHttpsConfig(
    GetBucketHttpsConfigResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'HttpsConfiguration',
    );
    result.httpsConfiguration = HttpsConfiguration.fromJson(body);
  }

  // MARK: - DeleteBucketHttpsConfig

  /// Serialize DeleteBucketHttpsConfig request
  static Future<void> serializeDeleteBucketHttpsConfig(
    DeleteBucketHttpsConfigRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for DeleteBucketHttpsConfig
  }

  /// Deserialize DeleteBucketHttpsConfig result
  static Future<void> deserializeDeleteBucketHttpsConfig(
    DeleteBucketHttpsConfigResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for DeleteBucketHttpsConfig
  }

  // MARK: - Helper Methods

  /// Convert HttpsConfiguration to XML data
  static Uint8List _httpsConfigurationToXml(HttpsConfiguration config) {
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<HttpsConfiguration>';

    if (config.tls != null) {
      xmlBody += '<TLS>';
      if (config.tls!.enable != null) {
        xmlBody += '<Enable>${config.tls!.enable! ? "true" : "false"}</Enable>';
      }
      if (config.tls!.tlsVersions != null) {
        for (final version in config.tls!.tlsVersions!) {
          xmlBody += '<TLSVersion>$version</TLSVersion>';
        }
      }
      xmlBody += '</TLS>';
    }

    xmlBody += '</HttpsConfiguration>';

    return Uint8List.fromList(utf8.encode(xmlBody));
  }
}
