import 'model_types.dart';

/// Indicates the container for the payer.
class RequestPaymentConfiguration {
  /// Indicates who pays the download and request fees.
  String? payer;

  RequestPaymentConfiguration({this.payer});

  /// Creates a RequestPaymentConfiguration instance from a JSON map
  factory RequestPaymentConfiguration.fromJson(Map<String, dynamic> json) {
    return RequestPaymentConfiguration(payer: json['Payer'] as String?);
  }

  /// Converts the RequestPaymentConfiguration instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'Payer': payer};
  }
}

/// The request for the PutBucketRequestPayment operation.
class PutBucketRequestPaymentRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The request body schema.
  RequestPaymentConfiguration? requestPaymentConfiguration;

  PutBucketRequestPaymentRequest({
    this.bucket,
    this.requestPaymentConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutBucketRequestPaymentRequest instance from a JSON map
  factory PutBucketRequestPaymentRequest.fromJson(Map<String, dynamic> json) {
    return PutBucketRequestPaymentRequest(
      bucket: json['bucket'] as String?,
      requestPaymentConfiguration: json['requestPaymentConfiguration'] != null
          ? RequestPaymentConfiguration.fromJson(
              json['requestPaymentConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the PutBucketRequestPaymentRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'requestPaymentConfiguration': requestPaymentConfiguration?.toJson(),
    };
  }
}

/// The result for the PutBucketRequestPayment operation.
class PutBucketRequestPaymentResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  PutBucketRequestPaymentResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutBucketRequestPaymentResult instance from a JSON map
  factory PutBucketRequestPaymentResult.fromJson(Map<String, dynamic> json) {
    return PutBucketRequestPaymentResult();
  }

  /// Converts the PutBucketRequestPaymentResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetBucketRequestPayment operation.
class GetBucketRequestPaymentRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  GetBucketRequestPaymentRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketRequestPaymentRequest instance from a JSON map
  factory GetBucketRequestPaymentRequest.fromJson(Map<String, dynamic> json) {
    return GetBucketRequestPaymentRequest(bucket: json['bucket'] as String?);
  }

  /// Converts the GetBucketRequestPaymentRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }
}

/// The result for the GetBucketRequestPayment operation.
class GetBucketRequestPaymentResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// Indicates the container for the payer.
  RequestPaymentConfiguration? requestPaymentConfiguration;

  GetBucketRequestPaymentResult({
    this.requestPaymentConfiguration,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketRequestPaymentResult instance from a JSON map
  factory GetBucketRequestPaymentResult.fromJson(Map<String, dynamic> json) {
    return GetBucketRequestPaymentResult(
      requestPaymentConfiguration: json['requestPaymentConfiguration'] != null
          ? RequestPaymentConfiguration.fromJson(
              json['requestPaymentConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the GetBucketRequestPaymentResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'requestPaymentConfiguration': requestPaymentConfiguration?.toJson(),
    };
  }
}
