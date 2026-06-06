import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_cors.dart';
import '../transform/serde_functions.dart';

/// Extension for bucket CORS operations serialization and deserialization
extension SerdeBucketCors on Serde {
  // MARK: - PutBucketCors

  /// Serialize PutBucketCors request
  static Future<void> serializePutBucketCors(
    PutBucketCorsRequest request,
    OperationInput input,
  ) async {
    if (request.corsConfiguration != null) {
      final xmlData = await _corsConfigurationToXml(request.corsConfiguration!);
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize PutBucketCors result
  static Future<void> deserializePutBucketCors(
    PutBucketCorsResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutBucketCors
  }

  // MARK: - GetBucketCors

  /// Serialize GetBucketCors request
  static Future<void> serializeGetBucketCors(
    GetBucketCorsRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketCors
  }

  /// Deserialize GetBucketCors result
  static Future<void> deserializeGetBucketCors(
    GetBucketCorsResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'CORSConfiguration',
    );
    result.corsConfiguration = CORSConfiguration.fromJson(body);
  }

  // MARK: - DeleteBucketCors

  /// Serialize DeleteBucketCors request
  static Future<void> serializeDeleteBucketCors(
    DeleteBucketCorsRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for DeleteBucketCors
  }

  /// Deserialize DeleteBucketCors result
  static Future<void> deserializeDeleteBucketCors(
    DeleteBucketCorsResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for DeleteBucketCors
  }

  // MARK: - OptionObject

  /// Serialize OptionObject request
  static Future<void> serializeOptionObject(
    OptionObjectRequest request,
    OperationInput input,
  ) async {
    if (request.origin != null) {
      input.headers['Origin'] = request.origin!;
    }
    if (request.accessControlRequestMethod != null) {
      input.headers['Access-Control-Request-Method'] =
          request.accessControlRequestMethod!;
    }
    if (request.accessControlRequestHeaders != null) {
      input.headers['Access-Control-Request-Headers'] =
          request.accessControlRequestHeaders!;
    }
  }

  /// Deserialize OptionObject result
  static Future<void> deserializeOptionObject(
    OptionObjectResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for OptionObject
    // Headers are automatically populated in commonProp.headers
  }

  // MARK: - Helper Methods

  /// Convert CORSConfiguration to XML data
  static Future<Uint8List> _corsConfigurationToXml(
    CORSConfiguration corsConfiguration,
  ) async {
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<CORSConfiguration>';

    if (corsConfiguration.corsRules != null) {
      for (final rule in corsConfiguration.corsRules!) {
        xmlBody += '<CORSRule>';

        if (rule.allowedOrigins != null) {
          for (final origin in rule.allowedOrigins!) {
            xmlBody += '<AllowedOrigin>$origin</AllowedOrigin>';
          }
        }

        if (rule.allowedMethods != null) {
          for (final method in rule.allowedMethods!) {
            xmlBody += '<AllowedMethod>$method</AllowedMethod>';
          }
        }

        if (rule.allowedHeaders != null) {
          for (final header in rule.allowedHeaders!) {
            xmlBody += '<AllowedHeader>$header</AllowedHeader>';
          }
        }

        if (rule.exposeHeaders != null) {
          for (final header in rule.exposeHeaders!) {
            xmlBody += '<ExposeHeader>$header</ExposeHeader>';
          }
        }

        if (rule.maxAgeSeconds != null) {
          xmlBody += '<MaxAgeSeconds>${rule.maxAgeSeconds}</MaxAgeSeconds>';
        }

        xmlBody += '</CORSRule>';
      }
    }

    if (corsConfiguration.responseVary != null) {
      xmlBody +=
          '<ResponseVary>${corsConfiguration.responseVary! ? "true" : "false"}</ResponseVary>';
    }

    xmlBody += '</CORSConfiguration>';

    return Uint8List.fromList(utf8.encode(xmlBody));
  }
}
