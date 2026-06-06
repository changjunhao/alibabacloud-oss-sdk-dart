import 'model_types.dart';

/// The configurations of the resource group to which the bucket belongs.
class BucketResourceGroupConfiguration {
  /// The ID of the resource group to which the bucket belongs.
  String? resourceGroupId;

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
  RequestModelProp commonProp;

  /// The name of the bucket that you want to query.
  String? bucket;

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
  ResultModelProp commonProp;

  /// The container that stores the ID of the resource group.
  BucketResourceGroupConfiguration? bucketResourceGroupConfiguration;

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
  RequestModelProp commonProp;

  /// The bucket for which you want to modify the ID of the resource group.
  String? bucket;

  /// The request body schema.
  BucketResourceGroupConfiguration? bucketResourceGroupConfiguration;

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
  ResultModelProp commonProp;

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
