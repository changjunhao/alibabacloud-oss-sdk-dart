import '../../models/model_bucket_basic.dart';
import '../../models/model_shared.dart';
import '../../models/model_types.dart';

/// Storage configuration for creating an AgenticBucket.
class CreateAgenticBucketConfiguration {
  /// Storage class: Standard, IA, or Archive; server defaults to Standard.
  String? storageClass;

  /// Data redundancy type: LRS or ZRS; server defaults to LRS.
  String? dataRedundancyType;

  /// Creation configuration; when omitted the request carries no XML body.
  CreateAgenticBucketConfiguration({
    this.storageClass,
    this.dataRedundancyType,
  });

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'storageClass': storageClass,
    'dataRedundancyType': dataRedundancyType,
  };

  /// Creates an instance from JSON.
  factory CreateAgenticBucketConfiguration.fromJson(
    Map<String, dynamic> json,
  ) => CreateAgenticBucketConfiguration(
    storageClass: json['storageClass'] as String?,
    dataRedundancyType: json['dataRedundancyType'] as String?,
  );
}

/// Server-side information for an AgenticBucket.
class AgenticBucketInfo {
  /// The physical full name.
  String? name;

  /// Owner account UID, kept as a string.
  String? owner;

  /// The region.
  String? region;

  /// Storage class.
  String? storageClass;

  /// Data redundancy type.
  String? dataRedundancyType;

  /// Status: Enabled or Disabled.
  String? status;

  /// Resource type; server returns `agentic`.
  String? bucketResourceType;

  /// Raw creation time string.
  String? createTime;

  /// Access control list.
  String? acl;

  /// Whether public access is blocked; kept as server true/false string.
  String? publicAccessBlock;

  /// Server-side encryption configuration.
  ServerSideEncryptionRule? serverSideEncryptionRule;

  /// Versioning status.
  String? versioning;

  /// Raw bucket policy JSON text.
  String? bucketPolicy;

  /// Creates an AgenticBucket info instance.
  AgenticBucketInfo({
    this.name,
    this.owner,
    this.region,
    this.storageClass,
    this.dataRedundancyType,
    this.status,
    this.bucketResourceType,
    this.createTime,
    this.acl,
    this.publicAccessBlock,
    this.serverSideEncryptionRule,
    this.versioning,
    this.bucketPolicy,
  });

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'owner': owner,
    'region': region,
    'storageClass': storageClass,
    'dataRedundancyType': dataRedundancyType,
    'status': status,
    'bucketResourceType': bucketResourceType,
    'createTime': createTime,
    'acl': acl,
    'publicAccessBlock': publicAccessBlock,
    'serverSideEncryptionRule': serverSideEncryptionRule?.toJson(),
    'versioning': versioning,
    'bucketPolicy': bucketPolicy,
  };

  /// Creates an instance from JSON.
  factory AgenticBucketInfo.fromJson(Map<String, dynamic> json) =>
      AgenticBucketInfo(
        name: json['name'] as String?,
        owner: json['owner'] as String?,
        region: json['region'] as String?,
        storageClass: json['storageClass'] as String?,
        dataRedundancyType: json['dataRedundancyType'] as String?,
        status: json['status'] as String?,
        bucketResourceType: json['bucketResourceType'] as String?,
        createTime: json['createTime'] as String?,
        acl: json['acl'] as String?,
        publicAccessBlock: json['publicAccessBlock'] as String?,
        serverSideEncryptionRule: json['serverSideEncryptionRule'] == null
            ? null
            : ServerSideEncryptionRule.fromJson(
                json['serverSideEncryptionRule'] as Map<String, dynamic>,
              ),
        versioning: json['versioning'] as String?,
        bucketPolicy: json['bucketPolicy'] as String?,
      );
}

/// Summary of an AgenticBucket in a listing.
class AgenticBucketSummary {
  /// The physical full name.
  String? name;

  /// Storage class.
  String? storageClass;

  /// Data redundancy type.
  String? dataRedundancyType;

  /// Raw creation time string.
  String? createTime;

  /// Creates a summary instance.
  AgenticBucketSummary({
    this.name,
    this.storageClass,
    this.dataRedundancyType,
    this.createTime,
  });

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'storageClass': storageClass,
    'dataRedundancyType': dataRedundancyType,
    'createTime': createTime,
  };

  /// Creates an instance from JSON.
  factory AgenticBucketSummary.fromJson(Map<String, dynamic> json) =>
      AgenticBucketSummary(
        name: json['name'] as String?,
        storageClass: json['storageClass'] as String?,
        dataRedundancyType: json['dataRedundancyType'] as String?,
        createTime: json['createTime'] as String?,
      );
}

/// Summary of a BucketSpace in a listing.
class BucketSpaceSummary {
  /// The physical full name.
  String? name;

  /// Location, e.g. oss-cn-hangzhou.
  String? location;

  /// Raw creation time string.
  String? creationDate;

  /// Storage class.
  String? storageClass;

