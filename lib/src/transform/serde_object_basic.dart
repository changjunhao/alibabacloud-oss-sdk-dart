import 'dart:convert';
import 'dart:typed_data';

import '../models/model_object_basic.dart';
import '../types/byte_stream.dart';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../utils/oss_utils.dart';
import 'serde_extensions.dart';
import 'serde_functions.dart';

/// Serialization and deserialization for basic object operations.
///
/// Handles converting request models to [OperationInput] and parsing
/// [OperationOutput] back into result models for PutObject, CopyObject,
/// GetObject, AppendObject, DeleteObject, HeadObject, GetObjectMeta,
/// DeleteMultipleObjects, RestoreObject, and CleanRestoredObject.
class SerdeObjectBasic {
  // MARK: - PutObject

  /// Serializes PutObjectRequest to OperationInput
  static void serializePutObject(
    PutObjectRequest request,
    OperationInput input,
  ) {
    if (request.forbidOverwrite != null) {
      input.headers['x-oss-forbid-overwrite'] = request.forbidOverwrite
          .toString();
    }
    if (request.serverSideEncryption != null) {
      input.headers['x-oss-server-side-encryption'] =
          request.serverSideEncryption!;
    }
    if (request.serverSideDataEncryption != null) {
      input.headers['x-oss-server-side-data-encryption'] =
          request.serverSideDataEncryption!;
    }
    if (request.serverSideEncryptionKeyId != null) {
      input.headers['x-oss-server-side-encryption-key-id'] =
          request.serverSideEncryptionKeyId!;
    }
    if (request.objectAcl != null) {
      input.headers['x-oss-object-acl'] = request.objectAcl!;
    }
    if (request.storageClass != null) {
      input.headers['x-oss-storage-class'] = request.storageClass!;
    }
    if (request.tagging != null) {
      input.headers['x-oss-tagging'] = request.tagging!;
    }
    if (request.cacheControl != null) {
      input.headers['Cache-Control'] = request.cacheControl!;
    }
    if (request.contentDisposition != null) {
      input.headers['Content-Disposition'] = request.contentDisposition!;
    }
    if (request.contentEncoding != null) {
      input.headers['Content-Encoding'] = request.contentEncoding!;
    }
    if (request.expires != null) {
      input.headers['Expires'] = request.expires!;
    }
    if (request.contentMd5 != null) {
      input.headers['Content-MD5'] = request.contentMd5!;
    }
    if (request.contentType != null) {
      input.headers['Content-Type'] = request.contentType!;
    }
    if (request.callback != null) {
      input.headers['x-oss-callback'] = request.callback!;
    }
    if (request.callbackVar != null) {
      input.headers['x-oss-callback-var'] = request.callbackVar!;
    }
    if (request.trafficLimit != null) {
      input.headers['x-oss-traffic-limit'] = request.trafficLimit.toString();
    }

    if (request.metadata != null) {
      for (final entry in request.metadata!.entries) {
        input.headers['x-oss-meta-${entry.key}'] = entry.value;
      }
    }

    input.body = request.body;
  }

  /// Deserializes OperationOutput to PutObjectResult
  static Future<void> deserializePutObject(
    PutObjectResult result,
    OperationOutput output,
  ) async {
    if (output.body != null) {
      final data = await output.body!.readData();
      if (data != null) {
        result.callbackResult = String.fromCharCodes(data);
      }
    }
  }

  // MARK: - CopyObject

