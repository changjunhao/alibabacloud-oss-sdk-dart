import 'model_types.dart';
import '../transform/serde_extensions.dart';

/// The container that stores the CORS rules. Up to 10 CORS rules can be configured for a bucket. The XML message body in a request can be up to 16 KB in size.
class CORSRule {
  /// The origins from which cross-origin requests are allowed.
  List<String>? allowedOrigins;

  /// The methods that you can use in cross-origin requests.
  List<String>? allowedMethods;

  /// Specifies whether the headers specified by Access-Control-Request-Headers in the OPTIONS preflight request are allowed. Each header specified by Access-Control-Request-Headers must match the value of an AllowedHeader element. You can use only one asterisk (*) as the wildcard character.
  List<String>? allowedHeaders;

  /// The response headers for allowed access requests from applications, such as an XMLHttpRequest object in JavaScript. The asterisk (*) wildcard character is not supported.
  List<String>? exposeHeaders;

  /// The period of time within which the browser can cache the response to an OPTIONS preflight request for the specified resource. Unit: seconds. You can specify only one MaxAgeSeconds element in a CORS rule.
  int? maxAgeSeconds;

  /// Creates a CORSRule instance.
  CORSRule({
    this.allowedOrigins,
    this.allowedMethods,
    this.allowedHeaders,
    this.exposeHeaders,
    this.maxAgeSeconds,
  });

  /// Creates a CORSRule instance from a JSON map
  factory CORSRule.fromJson(Map<String, dynamic> json) {
    return CORSRule(
      allowedOrigins: json['AllowedOrigin'] != null
          ? _toStringList(json['AllowedOrigin'])
          : null,
      allowedMethods: json['AllowedMethod'] != null
          ? _toStringList(json['AllowedMethod'])
          : null,
      allowedHeaders: json['AllowedHeader'] != null
          ? _toStringList(json['AllowedHeader'])
          : null,
      exposeHeaders: json['ExposeHeader'] != null
          ? _toStringList(json['ExposeHeader'])
          : null,
      maxAgeSeconds: json['MaxAgeSeconds'] != null
          ? (json['MaxAgeSeconds'] is int
                ? json['MaxAgeSeconds'] as int
                : int.tryParse(json['MaxAgeSeconds'].toString()))
          : null,
    );
  }

  /// Helper to convert a value that may be a String or List to `List<String>`
  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return List<String>.from(value);
    }
    return [value.toString()];
  }

  /// Converts the CORSRule instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'AllowedOrigin': allowedOrigins,
      'AllowedMethod': allowedMethods,
      'AllowedHeader': allowedHeaders,
      'ExposeHeader': exposeHeaders,
      'MaxAgeSeconds': maxAgeSeconds,
    };
  }
}

/// The container that stores CORS configuration.
class CORSConfiguration {
  /// The container that stores CORS rules. Up to 10 rules can be configured for a bucket.
  List<CORSRule>? corsRules;

  /// Indicates whether the Vary: Origin header was returned. Default value: false. - true: The Vary: Origin header is returned regardless whether the request is a cross-origin request or whether the cross-origin request succeeds. - false: The Vary: Origin header is not returned.
  bool? responseVary;

  /// Creates a CORSConfiguration instance.
  CORSConfiguration({this.corsRules, this.responseVary});

  /// Creates a CORSConfiguration instance from a JSON map
  factory CORSConfiguration.fromJson(Map<String, dynamic> json) {
    List<CORSRule>? corsRules;
    if (json['CORSRule'] != null) {
      if (json['CORSRule'] is List) {
        corsRules = (json['CORSRule'] as List)
            .map((e) => CORSRule.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (json['CORSRule'] is Map<String, dynamic>) {
        corsRules = [
          CORSRule.fromJson(json['CORSRule'] as Map<String, dynamic>),
        ];
      }
    }

    bool? responseVary;
    if (json['ResponseVary'] != null) {
      if (json['ResponseVary'] is bool) {
        responseVary = json['ResponseVary'] as bool;
      } else {
        responseVary = json['ResponseVary'].toString().toLowerCase() == 'true';
      }
    }

    return CORSConfiguration(corsRules: corsRules, responseVary: responseVary);
  }

  /// Converts the CORSConfiguration instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'CORSRule': corsRules?.map((e) => e.toJson()).toList(),
      'ResponseVary': responseVary,
    };
  }
}

