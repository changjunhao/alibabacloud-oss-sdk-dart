import 'model_enums.dart';
import 'model_types.dart';
import '../transform/serde_extensions.dart';

/// The container that stores the information about retention policies of the bucket.
class WormConfiguration {
  /// The ID of the retention policy.
  String? wormId;

  /// The status of the retention policy. Valid values:
  /// - InProgress: indicates that the retention policy is in the InProgress state.
  /// - Locked: indicates that the retention policy is in the Locked state.
  WormState? state;

  /// The number of days for which objects can be retained.
  int? retentionPeriodInDays;

  /// The time at which the retention policy was created.
  String? creationDate;

  /// The time at which the retention policy will be expired.
  String? expirationDate;

  WormConfiguration({
    this.wormId,
    this.state,
    this.retentionPeriodInDays,
    this.creationDate,
    this.expirationDate,
  });

  /// Creates a WormConfiguration instance from a JSON map
  factory WormConfiguration.fromJson(Map<String, dynamic> json) {
    return WormConfiguration(
      wormId: json['WormId'] as String?,
      state: WormState.fromString(json['State'] as String?),
      retentionPeriodInDays: json['RetentionPeriodInDays'] is int
          ? json['RetentionPeriodInDays'] as int
          : (json['RetentionPeriodInDays'] as String?)?.toInt(),
      creationDate: json['CreationDate'] as String?,
      expirationDate: json['ExpirationDate'] as String?,
    );
  }

  /// Converts the WormConfiguration instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'WormId': wormId,
      'State': state?.value,
      'RetentionPeriodInDays': retentionPeriodInDays,
      'CreationDate': creationDate,
      'ExpirationDate': expirationDate,
    };
  }
}

/// The container that stores the root node for initiating a WORM policy.
class InitiateWormConfiguration {
  /// The number of days for which objects can be retained.
  int? retentionPeriodInDays;

  InitiateWormConfiguration({this.retentionPeriodInDays});

  /// Creates an InitiateWormConfiguration instance from a JSON map
  factory InitiateWormConfiguration.fromJson(Map<String, dynamic> json) {
    return InitiateWormConfiguration(
      retentionPeriodInDays: json['RetentionPeriodInDays'] is int
          ? json['RetentionPeriodInDays'] as int
          : (json['RetentionPeriodInDays'] as String?)?.toInt(),
    );
  }

  /// Converts the InitiateWormConfiguration instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'RetentionPeriodInDays': retentionPeriodInDays};
  }
}

/// The container that stores the root node for extending a WORM policy.
class ExtendWormConfiguration {
  /// The number of days for which objects can be retained.
  int? retentionPeriodInDays;

  ExtendWormConfiguration({this.retentionPeriodInDays});

  /// Creates an ExtendWormConfiguration instance from a JSON map
  factory ExtendWormConfiguration.fromJson(Map<String, dynamic> json) {
    return ExtendWormConfiguration(
      retentionPeriodInDays: json['RetentionPeriodInDays'] is int
          ? json['RetentionPeriodInDays'] as int
          : (json['RetentionPeriodInDays'] as String?)?.toInt(),
    );
  }

  /// Converts the ExtendWormConfiguration instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'RetentionPeriodInDays': retentionPeriodInDays};
  }
}

