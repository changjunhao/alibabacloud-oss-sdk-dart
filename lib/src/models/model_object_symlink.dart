import 'model_types.dart';
import '../transform/serde_extensions.dart';

/// The request for the PutSymlink operation.
class PutSymlinkRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The target object to which the symbolic link points. The naming conventions for target objects are the same as those for objects.
  /// - Similar to ObjectName, TargetObjectName must be URL-encoded.
  /// - The target object to which a symbolic link points cannot be a symbolic link.
  String? symlinkTarget;

  /// The access control list (ACL) of the object. Default value: default. Valid values:- default: The ACL of the object is the same as that of the bucket in which the object is stored.
  /// - private: The ACL of the object is private. Only the owner of the object and authorized users can read and write this object.
  /// - public-read: The ACL of the object is public-read. Only the owner of the object and authorized users can read and write this object. Other users can only read the object. Exercise caution when you set the object ACL to this value.
  /// - public-read-write: The ACL of the object is public-read-write. All users can read and write this object. Exercise caution when you set the object ACL to this value.
  /// For more information about the ACL, see **[ACL](~~100676~~)**.
  /// Sees ObjectACLType for supported values.
  String? objectAcl;

  /// The storage class of the bucket. Default value: Standard.  Valid values:- Standard- IA- Archive- ColdArchive
  /// Sees StorageClassType for supported values.
  String? storageClass;

  /// Specifies whether the PutSymlink operation overwrites the object that has the same name as that of the symbolic link you want to create.
  /// - If the value of **x-oss-forbid-overwrite** is not specified or set to **false**, existing objects can be overwritten by objects that have the same names.
  /// - If the value of **x-oss-forbid-overwrite** is set to **true**, existing objects cannot be overwritten by objects that have the same names.
  /// If you specify the **x-oss-forbid-overwrite** request header, the queries per second (QPS) performance of OSS is degraded. If you want to use the **x-oss-forbid-overwrite** request header to perform a large number of operations (QPS greater than 1,000), contact technical support.  The **x-oss-forbid-overwrite** request header is invalid when versioning is enabled or suspended for the destination bucket. In this case, the object with the same name can be overwritten.
  bool? forbidOverwrite;

  PutSymlinkRequest({
    this.bucket,
    this.key,
    this.symlinkTarget,
    this.objectAcl,
    this.storageClass,
    this.forbidOverwrite,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutSymlinkRequest instance from a JSON map
  factory PutSymlinkRequest.fromJson(Map<String, dynamic> json) {
    return PutSymlinkRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      symlinkTarget: json['symlinkTarget'] as String?,
      objectAcl: json['objectAcl'] as String?,
      storageClass: json['storageClass'] as String?,
      forbidOverwrite: json['forbidOverwrite'] as bool?,
    );
  }

  /// Converts the PutSymlinkRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'symlinkTarget': symlinkTarget,
      'objectAcl': objectAcl,
      'storageClass': storageClass,
      'forbidOverwrite': forbidOverwrite,
    };
  }
}

/// The result for the PutSymlink operation.
class PutSymlinkResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// Version ID of the object.
  String? get versionId =>
      commonProp.headers?.getCaseInsensitive('x-oss-version-id');

  PutSymlinkResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutSymlinkResult instance from a JSON map
  factory PutSymlinkResult.fromJson(Map<String, dynamic> json) {
    return PutSymlinkResult();
  }

  /// Converts the PutSymlinkResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetSymlink operation.
class GetSymlinkRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The version of the object to which the symbolic link points.
  String? versionId;

  GetSymlinkRequest({
    this.bucket,
    this.key,
    this.versionId,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetSymlinkRequest instance from a JSON map
  factory GetSymlinkRequest.fromJson(Map<String, dynamic> json) {
    return GetSymlinkRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      versionId: json['versionId'] as String?,
    );
  }

  /// Converts the GetSymlinkRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'key': key, 'versionId': versionId};
  }
}

/// The result for the GetSymlink operation.
class GetSymlinkResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The target object to which the symbolic link points.
  String? get symlinkTarget =>
      commonProp.headers?.getCaseInsensitive('x-oss-symlink-target');

  /// Version ID of the object.
  String? get versionId =>
      commonProp.headers?.getCaseInsensitive('x-oss-version-id');

  GetSymlinkResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetSymlinkResult instance from a JSON map
  factory GetSymlinkResult.fromJson(Map<String, dynamic> json) {
    return GetSymlinkResult();
  }

  /// Converts the GetSymlinkResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}
