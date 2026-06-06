/// Interface for retry strategies.
abstract class Retryer {
  /// Creates a Retryer instance.
  const Retryer();

  /// Determines if an error is retryable.
  bool isErrorRetryable(Exception error);

  /// Returns the maximum number of retry attempts.
  int maxAttempts();

  /// Calculates the delay before the next retry attempt.
  Duration retryDelay(int attempt, Exception error);
}
