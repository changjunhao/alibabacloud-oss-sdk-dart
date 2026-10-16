import 'model_shared.dart';
import 'model_types.dart';
import '../transform/serde_extensions.dart';

/// Object summary information.
class ObjectSummary {
  /// The object type.
  ///
  /// Valid values include:
  /// - `Normal`: Created by a simple upload.
  /// - `Multipart`: Created by a multipart upload.
  /// - `Appendable`: Created by an append upload and can be appended later.
  String? type;

  /// Object size in bytes.
  int? size;

  /// Container for bucket owner information.
  Owner? owner;

  /// Transition time.
  DateTime? transitionTime;

  /// Object name.
  String? key;

  /// Entity tag (ETag) that identifies the object content.
  String? etag;

  /// Restore information.
  String? restoreInfo;

  /// Time when the object was last modified.
  DateTime? lastModified;

  /// Storage class of the object.
  String? storageClass;

  /// Creates a ObjectSummary instance.
  ObjectSummary({
    this.type,
    this.size,
    this.owner,
    this.transitionTime,
    this.key,
    this.etag,
    this.restoreInfo,
    this.lastModified,
    this.storageClass,
  });

  /// Converts the ObjectSummary instance to a JSON map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (type != null) json['Type'] = type;
    if (size != null) json['Size'] = size;
    if (owner != null) json['Owner'] = owner!.toJson();
    if (transitionTime != null) {
      json['TransitionTime'] = transitionTime!.toIso8601String();
    }
    if (key != null) json['Key'] = key;
    if (etag != null) json['ETag'] = etag;
    if (restoreInfo != null) json['RestoreInfo'] = restoreInfo;
    if (lastModified != null) {
      json['LastModified'] = lastModified!.toIso8601String();
    }
    if (storageClass != null) json['StorageClass'] = storageClass;
    return json;
  }

  /// Creates a ObjectSummary instance from a JSON map.
  factory ObjectSummary.fromJson(Map<String, dynamic> json) {
    return ObjectSummary(
      type: json.getCaseInsensitive('Type'),
      size: json.getCaseInsensitive('Size'),
      owner: json.getCaseInsensitive('Owner') != null
          ? Owner.fromJson(json.getCaseInsensitive('Owner'))
          : null,
      transitionTime: json.getCaseInsensitive('TransitionTime') != null
          ? DateTime.parse(json.getCaseInsensitive('TransitionTime'))
          : null,
      key: json.getCaseInsensitive('Key'),
      etag: json.getCaseInsensitive('ETag'),
      restoreInfo: json.getCaseInsensitive('RestoreInfo'),
      lastModified: json.getCaseInsensitive('LastModified') != null
          ? DateTime.parse(json.getCaseInsensitive('LastModified'))
          : null,
      storageClass: json.getCaseInsensitive('StorageClass'),
    );
  }
}

/// Bucket server-side encryption configuration.
class ServerSideEncryptionRule {
  /// Algorithm used to encrypt objects.
  ///
  /// If not specified, AES-256 is used. This field is only valid when
  /// `sseAlgorithm` is set to `KMS`. Valid value: `SM4`.
  String? kmsDataEncryption;

  /// Default server-side encryption method.
  ///
  /// Valid values are `KMS`, `AES-256`, and `SM4`.
  String? sseAlgorithm;

  /// Key managed by Key Management Service (KMS).
  String? kmsMasterKeyId;

  /// Creates a ServerSideEncryptionRule instance.
  ServerSideEncryptionRule({
    this.kmsDataEncryption,
    this.sseAlgorithm,
    this.kmsMasterKeyId,
  });

  /// Converts the ServerSideEncryptionRule instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'kMSDataEncryption': kmsDataEncryption,
      'sSEAlgorithm': sseAlgorithm,
      'kMSMasterKeyID': kmsMasterKeyId,
    };
  }

  /// Creates a ServerSideEncryptionRule instance from a JSON map.
  factory ServerSideEncryptionRule.fromJson(Map<String, dynamic> json) {
    return ServerSideEncryptionRule(
      kmsDataEncryption: json['kMSDataEncryption'] as String?,
      sseAlgorithm: json['sSEAlgorithm'] as String?,
      kmsMasterKeyId: json['kMSMasterKeyID'] as String?,
    );
  }
}

/// Bucket versioning status values.
enum BucketVersioningStatusType {
  /// Versioning is enabled.
  enabled('Enabled'),

  /// Versioning is suspended.
  suspended('Suspended');

  const BucketVersioningStatusType(this.value);

  /// The serialized string value of this enum item.
  final String value;

  @override
  String toString() => value;
}

