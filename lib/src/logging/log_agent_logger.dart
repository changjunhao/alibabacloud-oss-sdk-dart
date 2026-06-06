import 'dart:developer' as developer;
import 'package:alibabacloud_oss_sdk_dart/src/sdk_info.dart';
import 'log_agent.dart';
import 'log_agent_level.dart';

/// Log agent implementation backed by `dart:developer`.
class LogAgentLogger implements LogAgent {
  final LogAgentLevel level;
  final String _subsystem;

  /// Creates a logger-backed log agent.
  ///
  /// Parameters:
  /// - [level]: Minimum level to emit.
  /// - [subsystem]: Subsystem name used for log classification. Defaults to
  ///   the SDK name.
  LogAgentLogger({required this.level, String? subsystem})
    : _subsystem = subsystem ?? SdkInfo.name;

  @override
  String get name => 'Logger';

  @override
  void log({
    required LogAgentLevel level,
    required String message,
    Map<String, String>? metadata,
    String? source,
    String? file,
    String? function,
    int? line,
  }) {
    if (level >= this.level) {
      final formattedMessage = '[${SdkInfo.name}] ${level.rawValue} $message';
      final logLevel = _convertToLogLevel(level);

      developer.log(
        formattedMessage,
        name: _subsystem,
        level: logLevel,
        error: level == LogAgentLevel.error ? message : null,
      );
    }
  }

  /// Converts [LogAgentLevel] to a `dart:developer` log level.
  ///
  /// `dart:developer.log` uses numeric log levels:
  /// - 0-299: FINEST
  /// - 300-399: FINER
  /// - 400-499: FINE
  /// - 500-599: CONFIG
  /// - 600-699: INFO
  /// - 700-799: WARNING
  /// - 800-899: SEVERE
  /// - 900-999: SHOUT
  int _convertToLogLevel(LogAgentLevel level) {
    switch (level) {
      case LogAgentLevel.trace:
        // `dart:developer.log` has no trace level, so use FINEST.
        return 100;
      case LogAgentLevel.debug:
        return 500; // CONFIG
      case LogAgentLevel.info:
        return 600; // INFO
      case LogAgentLevel.warn:
        // `dart:developer.log` has no dedicated warning enum, so use WARNING.
        return 700; // WARNING
      case LogAgentLevel.error:
        return 800; // SEVERE
    }
  }
}
