import 'retryer.dart';
import 'backoff.dart';
import 'error_retryable.dart';
import 'full_jitter_backoff.dart';
import 'error_retryable_impl.dart';
import 'package:alibabacloud_oss_sdk_dart/src/defaults.dart';

/// Standard retryer implementation.
class StandardRetryer implements Retryer {
  final int _maxAttempt;
  final Backoff _backoff;
  final List<ErrorRetryable> _errorRetryable;

  StandardRetryer({
    int? maxAttempt,
    Backoff? backoff,
    List<ErrorRetryable>? errorRetryable,
  }) : _maxAttempt = maxAttempt ?? Defaults.maxAttempt,
       _backoff =
           backoff ??
           FullJitterBackoff(
             baseDelay: Defaults.baseDelay,
             maxBackoff: Defaults.maxBackoff,
           ),
       _errorRetryable =
           errorRetryable ?? [ServiceErrorRetryable(), ClientErrorRetryable()];

  @override
  int maxAttempts() {
    return _maxAttempt;
  }

  @override
  bool isErrorRetryable(Exception error) {
    for (final retryable in _errorRetryable) {
      if (retryable.isErrorRetryable(error)) {
        return true;
      }
    }
    return false;
  }

  @override
  Duration retryDelay(int attempt, Exception error) {
    return _backoff.backoffDelay(attempt, error);
  }
}