/// Bucket storage class and redundancy configuration.
class CreateBucketConfiguration {
  /// Bucket storage class.
  ///
  /// Valid values:
  /// * `Standard` (default)
  /// * IA
  /// * Archive
  /// * ColdArchive
  /// See [StorageClass] for supported values.
  String? storageClass;

  /// Bucket data redundancy type.
  ///
  /// * `LRS` (default): Stores multiple copies on different devices in the
  ///   same zone to provide durability and availability.
  /// * `ZRS`: Stores multiple copies across three zones in the same region.
  ///   Data remains accessible even if one zone becomes unavailable.
  ///
  /// Archive buckets cannot use `ZRS`.
  /// See [DataRedundancyType] for supported values.
  String? dataRedundancyType;

  /// Creates a CreateBucketConfiguration instance.
  CreateBucketConfiguration({this.storageClass, this.dataRedundancyType});

  /// Converts the CreateBucketConfiguration instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'storageClass': storageClass,
      'dataRedundancyType': dataRedundancyType,
    };
  }

  /// Creates a CreateBucketConfiguration instance from a JSON map.
  factory CreateBucketConfiguration.fromJson(Map<String, dynamic> json) {
    return CreateBucketConfiguration(
      storageClass: json['storageClass'] as String?,
      dataRedundancyType: json['dataRedundancyType'] as String?,
    );
  }
}

/// Common prefix grouping for listed objects.
///
/// Objects whose names share the same substring from the given prefix to the
/// first occurrence of the delimiter are grouped into a `CommonPrefixes` item.
class CommonPrefix {
  /// Prefix that must be included in the object names to list.
  String? prefix;

  /// Creates a CommonPrefix instance.
  CommonPrefix({this.prefix});

  /// Converts the CommonPrefix instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'prefix': prefix};
  }

  /// Creates a CommonPrefix instance from a JSON map.
  factory CommonPrefix.fromJson(Map<String, dynamic> json) {
    return CommonPrefix(prefix: json['prefix'] as String?);
  }
}

/// Bucket logging configuration.
class BucketPolicy {
  /// Bucket name where logs are stored.
  String? logBucket;

  /// Prefix used for stored logs.
  String? logPrefix;

  /// Creates a BucketPolicy instance.
  BucketPolicy({this.logBucket, this.logPrefix});

  /// Converts the BucketPolicy instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'logBucket': logBucket, 'logPrefix': logPrefix};
  }

  /// Creates a BucketPolicy instance from a JSON map.
  factory BucketPolicy.fromJson(Map<String, dynamic> json) {
    return BucketPolicy(
      logBucket: json['logBucket'] as String?,
      logPrefix: json['logPrefix'] as String?,
    );
  }
}

/// Container for bucket information.
class Bucket {
  /// Bucket redundancy type.
  /// See [DataRedundancyType] for supported values.
  String? dataRedundancyType;

  /// Public endpoint of the bucket.
  String? extranetEndpoint;

  /// Bucket name.
  String? name;

  /// Bucket storage class.
  /// See [StorageClass] for supported values.
  String? storageClass;

  /// Bucket owner.
  Owner? owner;

  /// Indicates whether cross-region replication (CRR) is enabled.
  /// Valid values: `Enabled`, `Disabled`.
  String? crossRegionReplication;

  /// ID of the resource group that contains the bucket.
  String? resourceGroupId;

  /// Indicates whether transfer acceleration is enabled.
  /// Valid values: `Enabled`, `Disabled`.
  String? transferAcceleration;

  /// Bucket versioning status.
  /// See [BucketVersioningStatusType] for supported values.
  String? versioning;

  /// Region where the bucket resides.
  String? location;

  /// Bucket server-side encryption configuration.
  ServerSideEncryptionRule? serverSideEncryptionRule;

  /// Bucket description.
  String? comment;

  /// Whether public access is blocked.
  bool? blockPublicAccess;

  /// Indicates whether access monitoring is enabled.
  /// Valid values: `Enabled`, `Disabled`.
  String? accessMonitor;

  /// Internal endpoint of the bucket.
  String? intranetEndpoint;

  /// Bucket ACL.
  AccessControlList? accessControlList;

  /// Bucket logging configuration.
  BucketPolicy? bucketPolicy;

  /// Bucket creation time in UTC.
  DateTime? creationDate;

  /// The resource type of the bucket.
  String? bucketResourceType;

  /// The associated AgenticBucket physical full name.
  String? agenticBucketName;

  /// Creates a Bucket instance.
  Bucket({
    this.dataRedundancyType,
    this.extranetEndpoint,
    this.name,
    this.storageClass,
    this.owner,
    this.crossRegionReplication,
    this.resourceGroupId,
    this.transferAcceleration,
    this.versioning,
    this.location,
    this.serverSideEncryptionRule,
    this.comment,
    this.blockPublicAccess,
    this.accessMonitor,
    this.intranetEndpoint,
    this.accessControlList,
    this.bucketPolicy,
    this.creationDate,
    this.bucketResourceType,
    this.agenticBucketName,
  });

