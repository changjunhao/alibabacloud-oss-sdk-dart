import 'dart:math';
import 'backoff.dart';

/// Equal jitter backoff strategy.
class EqualJitterBackoff implements Backoff {
  final Duration baseDelay;
  final Duration maxBackoff;
  final Random _random = Random();

  EqualJitterBackoff({required this.baseDelay, required this.maxBackoff});

  @override
  Duration backoffDelay(int attempt, Exception error) {
    final ceil = min(
      pow(2, attempt) * baseDelay.inMilliseconds,
      maxBackoff.inMilliseconds,
    );
    final delayMs = ceil / 2 + _random.nextDouble() * (ceil / 2 + 1);

    return Duration(milliseconds: delayMs.round());
  }
}
