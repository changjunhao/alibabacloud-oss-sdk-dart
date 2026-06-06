import 'enums.dart';

/// Default configuration values for the OSS SDK.
class Defaults {
  /// The OSS product identifier.
  static const String product = 'oss';

  /// The default maximum number of retry attempts.
  static const int maxAttempt = 3;

  /// The default maximum backoff duration between retries.
  static const Duration maxBackoff = Duration(seconds: 20);

  /// The default base delay for retry backoff calculation.
  static const Duration baseDelay = Duration(milliseconds: 300);

  /// The default timeout for a single HTTP request.
  static const Duration timeoutIntervalForRequest = Duration(seconds: 15);

  /// The default timeout for the entire resource transfer.
  static const Duration timeoutIntervalForResource = Duration(hours: 24);

  /// The default HTTP protocol scheme.
  static const String httpProtocol = 'https';

  /// The default set of enabled feature flags.
  static final FeatureFlag featureFlags =
      FeatureFlag.correctClockSkew |
      FeatureFlag.autoDetectMimeType |
      FeatureFlag.enableCRC64CheckUpload |
      FeatureFlag.enableCRC64CheckDownload;
}