/// The request for the InitiateBucketWorm operation.
class InitiateBucketWormRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The container of the request body.
  InitiateWormConfiguration? initiateWormConfiguration;

  InitiateBucketWormRequest({
    this.bucket,
    this.initiateWormConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates an InitiateBucketWormRequest instance from a JSON map
  factory InitiateBucketWormRequest.fromJson(Map<String, dynamic> json) {
    return InitiateBucketWormRequest(
      bucket: json['bucket'] as String?,
      initiateWormConfiguration: json['initiateWormConfiguration'] != null
          ? InitiateWormConfiguration.fromJson(
              json['initiateWormConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the InitiateBucketWormRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'initiateWormConfiguration': initiateWormConfiguration?.toJson(),
    };
  }
}

/// The result for the InitiateBucketWorm operation.
class InitiateBucketWormResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The ID of the retention policy from response header x-oss-worm-id.
  String? get wormId => commonProp.headers?.getCaseInsensitive('x-oss-worm-id');

  InitiateBucketWormResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates an InitiateBucketWormResult instance from a JSON map
  factory InitiateBucketWormResult.fromJson(Map<String, dynamic> json) {
    return InitiateBucketWormResult();
  }

  /// Converts the InitiateBucketWormResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the AbortBucketWorm operation.
class AbortBucketWormRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  AbortBucketWormRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates an AbortBucketWormRequest instance from a JSON map
  factory AbortBucketWormRequest.fromJson(Map<String, dynamic> json) {
    return AbortBucketWormRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the AbortBucketWormRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the AbortBucketWorm operation.
class AbortBucketWormResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  AbortBucketWormResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates an AbortBucketWormResult instance from a JSON map
  factory AbortBucketWormResult.fromJson(Map<String, dynamic> json) {
    return AbortBucketWormResult();
  }

  /// Converts the AbortBucketWormResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the CompleteBucketWorm operation.
class CompleteBucketWormRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The ID of the retention policy.
  String? wormId;

  CompleteBucketWormRequest({
    this.bucket,
    this.wormId,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a CompleteBucketWormRequest instance from a JSON map
  factory CompleteBucketWormRequest.fromJson(Map<String, dynamic> json) {
    return CompleteBucketWormRequest(
      bucket: json['bucket'] as String?,
      wormId: json['wormId'] as String?,
    );
  }

  /// Converts the CompleteBucketWormRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'wormId': wormId};
  }
}

/// The result for the CompleteBucketWorm operation.
class CompleteBucketWormResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  CompleteBucketWormResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a CompleteBucketWormResult instance from a JSON map
  factory CompleteBucketWormResult.fromJson(Map<String, dynamic> json) {
    return CompleteBucketWormResult();
  }

  /// Converts the CompleteBucketWormResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the ExtendBucketWorm operation.
class ExtendBucketWormRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The ID of the retention policy.
  String? wormId;

  /// The container of the request body.
  ExtendWormConfiguration? extendWormConfiguration;

  ExtendBucketWormRequest({
    this.bucket,
    this.wormId,
    this.extendWormConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates an ExtendBucketWormRequest instance from a JSON map
  factory ExtendBucketWormRequest.fromJson(Map<String, dynamic> json) {
    return ExtendBucketWormRequest(
      bucket: json['bucket'] as String?,
      wormId: json['wormId'] as String?,
      extendWormConfiguration: json['extendWormConfiguration'] != null
          ? ExtendWormConfiguration.fromJson(
              json['extendWormConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the ExtendBucketWormRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'wormId': wormId,
      'extendWormConfiguration': extendWormConfiguration?.toJson(),
    };
  }
}

/// The result for the ExtendBucketWorm operation.
class ExtendBucketWormResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  ExtendBucketWormResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates an ExtendBucketWormResult instance from a JSON map
  factory ExtendBucketWormResult.fromJson(Map<String, dynamic> json) {
    return ExtendBucketWormResult();
  }

  /// Converts the ExtendBucketWormResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetBucketWorm operation.
class GetBucketWormRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  GetBucketWormRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketWormRequest instance from a JSON map
  factory GetBucketWormRequest.fromJson(Map<String, dynamic> json) {
    return GetBucketWormRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the GetBucketWormRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketWorm operation.
class GetBucketWormResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The container that stores the information about retention policies of the bucket.
  WormConfiguration? wormConfiguration;

  GetBucketWormResult({this.wormConfiguration, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketWormResult instance from a JSON map
  factory GetBucketWormResult.fromJson(Map<String, dynamic> json) {
    return GetBucketWormResult(
      wormConfiguration: json['wormConfiguration'] != null
          ? WormConfiguration.fromJson(
              json['wormConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the GetBucketWormResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'wormConfiguration': wormConfiguration?.toJson()};
  }
}
