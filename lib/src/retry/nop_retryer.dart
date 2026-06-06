import 'retryer.dart';

/// No-operation retryer that doesn't retry any errors.
class NopRetryer implements Retryer {
  /// Creates a retryer that never retries.
  const NopRetryer();

  @override
  /// Returns the `maxAttempts` result.
  int maxAttempts() {
    return 1;
  }

  @override
  /// Returns the `isErrorRetryable` result.
  bool isErrorRetryable(Exception error) {
    return false;
  }

  @override
  /// Returns the `retryDelay` result.
  Duration retryDelay(int attempt, Exception error) {
    return Duration.zero;
  }
}
