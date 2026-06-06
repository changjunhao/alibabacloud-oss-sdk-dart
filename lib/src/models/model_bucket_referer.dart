import 'model_types.dart';

/// The container that stores the Referer whitelist.
/// The PutBucketReferer operation overwrites the existing Referer whitelist
/// with the Referer whitelist specified in RefererList.
class RefererList {
  /// The addresses in the Referer whitelist.
  List<String>? referers;

  /// Creates a RefererList instance.
  RefererList({this.referers});

  /// Creates a RefererList instance from a JSON map
  factory RefererList.fromJson(Map<String, dynamic> json) {
    return RefererList(
      referers: json['Referer'] != null
          ? List<String>.from(json['Referer'])
          : null,
    );
  }

  /// Converts the RefererList instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'Referer': referers};
  }
}

/// The container that stores the Referer blacklist.
class RefererBlacklist {
  /// The addresses in the Referer blacklist.
  List<String>? referers;

  /// Creates a RefererBlacklist instance.
  RefererBlacklist({this.referers});

  /// Creates a RefererBlacklist instance from a JSON map
  factory RefererBlacklist.fromJson(Map<String, dynamic> json) {
    return RefererBlacklist(
      referers: json['Referer'] != null
          ? List<String>.from(json['Referer'])
          : null,
    );
  }

  /// Converts the RefererBlacklist instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'Referer': referers};
  }
}

/// The container that stores the hotlink protection configurations.
class RefererConfiguration {
  /// Specifies whether to allow a request whose Referer field is empty.
  /// Valid values: true (default), false
  bool? allowEmptyReferer;

  /// Specifies whether to truncate the query string in the URL when the
  /// Referer is matched. Valid values: true (default), false
  bool? allowTruncateQueryString;

  /// Specifies whether to truncate the path and parts that follow the path
  /// in the URL when the Referer is matched. Valid values: true, false
  bool? truncatePath;

  /// The container that stores the Referer whitelist.
  RefererList? refererList;

  /// The container that stores the Referer blacklist.
  RefererBlacklist? refererBlacklist;

  /// Creates a RefererConfiguration instance.
  RefererConfiguration({
    this.allowEmptyReferer,
    this.allowTruncateQueryString,
    this.truncatePath,
    this.refererList,
    this.refererBlacklist,
  });

  /// Creates a RefererConfiguration instance from a JSON map
  factory RefererConfiguration.fromJson(Map<String, dynamic> json) {
    return RefererConfiguration(
      allowEmptyReferer: _parseBool(json['AllowEmptyReferer']),
      allowTruncateQueryString: _parseBool(json['AllowTruncateQueryString']),
      truncatePath: _parseBool(json['TruncatePath']),
      refererList: json['RefererList'] != null
          ? RefererList.fromJson(json['RefererList'] as Map<String, dynamic>)
          : null,
      refererBlacklist: json['RefererBlacklist'] != null
          ? RefererBlacklist.fromJson(
              json['RefererBlacklist'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the RefererConfiguration instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'AllowEmptyReferer': allowEmptyReferer,
      'AllowTruncateQueryString': allowTruncateQueryString,
      'TruncatePath': truncatePath,
      'RefererList': refererList?.toJson(),
      'RefererBlacklist': refererBlacklist?.toJson(),
    };
  }

  /// Creates a RefererConfiguration value using `_parseBool` parameters.
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }
}

/// The request for the PutBucketReferer operation.
class PutBucketRefererRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The request body schema.
  RefererConfiguration? refererConfiguration;

  /// Creates a PutBucketRefererRequest instance.
  PutBucketRefererRequest({
    this.bucket,
    this.refererConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();
}

/// The result for the PutBucketReferer operation.
class PutBucketRefererResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a PutBucketRefererResult instance.
  PutBucketRefererResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();
}

/// The request for the GetBucketReferer operation.
class GetBucketRefererRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// Creates a GetBucketRefererRequest instance.
  GetBucketRefererRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();
}

/// The result for the GetBucketReferer operation.
class GetBucketRefererResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The container that stores the hotlink protection configurations.
  RefererConfiguration? refererConfiguration;

  /// Creates a GetBucketRefererResult instance.
  GetBucketRefererResult({
    this.refererConfiguration,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();
}
