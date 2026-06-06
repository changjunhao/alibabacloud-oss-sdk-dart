import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_logging.dart';
import '../transform/serde_functions.dart';

/// Extension for bucket Logging operations serialization and deserialization
extension SerdeBucketLogging on Serde {
  // MARK: - PutBucketLogging

  /// Serialize PutBucketLogging request
  static Future<void> serializePutBucketLogging(
    PutBucketLoggingRequest request,
    OperationInput input,
  ) async {
    if (request.bucketLoggingStatus != null) {
      final xmlData = _bucketLoggingStatusToXml(request.bucketLoggingStatus!);
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize PutBucketLogging result
  static Future<void> deserializePutBucketLogging(
    PutBucketLoggingResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutBucketLogging
  }

  // MARK: - GetBucketLogging

  /// Serialize GetBucketLogging request
  static Future<void> serializeGetBucketLogging(
    GetBucketLoggingRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketLogging
  }

  /// Deserialize GetBucketLogging result
  static Future<void> deserializeGetBucketLogging(
    GetBucketLoggingResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'BucketLoggingStatus',
    );
    result.bucketLoggingStatus = BucketLoggingStatus.fromJson(body);
  }

  // MARK: - DeleteBucketLogging

  /// Serialize DeleteBucketLogging request
  static Future<void> serializeDeleteBucketLogging(
    DeleteBucketLoggingRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for DeleteBucketLogging
  }

  /// Deserialize DeleteBucketLogging result
  static Future<void> deserializeDeleteBucketLogging(
    DeleteBucketLoggingResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for DeleteBucketLogging
  }

  // MARK: - PutUserDefinedLogFieldsConfig

  /// Serialize PutUserDefinedLogFieldsConfig request
  static Future<void> serializePutUserDefinedLogFieldsConfig(
    PutUserDefinedLogFieldsConfigRequest request,
    OperationInput input,
  ) async {
    if (request.userDefinedLogFieldsConfiguration != null) {
      final xmlData = _userDefinedLogFieldsConfigurationToXml(
        request.userDefinedLogFieldsConfiguration!,
      );
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize PutUserDefinedLogFieldsConfig result
  static Future<void> deserializePutUserDefinedLogFieldsConfig(
    PutUserDefinedLogFieldsConfigResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutUserDefinedLogFieldsConfig
  }

  // MARK: - GetUserDefinedLogFieldsConfig

  /// Serialize GetUserDefinedLogFieldsConfig request
  static Future<void> serializeGetUserDefinedLogFieldsConfig(
    GetUserDefinedLogFieldsConfigRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetUserDefinedLogFieldsConfig
  }

  /// Deserialize GetUserDefinedLogFieldsConfig result
  static Future<void> deserializeGetUserDefinedLogFieldsConfig(
    GetUserDefinedLogFieldsConfigResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'UserDefinedLogFieldsConfiguration',
    );
    result.userDefinedLogFieldsConfiguration =
        UserDefinedLogFieldsConfiguration.fromJson(body);
  }

  // MARK: - DeleteUserDefinedLogFieldsConfig

  /// Serialize DeleteUserDefinedLogFieldsConfig request
  static Future<void> serializeDeleteUserDefinedLogFieldsConfig(
    DeleteUserDefinedLogFieldsConfigRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for DeleteUserDefinedLogFieldsConfig
  }

  /// Deserialize DeleteUserDefinedLogFieldsConfig result
  static Future<void> deserializeDeleteUserDefinedLogFieldsConfig(
    DeleteUserDefinedLogFieldsConfigResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for DeleteUserDefinedLogFieldsConfig
  }

  // MARK: - Helper Methods

  /// Convert BucketLoggingStatus to XML data
  static Uint8List _bucketLoggingStatusToXml(
    BucketLoggingStatus bucketLoggingStatus,
  ) {
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<BucketLoggingStatus>';

    if (bucketLoggingStatus.loggingEnabled != null) {
      final loggingEnabled = bucketLoggingStatus.loggingEnabled!;
      xmlBody += '<LoggingEnabled>';

      if (loggingEnabled.targetBucket != null) {
        xmlBody +=
            '<TargetBucket>${loggingEnabled.targetBucket}</TargetBucket>';
      }

      if (loggingEnabled.targetPrefix != null) {
        xmlBody +=
            '<TargetPrefix>${loggingEnabled.targetPrefix}</TargetPrefix>';
      }

      xmlBody += '</LoggingEnabled>';
    }

    xmlBody += '</BucketLoggingStatus>';
    return Uint8List.fromList(utf8.encode(xmlBody));
  }

  /// Convert UserDefinedLogFieldsConfiguration to XML data
  static Uint8List _userDefinedLogFieldsConfigurationToXml(
    UserDefinedLogFieldsConfiguration config,
  ) {
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<UserDefinedLogFieldsConfiguration>';

    if (config.headerSet != null && config.headerSet!.headers != null) {
      xmlBody += '<HeaderSet>';
      for (final header in config.headerSet!.headers!) {
        xmlBody += '<header>$header</header>';
      }
      xmlBody += '</HeaderSet>';
    }

    if (config.paramSet != null && config.paramSet!.parameters != null) {
      xmlBody += '<ParamSet>';
      for (final param in config.paramSet!.parameters!) {
        xmlBody += '<parameter>$param</parameter>';
      }
      xmlBody += '</ParamSet>';
    }

    xmlBody += '</UserDefinedLogFieldsConfiguration>';
    return Uint8List.fromList(utf8.encode(xmlBody));
  }
}
