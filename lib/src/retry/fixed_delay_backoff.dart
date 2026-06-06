import 'backoff.dart';

/// Fixed delay backoff strategy.
class FixedDelayBackoff implements Backoff {
  /// The `fixedBackoff` value.
  final Duration fixedBackoff;

  /// Creates a FixedDelayBackoff instance.
  FixedDelayBackoff({required this.fixedBackoff});

  @override
  /// Returns the `backoffDelay` result.
  Duration backoffDelay(int attempt, Exception error) {
    return fixedBackoff;
  }
}
