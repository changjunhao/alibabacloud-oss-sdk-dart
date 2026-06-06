import 'model_types.dart';

/// The configurations of the resource group to which the bucket belongs.
class BucketResourceGroupConfiguration {
  /// The ID of the resource group to which the bucket belongs.
  String? resourceGroupId;

  /// Creates a BucketResourceGroupConfiguration instance.
  BucketResourceGroupConfiguration({this.resourceGroupId});

  /// Creates an instance from a JSON map
  factory BucketResourceGroupConfiguration.fromJson(Map<String, dynamic> json) {
    return BucketResourceGroupConfiguration(
      resourceGroupId: json['ResourceGroupId'] as String?,
    );
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'ResourceGroupId': resourceGroupId};
  }
}

/// The request for the GetBucketResourceGroup operation.
class GetBucketResourceGroupRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket that you want to query.
  String? bucket;

  /// Creates a GetBucketResourceGroupRequest instance.
  GetBucketResourceGroupRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketResourceGroupRequest instance from a JSON map
  factory GetBucketResourceGroupRequest.fromJson(Map<String, dynamic> json) {
    return GetBucketResourceGroupRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketResourceGroup operation.
class GetBucketResourceGroupResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The container that stores the ID of the resource group.
  BucketResourceGroupConfiguration? bucketResourceGroupConfiguration;

  /// Creates a GetBucketResourceGroupResult instance.
  GetBucketResourceGroupResult({
    this.bucketResourceGroupConfiguration,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketResourceGroupResult instance from a JSON map
  factory GetBucketResourceGroupResult.fromJson(Map<String, dynamic> json) {
    return GetBucketResourceGroupResult(
      bucketResourceGroupConfiguration:
          json['bucketResourceGroupConfiguration'] != null
          ? BucketResourceGroupConfiguration.fromJson(
              json['bucketResourceGroupConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucketResourceGroupConfiguration': bucketResourceGroupConfiguration
          ?.toJson(),
    };
  }
}

/// The request for the PutBucketResourceGroup operation.
class PutBucketResourceGroupRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The bucket for which you want to modify the ID of the resource group.
  String? bucket;

  /// The request body schema.
  BucketResourceGroupConfiguration? bucketResourceGroupConfiguration;

  /// Creates a PutBucketResourceGroupRequest instance.
  PutBucketResourceGroupRequest({
    this.bucket,
    this.bucketResourceGroupConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutBucketResourceGroupRequest instance from a JSON map
  factory PutBucketResourceGroupRequest.fromJson(Map<String, dynamic> json) {
    return PutBucketResourceGroupRequest(
      bucket: json['bucket'] as String?,
      bucketResourceGroupConfiguration:
          json['bucketResourceGroupConfiguration'] != null
          ? BucketResourceGroupConfiguration.fromJson(
              json['bucketResourceGroupConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'bucketResourceGroupConfiguration': bucketResourceGroupConfiguration
          ?.toJson(),
    };
  }
}

/// The result for the PutBucketResourceGroup operation.
class PutBucketResourceGroupResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a PutBucketResourceGroupResult instance.
  PutBucketResourceGroupResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutBucketResourceGroupResult instance from a JSON map
  factory PutBucketResourceGroupResult.fromJson(Map<String, dynamic> json) {
    return PutBucketResourceGroupResult();
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}
