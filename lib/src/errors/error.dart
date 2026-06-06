/// Standard Error type returned by sdk.
abstract class SdkErrorType implements Exception {
  /// Creates a SdkErrorType instance.
  const SdkErrorType();

  /// Gets the Error instance that caused the current exception.
  Exception? get innerError;

  /// Error description
  String get description;
}
