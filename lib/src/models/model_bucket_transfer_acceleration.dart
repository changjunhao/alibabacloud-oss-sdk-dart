import 'model_types.dart';
import '../transform/serde_extensions.dart';

/// The container that stores the transfer acceleration configurations.
class TransferAccelerationConfiguration {
  /// Whether the transfer acceleration is enabled for this bucket.
  bool? enabled;

  /// Creates a TransferAccelerationConfiguration instance.
  TransferAccelerationConfiguration({this.enabled});

  /// Creates a TransferAccelerationConfiguration instance from a JSON map
  factory TransferAccelerationConfiguration.fromJson(
    Map<String, dynamic> json,
  ) {
    final enabledValue = json['Enabled'];
    bool? enabled;
    if (enabledValue is bool) {
      enabled = enabledValue;
    } else if (enabledValue is String) {
      enabled = enabledValue.toBool();
    }
    return TransferAccelerationConfiguration(enabled: enabled);
  }

  /// Converts the TransferAccelerationConfiguration instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'Enabled': enabled};
  }
}

/// The request for the PutBucketTransferAcceleration operation.
class PutBucketTransferAccelerationRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The container of the request body.
  TransferAccelerationConfiguration? transferAccelerationConfiguration;

  /// Creates a PutBucketTransferAccelerationRequest instance.
  PutBucketTransferAccelerationRequest({
    this.bucket,
    this.transferAccelerationConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutBucketTransferAccelerationRequest instance from a JSON map
  factory PutBucketTransferAccelerationRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return PutBucketTransferAccelerationRequest(
      bucket: json['bucket'] as String?,
      transferAccelerationConfiguration:
          json['transferAccelerationConfiguration'] != null
          ? TransferAccelerationConfiguration.fromJson(
              json['transferAccelerationConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the PutBucketTransferAccelerationRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'transferAccelerationConfiguration': transferAccelerationConfiguration
          ?.toJson(),
    };
  }
}

/// The result for the PutBucketTransferAcceleration operation.
class PutBucketTransferAccelerationResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a PutBucketTransferAccelerationResult instance.
  PutBucketTransferAccelerationResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutBucketTransferAccelerationResult instance from a JSON map
  factory PutBucketTransferAccelerationResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return PutBucketTransferAccelerationResult();
  }

  /// Converts the PutBucketTransferAccelerationResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetBucketTransferAcceleration operation.
class GetBucketTransferAccelerationRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// Creates a GetBucketTransferAccelerationRequest instance.
  GetBucketTransferAccelerationRequest({
    this.bucket,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketTransferAccelerationRequest instance from a JSON map
  factory GetBucketTransferAccelerationRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return GetBucketTransferAccelerationRequest(
      bucket: json['bucket'] as String?,
    );
  }

  /// Converts the GetBucketTransferAccelerationRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketTransferAcceleration operation.
class GetBucketTransferAccelerationResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The container that stores the transfer acceleration configurations.
  TransferAccelerationConfiguration? transferAccelerationConfiguration;

  /// Creates a GetBucketTransferAccelerationResult instance.
  GetBucketTransferAccelerationResult({
    this.transferAccelerationConfiguration,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketTransferAccelerationResult instance from a JSON map
  factory GetBucketTransferAccelerationResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return GetBucketTransferAccelerationResult(
      transferAccelerationConfiguration:
          json['transferAccelerationConfiguration'] != null
          ? TransferAccelerationConfiguration.fromJson(
              json['transferAccelerationConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the GetBucketTransferAccelerationResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'transferAccelerationConfiguration': transferAccelerationConfiguration
          ?.toJson(),
    };
  }
}