  /// Creates a summary instance.
  BucketSpaceSummary({
    this.name,
    this.location,
    this.creationDate,
    this.storageClass,
  });

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'location': location,
    'creationDate': creationDate,
    'storageClass': storageClass,
  };

  /// Creates an instance from JSON.
  factory BucketSpaceSummary.fromJson(Map<String, dynamic> json) =>
      BucketSpaceSummary(
        name: json['name'] as String?,
        location: json['location'] as String?,
        creationDate: json['creationDate'] as String?,
        storageClass: json['storageClass'] as String?,
      );
}

/// Request to create an AgenticBucket.
class CreateAgenticBucketRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// User-defined logical prefix, not the physical full name.
  String? bucket;

  /// Optional creation configuration.
  CreateAgenticBucketConfiguration? createAgenticBucketConfiguration;

  /// Creates a request instance.
  CreateAgenticBucketRequest({
    this.bucket,
    this.createAgenticBucketConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Converts business fields to JSON; common request properties are managed by commonProp.
  Map<String, dynamic> toJson() => {
    'bucket': bucket,
    'createAgenticBucketConfiguration': createAgenticBucketConfiguration
        ?.toJson(),
  };

  /// Creates an instance from JSON.
  factory CreateAgenticBucketRequest.fromJson(Map<String, dynamic> json) =>
      CreateAgenticBucketRequest(
        bucket: json['bucket'] as String?,
        createAgenticBucketConfiguration:
            json['createAgenticBucketConfiguration'] == null
            ? null
            : CreateAgenticBucketConfiguration.fromJson(
                json['createAgenticBucketConfiguration']
                    as Map<String, dynamic>,
              ),
      );
}

/// Result of creating an AgenticBucket.
class CreateAgenticBucketResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// Creates a result instance.
  CreateAgenticBucketResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Converts business fields to JSON.
  Map<String, dynamic> toJson() => {};

  /// Creates an instance from JSON.
  factory CreateAgenticBucketResult.fromJson(Map<String, dynamic> json) =>
      CreateAgenticBucketResult();
}

/// Request to delete an AgenticBucket.
class DeleteAgenticBucketRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// Logical prefix of the AgenticBucket.
  String? bucket;

  /// Creates a request instance.
  DeleteAgenticBucketRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'bucket': bucket};

  /// Creates an instance from JSON.
  factory DeleteAgenticBucketRequest.fromJson(Map<String, dynamic> json) =>
      DeleteAgenticBucketRequest(bucket: json['bucket'] as String?);
}

/// Result of deleting an AgenticBucket.
class DeleteAgenticBucketResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// Creates a result instance.
  DeleteAgenticBucketResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {};

  /// Creates an instance from JSON.
  factory DeleteAgenticBucketResult.fromJson(Map<String, dynamic> json) =>
      DeleteAgenticBucketResult();
}

/// Request to get AgenticBucket information.
class GetAgenticBucketRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// Logical prefix of the AgenticBucket.
  String? bucket;

  /// Creates a request instance.
  GetAgenticBucketRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'bucket': bucket};

  /// Creates an instance from JSON.
  factory GetAgenticBucketRequest.fromJson(Map<String, dynamic> json) =>
      GetAgenticBucketRequest(bucket: json['bucket'] as String?);
}

/// Result of getting AgenticBucket information.
class GetAgenticBucketResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// Detailed bucket information.
  AgenticBucketInfo? agenticBucketInfo;

  /// Creates a result instance.
  GetAgenticBucketResult({this.agenticBucketInfo, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'agenticBucketInfo': agenticBucketInfo?.toJson(),
  };

  /// Creates an instance from JSON.
  factory GetAgenticBucketResult.fromJson(Map<String, dynamic> json) =>
      GetAgenticBucketResult(
        agenticBucketInfo: json['agenticBucketInfo'] == null
            ? null
            : AgenticBucketInfo.fromJson(
                json['agenticBucketInfo'] as Map<String, dynamic>,
              ),
      );
}

/// Request to list AgenticBuckets in a region; does not require a bucket.
class ListAgenticBucketsRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// Continuation token returned from the previous page.
  String? continuationToken;

  /// Maximum number of items per page; server defaults to 100.
  int? maxKeys;

  /// Creates a request instance.
  ListAgenticBucketsRequest({
    this.continuationToken,
    this.maxKeys,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'continuationToken': continuationToken,
    'maxKeys': maxKeys,
  };

  /// Creates an instance from JSON.
  factory ListAgenticBucketsRequest.fromJson(Map<String, dynamic> json) =>
      ListAgenticBucketsRequest(
        continuationToken: json['continuationToken'] as String?,
        maxKeys: json['maxKeys'] as int?,
      );
}

