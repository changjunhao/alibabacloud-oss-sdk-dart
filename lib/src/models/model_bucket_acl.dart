import 'model_shared.dart';
import 'model_types.dart';

/// The request for the PutBucketAcl operation.
class PutBucketAclRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The ACL that you want to configure or modify for the bucket. The x-oss-acl header is included in PutBucketAcl requests to configure or modify the ACL of the bucket. If this header is not included, the ACL configurations do not take effect.
  /// Valid values:
  ///    public-read-write: All users can read and write objects in the bucket. Exercise caution when you set the value to public-read-write.
  ///    public-read: Only the owner and authorized users of the bucket can read and write objects in the bucket. Other users can only read objects in the bucket. Exercise caution when you set the value to public-read.
  ///    private: Only the owner and authorized users of this bucket can read and write objects in the bucket. Other users cannot access objects in the bucket.
  /// Sees CannedAccessControlList for supported values.
  String? acl;

  PutBucketAclRequest({this.bucket, this.acl, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'acl': acl};
  }
}

/// The result for the PutBucketAcl operation.
class PutBucketAclResponse extends ResultModel {
  @override
  ResultModelProp commonProp = ResultModelProp();

  PutBucketAclResponse();

  factory PutBucketAclResponse.fromJson(Map<String, dynamic> json) {
    return PutBucketAclResponse();
  }
}

/// The request for the GetBucketAcl operation.
class GetBucketAclRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  GetBucketAclRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketAcl operation.
class GetBucketAclResponse extends ResultModel {
  @override
  ResultModelProp commonProp = ResultModelProp();

  /// The container that stores the ACL information.
  AccessControlPolicy? accessControlPolicy;

  GetBucketAclResponse({this.accessControlPolicy});

  factory GetBucketAclResponse.fromJson(Map<String, dynamic> json) {
    return GetBucketAclResponse(
      accessControlPolicy: json['accessControlPolicy'] != null
          ? AccessControlPolicy.fromJson(
              json['accessControlPolicy'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
