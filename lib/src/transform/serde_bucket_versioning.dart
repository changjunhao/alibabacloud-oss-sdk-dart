import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_versioning.dart';
import '../models/model_shared.dart';
import '../models/model_bucket_basic.dart';
import 'serde_functions.dart';
import 'serde_extensions.dart';

/// Extension for bucket versioning operations serialization and deserialization
extension SerdeBucketVersioning on Serde {
  // MARK: - PutBucketVersioning

  /// Serialize PutBucketVersioning request
  static Future<void> serializePutBucketVersioning(
    PutBucketVersioningRequest request,
    OperationInput input,
  ) async {
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<VersioningConfiguration>';
    if (request.versioningConfiguration?.status != null) {
      xmlBody += '<Status>${request.versioningConfiguration!.status}</Status>';
    }
    xmlBody += '</VersioningConfiguration>';

    final xmlData = utf8.encode(xmlBody);
    input.body = ByteStream.fromData(Uint8List.fromList(xmlData));
  }

  /// Deserialize PutBucketVersioning result
  static Future<void> deserializePutBucketVersioning(
    PutBucketVersioningResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutBucketVersioning
  }

  // MARK: - GetBucketVersioning

  /// Serialize GetBucketVersioning request
  static Future<void> serializeGetBucketVersioning(
    GetBucketVersioningRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketVersioning
  }

  /// Deserialize GetBucketVersioning result
  static Future<void> deserializeGetBucketVersioning(
    GetBucketVersioningResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'VersioningConfiguration',
    );