  /// Serializes CopyObjectRequest to OperationInput
  static void serializeCopyObject(
    CopyObjectRequest request,
    OperationInput input,
  ) {
    if (request.sourceBucket != null && request.sourceKey != null) {
      input.headers['x-oss-copy-source'] =
          '/${request.sourceBucket}/${request.sourceKey}';
    }

    if (request.forbidOverwrite != null) {
      input.headers['x-oss-forbid-overwrite'] = request.forbidOverwrite
          .toString();
    }

    if (request.copySourceIfMatch != null) {
      input.headers['x-oss-copy-source-if-match'] = request.copySourceIfMatch!;
    }

    if (request.copySourceIfNoneMatch != null) {
      input.headers['x-oss-copy-source-if-none-match'] =
          request.copySourceIfNoneMatch!;
    }

    if (request.copySourceIfUnmodifiedSince != null) {
      input.headers['x-oss-copy-source-if-unmodified-since'] =
          request.copySourceIfUnmodifiedSince!;
    }

    if (request.copySourceIfModifiedSince != null) {
      input.headers['x-oss-copy-source-if-modified-since'] =
          request.copySourceIfModifiedSince!;
    }

    if (request.metadataDirective != null) {
      input.headers['x-oss-metadata-directive'] = request.metadataDirective!;
    }

    if (request.serverSideEncryption != null) {
      input.headers['x-oss-server-side-encryption'] =
          request.serverSideEncryption!;
    }

    if (request.serverSideDataEncryption != null) {
      input.headers['x-oss-server-side-data-encryption'] =
          request.serverSideDataEncryption!;
    }

    if (request.serverSideEncryptionKeyId != null) {
      input.headers['x-oss-server-side-encryption-key-id'] =
          request.serverSideEncryptionKeyId!;
    }

    if (request.objectAcl != null) {
      input.headers['x-oss-object-acl'] = request.objectAcl!;
    }

    if (request.storageClass != null) {
      input.headers['x-oss-storage-class'] = request.storageClass!;
    }

    if (request.tagging != null) {
      input.headers['x-oss-tagging'] = request.tagging!;
    }

    if (request.taggingDirective != null) {
      input.headers['x-oss-tagging-directive'] = request.taggingDirective!;
    }

    if (request.cacheControl != null) {
      input.headers['Cache-Control'] = request.cacheControl!;
    }

    if (request.contentDisposition != null) {
      input.headers['Content-Disposition'] = request.contentDisposition!;
    }

    if (request.contentEncoding != null) {
      input.headers['Content-Encoding'] = request.contentEncoding!;
    }

    if (request.expires != null) {
      input.headers['Expires'] = request.expires!;
    }

    if (request.contentMd5 != null) {
      input.headers['Content-MD5'] = request.contentMd5!;
    }

    if (request.contentType != null) {
      input.headers['Content-Type'] = request.contentType!;
    }

    if (request.trafficLimit != null) {
      input.headers['x-oss-traffic-limit'] = request.trafficLimit.toString();
    }

    if (request.metadata != null) {
      for (final entry in request.metadata!.entries) {
        input.headers['x-oss-meta-${entry.key}'] = entry.value;
      }
    }
  }

  /// Deserializes OperationOutput to CopyObjectResult
  static Future<void> deserializeCopyObject(
    CopyObjectResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'CopyObjectResult',
    );

