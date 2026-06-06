/// Interface for determining if an error is retryable.
abstract class ErrorRetryable {
  /// Determines if the given error is retryable.
  bool isErrorRetryable(Exception error);
}
