import 'dart:math';
import 'backoff.dart';

/// Full jitter backoff strategy.
class FullJitterBackoff implements Backoff {
  final Duration baseDelay;
  final Duration maxBackoff;
  final Random _random = Random();

  FullJitterBackoff({required this.baseDelay, required this.maxBackoff});

  @override
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
