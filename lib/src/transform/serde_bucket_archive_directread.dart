import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_archive_directread.dart';
import '../transform/serde_functions.dart';

/// Extension for bucket ArchiveDirectRead operations serialization and deserialization
extension SerdeBucketArchiveDirectread on Serde {
  // MARK: - GetBucketArchiveDirectRead

  /// Serialize GetBucketArchiveDirectRead request
  static Future<void> serializeGetBucketArchiveDirectRead(
    GetBucketArchiveDirectReadRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed
  }

  /// Deserialize GetBucketArchiveDirectRead result
  static Future<void> deserializeGetBucketArchiveDirectRead(
    GetBucketArchiveDirectReadResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'ArchiveDirectReadConfiguration',
    );
    result.archiveDirectReadConfiguration =
        ArchiveDirectReadConfiguration.fromJson(body);
  }

  // MARK: - PutBucketArchiveDirectRead

  /// Serialize PutBucketArchiveDirectRead request
  static Future<void> serializePutBucketArchiveDirectRead(
    PutBucketArchiveDirectReadRequest request,
    OperationInput input,
  ) async {
    if (request.archiveDirectReadConfiguration != null) {
      final xmlData = _archiveDirectReadConfigurationToXml(
        request.archiveDirectReadConfiguration!,
      );
      input.body = ByteStream.fromData(xmlData);
    }
  }

  /// Deserialize PutBucketArchiveDirectRead result
  static Future<void> deserializePutBucketArchiveDirectRead(
    PutBucketArchiveDirectReadResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed
  }

  // MARK: - Helper Methods

  /// Convert ArchiveDirectReadConfiguration to XML data
  static Uint8List _archiveDirectReadConfigurationToXml(
    ArchiveDirectReadConfiguration configuration,
  ) {
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<ArchiveDirectReadConfiguration>';

    if (configuration.enabled != null) {
      xmlBody += '<Enabled>${configuration.enabled}</Enabled>';
    }

    xmlBody += '</ArchiveDirectReadConfiguration>';

    return Uint8List.fromList(utf8.encode(xmlBody));
  }
}
