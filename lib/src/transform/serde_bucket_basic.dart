import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_bucket_basic.dart';
import '../models/model_shared.dart';
import 'serde_functions.dart';
import 'serde_extensions.dart';

/// Extension for bucket basic operations serialization and deserialization
extension SerdeBucketBasic on Serde {
  // MARK: - PutBucket

  /// Serialize PutBucket request
  static Future<void> serializePutBucket(
    PutBucketRequest request,
    OperationInput input,
  ) async {
    // Set ACL header if provided
    if (request.acl != null) {
      input.headers['x-oss-acl'] = request.acl!;
    }

    // Set resource group ID header if provided
    if (request.resourceGroupId != null) {
      input.headers['x-oss-resource-group-id'] = request.resourceGroupId!;
    }

    // Set bucket tagging header if provided
    if (request.bucketTagging != null) {
      input.headers['x-oss-bucket-tagging'] = request.bucketTagging!;
    }

    // Build XML body for CreateBucketConfiguration
    var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';
    xmlBody += '<CreateBucketConfiguration>';

    if (request.createBucketConfiguration?.storageClass != null) {
      xmlBody +=
          '<StorageClass>${request.createBucketConfiguration!.storageClass}</StorageClass>';
    }

    if (request.createBucketConfiguration?.dataRedundancyType != null) {
      xmlBody +=
          '<DataRedundancyType>${request.createBucketConfiguration!.dataRedundancyType}</DataRedundancyType>';
    }

    xmlBody += '</CreateBucketConfiguration>';

    // Set the body as ByteStream
    final xmlData = utf8.encode(xmlBody);
    input.body = ByteStream.fromData(Uint8List.fromList(xmlData));
  }

  /// Deserialize PutBucket result
  static Future<void> deserializePutBucket(
    PutBucketResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for PutBucket
  }

  // MARK: - DeleteBucket

  /// Serialize DeleteBucket request
  static Future<void> serializeDeleteBucket(
    DeleteBucketRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for DeleteBucket
  }

  /// Deserialize DeleteBucket result
  static Future<void> deserializeDeleteBucket(
    DeleteBucketResult result,
    OperationOutput output,
  ) async {
    // No additional deserialization needed for DeleteBucket
  }

  // MARK: - GetBucketStat

  /// Serialize GetBucketStat request
  static Future<void> serializeGetBucketStat(
    GetBucketStatRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketStat
  }

  /// Deserialize GetBucketStat result
  static Future<void> deserializeGetBucketStat(
    GetBucketStatResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'BucketStat',
    );

    final bucketStat = BucketStat(
      storage: (body['Storage'] as String?)?.toInt(),
      deleteMarkerCount: (body['DeleteMarkerCount'] as String?)?.toInt(),
      objectCount: (body['ObjectCount'] as String?)?.toInt(),
      lastModifiedTime: (body['LastModifiedTime'] as String?)?.toInt(),
      multipartUploadCount: (body['MultipartUploadCount'] as String?)?.toInt(),
      multipartPartCount: (body['MultipartPartCount'] as String?)?.toInt(),
      liveChannelCount: (body['LiveChannelCount'] as String?)?.toInt(),
      standardStorage: (body['StandardStorage'] as String?)?.toInt(),
      standardObjectCount: (body['StandardObjectCount'] as String?)?.toInt(),
      infrequentAccessStorage: (body['InfrequentAccessStorage'] as String?)
          ?.toInt(),
      infrequentAccessObjectCount:
          (body['InfrequentAccessObjectCount'] as String?)?.toInt(),
      infrequentAccessRealStorage:
          (body['InfrequentAccessRealStorage'] as String?)?.toInt(),
      archiveStorage: (body['ArchiveStorage'] as String?)?.toInt(),
      archiveObjectCount: (body['ArchiveObjectCount'] as String?)?.toInt(),
      archiveRealStorage: (body['ArchiveRealStorage'] as String?)?.toInt(),
      coldArchiveStorage: (body['ColdArchiveStorage'] as String?)?.toInt(),
      coldArchiveObjectCount: (body['ColdArchiveObjectCount'] as String?)
          ?.toInt(),
      coldArchiveRealStorage: (body['ColdArchiveRealStorage'] as String?)
          ?.toInt(),
      deepColdArchiveRealStorage:
          (body['DeepColdArchiveRealStorage'] as String?)?.toInt(),
      deepColdArchiveObjectCount:
          (body['DeepColdArchiveObjectCount'] as String?)?.toInt(),
      deepColdArchiveStorage: (body['DeepColdArchiveStorage'] as String?)
          ?.toInt(),
    );