  /// Converts the Bucket instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'dataRedundancyType': dataRedundancyType,
      'extranetEndpoint': extranetEndpoint,
      'name': name,
      'storageClass': storageClass,
      'owner': owner?.toJson(),
      'crossRegionReplication': crossRegionReplication,
      'resourceGroupId': resourceGroupId,
      'transferAcceleration': transferAcceleration,
      'versioning': versioning,
      'location': location,
      'serverSideEncryptionRule': serverSideEncryptionRule?.toJson(),
      'comment': comment,
      'blockPublicAccess': blockPublicAccess,
      'accessMonitor': accessMonitor,
      'intranetEndpoint': intranetEndpoint,
      'accessControlList': accessControlList?.toJson(),
      'bucketPolicy': bucketPolicy?.toJson(),
      'bucketResourceType': bucketResourceType,
      'agenticBucketName': agenticBucketName,
      'creationDate': creationDate?.toIso8601String(),
    };
  }

  /// Creates a Bucket instance from a JSON map.
  factory Bucket.fromJson(Map<String, dynamic> json) {
    return Bucket(
      dataRedundancyType: json['dataRedundancyType'] as String?,
      extranetEndpoint: json['extranetEndpoint'] as String?,
      name: json['name'] as String?,
      storageClass: json['storageClass'] as String?,
      owner: json['owner'] != null
          ? Owner.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      crossRegionReplication: json['crossRegionReplication'] as String?,
      resourceGroupId: json['resourceGroupId'] as String?,
      transferAcceleration: json['transferAcceleration'] as String?,
      versioning: json['versioning'] as String?,
      location: json['location'] as String?,
      serverSideEncryptionRule: json['serverSideEncryptionRule'] != null
          ? ServerSideEncryptionRule.fromJson(
              json['serverSideEncryptionRule'] as Map<String, dynamic>,
            )
          : null,
      comment: json['comment'] as String?,
      blockPublicAccess: json['blockPublicAccess'] as bool?,
      bucketResourceType: json['bucketResourceType'] as String?,
      agenticBucketName: json['agenticBucketName'] as String?,
      accessMonitor: json['accessMonitor'] as String?,
      intranetEndpoint: json['intranetEndpoint'] as String?,
      accessControlList: json['accessControlList'] != null
          ? AccessControlList.fromJson(
              json['accessControlList'] as Map<String, dynamic>,
            )
          : null,
      bucketPolicy: json['bucketPolicy'] != null
          ? BucketPolicy.fromJson(json['bucketPolicy'] as Map<String, dynamic>)
          : null,
      creationDate: json['creationDate'] != null
          ? DateTime.parse(json['creationDate'] as String)
          : null,
    );
  }
}

/// Container that stores bucket information.
class BucketInfo {
  /// Stored bucket information.
  Bucket? bucket;

  /// Creates a BucketInfo instance.
  BucketInfo({this.bucket});

