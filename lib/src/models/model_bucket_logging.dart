import 'model_types.dart';

/// The container that stores the information about access log collection.
class LoggingEnabled {
  /// The bucket that stores access logs.
  String? targetBucket;

  /// The prefix of the log objects. This parameter can be left empty.
  String? targetPrefix;

  LoggingEnabled({this.targetBucket, this.targetPrefix});

  /// Creates a LoggingEnabled instance from a JSON map
  factory LoggingEnabled.fromJson(Map<String, dynamic> json) {
    return LoggingEnabled(
      targetBucket: json['TargetBucket'] as String?,
      targetPrefix: json['TargetPrefix'] as String?,
    );
  }

  /// Converts the LoggingEnabled instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'TargetBucket': targetBucket, 'TargetPrefix': targetPrefix};
  }
}

/// Indicates the container used to store access logging configuration of a bucket.
class BucketLoggingStatus {
  /// Indicates the container used to store access logging information. This element is returned if it is enabled and is not returned if it is disabled.
  LoggingEnabled? loggingEnabled;

  BucketLoggingStatus({this.loggingEnabled});

  /// Creates a BucketLoggingStatus instance from a JSON map
  factory BucketLoggingStatus.fromJson(Map<String, dynamic> json) {
    return BucketLoggingStatus(
      loggingEnabled: json['LoggingEnabled'] != null
          ? LoggingEnabled.fromJson(
              json['LoggingEnabled'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the BucketLoggingStatus instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'LoggingEnabled': loggingEnabled?.toJson()};
  }
}

/// The container that stores the configurations of custom request headers.
class HeaderSet {
  /// The list of the custom request headers.
  List<String>? headers;

  HeaderSet({this.headers});

  /// Creates a HeaderSet instance from a JSON map
  factory HeaderSet.fromJson(Map<String, dynamic> json) {
    return HeaderSet(
      headers: json['header'] != null
          ? List<String>.from(json['header'])
          : null,
    );
  }

  /// Converts the HeaderSet instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'header': headers};
  }
}

/// The container that stores the configurations of custom URL parameters.
class ParamSet {
  /// The list of the custom URL parameters.
  List<String>? parameters;

  ParamSet({this.parameters});

  /// Creates a ParamSet instance from a JSON map
  factory ParamSet.fromJson(Map<String, dynamic> json) {
    return ParamSet(
      parameters: json['parameter'] != null
          ? List<String>.from(json['parameter'])
          : null,
    );
  }

  /// Converts the ParamSet instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'parameter': parameters};
  }
}

/// The specified field configurations of real-time logs in a bucket.
class UserDefinedLogFieldsConfiguration {
  /// The container that stores the configurations of custom request headers.
  HeaderSet? headerSet;

  /// The container that stores the configurations of custom URL parameters.
  ParamSet? paramSet;

  UserDefinedLogFieldsConfiguration({this.headerSet, this.paramSet});

  /// Creates a UserDefinedLogFieldsConfiguration instance from a JSON map
  factory UserDefinedLogFieldsConfiguration.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserDefinedLogFieldsConfiguration(
      headerSet: json['HeaderSet'] != null
          ? HeaderSet.fromJson(json['HeaderSet'] as Map<String, dynamic>)
          : null,
      paramSet: json['ParamSet'] != null
          ? ParamSet.fromJson(json['ParamSet'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts the UserDefinedLogFieldsConfiguration instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'HeaderSet': headerSet?.toJson(), 'ParamSet': paramSet?.toJson()};
  }
}

/// The request for the PutBucketLogging operation.
class PutBucketLoggingRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The request body schema.
  BucketLoggingStatus? bucketLoggingStatus;

  PutBucketLoggingRequest({
    this.bucket,
    this.bucketLoggingStatus,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();
}

/// The result for the PutBucketLogging operation.
class PutBucketLoggingResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  PutBucketLoggingResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();
}

/// The request for the GetBucketLogging operation.
class GetBucketLoggingRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  GetBucketLoggingRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();
}

/// The result for the GetBucketLogging operation.
class GetBucketLoggingResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// Indicates the container used to store access logging configuration of a bucket.
  BucketLoggingStatus? bucketLoggingStatus;

  GetBucketLoggingResult({
    this.bucketLoggingStatus,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();
}

/// The request for the DeleteBucketLogging operation.
class DeleteBucketLoggingRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  DeleteBucketLoggingRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();
}

/// The result for the DeleteBucketLogging operation.
class DeleteBucketLoggingResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  DeleteBucketLoggingResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();
}

/// The request for the PutUserDefinedLogFieldsConfig operation.
class PutUserDefinedLogFieldsConfigRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The container that stores the specified log configurations.
  UserDefinedLogFieldsConfiguration? userDefinedLogFieldsConfiguration;

  PutUserDefinedLogFieldsConfigRequest({
    this.bucket,
    this.userDefinedLogFieldsConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();
}

/// The result for the PutUserDefinedLogFieldsConfig operation.
class PutUserDefinedLogFieldsConfigResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  PutUserDefinedLogFieldsConfigResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();
}

/// The request for the GetUserDefinedLogFieldsConfig operation.
class GetUserDefinedLogFieldsConfigRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  GetUserDefinedLogFieldsConfigRequest({
    this.bucket,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();
}

/// The result for the GetUserDefinedLogFieldsConfig operation.
class GetUserDefinedLogFieldsConfigResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The container for the user-defined logging configuration.
  UserDefinedLogFieldsConfiguration? userDefinedLogFieldsConfiguration;

  GetUserDefinedLogFieldsConfigResult({
    this.userDefinedLogFieldsConfiguration,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();
}

/// The request for the DeleteUserDefinedLogFieldsConfig operation.
class DeleteUserDefinedLogFieldsConfigRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  DeleteUserDefinedLogFieldsConfigRequest({
    this.bucket,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();
}

/// The result for the DeleteUserDefinedLogFieldsConfig operation.
class DeleteUserDefinedLogFieldsConfigResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  DeleteUserDefinedLogFieldsConfigResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();
}
