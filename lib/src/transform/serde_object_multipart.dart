import 'dart:convert';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_object_multipart.dart';
import '../models/model_bucket_basic.dart';
import 'serde_extensions.dart';
import 'serde_functions.dart';

/// Serialization functions for multipart upload operations
class SerdeObjectMultipart {
  // MARK: - InitiateMultipartUpload
  /// Serialize InitiateMultipartUpload request
  static Future<void> serializeInitiateMultipartUpload(
    InitiateMultipartUploadRequest request,
    OperationInput input,
  ) async {
    // Set forbid-overwrite header
    if (request.forbidOverwrite != null) {
      input.headers['x-oss-forbid-overwrite'] = request.forbidOverwrite!
          .toStringValue();
    }

    // Set storage class header
    if (request.storageClass != null) {
      input.headers['x-oss-storage-class'] = request.storageClass!;
    }

    // Set tagging header
    if (request.tagging != null) {
      input.headers['x-oss-tagging'] = request.tagging!;
    }

    // Set server-side encryption header
    if (request.serverSideEncryption != null) {
      input.headers['x-oss-server-side-encryption'] =
          request.serverSideEncryption!;
    }

    // Set server-side data encryption header
    if (request.serverSideDataEncryption != null) {
      input.headers['x-oss-server-side-data-encryption'] =
          request.serverSideDataEncryption!;
    }

    // Set server-side encryption key ID header
    if (request.serverSideEncryptionKeyId != null) {
      input.headers['x-oss-server-side-encryption-key-id'] =
          request.serverSideEncryptionKeyId!;
    }

    // Set cache control header
    if (request.cacheControl != null) {
      input.headers['Cache-Control'] = request.cacheControl!;
    }

    // Set content disposition header
    if (request.contentDisposition != null) {
      input.headers['Content-Disposition'] = request.contentDisposition!;
    }

    // Set content encoding header
    if (request.contentEncoding != null) {
      input.headers['Content-Encoding'] = request.contentEncoding!;
    }

    // Set expires header
    if (request.expires != null) {
      input.headers['Expires'] = request.expires!;
    }

    // Set encoding type parameter
    if (request.encodingType != null) {
      input.parameters['encoding-type'] = request.encodingType!;
    }
  }

  /// Deserialize InitiateMultipartUpload result
  static Future<void> deserializeInitiateMultipartUpload(
    InitiateMultipartUploadResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'InitiateMultipartUploadResult',
    );

    result.uploadId = body['UploadId'] as String?;
    result.bucket = body['Bucket'] as String?;
    result.key = body['Key'] as String?;
    result.encodingType = body['EncodingType'] as String?;

