import 'package:alibabacloud_oss_sdk_dart/src/models/model_types.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_extensions.dart';

/// The request for the PutApi operation.
class PutApiRequest extends RequestModel {
  @override
  RequestModelProp commonProp = RequestModelProp();

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The access control list (ACL) of the object.
  String? acl;

  /// The metadata of the object that you want to upload.
  Map<String, String>? metadata;

  PutApiRequest({
    this.bucket,
    this.key,
    this.acl,
    this.metadata,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutApiRequest instance from a JSON map
  factory PutApiRequest.fromJson(Map<String, dynamic> json) {
    return PutApiRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      acl: json['acl'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, String>.from(json['metadata'] as Map)
          : null,
    );
  }

  /// Converts the PutApiRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'key': key, 'acl': acl, 'metadata': metadata};
  }
}

/// The XML result structure for PutApi operation.
class PutApiXmlResult {
  /// String value from XML response.
  String? strValue;

  /// Another string value from XML response.
  String? strValue1;

  PutApiXmlResult({this.strValue, this.strValue1});

  /// Creates a PutApiXmlResult instance from a JSON map
  factory PutApiXmlResult.fromJson(Map<String, dynamic> json) {
    return PutApiXmlResult(
      strValue: json['strValue'] as String?,
      strValue1: json['StrValue1'] as String?,
    );
  }

  /// Converts the PutApiXmlResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'strValue': strValue, 'StrValue1': strValue1};
  }
}

/// The result for the PutApi operation.
class PutApiResult extends ResultModel {
  @override
  ResultModelProp commonProp = ResultModelProp();

  /// String header value from response.
  String? get headerStr =>
      commonProp.headers?.getCaseInsensitive('x-oss-header-str');

  /// Integer header value from response.
  int? get headerInt =>
      commonProp.headers?.getCaseInsensitive('x-oss-header-int')?.toInt();

  /// Boolean header value from response.
  bool? get headerBool =>
      commonProp.headers?.getCaseInsensitive('x-oss-header-bool')?.toBool();

  /// The XML result structure.
  PutApiXmlResult? xmlResult;

  PutApiResult({this.xmlResult, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutApiResult instance from a JSON map
  factory PutApiResult.fromJson(Map<String, dynamic> json) {
    return PutApiResult(
      xmlResult: json['xmlResult'] != null
          ? PutApiXmlResult.fromJson(json['xmlResult'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts the PutApiResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'xmlResult': xmlResult?.toJson()};
  }
}
