import 'backoff.dart';

/// Fixed delay backoff strategy.
class FixedDelayBackoff implements Backoff {
  final Duration fixedBackoff;

  FixedDelayBackoff({required this.fixedBackoff});

  @override
  Duration backoffDelay(int attempt, Exception error) {
    return fixedBackoff;
  }
}