    _deserializeInitiateMultipartUploadEncodingType(result);
  }

  /// Handle encoding type for InitiateMultipartUpload result
  static void _deserializeInitiateMultipartUploadEncodingType(
    InitiateMultipartUploadResult result,
  ) {
    if (result.encodingType == 'url') {
      result.key = Uri.decodeComponent(result.key ?? '');
    }
  }

  // MARK: - UploadPartCopy
  /// Serialize UploadPartCopy request
  static Future<void> serializeUploadPartCopy(
    UploadPartCopyRequest request,
    OperationInput input,
  ) async {
    // Set copy source header
    if (request.sourceBucket != null && request.sourceKey != null) {
      input.headers['x-oss-copy-source'] =
          '/${request.sourceBucket}/${request.sourceKey}';
    }

    // Set copy source range header
    if (request.copySourceRange != null) {
      input.headers['x-oss-copy-source-range'] = request.copySourceRange!;
    }

    // Set copy source if match header
    if (request.copySourceIfMatch != null) {
      input.headers['x-oss-copy-source-if-match'] = request.copySourceIfMatch!;
    }

    // Set copy source if none match header
    if (request.copySourceIfNoneMatch != null) {
      input.headers['x-oss-copy-source-if-none-match'] =
          request.copySourceIfNoneMatch!;
    }

    // Set copy source if unmodified since header
    if (request.copySourceIfUnmodifiedSince != null) {
      input.headers['x-oss-copy-source-if-unmodified-since'] =
          request.copySourceIfUnmodifiedSince!;
    }

    // Set copy source if modified since header
    if (request.copySourceIfModifiedSince != null) {
      input.headers['x-oss-copy-source-if-modified-since'] =
          request.copySourceIfModifiedSince!;
    }

    // Set part number parameter
    if (request.partNumber != null) {
      input.parameters['partNumber'] = request.partNumber!.toString();
    }

    // Set upload ID parameter
    if (request.uploadId != null) {
      input.parameters['uploadId'] = request.uploadId!;
    }
  }

  /// Deserialize UploadPartCopy result
  static Future<void> deserializeUploadPartCopy(
    UploadPartCopyResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'CopyPartResult',
    );

    final copyPartResult = CopyPartResult(
      etag: body['ETag'] as String?,
      lastModified: (body['LastModified'] as String?)?.toDate(),
    );

    result.copyPartResult = copyPartResult;
  }

  // MARK: - UploadPart
  /// Serialize UploadPart request
  static Future<void> serializeUploadPart(
    UploadPartRequest request,
    OperationInput input,
  ) async {
    // Set part number parameter
    if (request.partNumber != null) {
      input.parameters['partNumber'] = request.partNumber!.toString();
    }

    // Set upload ID parameter
    if (request.uploadId != null) {
      input.parameters['uploadId'] = request.uploadId!;
    }

    // Set request body
    input.body = request.body;
  }

  /// Deserialize UploadPart result
  static Future<void> deserializeUploadPart(
    UploadPartResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for UploadPart
    // The ETag is automatically handled by the result model's getter
  }

  // MARK: - CompleteMultipartUpload
  /// Serialize CompleteMultipartUpload request
  static Future<void> serializeCompleteMultipartUpload(
    CompleteMultipartUploadRequest request,
    OperationInput input,
  ) async {
    // Set forbid-overwrite header
    if (request.forbidOverwrite != null) {
      input.headers['x-oss-forbid-overwrite'] = request.forbidOverwrite!
          .toStringValue();
    }

    // Set complete-all header
    if (request.completeAll != null) {
      input.headers['x-oss-complete-all'] = request.completeAll!;
    }

    if (request.callback != null) {
      input.headers['x-oss-callback'] = request.callback!;
    }

    if (request.callbackVar != null) {
      input.headers['x-oss-callback-var'] = request.callbackVar!;
    }

    // Set upload ID parameter
    if (request.uploadId != null) {
      input.parameters['uploadId'] = request.uploadId!;
    }

    // Set encoding type parameter
    if (request.encodingType != null) {
      input.parameters['encoding-type'] = request.encodingType!;
    }

    // Generate XML body for parts
    if (request.completeMultipartUpload?.parts != null) {
      final parts = request.completeMultipartUpload!.parts!;
      var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
      xmlBody += '<CompleteMultipartUpload>';

      for (final part in parts) {
        if (part.partNumber != null && part.etag != null) {
          xmlBody += '<Part>';
          xmlBody += '<PartNumber>${part.partNumber}</PartNumber>';
          xmlBody += '<ETag>${part.etag}</ETag>';
          xmlBody += '</Part>';
        }
      }

      xmlBody += '</CompleteMultipartUpload>';
      input.body = ByteStream.fromData(utf8.encode(xmlBody));
    }
  }

  /// Deserialize CompleteMultipartUpload result
  static Future<void> deserializeCompleteMultipartUpload(
    CompleteMultipartUploadResult result,
    OperationOutput output,
  ) async {
    // Check for callback result in headers
    final callbackResult = output.headers.getCaseInsensitive('x-oss-callback');
    if (callbackResult != null) {
      result.callbackResult = base64Decode(callbackResult);
    } else {
      // Parse XML response body
      final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
        output.body,
        'CompleteMultipartUploadResult',
      );

      result.bucket = body['Bucket'] as String?;
      result.key = body['Key'] as String?;
      result.etag = body['ETag'] as String?;
      result.location = body['Location'] as String?;
      result.encodingType = body['EncodingType'] as String?;

      // Handle URL encoding
      if (result.encodingType == 'url') {
        result.key = Uri.decodeComponent(result.key ?? '');
      }
    }
  }

  // MARK: - AbortMultipartUpload
  /// Serialize AbortMultipartUpload request
  static Future<void> serializeAbortMultipartUpload(
    AbortMultipartUploadRequest request,
    OperationInput input,
  ) async {
    // Set upload ID parameter
    if (request.uploadId != null) {
      input.parameters['uploadId'] = request.uploadId!;
    }
  }

  /// Deserialize AbortMultipartUpload result
  static Future<void> deserializeAbortMultipartUpload(
    AbortMultipartUploadResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for AbortMultipartUpload
  }

  // MARK: - ListMultipartUploads
  /// Serialize ListMultipartUploads request
  static Future<void> serializeListMultipartUploads(
    ListMultipartUploadsRequest request,
    OperationInput input,
  ) async {
    // Set delimiter parameter
    if (request.delimiter != null) {
      input.parameters['delimiter'] = request.delimiter!;
    }

    // Set max-uploads parameter
    if (request.maxUploads != null) {
      input.parameters['max-uploads'] = request.maxUploads!.toString();
    }

    // Set key-marker parameter
    if (request.keyMarker != null) {
      input.parameters['key-marker'] = request.keyMarker!;
    }

    // Set prefix parameter
    if (request.prefix != null) {
      input.parameters['prefix'] = request.prefix!;
    }

    // Set upload-id-marker parameter
    if (request.uploadIdMarker != null) {
      input.parameters['upload-id-marker'] = request.uploadIdMarker!;
    }

    // Set encoding-type parameter
    if (request.encodingType != null) {
      input.parameters['encoding-type'] = request.encodingType!;
    }
  }

  /// Deserialize ListMultipartUploads result
  static Future<void> deserializeListMultipartUploads(
    ListMultipartUploadsResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'ListMultipartUploadsResult',
    );

    result.isTruncated = (body['IsTruncated'] as String?)?.toBool();
    result.bucket = body['Bucket'] as String?;
    result.keyMarker = body['KeyMarker'] as String?;
    result.uploadIdMarker = body['UploadIdMarker'] as String?;
    result.nextKeyMarker = body['NextKeyMarker'] as String?;
    result.nextUploadIdMarker = body['NextUploadIdMarker'] as String?;
    result.delimiter = body['Delimiter'] as String?;
    result.prefix = body['Prefix'] as String?;
    result.encodingType = body['EncodingType'] as String?;
    result.maxUploads = (body['MaxUploads'] as String?)?.toInt();

    // Handle CommonPrefixes
    final commonPrefixData = body['CommonPrefixes'];
    List<CommonPrefix>? commonPrefixes;
    if (commonPrefixData is Map<String, dynamic>) {
      // Single CommonPrefix
      final prefix = commonPrefixData['Prefix'] as String?;
      if (prefix != null) {
        commonPrefixes = [CommonPrefix(prefix: prefix)];
      }
    } else if (commonPrefixData is List) {
      // Multiple CommonPrefixes
      commonPrefixes = [];
      for (final prefixElement in commonPrefixData) {
        if (prefixElement is Map<String, dynamic>) {
          final prefix = prefixElement['Prefix'] as String?;
          if (prefix != null) {
            commonPrefixes.add(CommonPrefix(prefix: prefix));
          }
        }
      }
    }
    result.commonPrefixes = commonPrefixes;

    // Handle Uploads
    final uploadData = body['Upload'];
    List<Upload> uploads = [];
    if (uploadData is Map<String, dynamic>) {
      // Single Upload
      final key = uploadData['Key'] as String?;
      final uploadId = uploadData['UploadId'] as String?;
      if (key != null && uploadId != null) {
        final initiated = (uploadData['Initiated'] as String?)?.toDate();
        uploads.add(Upload(initiated: initiated, key: key, uploadId: uploadId));
      }
    } else if (uploadData is List) {
      // Multiple Uploads
      for (final uploadElement in uploadData) {
        if (uploadElement is Map<String, dynamic>) {
          final key = uploadElement['Key'] as String?;
          final uploadId = uploadElement['UploadId'] as String?;
          if (key != null && uploadId != null) {
            final initiated = (uploadElement['Initiated'] as String?)?.toDate();
            uploads.add(
              Upload(initiated: initiated, key: key, uploadId: uploadId),
            );
          }
        }
      }
    }
    result.uploads = uploads;

    _deserializeListMultipartUploadsEncodingType(result);
  }

  /// Handle encoding type for ListMultipartUploads result
  static void _deserializeListMultipartUploadsEncodingType(
    ListMultipartUploadsResult result,
  ) {
    if (result.encodingType == 'url') {
      result.prefix = result.prefix != null
          ? Uri.decodeComponent(result.prefix!)
          : null;
      result.keyMarker = result.keyMarker != null
          ? Uri.decodeComponent(result.keyMarker!)
          : null;
      result.nextKeyMarker = result.nextKeyMarker != null
          ? Uri.decodeComponent(result.nextKeyMarker!)
          : null;
      result.delimiter = result.delimiter != null
          ? Uri.decodeComponent(result.delimiter!)
          : null;

      if (result.uploads != null) {
        final decodedUploads = <Upload>[];
        for (final upload in result.uploads!) {
          decodedUploads.add(
            Upload(
              initiated: upload.initiated,
              key: upload.key != null ? Uri.decodeComponent(upload.key!) : null,
              uploadId: upload.uploadId,
            ),
          );
        }
        result.uploads = decodedUploads;
      }
    }
  }

  // MARK: - ListParts
  /// Serialize ListParts request
  static Future<void> serializeListParts(
    ListPartsRequest request,
    OperationInput input,
  ) async {
    // Set upload ID parameter
    if (request.uploadId != null) {
      input.parameters['uploadId'] = request.uploadId!;
    }

    // Set max-parts parameter
    if (request.maxParts != null) {
      input.parameters['max-parts'] = request.maxParts!.toString();
    }

    // Set part-number-marker parameter
    if (request.partNumberMarker != null) {
      input.parameters['part-number-marker'] = request.partNumberMarker!
          .toString();
    }

    // Set encoding-type parameter
    if (request.encodingType != null) {
      input.parameters['encoding-type'] = request.encodingType!;
    }
  }

  /// Deserialize ListParts result
  static Future<void> deserializeListParts(
    ListPartsResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'ListPartsResult',
    );

    result.bucket = body['Bucket'] as String?;
    result.key = body['Key'] as String?;
    result.uploadId = body['UploadId'] as String?;
    result.encodingType = body['EncodingType'] as String?;
    result.isTruncated = (body['IsTruncated'] as String?)?.toBool();
    result.partNumberMarker = (body['PartNumberMarker'] as String?)?.toInt();
    result.nextPartNumberMarker = (body['NextPartNumberMarker'] as String?)
        ?.toInt();
    result.maxParts = (body['MaxParts'] as String?)?.toInt();

    // Handle Parts
    final partData = body['Part'];
    List<Part> parts = [];
    if (partData is Map<String, dynamic>) {
      // Single Part
      final etag = partData['ETag'] as String?;
      final hashCrc64 = partData['HashCrc64'] as String?;
      final partNumber = (partData['PartNumber'] as String?)?.toInt();
      final size = (partData['Size'] as String?)?.toInt();
      final lastModified = (partData['LastModified'] as String?)?.toDate();

      parts.add(
        Part(
          etag: etag,
          hashCrc64: hashCrc64,
          partNumber: partNumber,
          size: size,
          lastModified: lastModified,
        ),
      );
    } else if (partData is List) {
      // Multiple Parts
      for (final partElement in partData) {
        if (partElement is Map<String, dynamic>) {
          final etag = partElement['ETag'] as String?;
          final hashCrc64 = partElement['HashCrc64'] as String?;
          final partNumber = (partElement['PartNumber'] as String?)?.toInt();
          final size = (partElement['Size'] as String?)?.toInt();
          final lastModified = (partElement['LastModified'] as String?)
              ?.toDate();

          parts.add(
            Part(
              etag: etag,
              hashCrc64: hashCrc64,
              partNumber: partNumber,
              size: size,
              lastModified: lastModified,
            ),
          );
        }
      }
    }
    result.parts = parts;

    _deserializeListPartsEncodingType(result);
  }

  /// Handle encoding type for ListParts result
  static void _deserializeListPartsEncodingType(ListPartsResult result) {
    if (result.encodingType == 'url') {
      result.key = result.key != null ? Uri.decodeComponent(result.key!) : null;
    }
  }
}
