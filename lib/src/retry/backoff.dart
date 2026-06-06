/// Interface for backoff strategies.
abstract class Backoff {
  /// Creates a backoff strategy.
  const Backoff();

  /// Calculates the backoff delay for a given attempt and error.
  Duration backoffDelay(int attempt, Exception error);
}
