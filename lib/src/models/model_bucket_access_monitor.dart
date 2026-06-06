import 'model_enums.dart';
import 'model_types.dart';

/// The container that stores access monitor configuration.
class AccessMonitorConfiguration {
  /// The access tracking status of the bucket. Valid values:
  /// - Enabled: Access tracking is enabled.
  /// - Disabled: Access tracking is disabled.
  AccessMonitorStatus? status;

  AccessMonitorConfiguration({this.status});

  /// Creates an AccessMonitorConfiguration instance from a JSON map
  factory AccessMonitorConfiguration.fromJson(Map<String, dynamic> json) {
    return AccessMonitorConfiguration(
      status: AccessMonitorStatus.fromString(json['Status'] as String?),
    );
  }

  /// Converts the AccessMonitorConfiguration instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'Status': status?.value};
  }
}

/// The request for the PutBucketAccessMonitor operation.
class PutBucketAccessMonitorRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The request body schema.
  AccessMonitorConfiguration? accessMonitorConfiguration;

  PutBucketAccessMonitorRequest({
    this.bucket,
    this.accessMonitorConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutBucketAccessMonitorRequest instance from a JSON map
  factory PutBucketAccessMonitorRequest.fromJson(Map<String, dynamic> json) {
    return PutBucketAccessMonitorRequest(
      bucket: json['bucket'] as String?,
      accessMonitorConfiguration: json['accessMonitorConfiguration'] != null
          ? AccessMonitorConfiguration.fromJson(
              json['accessMonitorConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the PutBucketAccessMonitorRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'accessMonitorConfiguration': accessMonitorConfiguration?.toJson(),
    };
  }
}

/// The result for the PutBucketAccessMonitor operation.
class PutBucketAccessMonitorResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  PutBucketAccessMonitorResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutBucketAccessMonitorResult instance from a JSON map
  factory PutBucketAccessMonitorResult.fromJson(Map<String, dynamic> json) {
    return PutBucketAccessMonitorResult();
  }

  /// Converts the PutBucketAccessMonitorResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetBucketAccessMonitor operation.
class GetBucketAccessMonitorRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  GetBucketAccessMonitorRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketAccessMonitorRequest instance from a JSON map
  factory GetBucketAccessMonitorRequest.fromJson(Map<String, dynamic> json) {
    return GetBucketAccessMonitorRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the GetBucketAccessMonitorRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketAccessMonitor operation.
class GetBucketAccessMonitorResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The container that stores access monitor configuration.
  AccessMonitorConfiguration? accessMonitorConfiguration;

  GetBucketAccessMonitorResult({
    this.accessMonitorConfiguration,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketAccessMonitorResult instance from a JSON map
  factory GetBucketAccessMonitorResult.fromJson(Map<String, dynamic> json) {
    return GetBucketAccessMonitorResult(
      accessMonitorConfiguration: json['accessMonitorConfiguration'] != null
          ? AccessMonitorConfiguration.fromJson(
              json['accessMonitorConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the GetBucketAccessMonitorResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'accessMonitorConfiguration': accessMonitorConfiguration?.toJson()};
  }
}
