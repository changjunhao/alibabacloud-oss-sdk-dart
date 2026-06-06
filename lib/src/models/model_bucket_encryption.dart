import 'model_types.dart';

/// The container that stores the default server-side encryption method.
class ApplyServerSideEncryptionByDefault {
  /// The default server-side encryption method. Valid values: KMS, AES256, and SM4.
  String? sseAlgorithm;

  /// The CMK ID that is specified when SSEAlgorithm is set to KMS and a specified CMK is used for encryption.
  String? kmsMasterKeyId;

  /// The algorithm that is used to encrypt objects. If this parameter is not specified, objects are encrypted by using AES256. This parameter is valid only when SSEAlgorithm is set to KMS. Valid value: SM4.
  String? kmsDataEncryption;

  /// Creates a ApplyServerSideEncryptionByDefault instance.
  ApplyServerSideEncryptionByDefault({
    this.sseAlgorithm,
    this.kmsMasterKeyId,
    this.kmsDataEncryption,
  });

  /// Creates an instance from a JSON map
  factory ApplyServerSideEncryptionByDefault.fromJson(
    Map<String, dynamic> json,
  ) {
    return ApplyServerSideEncryptionByDefault(
      sseAlgorithm: json['SSEAlgorithm'] as String?,
      kmsMasterKeyId: json['KMSMasterKeyID'] as String?,
      kmsDataEncryption: json['KMSDataEncryption'] as String?,
    );
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'SSEAlgorithm': sseAlgorithm,
      'KMSMasterKeyID': kmsMasterKeyId,
      'KMSDataEncryption': kmsDataEncryption,
    };
  }
}

/// The container that stores server-side encryption rules.
class ServerSideEncryptionRule {
  /// The container that stores the default server-side encryption method.
  ApplyServerSideEncryptionByDefault? applyServerSideEncryptionByDefault;

  /// Creates a ServerSideEncryptionRule instance.
  ServerSideEncryptionRule({this.applyServerSideEncryptionByDefault});

  /// Creates an instance from a JSON map
  factory ServerSideEncryptionRule.fromJson(Map<String, dynamic> json) {
    return ServerSideEncryptionRule(
      applyServerSideEncryptionByDefault:
          json['ApplyServerSideEncryptionByDefault'] != null
          ? ApplyServerSideEncryptionByDefault.fromJson(
              json['ApplyServerSideEncryptionByDefault']
                  as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'ApplyServerSideEncryptionByDefault': applyServerSideEncryptionByDefault
          ?.toJson(),
    };
  }
}

/// The request for the PutBucketEncryption operation.
class PutBucketEncryptionRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The request body schema.
  ServerSideEncryptionRule? serverSideEncryptionRule;

  /// Creates a PutBucketEncryptionRequest instance.
  PutBucketEncryptionRequest({
    this.bucket,
    this.serverSideEncryptionRule,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutBucketEncryptionRequest instance from a JSON map
  factory PutBucketEncryptionRequest.fromJson(Map<String, dynamic> json) {
    return PutBucketEncryptionRequest(
      bucket: json['bucket'] as String?,
      serverSideEncryptionRule: json['serverSideEncryptionRule'] != null
          ? ServerSideEncryptionRule.fromJson(
              json['serverSideEncryptionRule'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'serverSideEncryptionRule': serverSideEncryptionRule?.toJson(),
    };
  }
}

/// The result for the PutBucketEncryption operation.
class PutBucketEncryptionResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a PutBucketEncryptionResult instance.
  PutBucketEncryptionResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutBucketEncryptionResult instance from a JSON map
  factory PutBucketEncryptionResult.fromJson(Map<String, dynamic> json) {
    return PutBucketEncryptionResult();
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetBucketEncryption operation.
class GetBucketEncryptionRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// Creates a GetBucketEncryptionRequest instance.
  GetBucketEncryptionRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketEncryptionRequest instance from a JSON map
  factory GetBucketEncryptionRequest.fromJson(Map<String, dynamic> json) {
    return GetBucketEncryptionRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketEncryption operation.
class GetBucketEncryptionResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The container that stores server-side encryption rules.
  ServerSideEncryptionRule? serverSideEncryptionRule;

  /// Creates a GetBucketEncryptionResult instance.
  GetBucketEncryptionResult({
    this.serverSideEncryptionRule,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketEncryptionResult instance from a JSON map
  factory GetBucketEncryptionResult.fromJson(Map<String, dynamic> json) {
    return GetBucketEncryptionResult(
      serverSideEncryptionRule: json['serverSideEncryptionRule'] != null
          ? ServerSideEncryptionRule.fromJson(
              json['serverSideEncryptionRule'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'serverSideEncryptionRule': serverSideEncryptionRule?.toJson()};
  }
}

/// The request for the DeleteBucketEncryption operation.
class DeleteBucketEncryptionRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// Creates a DeleteBucketEncryptionRequest instance.
  DeleteBucketEncryptionRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a DeleteBucketEncryptionRequest instance from a JSON map
  factory DeleteBucketEncryptionRequest.fromJson(Map<String, dynamic> json) {
    return DeleteBucketEncryptionRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the DeleteBucketEncryption operation.
class DeleteBucketEncryptionResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a DeleteBucketEncryptionResult instance.
  DeleteBucketEncryptionResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a DeleteBucketEncryptionResult instance from a JSON map
  factory DeleteBucketEncryptionResult.fromJson(Map<String, dynamic> json) {
    return DeleteBucketEncryptionResult();
  }

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}
