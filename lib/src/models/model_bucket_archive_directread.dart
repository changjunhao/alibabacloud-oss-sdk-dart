import 'model_types.dart';

/// The container that stores the configurations for real-time access of Archive objects.
class ArchiveDirectReadConfiguration {
  /// Specifies whether to enable real-time access of Archive objects for a bucket.
  /// Valid values:
  /// - true
  /// - false
  bool? enabled;

  /// Creates a ArchiveDirectReadConfiguration instance.
  ArchiveDirectReadConfiguration({this.enabled});

  /// Creates an ArchiveDirectReadConfiguration instance from a JSON map
  factory ArchiveDirectReadConfiguration.fromJson(Map<String, dynamic> json) {
    return ArchiveDirectReadConfiguration(enabled: _parseBool(json['Enabled']));
  }

  /// Creates a ArchiveDirectReadConfiguration value using `_parseBool` parameters.
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  /// Converts the ArchiveDirectReadConfiguration instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'Enabled': enabled};
  }
}

/// The request for the GetBucketArchiveDirectRead operation.
class GetBucketArchiveDirectReadRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// Creates a GetBucketArchiveDirectReadRequest instance.
  GetBucketArchiveDirectReadRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketArchiveDirectReadRequest instance from a JSON map
  factory GetBucketArchiveDirectReadRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return GetBucketArchiveDirectReadRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the GetBucketArchiveDirectReadRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketArchiveDirectRead operation.
class GetBucketArchiveDirectReadResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The container that stores the configurations for real-time access of Archive objects.
  ArchiveDirectReadConfiguration? archiveDirectReadConfiguration;

  /// Creates a GetBucketArchiveDirectReadResult instance.
  GetBucketArchiveDirectReadResult({
    this.archiveDirectReadConfiguration,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketArchiveDirectReadResult instance from a JSON map
  factory GetBucketArchiveDirectReadResult.fromJson(Map<String, dynamic> json) {
    return GetBucketArchiveDirectReadResult(
      archiveDirectReadConfiguration:
          json['archiveDirectReadConfiguration'] != null
          ? ArchiveDirectReadConfiguration.fromJson(
              json['archiveDirectReadConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the GetBucketArchiveDirectReadResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'archiveDirectReadConfiguration': archiveDirectReadConfiguration
          ?.toJson(),
    };
  }
}

/// The request for the PutBucketArchiveDirectRead operation.
class PutBucketArchiveDirectReadRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The request body.
  ArchiveDirectReadConfiguration? archiveDirectReadConfiguration;

  /// Creates a PutBucketArchiveDirectReadRequest instance.
  PutBucketArchiveDirectReadRequest({
    this.bucket,
    this.archiveDirectReadConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutBucketArchiveDirectReadRequest instance from a JSON map
  factory PutBucketArchiveDirectReadRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return PutBucketArchiveDirectReadRequest(
      bucket: json['bucket'] as String?,
      archiveDirectReadConfiguration:
          json['archiveDirectReadConfiguration'] != null
          ? ArchiveDirectReadConfiguration.fromJson(
              json['archiveDirectReadConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the PutBucketArchiveDirectReadRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'archiveDirectReadConfiguration': archiveDirectReadConfiguration
          ?.toJson(),
    };
  }
}

/// The result for the PutBucketArchiveDirectRead operation.
class PutBucketArchiveDirectReadResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a PutBucketArchiveDirectReadResult instance.
  PutBucketArchiveDirectReadResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutBucketArchiveDirectReadResult instance from a JSON map
  factory PutBucketArchiveDirectReadResult.fromJson(Map<String, dynamic> json) {
    return PutBucketArchiveDirectReadResult();
  }

  /// Converts the PutBucketArchiveDirectReadResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}
