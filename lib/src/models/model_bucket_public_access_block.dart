import 'model_types.dart';

/// The container in which the Block Public Access configurations are stored.
class PublicAccessBlockConfiguration {
  /// Specifies whether to enable Block Public Access.
  /// true: enables Block Public Access.
  /// false (default): disables Block Public Access.
  bool? blockPublicAccess;

  /// Creates a PublicAccessBlockConfiguration instance.
  PublicAccessBlockConfiguration({this.blockPublicAccess});

  /// Creates a PublicAccessBlockConfiguration instance from a JSON map
  factory PublicAccessBlockConfiguration.fromJson(Map<String, dynamic> json) {
    return PublicAccessBlockConfiguration(
      blockPublicAccess: _parseBool(json['BlockPublicAccess']),
    );
  }

  /// Creates a PublicAccessBlockConfiguration value using `_parseBool` parameters.
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  /// Converts the PublicAccessBlockConfiguration instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'BlockPublicAccess': blockPublicAccess};
  }
}

/// The request for the PutBucketPublicAccessBlock operation.
class PutBucketPublicAccessBlockRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// Request body.
  PublicAccessBlockConfiguration? publicAccessBlockConfiguration;

  /// Creates a PutBucketPublicAccessBlockRequest instance.
  PutBucketPublicAccessBlockRequest({
    this.bucket,
    this.publicAccessBlockConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutBucketPublicAccessBlockRequest instance from a JSON map
  factory PutBucketPublicAccessBlockRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return PutBucketPublicAccessBlockRequest(
      bucket: json['bucket'] as String?,
      publicAccessBlockConfiguration:
          json['publicAccessBlockConfiguration'] != null
          ? PublicAccessBlockConfiguration.fromJson(
              json['publicAccessBlockConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the PutBucketPublicAccessBlockRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'publicAccessBlockConfiguration': publicAccessBlockConfiguration
          ?.toJson(),
    };
  }
}

/// The result for the PutBucketPublicAccessBlock operation.
class PutBucketPublicAccessBlockResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a PutBucketPublicAccessBlockResult instance.
  PutBucketPublicAccessBlockResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutBucketPublicAccessBlockResult instance from a JSON map
  factory PutBucketPublicAccessBlockResult.fromJson(Map<String, dynamic> json) {
    return PutBucketPublicAccessBlockResult();
  }

  /// Converts the PutBucketPublicAccessBlockResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetBucketPublicAccessBlock operation.
class GetBucketPublicAccessBlockRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// Creates a GetBucketPublicAccessBlockRequest instance.
  GetBucketPublicAccessBlockRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketPublicAccessBlockRequest instance from a JSON map
  factory GetBucketPublicAccessBlockRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return GetBucketPublicAccessBlockRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the GetBucketPublicAccessBlockRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketPublicAccessBlock operation.
class GetBucketPublicAccessBlockResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The container in which the Block Public Access configurations are stored.
  PublicAccessBlockConfiguration? publicAccessBlockConfiguration;

  /// Creates a GetBucketPublicAccessBlockResult instance.
  GetBucketPublicAccessBlockResult({
    this.publicAccessBlockConfiguration,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketPublicAccessBlockResult instance from a JSON map
  factory GetBucketPublicAccessBlockResult.fromJson(Map<String, dynamic> json) {
    return GetBucketPublicAccessBlockResult(
      publicAccessBlockConfiguration:
          json['publicAccessBlockConfiguration'] != null
          ? PublicAccessBlockConfiguration.fromJson(
              json['publicAccessBlockConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the GetBucketPublicAccessBlockResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'publicAccessBlockConfiguration': publicAccessBlockConfiguration
          ?.toJson(),
    };
  }
}

/// The request for the DeleteBucketPublicAccessBlock operation.
class DeleteBucketPublicAccessBlockRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// Creates a DeleteBucketPublicAccessBlockRequest instance.
  DeleteBucketPublicAccessBlockRequest({
    this.bucket,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a DeleteBucketPublicAccessBlockRequest instance from a JSON map
  factory DeleteBucketPublicAccessBlockRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return DeleteBucketPublicAccessBlockRequest(
      bucket: json['bucket'] as String?,
    );
  }

  /// Converts the DeleteBucketPublicAccessBlockRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the DeleteBucketPublicAccessBlock operation.
class DeleteBucketPublicAccessBlockResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a DeleteBucketPublicAccessBlockResult instance.
  DeleteBucketPublicAccessBlockResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a DeleteBucketPublicAccessBlockResult instance from a JSON map
  factory DeleteBucketPublicAccessBlockResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return DeleteBucketPublicAccessBlockResult();
  }

  /// Converts the DeleteBucketPublicAccessBlockResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}