  /// Converts the BucketInfo instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'bucket': bucket?.toJson()};
  }

  /// Creates a BucketInfo instance from a JSON map.
  factory BucketInfo.fromJson(Map<String, dynamic> json) {
    return BucketInfo(
      bucket: json['bucket'] != null
          ? Bucket.fromJson(json['bucket'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Container for all data returned by `GetBucketStat`.
class BucketStat {
  /// Total number of objects in the bucket.
  int? objectCount;

  /// Actual storage used by IA objects, in bytes.
  int? infrequentAccessRealStorage;

  /// Number of IA objects in the bucket.
  int? infrequentAccessObjectCount;

  /// Actual storage used by Archive objects, in bytes.
  int? archiveRealStorage;

  /// Number of Cold Archive objects in the bucket.
  int? coldArchiveObjectCount;

  /// Actual storage used by Deep Cold Archive objects, in bytes.
  int? deepColdArchiveRealStorage;

  /// Billable storage used by IA objects, in bytes.
  int? infrequentAccessStorage;

  /// Number of Archive objects in the bucket.
  int? archiveObjectCount;

  /// Number of Deep Cold Archive objects in the bucket.
  int? deepColdArchiveObjectCount;

  /// Number of initiated multipart uploads that are not yet completed or aborted.
  int? multipartUploadCount;

  /// Number of uploaded multipart parts in the bucket.
  int? multipartPartCount;

  /// Number of delete markers in the bucket.
  int? deleteMarkerCount;

  /// Last modification time of the statistics, as a Unix timestamp in seconds.
  int? lastModifiedTime;

  /// Storage used by Standard objects, in bytes.
  int? standardStorage;

  /// Actual storage used by Cold Archive objects, in bytes.
  int? coldArchiveRealStorage;

  /// Total storage used by the bucket, in bytes.
  int? storage;

  /// Number of LiveChannels in the bucket.
  int? liveChannelCount;

  /// Number of Standard objects in the bucket.
  int? standardObjectCount;

  /// Billable storage used by Archive objects, in bytes.
  int? archiveStorage;

  /// Billable storage used by Cold Archive objects, in bytes.
  int? coldArchiveStorage;

  /// Billable storage used by Deep Cold Archive objects, in bytes.
  int? deepColdArchiveStorage;

  /// Creates a BucketStat instance.
  BucketStat({
    this.objectCount,
    this.infrequentAccessRealStorage,
    this.infrequentAccessObjectCount,
    this.archiveRealStorage,
    this.coldArchiveObjectCount,
    this.deepColdArchiveRealStorage,
    this.infrequentAccessStorage,
    this.archiveObjectCount,
    this.deepColdArchiveObjectCount,
    this.multipartUploadCount,
    this.multipartPartCount,
    this.deleteMarkerCount,
    this.lastModifiedTime,
    this.standardStorage,
    this.coldArchiveRealStorage,
    this.storage,
    this.liveChannelCount,
    this.standardObjectCount,
    this.archiveStorage,
    this.coldArchiveStorage,
    this.deepColdArchiveStorage,
  });

  /// Converts the BucketStat instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'objectCount': objectCount,
      'infrequentAccessRealStorage': infrequentAccessRealStorage,
      'infrequentAccessObjectCount': infrequentAccessObjectCount,
      'archiveRealStorage': archiveRealStorage,
      'coldArchiveObjectCount': coldArchiveObjectCount,
      'deepColdArchiveRealStorage': deepColdArchiveRealStorage,
      'infrequentAccessStorage': infrequentAccessStorage,
      'archiveObjectCount': archiveObjectCount,
      'deepColdArchiveObjectCount': deepColdArchiveObjectCount,
      'multipartUploadCount': multipartUploadCount,
      'multipartPartCount': multipartPartCount,
      'deleteMarkerCount': deleteMarkerCount,
      'lastModifiedTime': lastModifiedTime,
      'standardStorage': standardStorage,
      'coldArchiveRealStorage': coldArchiveRealStorage,
      'storage': storage,
      'liveChannelCount': liveChannelCount,
      'standardObjectCount': standardObjectCount,
      'archiveStorage': archiveStorage,
      'coldArchiveStorage': coldArchiveStorage,
      'deepColdArchiveStorage': deepColdArchiveStorage,
    };
  }

  /// Creates a BucketStat instance from a JSON map.
  factory BucketStat.fromJson(Map<String, dynamic> json) {
    return BucketStat(
      objectCount: json['objectCount'] as int?,
      infrequentAccessRealStorage: json['infrequentAccessRealStorage'] as int?,
      infrequentAccessObjectCount: json['infrequentAccessObjectCount'] as int?,
      archiveRealStorage: json['archiveRealStorage'] as int?,
      coldArchiveObjectCount: json['coldArchiveObjectCount'] as int?,
      deepColdArchiveRealStorage: json['deepColdArchiveRealStorage'] as int?,
      infrequentAccessStorage: json['infrequentAccessStorage'] as int?,
      archiveObjectCount: json['archiveObjectCount'] as int?,
      deepColdArchiveObjectCount: json['deepColdArchiveObjectCount'] as int?,
      multipartUploadCount: json['multipartUploadCount'] as int?,
      multipartPartCount: json['multipartPartCount'] as int?,
      deleteMarkerCount: json['deleteMarkerCount'] as int?,
      lastModifiedTime: json['lastModifiedTime'] as int?,
      standardStorage: json['standardStorage'] as int?,
      coldArchiveRealStorage: json['coldArchiveRealStorage'] as int?,
      storage: json['storage'] as int?,
      liveChannelCount: json['liveChannelCount'] as int?,
      standardObjectCount: json['standardObjectCount'] as int?,
      archiveStorage: json['archiveStorage'] as int?,
      coldArchiveStorage: json['coldArchiveStorage'] as int?,
      deepColdArchiveStorage: json['deepColdArchiveStorage'] as int?,
    );
  }
}

/// Request for the `GetBucketStat` operation.
class GetBucketStatRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// Bucket whose statistics are queried.
  String? bucket;

  /// Creates a GetBucketStatRequest instance.
  GetBucketStatRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Converts the GetBucketStatRequest instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }

  /// Creates a GetBucketStatRequest instance from a JSON map.
  factory GetBucketStatRequest.fromJson(Map<String, dynamic> json) {
    return GetBucketStatRequest(bucket: json['bucket'] as String?);
  }
}