/// Single-page result of an AgenticBucket listing.
class ListAgenticBucketsResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The region.
  String? region;

  /// Owner account UID.
  String? owner;

  /// Token used for this request.
  String? continuationToken;

  /// Token for the next page.
  String? nextContinuationToken;

  /// Whether there is a next page.
  bool? isTruncated;

  /// Summary list for this page.
  List<AgenticBucketSummary>? agenticBuckets;

  /// Creates a result instance.
  ListAgenticBucketsResult({
    this.region,
    this.owner,
    this.continuationToken,
    this.nextContinuationToken,
    this.isTruncated,
    this.agenticBuckets,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'region': region,
    'owner': owner,
    'continuationToken': continuationToken,
    'nextContinuationToken': nextContinuationToken,
    'isTruncated': isTruncated,
    'agenticBuckets': agenticBuckets?.map((value) => value.toJson()).toList(),
  };

  /// Creates an instance from JSON.
  factory ListAgenticBucketsResult.fromJson(Map<String, dynamic> json) =>
      ListAgenticBucketsResult(
        region: json['region'] as String?,
        owner: json['owner'] as String?,
        continuationToken: json['continuationToken'] as String?,
        nextContinuationToken: json['nextContinuationToken'] as String?,
        isTruncated: json['isTruncated'] as bool?,
        agenticBuckets: (json['agenticBuckets'] as List?)
            ?.map(
              (value) =>
                  AgenticBucketSummary.fromJson(value as Map<String, dynamic>),
            )
            .toList(),
      );
}

/// Request to change the status of an AgenticBucket.
class PutAgenticBucketStatusRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// Logical prefix of the AgenticBucket.
  String? bucket;

  /// Target status: Enabled or Disabled.
  String? status;

  /// Creates a request instance.
  PutAgenticBucketStatusRequest({
    this.bucket,
    this.status,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'bucket': bucket, 'status': status};

  /// Creates an instance from JSON.
  factory PutAgenticBucketStatusRequest.fromJson(Map<String, dynamic> json) =>
      PutAgenticBucketStatusRequest(
        bucket: json['bucket'] as String?,
        status: json['status'] as String?,
      );
}

/// Result of changing an AgenticBucket status.
class PutAgenticBucketStatusResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// Creates a result instance.
  PutAgenticBucketStatusResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {};

  /// Creates an instance from JSON.
  factory PutAgenticBucketStatusResult.fromJson(Map<String, dynamic> json) =>
      PutAgenticBucketStatusResult();
}

/// Request to list BucketSpaces under an AgenticBucket.
class ListBucketSpacesRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// Logical prefix of the parent AgenticBucket.
  String? bucket;

  /// Prefix to filter BucketSpace names.
  String? prefix;

  /// Token returned from the previous page.
  String? continuationToken;

  /// Start listing after this name.
  String? startAfter;

  /// Maximum number of items per page; server defaults to 100.
  int? maxKeys;

  /// Creates a request instance.
  ListBucketSpacesRequest({
    this.bucket,
    this.prefix,
    this.continuationToken,
    this.startAfter,
    this.maxKeys,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'bucket': bucket,
    'prefix': prefix,
    'continuationToken': continuationToken,
    'startAfter': startAfter,
    'maxKeys': maxKeys,
  };

  /// Creates an instance from JSON.
  factory ListBucketSpacesRequest.fromJson(Map<String, dynamic> json) =>
      ListBucketSpacesRequest(
        bucket: json['bucket'] as String?,
        prefix: json['prefix'] as String?,
        continuationToken: json['continuationToken'] as String?,
        startAfter: json['startAfter'] as String?,
        maxKeys: json['maxKeys'] as int?,
      );
}

/// Single-page result of a BucketSpace listing.
class ListBucketSpacesResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// Owner information, including ID and DisplayName.
  Owner? owner;

  /// Requested name prefix.
  String? prefix;

  /// Maximum number of items per page.
  int? maxKeys;

  /// Token used for this request.
  String? continuationToken;

  /// Token for the next page.
  String? nextContinuationToken;

  /// Starting name for the request.
  String? startAfter;

  /// Whether there is a next page.
  bool? isTruncated;

  /// Summary list for this page.
  List<BucketSpaceSummary>? bucketSpaces;

  /// Creates a result instance.
  ListBucketSpacesResult({
    this.owner,
    this.prefix,
    this.maxKeys,
    this.continuationToken,
    this.nextContinuationToken,
    this.startAfter,
    this.isTruncated,
    this.bucketSpaces,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'owner': owner?.toJson(),
    'prefix': prefix,
    'maxKeys': maxKeys,
    'continuationToken': continuationToken,
    'nextContinuationToken': nextContinuationToken,
    'startAfter': startAfter,
    'isTruncated': isTruncated,
    'bucketSpaces': bucketSpaces?.map((value) => value.toJson()).toList(),
  };

  /// Creates an instance from JSON.
  factory ListBucketSpacesResult.fromJson(Map<String, dynamic> json) =>
      ListBucketSpacesResult(
        owner: json['owner'] == null
            ? null
            : Owner.fromJson(json['owner'] as Map<String, dynamic>),
        prefix: json['prefix'] as String?,
        maxKeys: json['maxKeys'] as int?,
        continuationToken: json['continuationToken'] as String?,
        nextContinuationToken: json['nextContinuationToken'] as String?,
        startAfter: json['startAfter'] as String?,
        isTruncated: json['isTruncated'] as bool?,
        bucketSpaces: (json['bucketSpaces'] as List?)
            ?.map(
              (value) =>
                  BucketSpaceSummary.fromJson(value as Map<String, dynamic>),
            )
            .toList(),
      );
}
