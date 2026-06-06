import 'model_types.dart';
import '../transform/serde_extensions.dart';

/// The container that stores TLS version configurations.
class TLS {
  /// Specifies whether to enable TLS version management for the bucket.
  bool? enable;

  /// The TLS versions.
  List<String>? tlsVersions;

  TLS({this.enable, this.tlsVersions});

  /// Creates a TLS instance from a JSON map
  factory TLS.fromJson(Map<String, dynamic> json) {
    final enableValue = json['Enable'];
    bool? enable;
    if (enableValue is bool) {
      enable = enableValue;
    } else if (enableValue is String) {
      enable = enableValue.toBool();
    }

    List<String>? tlsVersions;
    if (json['TLSVersion'] != null) {
      if (json['TLSVersion'] is List) {
        tlsVersions = List<String>.from(json['TLSVersion']);
      } else {
        tlsVersions = [json['TLSVersion'].toString()];
      }
    }

    return TLS(enable: enable, tlsVersions: tlsVersions);
  }

  /// Converts the TLS instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'Enable': enable, 'TLSVersion': tlsVersions};
  }
}

/// The container that stores Transport Layer Security (TLS) version configurations.
class HttpsConfiguration {
  /// The container that stores TLS version configurations.
  TLS? tls;

  HttpsConfiguration({this.tls});

  /// Creates a HttpsConfiguration instance from a JSON map
  factory HttpsConfiguration.fromJson(Map<String, dynamic> json) {
    return HttpsConfiguration(
      tls: json['TLS'] != null
          ? TLS.fromJson(json['TLS'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts the HttpsConfiguration instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'TLS': tls?.toJson()};
  }
}

/// The request for the PutBucketHttpsConfig operation.
class PutBucketHttpsConfigRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The request body schema.
  HttpsConfiguration? httpsConfiguration;

  PutBucketHttpsConfigRequest({
    this.bucket,
    this.httpsConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutBucketHttpsConfigRequest instance from a JSON map
  factory PutBucketHttpsConfigRequest.fromJson(Map<String, dynamic> json) {
    return PutBucketHttpsConfigRequest(
      bucket: json['bucket'] as String?,
      httpsConfiguration: json['httpsConfiguration'] != null
          ? HttpsConfiguration.fromJson(
              json['httpsConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the PutBucketHttpsConfigRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'httpsConfiguration': httpsConfiguration?.toJson(),
    };
  }
}

/// The result for the PutBucketHttpsConfig operation.
class PutBucketHttpsConfigResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  PutBucketHttpsConfigResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutBucketHttpsConfigResult instance from a JSON map
  factory PutBucketHttpsConfigResult.fromJson(Map<String, dynamic> json) {
    return PutBucketHttpsConfigResult();
  }

  /// Converts the PutBucketHttpsConfigResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetBucketHttpsConfig operation.
class GetBucketHttpsConfigRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  GetBucketHttpsConfigRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketHttpsConfigRequest instance from a JSON map
  factory GetBucketHttpsConfigRequest.fromJson(Map<String, dynamic> json) {
    return GetBucketHttpsConfigRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the GetBucketHttpsConfigRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketHttpsConfig operation.
class GetBucketHttpsConfigResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The container that stores HTTPS configurations.
  HttpsConfiguration? httpsConfiguration;

  GetBucketHttpsConfigResult({
    this.httpsConfiguration,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketHttpsConfigResult instance from a JSON map
  factory GetBucketHttpsConfigResult.fromJson(Map<String, dynamic> json) {
    return GetBucketHttpsConfigResult(
      httpsConfiguration: json['httpsConfiguration'] != null
          ? HttpsConfiguration.fromJson(
              json['httpsConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the GetBucketHttpsConfigResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'httpsConfiguration': httpsConfiguration?.toJson()};
  }
}

/// The request for the DeleteBucketHttpsConfig operation.
class DeleteBucketHttpsConfigRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  DeleteBucketHttpsConfigRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a DeleteBucketHttpsConfigRequest instance from a JSON map
  factory DeleteBucketHttpsConfigRequest.fromJson(Map<String, dynamic> json) {
    return DeleteBucketHttpsConfigRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the DeleteBucketHttpsConfigRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the DeleteBucketHttpsConfig operation.
class DeleteBucketHttpsConfigResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  DeleteBucketHttpsConfigResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a DeleteBucketHttpsConfigResult instance from a JSON map
  factory DeleteBucketHttpsConfigResult.fromJson(Map<String, dynamic> json) {
    return DeleteBucketHttpsConfigResult();
  }

  /// Converts the DeleteBucketHttpsConfigResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}
