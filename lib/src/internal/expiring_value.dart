import 'dart:async';

/// Type holding a value and an expiration value.
///
/// When accessing the value you have to provide a closure that will update the
/// value if it has expired or is about to expire. The type ensures there is only
/// ever one value update running at any one time. If an update is already running
/// when you call `getValue` it will wait on the current update function to finish.
class ExpiringValue<T> {
  /// Internal state of the expiring value
  _State<T> _state;

  /// Threshold time in seconds before expiration to trigger refresh
  final Duration threshold;

  /// Constructor with threshold
  ExpiringValue({Duration? threshold})
    : threshold = threshold ?? const Duration(seconds: 2),
      _state = _NoValue<T>();

  /// Constructor with initial value
  ExpiringValue.withValue(
    T initialValue,
    DateTime expires, {
    Duration? threshold,
  }) : threshold = threshold ?? const Duration(seconds: 2),
       _state = _WithValue<T>(initialValue, expires);

  /// Constructor with async initial value getter
  ExpiringValue.withAsyncValue({
    Duration? threshold,
    required Future<(T, DateTime)> Function() getExpiringValue,
  }) : threshold = threshold ?? const Duration(seconds: 2),
       _state = _InitialWaitingOnValue<T>(Completer<(T, DateTime)>()) {
    // Start the initial value generation
    final completer = (_state as _InitialWaitingOnValue<T>).completer;
    getExpiringValue()
        .then((result) {
          if (!completer.isCompleted) {
            completer.complete(result);
          }
        })
        .catchError((error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        });
  }

  /// Get the current value, refreshing if necessary
  Future<T> getValue(Future<(T, DateTime)> Function() getExpiringValue) async {
    switch (_state) {
      case _NoValue<T>():
        final completer = Completer<T>();
        _state = _WaitingOnValue<T>(completer);
        _getValueTask(getExpiringValue, completer);
        return await completer.future;

      case _InitialWaitingOnValue<T>(completer: final completer):
        try {
          final (value, expires) = await completer.future;
          _state = _WithValue<T>(value, expires);
          return value;
        } catch (error) {
          _state = _Error<T>(error);
          rethrow;
        }

      case _WaitingOnValue<T>(completer: final completer):
        return await completer.future;

      case _WithValue<T>(value: final value, expires: final expires):
        final now = DateTime.now();
        if (expires.isBefore(now)) {
          // Value has expired, create new task and wait for result
          final completer = Completer<T>();
          _state = _WaitingOnValue<T>(completer);
          _getValueTask(getExpiringValue, completer);
          return await completer.future;
        } else if (expires.difference(now) < threshold) {
          // Value is about to expire, start refresh but return current value
          final completer = Completer<T>();
          _state = _WithValueAndWaiting<T>(value, expires, completer);
          _getValueTask(getExpiringValue, completer);
          return value;
        } else {
          // Value is still valid
          return value;
        }

      case _WithValueAndWaiting<T>(
        value: final value,
        expires: final expires,
        completer: final completer,
      ):
        final now = DateTime.now();
        if (expires.isBefore(now)) {
          // Value has expired, wait for the refresh task
          return await completer.future;
        } else {
          // Value hasn't expired, return current value
          return value;
        }

      case _Error<T>(error: final error):
        throw error;
    }
  }

  /// Create a task that will return a new version of the value and expiration date
  void _getValueTask(
    Future<(T, DateTime)> Function() getExpiringValue,
    Completer<T> completer,
  ) {
    getExpiringValue()
        .then((result) {
          final (value, expires) = result;
          _state = _WithValue<T>(value, expires);
          if (!completer.isCompleted) {
            completer.complete(value);
          }
        })
        .catchError((error) {
          _state = _Error<T>(error);
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        });
  }

  /// Cancel any ongoing operations
  void cancel() {
    switch (_state) {
      case _InitialWaitingOnValue<T>(completer: final completer):
        if (!completer.isCompleted) {
          completer.completeError(Exception('Operation cancelled'));
        }
        break;
      case _WaitingOnValue<T>(completer: final completer):
        if (!completer.isCompleted) {
          completer.completeError(Exception('Operation cancelled'));
        }
        break;
      case _WithValueAndWaiting<T>(completer: final completer):
        if (!completer.isCompleted) {
          completer.completeError(Exception('Operation cancelled'));
        }
        break;
      default:
        break;
    }
  }
}

/// Internal state representation
sealed class _State<T> {}

/// No value is stored
class _NoValue<T> extends _State<T> {}

/// Initial call waiting on a value to be generated
class _InitialWaitingOnValue<T> extends _State<T> {
  final Completer<(T, DateTime)> completer;
  _InitialWaitingOnValue(this.completer);
}

/// Waiting on a value to be generated
class _WaitingOnValue<T> extends _State<T> {
  final Completer<T> completer;
  _WaitingOnValue(this.completer);
}

/// Is holding a value
class _WithValue<T> extends _State<T> {
  final T value;
  final DateTime expires;
  _WithValue(this.value, this.expires);
}

/// Is holding a value, and there is a task in progress to update it
class _WithValueAndWaiting<T> extends _State<T> {
  final T value;
  final DateTime expires;
  final Completer<T> completer;
  _WithValueAndWaiting(this.value, this.expires, this.completer);
}

/// Error state
class _Error<T> extends _State<T> {
  final Object error;
  _Error(this.error);
}
