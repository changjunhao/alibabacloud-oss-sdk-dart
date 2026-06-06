import 'model_types.dart';
import 'model_bucket_public_access_block.dart';

/// The request for the GetPublicAccessBlock operation.
class GetPublicAccessBlockRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// Creates a GetPublicAccessBlockRequest instance.
  GetPublicAccessBlockRequest({RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetPublicAccessBlockRequest instance from a JSON map
  factory GetPublicAccessBlockRequest.fromJson(Map<String, dynamic> json) {
    return GetPublicAccessBlockRequest();
  }

  /// Converts the GetPublicAccessBlockRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The result for the GetPublicAccessBlock operation.
class GetPublicAccessBlockResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The container in which the Block Public Access configurations are stored.
  PublicAccessBlockConfiguration? publicAccessBlockConfiguration;

  /// Creates a GetPublicAccessBlockResult instance.
  GetPublicAccessBlockResult({
    this.publicAccessBlockConfiguration,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetPublicAccessBlockResult instance from a JSON map
  factory GetPublicAccessBlockResult.fromJson(Map<String, dynamic> json) {
    return GetPublicAccessBlockResult(
      publicAccessBlockConfiguration:
          json['publicAccessBlockConfiguration'] != null
          ? PublicAccessBlockConfiguration.fromJson(
              json['publicAccessBlockConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the GetPublicAccessBlockResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'publicAccessBlockConfiguration': publicAccessBlockConfiguration
          ?.toJson(),
    };
  }
}

/// The request for the PutPublicAccessBlock operation.
class PutPublicAccessBlockRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// Request body.
  PublicAccessBlockConfiguration? publicAccessBlockConfiguration;

  /// Creates a PutPublicAccessBlockRequest instance.
  PutPublicAccessBlockRequest({
    this.publicAccessBlockConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutPublicAccessBlockRequest instance from a JSON map
  factory PutPublicAccessBlockRequest.fromJson(Map<String, dynamic> json) {
    return PutPublicAccessBlockRequest(
      publicAccessBlockConfiguration:
          json['publicAccessBlockConfiguration'] != null
          ? PublicAccessBlockConfiguration.fromJson(
              json['publicAccessBlockConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the PutPublicAccessBlockRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'publicAccessBlockConfiguration': publicAccessBlockConfiguration
          ?.toJson(),
    };
  }
}

/// The result for the PutPublicAccessBlock operation.
class PutPublicAccessBlockResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a PutPublicAccessBlockResult instance.
  PutPublicAccessBlockResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutPublicAccessBlockResult instance from a JSON map
  factory PutPublicAccessBlockResult.fromJson(Map<String, dynamic> json) {
    return PutPublicAccessBlockResult();
  }

  /// Converts the PutPublicAccessBlockResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the DeletePublicAccessBlock operation.
class DeletePublicAccessBlockRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// Creates a DeletePublicAccessBlockRequest instance.
  DeletePublicAccessBlockRequest({RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a DeletePublicAccessBlockRequest instance from a JSON map
  factory DeletePublicAccessBlockRequest.fromJson(Map<String, dynamic> json) {
    return DeletePublicAccessBlockRequest();
  }

  /// Converts the DeletePublicAccessBlockRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The result for the DeletePublicAccessBlock operation.
class DeletePublicAccessBlockResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a DeletePublicAccessBlockResult instance.
  DeletePublicAccessBlockResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a DeletePublicAccessBlockResult instance from a JSON map
  factory DeletePublicAccessBlockResult.fromJson(Map<String, dynamic> json) {
    return DeletePublicAccessBlockResult();
  }

  /// Converts the DeletePublicAccessBlockResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}