/// The request for the PutBucketCors operation.
class PutBucketCorsRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The request body schema.
  CORSConfiguration? corsConfiguration;

  /// Creates a PutBucketCorsRequest instance.
  PutBucketCorsRequest({
    this.bucket,
    this.corsConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutBucketCorsRequest instance from a JSON map
  factory PutBucketCorsRequest.fromJson(Map<String, dynamic> json) {
    return PutBucketCorsRequest(
      bucket: json['bucket'] as String?,
      corsConfiguration: json['corsConfiguration'] != null
          ? CORSConfiguration.fromJson(
              json['corsConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the PutBucketCorsRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'corsConfiguration': corsConfiguration?.toJson()};
  }
}

/// The result for the PutBucketCors operation.
class PutBucketCorsResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a PutBucketCorsResult instance.
  PutBucketCorsResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutBucketCorsResult instance from a JSON map
  factory PutBucketCorsResult.fromJson(Map<String, dynamic> json) {
    return PutBucketCorsResult();
  }

  /// Converts the PutBucketCorsResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetBucketCors operation.
class GetBucketCorsRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// Creates a GetBucketCorsRequest instance.
  GetBucketCorsRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketCorsRequest instance from a JSON map
  factory GetBucketCorsRequest.fromJson(Map<String, dynamic> json) {
    return GetBucketCorsRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the GetBucketCorsRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketCors operation.
class GetBucketCorsResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The container that stores CORS configuration.
  CORSConfiguration? corsConfiguration;

  /// Creates a GetBucketCorsResult instance.
  GetBucketCorsResult({this.corsConfiguration, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketCorsResult instance from a JSON map
  factory GetBucketCorsResult.fromJson(Map<String, dynamic> json) {
    return GetBucketCorsResult(
      corsConfiguration: json['corsConfiguration'] != null
          ? CORSConfiguration.fromJson(
              json['corsConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the GetBucketCorsResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'corsConfiguration': corsConfiguration?.toJson()};
  }
}

/// The request for the DeleteBucketCors operation.
class DeleteBucketCorsRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// Creates a DeleteBucketCorsRequest instance.
  DeleteBucketCorsRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a DeleteBucketCorsRequest instance from a JSON map
  factory DeleteBucketCorsRequest.fromJson(Map<String, dynamic> json) {
    return DeleteBucketCorsRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the DeleteBucketCorsRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the DeleteBucketCors operation.
class DeleteBucketCorsResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a DeleteBucketCorsResult instance.
  DeleteBucketCorsResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a DeleteBucketCorsResult instance from a JSON map
  factory DeleteBucketCorsResult.fromJson(Map<String, dynamic> json) {
    return DeleteBucketCorsResult();
  }

  /// Converts the DeleteBucketCorsResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the OptionObject operation.
class OptionObjectRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The origin of the request. It is used to identify a cross-origin request. You can specify only one Origin header in a cross-origin request. By default, this header is left empty.
  String? origin;

  /// The method to be used in the actual cross-origin request. You can specify only one Access-Control-Request-Method header in a cross-origin request. By default, this header is left empty.
  String? accessControlRequestMethod;

  /// The custom headers to be sent in the actual cross-origin request. You can configure multiple custom headers in a cross-origin request. Custom headers are separated by commas (,). By default, this header is left empty.
  String? accessControlRequestHeaders;

  /// Creates a OptionObjectRequest instance.
  OptionObjectRequest({
    this.bucket,
    this.key,
    this.origin,
    this.accessControlRequestMethod,
    this.accessControlRequestHeaders,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates an OptionObjectRequest instance from a JSON map
  factory OptionObjectRequest.fromJson(Map<String, dynamic> json) {
    return OptionObjectRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      origin: json['origin'] as String?,
      accessControlRequestMethod: json['accessControlRequestMethod'] as String?,
      accessControlRequestHeaders:
          json['accessControlRequestHeaders'] as String?,
    );
  }

  /// Converts the OptionObjectRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'origin': origin,
      'accessControlRequestMethod': accessControlRequestMethod,
      'accessControlRequestHeaders': accessControlRequestHeaders,
    };
  }
}

/// The result for the OptionObject operation.
class OptionObjectResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The origin of the request; not included in the response when the cross-origin request is denied.
  String? get accessControlAllowOrigin =>
      commonProp.headers?.getCaseInsensitive('Access-Control-Allow-Origin');

  /// Allowed HTTP request methods; not included in the response when the request is denied.
  String? get accessControlAllowMethods =>
      commonProp.headers?.getCaseInsensitive('Access-Control-Allow-Methods');

  /// Allowed request headers; the request is rejected when it contains disallowed headers.
  String? get accessControlAllowHeaders =>
      commonProp.headers?.getCaseInsensitive('Access-Control-Allow-Headers');

  /// List of response headers that client JavaScript is allowed to read.
  String? get accessControlExposeHeaders =>
      commonProp.headers?.getCaseInsensitive('Access-Control-Expose-Headers');

  /// Maximum duration in seconds for the browser to cache the preflight result.
  int? get accessControlMaxAge {
    final value = commonProp.headers?.getCaseInsensitive(
      'Access-Control-Max-Age',
    );
    return value?.toInt();
  }

  /// Creates a OptionObjectResult instance.
  OptionObjectResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates an OptionObjectResult instance from a JSON map
  factory OptionObjectResult.fromJson(Map<String, dynamic> json) {
    return OptionObjectResult();
  }

  /// Converts the OptionObjectResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}