    result.bucketStat = bucketStat;
  }

  // MARK: - ListObjects

  /// Serialize ListObjects request
  static Future<void> serializeListObjects(
    ListObjectsRequest request,
    OperationInput input,
  ) async {
    if (request.delimiter != null) {
      input.parameters['delimiter'] = request.delimiter!;
    }

    if (request.marker != null) {
      input.parameters['marker'] = request.marker!;
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

  /// Deserialize ListObjects result
  static Future<void> deserializeListObjects(
    ListObjectsResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'ListBucketResult',
    );

    result.name = body['Name'] as String?;
    if (body['IsTruncated'] is String) {
      final isTruncatedString = body['IsTruncated'] as String;
      result.isTruncated = isTruncatedString.toLowerCase() == 'true';
    }
    result.marker = body['Marker'] as String?;
    result.nextMarker = body['NextMarker'] as String?;
    result.prefix = body['Prefix'] as String?;
    result.delimiter = body['Delimiter'] as String?;
    result.encodingType = body['EncodingType'] as String?;
    result.maxKeys = (body['MaxKeys'] as String?)?.toInt();

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

    // Handle Contents
    List<ObjectSummary>? contentObjects;
    final contents = body['Contents'];
    if (contents != null) {
      contentObjects = [];

      List<Map<String, dynamic>> objects = [];
      if (contents is List) {
        for (final content in contents) {
          if (content is Map<String, dynamic>) {
            objects.add(content);
          }
        }
      } else if (contents is Map<String, dynamic>) {
        objects.add(contents);
      }

      for (final objectData in objects) {
        final contentObject = ObjectSummary(
          key: objectData['Key'] as String?,
          etag: objectData['ETag'] as String?,
          lastModified: (objectData['LastModified'] as String?)?.toDate(),
          transitionTime: (objectData['TransitionTime'] as String?)?.toDate(),
          size: (objectData['Size'] as String?)?.toInt(),
          storageClass: objectData['StorageClass'] as String?,
          restoreInfo: objectData['RestoreInfo'] as String?,
          type: objectData['Type'] as String?,
        );

        // Handle Owner
        final ownerData = objectData['Owner'];
        if (ownerData is Map<String, dynamic>) {
          contentObject.owner = Owner(
            displayName: ownerData['DisplayName'] as String?,
            id: ownerData['ID'] as String?,
          );
        }

        contentObjects.add(contentObject);
      }
    }
    result.contents = contentObjects;

    _deserializeEncodingType(result);
  }

  /// Handle URL decoding for encoding-type="url"
  static void _deserializeEncodingType(ListObjectsResult result) {
    if (result.encodingType != 'url') {
      return;
    }

    result.name = result.name != null
        ? Uri.decodeComponent(result.name!)
        : null;
    result.delimiter = result.delimiter != null
        ? Uri.decodeComponent(result.delimiter!)
        : null;
    result.prefix = result.prefix != null
        ? Uri.decodeComponent(result.prefix!)
        : null;
    result.marker = result.marker != null
        ? Uri.decodeComponent(result.marker!)
        : null;
    result.nextMarker = result.nextMarker != null
        ? Uri.decodeComponent(result.nextMarker!)
        : null;

    if (result.contents != null) {
      final decodeContents = <ObjectSummary>[];
      for (final content in result.contents!) {
        final decodeContent = ObjectSummary(
          key: content.key != null ? Uri.decodeComponent(content.key!) : null,
          etag: content.etag,
          lastModified: content.lastModified,
          transitionTime: content.transitionTime,
          size: content.size,
          storageClass: content.storageClass,
          restoreInfo: content.restoreInfo,
          type: content.type,
          owner: content.owner,
        );
        decodeContents.add(decodeContent);
      }
      result.contents = decodeContents;
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

  // MARK: - ListObjectsV2

  /// Serialize ListObjectsV2 request
  static Future<void> serializeListObjectsV2(
    ListObjectsV2Request request,
    OperationInput input,
  ) async {
    if (request.delimiter != null) {
      input.parameters['delimiter'] = request.delimiter!;
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

    if (request.fetchOwner != null) {
      input.parameters['fetch-owner'] = request.fetchOwner.toString();
    }

    if (request.startAfter != null) {
      input.parameters['start-after'] = request.startAfter!;
    }

    if (request.continuationToken != null) {
      input.parameters['continuation-token'] = request.continuationToken!;
    }
  }

  /// Deserialize ListObjectsV2 result
  static Future<void> deserializeListObjectsV2(
    ListObjectsV2Result result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'ListBucketResult',
    );

    result.name = body['Name'] as String?;
    if (body['IsTruncated'] is String) {
      final isTruncatedString = body['IsTruncated'] as String;
      result.isTruncated = isTruncatedString.toLowerCase() == 'true';
    }
    if (body['KeyCount'] is String) {
      result.keyCount = (body['KeyCount'] as String).toInt();
    }
    result.startAfter = body['StartAfter'] as String?;
    result.prefix = body['Prefix'] as String?;
    result.continuationToken = body['ContinuationToken'] as String?;
    result.nextContinuationToken = body['NextContinuationToken'] as String?;
    result.delimiter = body['Delimiter'] as String?;
    result.encodingType = body['EncodingType'] as String?;
    result.maxKeys = (body['MaxKeys'] as String?)?.toInt();

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

    // Handle Contents
    List<ObjectSummary>? contentObjects;
    final contents = body['Contents'];
    if (contents != null) {
      contentObjects = [];

      List<Map<String, dynamic>> objects = [];
      if (contents is List) {
        for (final content in contents) {
          if (content is Map<String, dynamic>) {
            objects.add(content);
          }
        }
      } else if (contents is Map<String, dynamic>) {
        objects.add(contents);
      }

      for (final objectData in objects) {
        final contentObject = ObjectSummary(
          key: objectData['Key'] as String?,
          etag: objectData['ETag'] as String?,
          lastModified: (objectData['LastModified'] as String?)?.toDate(),
          transitionTime: (objectData['TransitionTime'] as String?)?.toDate(),
          size: (objectData['Size'] as String?)?.toInt(),
          storageClass: objectData['StorageClass'] as String?,
          restoreInfo: objectData['RestoreInfo'] as String?,
          type: objectData['Type'] as String?,
        );

        // Handle Owner
        final ownerData = objectData['Owner'];
        if (ownerData is Map<String, dynamic>) {
          contentObject.owner = Owner(
            displayName: ownerData['DisplayName'] as String?,
            id: ownerData['ID'] as String?,
          );
        }

        contentObjects.add(contentObject);
      }
    }
    result.contents = contentObjects;

    _deserializeEncodingTypeV2(result);
  }

  /// Handle URL decoding for encoding-type="url" in ListObjectsV2
  static void _deserializeEncodingTypeV2(ListObjectsV2Result result) {
    if (result.encodingType != 'url') {
      return;
    }

    result.name = result.name != null
        ? Uri.decodeComponent(result.name!)
        : null;
    result.delimiter = result.delimiter != null
        ? Uri.decodeComponent(result.delimiter!)
        : null;
    result.prefix = result.prefix != null
        ? Uri.decodeComponent(result.prefix!)
        : null;
    result.continuationToken = result.continuationToken != null
        ? Uri.decodeComponent(result.continuationToken!)
        : null;
    result.nextContinuationToken = result.nextContinuationToken != null
        ? Uri.decodeComponent(result.nextContinuationToken!)
        : null;
    result.startAfter = result.startAfter != null
        ? Uri.decodeComponent(result.startAfter!)
        : null;

    if (result.contents != null) {
      final decodeContents = <ObjectSummary>[];
      for (final content in result.contents!) {
        final decodeContent = ObjectSummary(
          key: content.key != null ? Uri.decodeComponent(content.key!) : null,
          etag: content.etag,
          lastModified: content.lastModified,
          transitionTime: content.transitionTime,
          size: content.size,
          storageClass: content.storageClass,
          restoreInfo: content.restoreInfo,
          type: content.type,
          owner: content.owner,
        );
        decodeContents.add(decodeContent);
      }
      result.contents = decodeContents;
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

  // MARK: - GetBucketInfo

  /// Serialize GetBucketInfo request
  static Future<void> serializeGetBucketInfo(
    GetBucketInfoRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketInfo
  }

  /// Deserialize GetBucketInfo result
  static Future<void> deserializeGetBucketInfo(
    GetBucketInfoResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'BucketInfo',
    );

    final bucketContent = body['Bucket'] as Map<String, dynamic>?;

    if (bucketContent != null) {
      final bucket = Bucket(
        extranetEndpoint: bucketContent['ExtranetEndpoint'] as String?,
        intranetEndpoint: bucketContent['IntranetEndpoint'] as String?,
        location: bucketContent['Location'] as String?,
        resourceGroupId: bucketContent['ResourceGroupId'] as String?,
        versioning: bucketContent['Versioning'] as String?,
        crossRegionReplication:
            bucketContent['CrossRegionReplication'] as String?,
        transferAcceleration: bucketContent['TransferAcceleration'] as String?,
        accessMonitor: bucketContent['AccessMonitor'] as String?,
        storageClass: bucketContent['StorageClass'] as String?,
        dataRedundancyType: bucketContent['DataRedundancyType'] as String?,
        name: bucketContent['Name'] as String?,
        comment: bucketContent['Comment'] as String?,
        creationDate: (bucketContent['CreationDate'] as String?)?.toDate(),
        blockPublicAccess: (bucketContent['BlockPublicAccess'] as String?)
            ?.toBool(),
      );

      // Handle AccessControlList
      final accessControlListData =
          bucketContent['AccessControlList'] as Map<String, dynamic>?;
      if (accessControlListData != null) {
        bucket.accessControlList = AccessControlList(
          grant: accessControlListData['Grant'] as String?,
        );
      }

      // Handle BucketPolicy
      final bucketPolicyData =
          bucketContent['BucketPolicy'] as Map<String, dynamic>?;
      if (bucketPolicyData != null) {
        bucket.bucketPolicy = BucketPolicy(
          logBucket: bucketPolicyData['LogBucket'] as String?,
          logPrefix: bucketPolicyData['LogPrefix'] as String?,
        );
      }

      // Handle ServerSideEncryptionRule
      final serverSideEncryptionRuleData =
          bucketContent['ServerSideEncryptionRule'] as Map<String, dynamic>?;
      if (serverSideEncryptionRuleData != null) {
        bucket.serverSideEncryptionRule = ServerSideEncryptionRule(
          kmsDataEncryption:
              serverSideEncryptionRuleData['KMSDataEncryption'] as String?,
          sseAlgorithm: serverSideEncryptionRuleData['SSEAlgorithm'] as String?,
          kmsMasterKeyId:
              serverSideEncryptionRuleData['KMSMasterKeyID'] as String?,
        );
      }

      // Handle Owner
      final ownerData = bucketContent['Owner'] as Map<String, dynamic>?;
      if (ownerData != null) {
        bucket.owner = Owner(
          displayName: ownerData['DisplayName'] as String?,
          id: ownerData['ID'] as String?,
        );
      }

      result.bucketInfo = BucketInfo(bucket: bucket);
    }
  }

  // MARK: - GetBucketLocation

  /// Serialize GetBucketLocation request
  static Future<void> serializeGetBucketLocation(
    GetBucketLocationRequest request,
    OperationInput input,
  ) async {
    // No additional serialization needed for GetBucketLocation
  }

  /// Deserialize GetBucketLocation result
  static Future<void> deserializeGetBucketLocation(
    GetBucketLocationResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<String>(
      output.body,
      'LocationConstraint',
    );

    result.locationConstraint = body;
  }
}
