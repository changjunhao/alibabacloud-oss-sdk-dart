import 'model_types.dart';
import '../transform/serde_extensions.dart';

/// The container used to store the tag that you want to configure.
class Tag {
  /// The key of a tag.
  /// * A tag key can be up to 64 bytes in length.
  /// * A tag key cannot start with `http://`, `https://`, or `Aliyun`.
  /// * A tag key must be UTF-8 encoded.
  /// * A tag key cannot be left empty.
  String? key;

  /// The value of the tag that you want to add or modify.
  /// * A tag value can be up to 128 bytes in length.
  /// * A tag value must be UTF-8 encoded.
  /// * The tag value can be left empty.
  String? value;

  Tag({this.key, this.value});

  /// Creates a Tag instance from a JSON map
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(key: json['Key'] as String?, value: json['Value'] as String?);
  }

  /// Converts the Tag instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'Key': key, 'Value': value};
  }
}

/// The container for tags.
class TagSet {
  /// The tags.
  List<Tag>? tags;

  TagSet({this.tags});

  /// Creates a TagSet instance from a JSON map
  factory TagSet.fromJson(Map<String, dynamic> json) {
    return TagSet(
      tags: json['Tag'] != null
          ? (json['Tag'] as List)
                .map((e) => Tag.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  /// Converts the TagSet instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'Tag': tags?.map((e) => e.toJson()).toList()};
  }
}

/// The container that stores the returned tag of the bucket.
class Tagging {
  /// The tag set of the target object.
  TagSet? tagSet;

  Tagging({this.tagSet});

  /// Creates a Tagging instance from a JSON map
  factory Tagging.fromJson(Map<String, dynamic> json) {
    return Tagging(
      tagSet: json['TagSet'] != null
          ? TagSet.fromJson(json['TagSet'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts the Tagging instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'TagSet': tagSet?.toJson()};
  }
}

/// The request for the PutObjectTagging operation.
class PutObjectTaggingRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The name of the object.
  String? key;

  /// The version id of the target object.
  String? versionId;

  /// The request body schema.
  Tagging? tagging;

  PutObjectTaggingRequest({
    this.bucket,
    this.key,
    this.versionId,
    this.tagging,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutObjectTaggingRequest instance from a JSON map
  factory PutObjectTaggingRequest.fromJson(Map<String, dynamic> json) {
    return PutObjectTaggingRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      versionId: json['versionId'] as String?,
      tagging: json['tagging'] != null
          ? Tagging.fromJson(json['tagging'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts the PutObjectTaggingRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'versionId': versionId,
      'tagging': tagging?.toJson(),
    };
  }
}

/// The result for the PutObjectTagging operation.
class PutObjectTaggingResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// Version ID of the object.
  String? get versionId =>
      commonProp.headers?.getCaseInsensitive('x-oss-version-id');

  PutObjectTaggingResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutObjectTaggingResult instance from a JSON map
  factory PutObjectTaggingResult.fromJson(Map<String, dynamic> json) {
    return PutObjectTaggingResult();
  }

  /// Converts the PutObjectTaggingResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetObjectTagging operation.
class GetObjectTaggingRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The versionID of the object that you want to query.
  String? versionId;

  GetObjectTaggingRequest({
    this.bucket,
    this.key,
    this.versionId,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetObjectTaggingRequest instance from a JSON map
  factory GetObjectTaggingRequest.fromJson(Map<String, dynamic> json) {
    return GetObjectTaggingRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      versionId: json['versionId'] as String?,
    );
  }

  /// Converts the GetObjectTaggingRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'key': key, 'versionId': versionId};
  }
}

/// The result for the GetObjectTagging operation.
class GetObjectTaggingResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The container that stores the returned tag of the bucket.
  Tagging? tagging;

  GetObjectTaggingResult({this.tagging, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetObjectTaggingResult instance from a JSON map
  factory GetObjectTaggingResult.fromJson(Map<String, dynamic> json) {
    return GetObjectTaggingResult(
      tagging: json['tagging'] != null
          ? Tagging.fromJson(json['tagging'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts the GetObjectTaggingResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'tagging': tagging?.toJson()};
  }
}

/// The request for the DeleteObjectTagging operation.
class DeleteObjectTaggingRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The version ID of the object that you want to delete.
  String? versionId;

  DeleteObjectTaggingRequest({
    this.bucket,
    this.key,
    this.versionId,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a DeleteObjectTaggingRequest instance from a JSON map
  factory DeleteObjectTaggingRequest.fromJson(Map<String, dynamic> json) {
    return DeleteObjectTaggingRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      versionId: json['versionId'] as String?,
    );
  }

  /// Converts the DeleteObjectTaggingRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'key': key, 'versionId': versionId};
  }
}

/// The result for the DeleteObjectTagging operation.
class DeleteObjectTaggingResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  DeleteObjectTaggingResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a DeleteObjectTaggingResult instance from a JSON map
  factory DeleteObjectTaggingResult.fromJson(Map<String, dynamic> json) {
    return DeleteObjectTaggingResult();
  }

  /// Converts the DeleteObjectTaggingResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}