/// Result of the `GetBucketStat` operation.
class GetBucketStatResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Container for all data returned by `GetBucketStat`.
  BucketStat? bucketStat;

  /// Creates a GetBucketStatResult instance.
  GetBucketStatResult({this.bucketStat, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Converts the GetBucketStatResult instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'bucketStat': bucketStat?.toJson()};
  }

  /// Creates a GetBucketStatResult instance from a JSON map.
  factory GetBucketStatResult.fromJson(Map<String, dynamic> json) {
    return GetBucketStatResult(
      bucketStat: json['bucketStat'] != null
          ? BucketStat.fromJson(json['bucketStat'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Request for the `PutBucket` operation.
class PutBucketRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// Bucket name.
  ///
  /// Naming rules:
  /// - Only lowercase letters, digits, and hyphens (`-`) are allowed.
  /// - The name must start and end with a lowercase letter or digit.
  /// - The length must be between 3 and 63 characters.
  String? bucket;

  /// ACL of the bucket to create.
  ///
  /// Valid values:
  /// - `public-read-write`
  /// - `public-read`
  /// - `private` (default)
  ///
  /// See [CannedAccessControlList] for supported values.
  String? acl;

  /// Resource group ID.
  ///
  /// If this header is included, the created bucket belongs to the specified
  /// resource group. If the value is `rg-default-id`, the bucket belongs to
  /// the default resource group. If omitted, the bucket also belongs to the
  /// default resource group.
  String? resourceGroupId;

  /// Bucket tags.
  String? bucketTagging;

  /// Container for the request body.
  CreateBucketConfiguration? createBucketConfiguration;

  /// The physical full name of the AgenticBucket that the BucketSpace belongs to; sent as-is.
  String? agenticBucket;

  /// Creates a PutBucketRequest instance.
  PutBucketRequest({
    this.bucket,
    this.acl,
    this.resourceGroupId,
    this.bucketTagging,
    this.createBucketConfiguration,
    this.agenticBucket,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Converts the PutBucketRequest instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'acl': acl,
      'resourceGroupId': resourceGroupId,
      'bucketTagging': bucketTagging,
      'agenticBucket': agenticBucket,
      'createBucketConfiguration': createBucketConfiguration?.toJson(),
    };
  }

  /// Creates a PutBucketRequest instance from a JSON map.
  factory PutBucketRequest.fromJson(Map<String, dynamic> json) {
    return PutBucketRequest(
      bucket: json['bucket'] as String?,
      acl: json['acl'] as String?,
      resourceGroupId: json['resourceGroupId'] as String?,
      bucketTagging: json['bucketTagging'] as String?,
      agenticBucket: json['agenticBucket'] as String?,
      createBucketConfiguration: json['createBucketConfiguration'] != null
          ? CreateBucketConfiguration.fromJson(
              json['createBucketConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// Result of the `PutBucket` operation.
class PutBucketResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a PutBucketResult instance.
  PutBucketResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Converts the PutBucketResult instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {};
  }

  /// Creates a PutBucketResult instance from a JSON map.
  factory PutBucketResult.fromJson(Map<String, dynamic> json) {
    return PutBucketResult();
  }
}

/// Request for the `DeleteBucket` operation.
class DeleteBucketRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// Bucket name.
  String? bucket;

  /// Creates a DeleteBucketRequest instance.
  DeleteBucketRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Converts the DeleteBucketRequest instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }

  /// Creates a DeleteBucketRequest instance from a JSON map.
  factory DeleteBucketRequest.fromJson(Map<String, dynamic> json) {
    return DeleteBucketRequest(bucket: json['bucket'] as String?);
  }
}

/// Result of the `DeleteBucket` operation.
class DeleteBucketResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a DeleteBucketResult instance.
  DeleteBucketResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Converts the DeleteBucketResult instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {};
  }

  /// Creates a DeleteBucketResult instance from a JSON map.
  factory DeleteBucketResult.fromJson(Map<String, dynamic> json) {
    return DeleteBucketResult();
  }
}

/// Request for the `ListObjects` operation.
class ListObjectsRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// Bucket name.
  String? bucket;

  /// Delimiter used to group objects by name.
  /// When specified, the response includes `CommonPrefixes`.
  String? delimiter;

  /// Marker that specifies where listing starts.
  /// Returned objects are those whose names are lexicographically after `marker`.
  String? marker;

  /// Maximum number of objects to return.
  /// If more objects are available, the response includes `NextMarker`.
  int? maxKeys;

  /// Prefix that must be present in returned object names.
  String? prefix;

  /// Encoding type used in the response.
  String? encodingType;

  /// Creates a ListObjectsRequest instance.
  ListObjectsRequest({
    this.bucket,
    this.delimiter,
    this.marker,
    this.maxKeys,
    this.prefix,
    this.encodingType,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Converts the ListObjectsRequest instance to a JSON map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (bucket != null) json['Bucket'] = bucket;
    if (delimiter != null) json['delimiter'] = delimiter;
    if (marker != null) json['marker'] = marker;
    if (maxKeys != null) json['max-keys'] = maxKeys;
    if (prefix != null) json['prefix'] = prefix;
    if (encodingType != null) json['encoding-type'] = encodingType;
    return json;
  }

  /// Creates a ListObjectsRequest value using `fromJson` parameters.
  static ListObjectsRequest fromJson(Map<String, dynamic> json) {
    return ListObjectsRequest(
      bucket: json.getCaseInsensitive('Bucket'),
      delimiter: json.getCaseInsensitive('delimiter'),
      marker: json.getCaseInsensitive('marker'),
      maxKeys: json.getCaseInsensitive('max-keys'),
      prefix: json.getCaseInsensitive('prefix'),
      encodingType: json.getCaseInsensitive('encoding-type'),
    );
  }
}

/// Result of the `ListObjects` operation.
class ListObjectsResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Prefix returned in object names.
  String? prefix;

  /// Maximum number of objects returned in the response.
  int? maxKeys;

  /// Indicates whether the results are truncated.
  bool? isTruncated;

  /// Marker that indicates where the listing started.
  String? marker;

  /// Marker for the next listing request.
  String? nextMarker;

  /// Encoding type used in the response.
  String? encodingType;

  /// Bucket name.
  String? name;

  /// Returned object metadata entries.
  List<ObjectSummary>? contents;

  /// Objects grouped by the first shared substring from the prefix to the
  /// delimiter.
  List<CommonPrefix>? commonPrefixes;

  /// Delimiter used to group object names.
  String? delimiter;

  /// Creates a ListObjectsResult instance.
  ListObjectsResult({
    this.prefix,
    this.maxKeys,
    this.isTruncated,
    this.marker,
    this.nextMarker,
    this.encodingType,
    this.name,
    this.contents,
    this.commonPrefixes,
    this.delimiter,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Converts the ListObjectsResult instance to a JSON map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (prefix != null) json['Prefix'] = prefix;
    if (maxKeys != null) json['MaxKeys'] = maxKeys;
    if (isTruncated != null) json['IsTruncated'] = isTruncated;
    if (marker != null) json['Marker'] = marker;
    if (nextMarker != null) json['NextMarker'] = nextMarker;
    if (encodingType != null) json['EncodingType'] = encodingType;
    if (name != null) json['Name'] = name;
    if (contents != null) {
      json['Contents'] = contents!.map((e) => e.toJson()).toList();
    }
    if (commonPrefixes != null) {
      json['CommonPrefixes'] = commonPrefixes!.map((e) => e.toJson()).toList();
    }
    if (delimiter != null) json['Delimiter'] = delimiter;
    return json;
  }

  /// Creates a ListObjectsResult value using `fromJson` parameters.
  static ListObjectsResult fromJson(Map<String, dynamic> json) {
    return ListObjectsResult(
      prefix: json.getCaseInsensitive('Prefix'),
      maxKeys: json.getCaseInsensitive('MaxKeys'),
      isTruncated: json.getCaseInsensitive('IsTruncated'),
      marker: json.getCaseInsensitive('Marker'),
      nextMarker: json.getCaseInsensitive('NextMarker'),
      encodingType: json.getCaseInsensitive('EncodingType'),
      name: json.getCaseInsensitive('Name'),
      contents: json.getCaseInsensitive('Contents') != null
          ? (json.getCaseInsensitive('Contents') as List)
                .map((e) => ObjectSummary.fromJson(e))
                .toList()
          : null,
      commonPrefixes: json.getCaseInsensitive('CommonPrefixes') != null
          ? (json.getCaseInsensitive('CommonPrefixes') as List)
                .map((e) => CommonPrefix.fromJson(e))
                .toList()
          : null,
      delimiter: json.getCaseInsensitive('Delimiter'),
    );
  }
}

/// Request for the `ListObjectsV2` operation.
class ListObjectsV2Request extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// Bucket name.
  String? bucket;

  /// Delimiter used to group objects by name.
  /// When specified, the response includes `CommonPrefixes`.
  String? delimiter;

  /// Maximum number of objects to return.
  ///
  /// Valid values are `1` to `999`. The default is `100`. If more objects are
  /// available, the response includes `NextContinuationToken`.
  int? maxKeys;

  /// Prefix that must be present in returned object names.
  ///
  /// The value can be up to 1,024 bytes long. If the prefix is a directory
  /// name and `delimiter` is `/`, only objects in that directory are listed and
  /// child directories are returned in `CommonPrefixes`.
  String? prefix;

  /// Encoding type used in the response.
  ///
  /// `Delimiter`, `StartAfter`, `Prefix`, `NextContinuationToken`, and `Key`
  /// are UTF-8 encoded. Use this field if those values contain control
  /// characters not supported by XML 1.0.
  /// See [EncodingType] for supported values.
  String? encodingType;

  /// Whether to include bucket owner information in the response.
  /// Valid values: `true`, `false`.
  bool? fetchOwner;

  /// Object name after which listing begins.
  ///
  /// Returned objects are those whose names are lexicographically after
  /// `startAfter`.
  String? startAfter;

  /// Continuation token used to resume listing.
  /// This value can be taken from `NextContinuationToken`.
  String? continuationToken;

  /// Creates a ListObjectsV2Request instance.
  ListObjectsV2Request({
    this.bucket,
    this.delimiter,
    this.maxKeys,
    this.prefix,
    this.encodingType,
    this.fetchOwner,
    this.startAfter,
    this.continuationToken,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Converts the ListObjectsV2Request instance to a JSON map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (bucket != null) json['Bucket'] = bucket;
    if (delimiter != null) json['delimiter'] = delimiter;
    if (maxKeys != null) json['max-keys'] = maxKeys;
    if (prefix != null) json['prefix'] = prefix;
    if (encodingType != null) json['encoding-type'] = encodingType;
    if (fetchOwner != null) json['fetch-owner'] = fetchOwner;
    if (startAfter != null) json['start-after'] = startAfter;
    if (continuationToken != null) {
      json['continuation-token'] = continuationToken;
    }
    return json;
  }

  /// Creates a ListObjectsV2Request value using `fromJson` parameters.
  static ListObjectsV2Request fromJson(Map<String, dynamic> json) {
    return ListObjectsV2Request(
      bucket: json.getCaseInsensitive('Bucket'),
      delimiter: json.getCaseInsensitive('delimiter'),
      maxKeys: json.getCaseInsensitive('max-keys'),
      prefix: json.getCaseInsensitive('prefix'),
      encodingType: json.getCaseInsensitive('encoding-type'),
      fetchOwner: json.getCaseInsensitive('fetch-owner'),
      startAfter: json.getCaseInsensitive('start-after'),
      continuationToken: json.getCaseInsensitive('continuation-token'),
    );
  }
}

/// Result of the `ListObjectsV2` operation.
class ListObjectsV2Result extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Prefix returned in object names.
  String? prefix;

  /// Returned when `start-after` is specified in the request.
  String? startAfter;

  /// Maximum number of objects returned in the response.
  int? maxKeys;

  /// Indicates whether the results are truncated.
  /// Valid values: `true`, `false`.
  bool? isTruncated;

  /// Number of results returned by this request.
  /// When `delimiter` is specified, this is the sum of `Key` and
  /// `CommonPrefixes` entries.
  int? keyCount;

  /// Encoding type used in the response.
  String? encodingType;

  /// Bucket name.
  String? name;

  /// Returned when `continuation-token` is specified in the request.
  String? continuationToken;

  /// Continuation token for the next listing request.
  String? nextContinuationToken;

  /// Returned object metadata entries.
  List<ObjectSummary>? contents;

  /// Objects grouped by the next shared substring from the prefix to the
  /// delimiter.
  List<CommonPrefix>? commonPrefixes;

  /// Delimiter used to group object names.
  String? delimiter;

  /// Creates a ListObjectsV2Result instance.
  ListObjectsV2Result({
    this.prefix,
    this.startAfter,
    this.maxKeys,
    this.isTruncated,
    this.keyCount,
    this.encodingType,
    this.name,
    this.continuationToken,
    this.nextContinuationToken,
    this.contents,
    this.commonPrefixes,
    this.delimiter,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Converts the ListObjectsV2Result instance to a JSON map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (prefix != null) json['Prefix'] = prefix;
    if (startAfter != null) json['StartAfter'] = startAfter;
    if (maxKeys != null) json['MaxKeys'] = maxKeys;
    if (isTruncated != null) json['IsTruncated'] = isTruncated;
    if (keyCount != null) json['KeyCount'] = keyCount;
    if (encodingType != null) json['EncodingType'] = encodingType;
    if (name != null) json['Name'] = name;
    if (continuationToken != null) {
      json['ContinuationToken'] = continuationToken;
    }
    if (nextContinuationToken != null) {
      json['NextContinuationToken'] = nextContinuationToken;
    }
    if (contents != null) {
      json['Contents'] = contents!.map((e) => e.toJson()).toList();
    }
    if (commonPrefixes != null) {
      json['CommonPrefixes'] = commonPrefixes!.map((e) => e.toJson()).toList();
    }
    if (delimiter != null) json['Delimiter'] = delimiter;
    return json;
  }

  /// Creates a ListObjectsV2Result value using `fromJson` parameters.
  static ListObjectsV2Result fromJson(Map<String, dynamic> json) {
    return ListObjectsV2Result(
      prefix: json.getCaseInsensitive('Prefix'),
      startAfter: json.getCaseInsensitive('StartAfter'),
      maxKeys: json.getCaseInsensitive('MaxKeys'),
      isTruncated: json.getCaseInsensitive('IsTruncated'),
      keyCount: json.getCaseInsensitive('KeyCount'),
      encodingType: json.getCaseInsensitive('EncodingType'),
      name: json.getCaseInsensitive('Name'),
      continuationToken: json.getCaseInsensitive('ContinuationToken'),
      nextContinuationToken: json.getCaseInsensitive('NextContinuationToken'),
      contents: json.getCaseInsensitive('Contents') != null
          ? (json.getCaseInsensitive('Contents') as List)
                .map((e) => ObjectSummary.fromJson(e))
                .toList()
          : null,
      commonPrefixes: json.getCaseInsensitive('CommonPrefixes') != null
          ? (json.getCaseInsensitive('CommonPrefixes') as List)
                .map((e) => CommonPrefix.fromJson(e))
                .toList()
          : null,
      delimiter: json.getCaseInsensitive('Delimiter'),
    );
  }
}

/// Request for the `GetBucketInfo` operation.
class GetBucketInfoRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// Bucket name.
  String? bucket;

  /// Creates a GetBucketInfoRequest instance.
  GetBucketInfoRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Converts the GetBucketInfoRequest instance to a JSON map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (bucket != null) json['Bucket'] = bucket;
    return json;
  }

  /// Creates a GetBucketInfoRequest value using `fromJson` parameters.
  static GetBucketInfoRequest fromJson(Map<String, dynamic> json) {
    return GetBucketInfoRequest(bucket: json.getCaseInsensitive('Bucket'));
  }
}

