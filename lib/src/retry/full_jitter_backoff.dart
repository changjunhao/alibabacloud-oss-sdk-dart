import 'dart:math';
import 'backoff.dart';

/// Full jitter backoff strategy.
class FullJitterBackoff implements Backoff {
  /// The `baseDelay` value.
  final Duration baseDelay;

  /// The `maxBackoff` value.
  final Duration maxBackoff;
  final Random _random = Random();

  /// Creates a FullJitterBackoff instance.
  FullJitterBackoff({required this.baseDelay, required this.maxBackoff});

  @override
  /// Returns the `backoffDelay` result.
  Duration backoffDelay(int attempt, Exception error) {
    final delayMs =
        _random.nextDouble() *
        min(
          pow(2, attempt) * baseDelay.inMilliseconds,
          maxBackoff.inMilliseconds,
        );

    return Duration(milliseconds: delayMs.round());
  }
}
