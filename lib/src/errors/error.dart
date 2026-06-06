/// Standard Error type returned by sdk.
abstract class SdkErrorType implements Exception {
  /// Gets the Error instance that caused the current exception.
  Exception? get innerError;

  /// Error description
  String get description;
}
