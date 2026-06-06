import 'model_types.dart';

/// The container in which the Block Public Access configurations are stored.
class PublicAccessBlockConfiguration {
  /// Specifies whether to enable Block Public Access.
  /// true: enables Block Public Access.
  /// false (default): disables Block Public Access.
  bool? blockPublicAccess;

  PublicAccessBlockConfiguration({this.blockPublicAccess});

  /// Creates a PublicAccessBlockConfiguration instance from a JSON map
  factory PublicAccessBlockConfiguration.fromJson(Map<String, dynamic> json) {
    return PublicAccessBlockConfiguration(
      blockPublicAccess: _parseBool(json['BlockPublicAccess']),
    );
  }

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
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// Request body.
  PublicAccessBlockConfiguration? publicAccessBlockConfiguration;

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
  ResultModelProp commonProp;

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
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

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
  ResultModelProp commonProp;

  /// The container in which the Block Public Access configurations are stored.
  PublicAccessBlockConfiguration? publicAccessBlockConfiguration;

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
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

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
  ResultModelProp commonProp;

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
