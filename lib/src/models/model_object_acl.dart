import 'model_shared.dart';
import 'model_types.dart';
import '../transform/serde_extensions.dart';

/// The request for the PutObjectAcl operation.
class PutObjectAclRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The name of the object.
  String? key;

  /// The access control list (ACL) of the object.
  /// Sees ObjectACLType for supported values.
  String? objectAcl;

  /// The version id of the object.
  String? versionId;

  PutObjectAclRequest({
    this.bucket,
    this.key,
    this.objectAcl,
    this.versionId,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutObjectAclRequest instance from a JSON map
  factory PutObjectAclRequest.fromJson(Map<String, dynamic> json) {
    return PutObjectAclRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      objectAcl: json['objectAcl'] as String?,
      versionId: json['versionId'] as String?,
    );
  }

  /// Converts the PutObjectAclRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'objectAcl': objectAcl,
      'versionId': versionId,
    };
  }
}

/// The result for the PutObjectAcl operation.
class PutObjectAclResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// Version of the object.
  String? get versionId =>
      commonProp.headers?.getCaseInsensitive('x-oss-version-id');

  PutObjectAclResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutObjectAclResult instance from a JSON map
  factory PutObjectAclResult.fromJson(Map<String, dynamic> json) {
    return PutObjectAclResult();
  }

  /// Converts the PutObjectAclResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetObjectAcl operation.
class GetObjectAclRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The name of the object.
  String? key;

  /// The version id of the target object.
  String? versionId;

  GetObjectAclRequest({
    this.bucket,
    this.key,
    this.versionId,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetObjectAclRequest instance from a JSON map
  factory GetObjectAclRequest.fromJson(Map<String, dynamic> json) {
    return GetObjectAclRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      versionId: json['versionId'] as String?,
    );
  }

  /// Converts the GetObjectAclRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'key': key, 'versionId': versionId};
  }
}

/// The result for the GetObjectAcl operation.
class GetObjectAclResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The container that stores the results of the GetObjectACL request.
  AccessControlPolicy? accessControlPolicy;

  GetObjectAclResult({this.accessControlPolicy, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetObjectAclResult instance from a JSON map
  factory GetObjectAclResult.fromJson(Map<String, dynamic> json) {
    return GetObjectAclResult(
      accessControlPolicy: json['accessControlPolicy'] != null
          ? AccessControlPolicy.fromJson(
              json['accessControlPolicy'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the GetObjectAclResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'accessControlPolicy': accessControlPolicy?.toJson()};
  }
}
