/// Log levels ordered by severity.
///
/// `.trace` is the lowest level and `.error` is the highest.
enum LogAgentLevel {
  /// Messages primarily useful when tracing execution.
  trace,

  /// Messages primarily useful during debugging.
  debug,

  /// Informational messages.
  info,

  /// Messages for non-error conditions.
  warn,

  /// Messages for error conditions.
  error,
}

/// Convenience helpers for [LogAgentLevel].
extension LogAgentLevelExtension on LogAgentLevel {
  /// Returns the string form of the log level.
  String get rawValue {
    switch (this) {
      case LogAgentLevel.trace:
        return 'trace';
      case LogAgentLevel.debug:
        return 'debug';
      case LogAgentLevel.info:
        return 'info';
      case LogAgentLevel.warn:
        return 'warn';
      case LogAgentLevel.error:
        return 'error';
    }
  }

  /// Returns a numeric representation used for comparisons.
  int get naturalIntegralValue {
    switch (this) {
      case LogAgentLevel.trace:
        return 0;
      case LogAgentLevel.debug:
        return 1;
      case LogAgentLevel.info:
        return 2;
      case LogAgentLevel.warn:
        return 3;
      case LogAgentLevel.error:
        return 4;
    }
  }

  /// Compares log levels.
  bool operator >=(LogAgentLevel other) {
    return naturalIntegralValue >= other.naturalIntegralValue;
  }

  /// Compares log levels.
  bool operator <=(LogAgentLevel other) {
    return naturalIntegralValue <= other.naturalIntegralValue;
  }

  /// Compares log levels.
  bool operator >(LogAgentLevel other) {
    return naturalIntegralValue > other.naturalIntegralValue;
  }

  /// Compares log levels.
  bool operator <(LogAgentLevel other) {
    return naturalIntegralValue < other.naturalIntegralValue;
  }
}
