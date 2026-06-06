import 'dart:math';
import 'backoff.dart';

/// Equal jitter backoff strategy.
class EqualJitterBackoff implements Backoff {
  /// The `baseDelay` value.
  final Duration baseDelay;

  /// The `maxBackoff` value.
  final Duration maxBackoff;
  final Random _random = Random();

  /// Creates an EqualJitterBackoff instance.
  EqualJitterBackoff({required this.baseDelay, required this.maxBackoff});

  @override
  /// Returns the `backoffDelay` result.
  Duration backoffDelay(int attempt, Exception error) {
    final ceil = min(
      pow(2, attempt) * baseDelay.inMilliseconds,
      maxBackoff.inMilliseconds,
    );
    final delayMs = ceil / 2 + _random.nextDouble() * (ceil / 2 + 1);

    return Duration(milliseconds: delayMs.round());
  }
}
