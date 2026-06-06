import 'model_types.dart';
import 'model_bucket_public_access_block.dart';

/// The request for the GetPublicAccessBlock operation.
class GetPublicAccessBlockRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

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
  ResultModelProp commonProp;

  /// The container in which the Block Public Access configurations are stored.
  PublicAccessBlockConfiguration? publicAccessBlockConfiguration;

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
  RequestModelProp commonProp;

  /// Request body.
  PublicAccessBlockConfiguration? publicAccessBlockConfiguration;

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
  ResultModelProp commonProp;

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
  RequestModelProp commonProp;

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
  ResultModelProp commonProp;

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