    result.etag = body['ETag'] as String?;
    if (body['LastModified'] != null) {
      result.lastModified = body['LastModified'] as String?;
    }
  }

  // MARK: - GetObject

  /// Serializes GetObjectRequest to OperationInput
  static void serializeGetObject(
    GetObjectRequest request,
    OperationInput input,
  ) {
    if (request.range != null) {
      input.headers['Range'] = request.range!;
    }
    if (request.rangeBehavior != null) {
      input.headers['x-oss-range-behavior'] = request.rangeBehavior!;
    }
    if (request.ifModifiedSince != null) {
      input.headers['If-Modified-Since'] = request.ifModifiedSince!;
    }
    if (request.ifUnmodifiedSince != null) {
      input.headers['If-Unmodified-Since'] = request.ifUnmodifiedSince!;
    }
    if (request.ifMatch != null) {
      input.headers['If-Match'] = request.ifMatch!;
    }
    if (request.ifNoneMatch != null) {
      input.headers['If-None-Match'] = request.ifNoneMatch!;
    }
    if (request.acceptEncoding != null) {
      input.headers['Accept-Encoding'] = request.acceptEncoding!;
    }
    if (request.responseContentType != null) {
      input.parameters['response-content-type'] = request.responseContentType!;
    }
    if (request.responseContentLanguage != null) {
      input.parameters['response-content-language'] =
          request.responseContentLanguage!;
    }
    if (request.responseExpires != null) {
      input.parameters['response-expires'] = request.responseExpires!;
    }
    if (request.responseCacheControl != null) {
      input.parameters['response-cache-control'] =
          request.responseCacheControl!;
    }
    if (request.responseContentDisposition != null) {
      input.parameters['response-content-disposition'] =
          request.responseContentDisposition!;
    }
    if (request.responseContentEncoding != null) {
      input.parameters['response-content-encoding'] =
          request.responseContentEncoding!;
    }
    if (request.versionId != null) {
      input.parameters['versionId'] = request.versionId!;
    }
    if (request.trafficLimit != null) {
      input.headers['x-oss-traffic-limit'] = request.trafficLimit.toString();
    }
    if (request.process != null) {
      input.headers['x-oss-process'] = request.process!;
    }
  }

  /// Deserializes OperationOutput to GetObjectResult
  static Future<void> deserializeGetObject(
    GetObjectResult result,
    OperationOutput output,
  ) async {
    result.body = output.body;
  }

  // MARK: - AppendObject

  /// Serializes AppendObjectRequest to OperationInput
  static void serializeAppendObject(
    AppendObjectRequest request,
    OperationInput input,
  ) {
    if (request.serverSideEncryption != null) {
      input.headers['x-oss-server-side-encryption'] =
          request.serverSideEncryption!;
    }

    if (request.objectAcl != null) {
      input.headers['x-oss-object-acl'] = request.objectAcl!;
    }

    if (request.storageClass != null) {
      input.headers['x-oss-storage-class'] = request.storageClass!;
    }

    if (request.metadata != null) {
      for (final entry in request.metadata!.entries) {
        input.headers['x-oss-meta-${entry.key}'] = entry.value;
      }
    }

    if (request.cacheControl != null) {
      input.headers['Cache-Control'] = request.cacheControl!;
    }

    if (request.contentDisposition != null) {
      input.headers['Content-Disposition'] = request.contentDisposition!;
    }

    if (request.contentEncoding != null) {
      input.headers['Content-Encoding'] = request.contentEncoding!;
    }

    if (request.contentMd5 != null) {
      input.headers['Content-MD5'] = request.contentMd5!;
    }

    if (request.contentType != null) {
      input.headers['Content-Type'] = request.contentType!;
    }

    if (request.expires != null) {
      input.headers['Expires'] = request.expires!;
    }

    if (request.position != null) {
      input.parameters['position'] = request.position.toString();
    }

    if (request.trafficLimit != null) {
      input.headers['x-oss-traffic-limit'] = request.trafficLimit.toString();
    }

    input.body = request.body;
  }

  /// Deserializes OperationOutput to AppendObjectResult
  static Future<void> deserializeAppendObject(
    AppendObjectResult result,
    OperationOutput output,
  ) async {
    // No deserialization needed for AppendObject
  }

  // MARK: - DeleteObject

  /// Serializes DeleteObjectRequest to OperationInput
  static void serializeDeleteObject(
    DeleteObjectRequest request,
    OperationInput input,
  ) {
    if (request.versionId != null) {
      input.parameters['versionId'] = request.versionId!;
    }
  }

  /// Deserializes OperationOutput to DeleteObjectResult
  static Future<void> deserializeDeleteObject(
    DeleteObjectResult result,
    OperationOutput output,
  ) async {
    // No deserialization needed for DeleteObject
  }

  // MARK: - HeadObject

  /// Serializes HeadObjectRequest to OperationInput
  static void serializeHeadObject(
    HeadObjectRequest request,
    OperationInput input,
  ) {
    if (request.ifModifiedSince != null) {
      input.headers['If-Modified-Since'] = request.ifModifiedSince!;
    }
    if (request.ifUnmodifiedSince != null) {
      input.headers['If-Unmodified-Since'] = request.ifUnmodifiedSince!;
    }
    if (request.ifMatch != null) {
      input.headers['If-Match'] = request.ifMatch!;
    }
    if (request.ifNoneMatch != null) {
      input.headers['If-None-Match'] = request.ifNoneMatch!;
    }
    if (request.versionId != null) {
      input.parameters['versionId'] = request.versionId!;
    }
  }

  /// Deserializes OperationOutput to HeadObjectResult
  static Future<void> deserializeHeadObject(
    HeadObjectResult result,
    OperationOutput output,
  ) async {
    // No deserialization needed for HeadObject
  }

  // MARK: - GetObjectMeta

  /// Serializes GetObjectMetaRequest to OperationInput
  static void serializeGetObjectMeta(
    GetObjectMetaRequest request,
    OperationInput input,
  ) {
    if (request.versionId != null) {
      input.parameters['versionId'] = request.versionId!;
    }
  }

  /// Deserializes OperationOutput to GetObjectMetaResult
  static Future<void> deserializeGetObjectMeta(
    GetObjectMetaResult result,
    OperationOutput output,
  ) async {
    // No deserialization needed for GetObjectMeta
  }

  // MARK: - DeleteMultipleObjects

  /// Serializes DeleteMultipleObjectsRequest to OperationInput
  static void serializeDeleteMultipleObjects(
    DeleteMultipleObjectsRequest request,
    OperationInput input,
  ) {
    if (request.encodingType != null) {
      input.headers['Encoding-Type'] = request.encodingType!;
    }

    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<Delete>';
    if (request.quiet != null) {
      xmlBody += '<Quiet>${request.quiet}</Quiet>';
    }
    if (request.objects != null) {
      for (final object in request.objects!) {
        if (object.key != null) {
          xmlBody += '<Object><Key>${object.key!.escape()}</Key>';
          if (object.versionId != null) {
            xmlBody += '<VersionId>${object.versionId}</VersionId>';
          }
          xmlBody += '</Object>';
        }
      }
    }
    xmlBody += '</Delete>';

    final xmlData = utf8.encode(xmlBody);
    input.body = ByteStream.fromData(Uint8List.fromList(xmlData));
  }

  /// Deserializes OperationOutput to DeleteMultipleObjectsResult
  static Future<void> deserializeDeleteMultipleObjects(
    DeleteMultipleObjectsResult result,
    OperationOutput output,
  ) async {
    final deleteResult =
        await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
          output.body,
          'DeleteResult',
        );

    result.encodingType = deleteResult['EncodingType'] as String?;
    final deleted = deleteResult['Deleted'];
    if (deleted != null) {
      final deletedObjects = <DeletedInfo>[];

      if (deleted is List) {
        // Multiple deleted objects
        for (final object in deleted) {
          if (object is Map<String, dynamic>) {
            final key = object['Key'] as String?;
            if (key != null) {
              var deletedObject = DeletedInfo(
                key: key,
                versionId: object['VersionId'] as String?,
                deleteMarker: (object['DeleteMarker'] as String?)?.toBool(),
                deleteMarkerVersionId:
                    object['DeleteMarkerVersionId'] as String?,
              );

              if (result.encodingType == 'url') {
                deletedObject.key = Uri.decodeComponent(
                  deletedObject.key ?? '',
                );
              }

              deletedObjects.add(deletedObject);
            }
          }
        }
      } else if (deleted is Map<String, dynamic>) {
        // Single deleted object
        final key = deleted['Key'] as String?;
        if (key != null) {
          var deletedObject = DeletedInfo(
            key: key,
            versionId: deleted['VersionId'] as String?,
            deleteMarker: (deleted['DeleteMarker'] as String?)?.toBool(),
            deleteMarkerVersionId: deleted['DeleteMarkerVersionId'] as String?,
          );

          if (result.encodingType == 'url') {
            deletedObject.key = Uri.decodeComponent(deletedObject.key ?? '');
          }

          deletedObjects.add(deletedObject);
        }
      }

      result.deletedObjects = deletedObjects;
    }
  }

  // MARK: - RestoreObject

  /// Serializes RestoreObjectRequest to OperationInput
  static void serializeRestoreObject(
    RestoreObjectRequest request,
    OperationInput input,
  ) {
    if (request.versionId != null) {
      input.parameters['versionId'] = request.versionId!;
    }

    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<RestoreRequest>';
    if (request.restoreRequest?.days != null) {
      xmlBody += '<Days>${request.restoreRequest!.days}</Days>';
    }
    if (request.restoreRequest?.jobParameters?.tier != null) {
      xmlBody +=
          '<JobParameters><Tier>${request.restoreRequest!.jobParameters!.tier}</Tier></JobParameters>';
    }
    xmlBody += '</RestoreRequest>';

    final xmlData = utf8.encode(xmlBody);
    input.body = ByteStream.fromData(Uint8List.fromList(xmlData));
  }

  /// Deserializes OperationOutput to RestoreObjectResult
  static Future<void> deserializeRestoreObject(
    RestoreObjectResult result,
    OperationOutput output,
  ) async {
    // No deserialization needed for RestoreObject
  }

  // MARK: - CleanRestoredObject

  /// Serializes CleanRestoredObjectRequest to OperationInput
  static void serializeCleanRestoredObject(
    CleanRestoredObjectRequest request,
    OperationInput input,
  ) {
    // No serialization needed for CleanRestoredObject
  }

  /// Deserializes OperationOutput to CleanRestoredObjectResult
  static Future<void> deserializeCleanRestoredObject(
    CleanRestoredObjectResult result,
    OperationOutput output,
  ) async {
    // No deserialization needed for CleanRestoredObject
  }
}
