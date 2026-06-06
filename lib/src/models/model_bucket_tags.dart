import 'model_types.dart';
import 'model_object_tagging.dart';

/// The request for the PutBucketTags operation.
class PutBucketTagsRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The request body schema.
  Tagging? tagging;

  PutBucketTagsRequest({
    this.bucket,
    this.tagging,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutBucketTagsRequest instance from a JSON map
  factory PutBucketTagsRequest.fromJson(Map<String, dynamic> json) {
    return PutBucketTagsRequest(
      bucket: json['bucket'] as String?,
      tagging: json['tagging'] != null
          ? Tagging.fromJson(json['tagging'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts the PutBucketTagsRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'tagging': tagging?.toJson()};
  }
}

/// The result for the PutBucketTags operation.
class PutBucketTagsResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  PutBucketTagsResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutBucketTagsResult instance from a JSON map
  factory PutBucketTagsResult.fromJson(Map<String, dynamic> json) {
    return PutBucketTagsResult();
  }

  /// Converts the PutBucketTagsResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetBucketTags operation.
class GetBucketTagsRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  GetBucketTagsRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketTagsRequest instance from a JSON map
  factory GetBucketTagsRequest.fromJson(Map<String, dynamic> json) {
    return GetBucketTagsRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the GetBucketTagsRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketTags operation.
class GetBucketTagsResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The container that stores the returned tags of the bucket. If no tags are configured for the bucket, an XML message body is returned in which the Tagging element is empty.
  Tagging? tagging;

  GetBucketTagsResult({this.tagging, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketTagsResult instance from a JSON map
  factory GetBucketTagsResult.fromJson(Map<String, dynamic> json) {
    return GetBucketTagsResult(
      tagging: json['tagging'] != null
          ? Tagging.fromJson(json['tagging'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts the GetBucketTagsResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'tagging': tagging?.toJson()};
  }
}

/// The request for the DeleteBucketTags operation.
class DeleteBucketTagsRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  DeleteBucketTagsRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a DeleteBucketTagsRequest instance from a JSON map
  factory DeleteBucketTagsRequest.fromJson(Map<String, dynamic> json) {
    return DeleteBucketTagsRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the DeleteBucketTagsRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the DeleteBucketTags operation.
class DeleteBucketTagsResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  DeleteBucketTagsResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a DeleteBucketTagsResult instance from a JSON map
  factory DeleteBucketTagsResult.fromJson(Map<String, dynamic> json) {
    return DeleteBucketTagsResult();
  }

  /// Converts the DeleteBucketTagsResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}
