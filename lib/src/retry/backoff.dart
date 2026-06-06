/// Interface for backoff strategies.
abstract class Backoff {
  /// Calculates the backoff delay for a given attempt and error.
  Duration backoffDelay(int attempt, Exception error);
}
