import 'retryer.dart';

/// No-operation retryer that doesn't retry any errors.
class NopRetryer implements Retryer {
  @override
  int maxAttempts() {
    return 1;
  }

  @override
  bool isErrorRetryable(Exception error) {
    return false;
  }

  @override
  Duration retryDelay(int attempt, Exception error) {
    return Duration.zero;
  }
}
