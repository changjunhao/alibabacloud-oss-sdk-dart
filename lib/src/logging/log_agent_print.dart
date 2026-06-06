import 'package:alibabacloud_oss_sdk_dart/src/sdk_info.dart';
import 'log_agent.dart';
import 'log_agent_level.dart';

/// Log agent implementation backed by `print`.
class LogAgentPrint implements LogAgent {
  final LogAgentLevel level;

  /// Creates a print-based log agent.
  ///
  /// Parameters:
  /// - [level]: Minimum level to emit.
  LogAgentPrint({required this.level});

  @override
  String get name => 'Print';

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
      print(formattedMessage);
    }
  }
}
