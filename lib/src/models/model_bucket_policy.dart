import 'model_types.dart';

/// The container that stores public access information.
class PolicyStatus {
  /// Indicates whether the current bucket policy allows public access.
  bool? isPublic;

  PolicyStatus({this.isPublic});

  /// Creates an instance from a JSON map
  factory PolicyStatus.fromJson(Map<String, dynamic> json) {
    final isPublicValue = json['IsPublic'];
    bool? isPublic;
    if (isPublicValue is bool) {
      isPublic = isPublicValue;
    } else if (isPublicValue is String) {
      isPublic = isPublicValue.toLowerCase() == 'true';
    }
    return PolicyStatus(isPublic: isPublic);
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'IsPublic': isPublic};
  }
}

/// The request for the PutBucketPolicy operation.
class PutBucketPolicyRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The request body (policy JSON string).
  String? body;

  PutBucketPolicyRequest({this.bucket, this.body, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutBucketPolicyRequest instance from a JSON map
  factory PutBucketPolicyRequest.fromJson(Map<String, dynamic> json) {
    return PutBucketPolicyRequest(
      bucket: json['bucket'] as String?,
      body: json['body'] as String?,
    );
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'body': body};
  }
}

/// The result for the PutBucketPolicy operation.
class PutBucketPolicyResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  PutBucketPolicyResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutBucketPolicyResult instance from a JSON map
  factory PutBucketPolicyResult.fromJson(Map<String, dynamic> json) {
    return PutBucketPolicyResult();
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetBucketPolicy operation.
class GetBucketPolicyRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  GetBucketPolicyRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketPolicyRequest instance from a JSON map
  factory GetBucketPolicyRequest.fromJson(Map<String, dynamic> json) {
    return GetBucketPolicyRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketPolicy operation.
class GetBucketPolicyResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The policy body content.
  String? body;

  GetBucketPolicyResult({this.body, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketPolicyResult instance from a JSON map
  factory GetBucketPolicyResult.fromJson(Map<String, dynamic> json) {
    return GetBucketPolicyResult(body: json['body'] as String?);
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'body': body};
  }
}

/// The request for the DeleteBucketPolicy operation.
class DeleteBucketPolicyRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  DeleteBucketPolicyRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a DeleteBucketPolicyRequest instance from a JSON map
  factory DeleteBucketPolicyRequest.fromJson(Map<String, dynamic> json) {
    return DeleteBucketPolicyRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the DeleteBucketPolicy operation.
class DeleteBucketPolicyResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  DeleteBucketPolicyResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a DeleteBucketPolicyResult instance from a JSON map
  factory DeleteBucketPolicyResult.fromJson(Map<String, dynamic> json) {
    return DeleteBucketPolicyResult();
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetBucketPolicyStatus operation.
class GetBucketPolicyStatusRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  GetBucketPolicyStatusRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketPolicyStatusRequest instance from a JSON map
  factory GetBucketPolicyStatusRequest.fromJson(Map<String, dynamic> json) {
    return GetBucketPolicyStatusRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketPolicyStatus operation.
class GetBucketPolicyStatusResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The container that stores public access information.
  PolicyStatus? policyStatus;

  GetBucketPolicyStatusResult({this.policyStatus, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketPolicyStatusResult instance from a JSON map
  factory GetBucketPolicyStatusResult.fromJson(Map<String, dynamic> json) {
    return GetBucketPolicyStatusResult(
      policyStatus: json['policyStatus'] != null
          ? PolicyStatus.fromJson(json['policyStatus'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'policyStatus': policyStatus?.toJson()};
  }
}