    if (body.isNotEmpty) {
      result.versioningConfiguration = VersioningConfiguration(
        status: body['Status'] as String?,
      );
    }
  }

  // MARK: - ListObjectVersions

  /// Serialize ListObjectVersions request
  static Future<void> serializeListObjectVersions(
    ListObjectVersionsRequest request,
    OperationInput input,
  ) async {
    if (request.delimiter != null) {
      input.parameters['delimiter'] = request.delimiter!;
    }

    if (request.keyMarker != null) {
      input.parameters['key-marker'] = request.keyMarker!;
    }

    if (request.versionIdMarker != null) {
      input.parameters['version-id-marker'] = request.versionIdMarker!;
    }

    if (request.maxKeys != null) {
      input.parameters['max-keys'] = request.maxKeys.toString();
    }

    if (request.prefix != null) {
      input.parameters['prefix'] = request.prefix!;
    }

    if (request.encodingType != null) {
      input.parameters['encoding-type'] = request.encodingType!;
    }
  }

  /// Deserialize ListObjectVersions result
  static Future<void> deserializeListObjectVersions(
    ListObjectVersionsResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'ListVersionsResult',
    );

    result.name = body['Name'] as String?;
    result.prefix = body['Prefix'] as String?;
    result.keyMarker = body['KeyMarker'] as String?;
    result.nextKeyMarker = body['NextKeyMarker'] as String?;
    result.versionIdMarker = body['VersionIdMarker'] as String?;
    result.nextVersionIdMarker = body['NextVersionIdMarker'] as String?;
    result.encodingType = body['EncodingType'] as String?;
    result.delimiter = body['Delimiter'] as String?;
    result.maxKeys = (body['MaxKeys'] as String?)?.toInt();
    if (body['IsTruncated'] is String) {
      final isTruncatedString = body['IsTruncated'] as String;
      result.isTruncated = isTruncatedString.toLowerCase() == 'true';
    }

    // Handle CommonPrefixes
    List<CommonPrefix>? commonPrefixes;
    final commonPrefixData = body['CommonPrefixes'];
    if (commonPrefixData != null) {
      if (commonPrefixData is Map<String, dynamic>) {
        // Single CommonPrefix
        final prefix = commonPrefixData['Prefix'] as String?;
        if (prefix != null) {
          commonPrefixes = [CommonPrefix(prefix: prefix)];
        }
      } else if (commonPrefixData is List) {
        // Multiple CommonPrefixes
        commonPrefixes = [];
        for (final prefixData in commonPrefixData) {
          if (prefixData is Map<String, dynamic>) {
            final prefix = prefixData['Prefix'] as String?;
            if (prefix != null) {
              commonPrefixes.add(CommonPrefix(prefix: prefix));
            }
          }
        }
      }
    }
    result.commonPrefixes = commonPrefixes;

    // Handle Version (object versions)
    final versionData = body['Version'];
    if (versionData != null) {
      final objectVersions = <ObjectVersion>[];

      List<Map<String, dynamic>> versions = [];
      if (versionData is List) {
        for (final version in versionData) {
          if (version is Map<String, dynamic>) {
            versions.add(version);
          }
        }
      } else if (versionData is Map<String, dynamic>) {
        versions.add(versionData);
      }

      for (final version in versions) {
        final objectVersion = ObjectVersion();
        objectVersion.key = version['Key'] as String?;
        objectVersion.versionId = version['VersionId'] as String?;
        objectVersion.eTag = version['ETag'] as String?;
        objectVersion.restoreInfo = version['RestoreInfo'] as String?;
        objectVersion.storageClass = version['StorageClass'] as String?;
        objectVersion.size = (version['Size'] as String?)?.toInt();
        objectVersion.lastModified = (version['LastModified'] as String?)
            ?.toDate();
        objectVersion.transitionTime = (version['TransitionTime'] as String?)
            ?.toDate();
        objectVersion.isLatest = (version['IsLatest'] as String?)?.toBool();

        // Handle Owner
        final ownerData = version['Owner'];
        if (ownerData is Map<String, dynamic>) {
          objectVersion.owner = Owner(
            displayName: ownerData['DisplayName'] as String?,
            id: ownerData['ID'] as String?,
          );
        }

        objectVersions.add(objectVersion);
      }
      result.versions = objectVersions;
    }

    // Handle DeleteMarker
    final deleteMarkerData = body['DeleteMarker'];
    if (deleteMarkerData != null) {
      final deleteMarkers = <DeleteMarkerEntry>[];

      List<Map<String, dynamic>> markers = [];
      if (deleteMarkerData is List) {
        for (final marker in deleteMarkerData) {
          if (marker is Map<String, dynamic>) {
            markers.add(marker);
          }
        }
      } else if (deleteMarkerData is Map<String, dynamic>) {
        markers.add(deleteMarkerData);
      }

      for (final marker in markers) {
        final deleteMarker = DeleteMarkerEntry();
        deleteMarker.key = marker['Key'] as String?;
        deleteMarker.versionId = marker['VersionId'] as String?;
        deleteMarker.lastModified = (marker['LastModified'] as String?)
            ?.toDate();
        deleteMarker.isLatest = (marker['IsLatest'] as String?)?.toBool();

        // Handle Owner
        final ownerData = marker['Owner'];
        if (ownerData is Map<String, dynamic>) {
          deleteMarker.owner = Owner(
            displayName: ownerData['DisplayName'] as String?,
            id: ownerData['ID'] as String?,
          );
        }

        deleteMarkers.add(deleteMarker);
      }
      result.deleteMarkers = deleteMarkers;
    }

    _deserializeEncodingType(result);
  }

  /// Handle URL encoding type for ListObjectVersions result
  static void _deserializeEncodingType(ListObjectVersionsResult result) {
    if (result.encodingType != 'url') {
      return;
    }

    result.prefix = result.prefix != null
        ? Uri.decodeComponent(result.prefix!)
        : null;
    result.delimiter = result.delimiter != null
        ? Uri.decodeComponent(result.delimiter!)
        : null;
    result.nextKeyMarker = result.nextKeyMarker != null
        ? Uri.decodeComponent(result.nextKeyMarker!)
        : null;
    result.keyMarker = result.keyMarker != null
        ? Uri.decodeComponent(result.keyMarker!)
        : null;

    if (result.versions != null) {
      final decodeVersions = <ObjectVersion>[];
      for (final version in result.versions!) {
        final decodeVersion = ObjectVersion();
        decodeVersion.key = version.key != null
            ? Uri.decodeComponent(version.key!)
            : null;
        decodeVersion.versionId = version.versionId;
        decodeVersion.eTag = version.eTag;
        decodeVersion.restoreInfo = version.restoreInfo;
        decodeVersion.storageClass = version.storageClass;
        decodeVersion.size = version.size;
        decodeVersion.lastModified = version.lastModified;
        decodeVersion.transitionTime = version.transitionTime;
        decodeVersion.isLatest = version.isLatest;
        decodeVersion.owner = version.owner;
        decodeVersions.add(decodeVersion);
      }
      result.versions = decodeVersions;
    }

    if (result.deleteMarkers != null) {
      final decodeDeleteMarkers = <DeleteMarkerEntry>[];
      for (final deleteMarker in result.deleteMarkers!) {
        final decodeDeleteMarker = DeleteMarkerEntry();
        decodeDeleteMarker.key = deleteMarker.key != null
            ? Uri.decodeComponent(deleteMarker.key!)
            : null;
        decodeDeleteMarker.versionId = deleteMarker.versionId;
        decodeDeleteMarker.lastModified = deleteMarker.lastModified;
        decodeDeleteMarker.isLatest = deleteMarker.isLatest;
        decodeDeleteMarker.owner = deleteMarker.owner;
        decodeDeleteMarkers.add(decodeDeleteMarker);
      }
      result.deleteMarkers = decodeDeleteMarkers;
    }

    if (result.commonPrefixes != null) {
      final decodeCommonPrefixes = <CommonPrefix>[];
      for (final commonPrefix in result.commonPrefixes!) {
        final decodeCommonPrefix = CommonPrefix(
          prefix: commonPrefix.prefix != null
              ? Uri.decodeComponent(commonPrefix.prefix!)
              : null,
        );
        decodeCommonPrefixes.add(decodeCommonPrefix);
      }
      result.commonPrefixes = decodeCommonPrefixes;
    }
  }
}