/// Result of the `GetBucketInfo` operation.
class GetBucketInfoResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Container that stores bucket information.
  BucketInfo? bucketInfo;

  /// Creates a GetBucketInfoResult instance.
  GetBucketInfoResult({this.bucketInfo, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Converts the GetBucketInfoResult instance to a JSON map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (bucketInfo != null) json['BucketInfo'] = bucketInfo!.toJson();
    return json;
  }

  /// Creates a GetBucketInfoResult value using `fromJson` parameters.
  static GetBucketInfoResult fromJson(Map<String, dynamic> json) {
    return GetBucketInfoResult(
      bucketInfo: json.getCaseInsensitive('BucketInfo') != null
          ? BucketInfo.fromJson(
              json.getCaseInsensitive('BucketInfo') as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// Request for the `GetBucketLocation` operation.
class GetBucketLocationRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// Bucket name.
  String? bucket;

  /// Creates a GetBucketLocationRequest instance.
  GetBucketLocationRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Converts the GetBucketLocationRequest instance to a JSON map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (bucket != null) json['Bucket'] = bucket;
    return json;
  }

  /// Creates a GetBucketLocationRequest value using `fromJson` parameters.
  static GetBucketLocationRequest fromJson(Map<String, dynamic> json) {
    return GetBucketLocationRequest(bucket: json.getCaseInsensitive('Bucket'));
  }
}

/// Result of the `GetBucketLocation` operation.
class GetBucketLocationResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Region where the bucket resides.
  ///
  /// Examples include `oss-cn-hangzhou`, `oss-cn-shanghai`, `oss-cn-qingdao`,
  /// `oss-cn-beijing`, `oss-cn-zhangjiakou`, `oss-cn-hongkong`,
  /// `oss-cn-shenzhen`, `oss-us-west-1`, `oss-us-east-1`, and
  /// `oss-ap-southeast-1`.
  String? locationConstraint;

  /// Creates a GetBucketLocationResult instance.
  GetBucketLocationResult({
    this.locationConstraint,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Converts the GetBucketLocationResult instance to a JSON map.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (locationConstraint != null) {
      json['LocationConstraint'] = locationConstraint;
    }
    return json;
  }

  /// Creates a GetBucketLocationResult value using `fromJson` parameters.
  static GetBucketLocationResult fromJson(Map<String, dynamic> json) {
    return GetBucketLocationResult(
      locationConstraint: json.getCaseInsensitive('LocationConstraint'),
    );
  }
}
