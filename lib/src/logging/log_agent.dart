import 'log_agent_level.dart';

/// Abstract logging interface.
///
/// Defines the basic API used by logging implementations.
abstract class LogAgent {
  /// The logger name, typically the name of the backing logger type.
  String get name;

  /// Logs a message at the provided level.
  ///
  /// If the supplied [LogAgentLevel] is at or above the logger threshold, the
  /// message is emitted. Otherwise it is ignored.
  ///
  /// Parameters:
  /// - [level]: Severity level for the message.
  /// - [message]: Message text to log.
  /// - [metadata]: One-off metadata attached to this message.
  /// - [source]: Source module for this message.
  /// - [file]: File where this message originated.
  /// - [function]: Function where this message originated.
  /// - [line]: Line number where this message originated.
  void log({
    required LogAgentLevel level,
    required String message,
    Map<String, String>? metadata,
    String? source,
    String? file,
    String? function,
    int? line,
  });
}

/// Convenience wrappers for [LogAgent].
extension LogAgentExtension on LogAgent {
  /// Logs a message that is primarily useful when tracing execution.
  void trace(String message, {String? file, String? function, int? line}) {
    log(
      level: LogAgentLevel.trace,
      message: message,
      metadata: null,
      source: _currentModule(file),
      file: file,
      function: function,
      line: line,
    );
  }

  /// Logs a message that is primarily useful during debugging.
  void debug(String message, {String? file, String? function, int? line}) {
    log(
      level: LogAgentLevel.debug,
      message: message,
      metadata: null,
      source: _currentModule(file),
      file: file,
      function: function,
      line: line,
    );
  }

  /// Logs an informational message.
  void info(String message, {String? file, String? function, int? line}) {
    log(
      level: LogAgentLevel.info,
      message: message,
      metadata: null,
      source: _currentModule(file),
      file: file,
      function: function,
      line: line,
    );
  }

  /// Logs a warning-style message for a non-error condition.
  void warn(String message, {String? file, String? function, int? line}) {
    log(
      level: LogAgentLevel.warn,
      message: message,
      metadata: null,
      source: _currentModule(file),
      file: file,
      function: function,
      line: line,
    );
  }

  /// Logs an error message.
  void error(String message, {String? file, String? function, int? line}) {
    log(
      level: LogAgentLevel.error,
      message: message,
      metadata: null,
      source: _currentModule(file),
      file: file,
      function: function,
      line: line,
    );
  }
}

/// Extracts the current module name from a file path.
String? _currentModule(String? file) {
  if (file == null) return null;

  final slashIndex = file.indexOf('/');
  if (slashIndex != -1) {
    return file.substring(0, slashIndex);
  } else {
    return 'n/a';
  }
}
