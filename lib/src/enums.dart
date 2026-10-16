/// The version of the signing algorithm used to authenticate requests.
enum SignerVersion { v1, v4 }

/// Keys used for storing operation-level metadata.
enum OperationMetaKey {
  additionalHeaderNames('additionalHeaderNames'),
  progressHandler('progressHandler'),
  interceptors('interceptors'),
  networkInterceptors('networkInterceptors'),
  responseHandlers('responseHandlers');

  const OperationMetaKey(this.value);

  /// The serialized string value of this enum item.
  final String value;
}

/// The type of endpoint used to access OSS.
enum EndpointType { defautt, internal, accelerate, dualstack, overseas }

/// The addressing style for constructing OSS request URLs.
enum AddressStyleType { virtualHosted, cname, path, virtualHostedAlias }

/// The HTTP protocol scheme.
enum HttpProtocol {
  http('http'),
  https('https');

  const HttpProtocol(this.value);

  /// The serialized string value of this enum item.
  final String value;
}

/// Bitwise feature flags for enabling or disabling SDK behaviors.
class FeatureFlag {
  /// The `rawValue` value.
  final int rawValue;

  /// Creates a FeatureFlag instance.
  const FeatureFlag._(this.rawValue);

  /// Create a FeatureFlag from raw value
  factory FeatureFlag.fromRawValue(int rawValue) {
    return FeatureFlag._(rawValue);
  }

  /// If the client time is different from server time by more than about 15 minutes,
  /// the requests your application makes will be signed with the incorrect time, and the server will reject them.
  /// The feature to help to identify this case, and SDK will correct for clock skew.
  static const FeatureFlag correctClockSkew = FeatureFlag._(1 << 0);

  /// The `enableMD5` value.
  static const FeatureFlag enableMD5 = FeatureFlag._(1 << 1);

  /// Content-Type is automatically added based on the object name if not specified.
  /// This feature takes effect for PutObject, AppendObject and InitiateMultipartUpload
  static const FeatureFlag autoDetectMimeType = FeatureFlag._(1 << 2);

  /// Check data integrity of uploads via the crc64.
  static const FeatureFlag enableCRC64CheckUpload = FeatureFlag._(1 << 3);

  /// Check data integrity of downloads via the crc64.
  static const FeatureFlag enableCRC64CheckDownload = FeatureFlag._(1 << 4);

  /// Combine multiple feature flags
  FeatureFlag operator |(FeatureFlag other) {
    return FeatureFlag._(rawValue | other.rawValue);
  }

  /// Check if a feature flag is enabled
  bool contains(FeatureFlag flag) {
    return (rawValue & flag.rawValue) != 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureFlag && other.rawValue == rawValue;
  }

  @override
  /// Returns the `hashCode` value.
  int get hashCode => rawValue.hashCode;
}

/// Regex patterns for validating OSS resource names.
enum Pattern {
  endpointPattern(r'^[a-zA-Z0-9._-]+$'),
  regionPattern(r'^[a-z0-9-]+$'),
  bucketNamePattern(r'^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$'),
  objectKeyPattern(r'[^\/]{1,1023}');

  const Pattern(this.value);

  /// The serialized string value of this enum item.
  final String value;
}
