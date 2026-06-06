import 'dart:convert';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/logging/log_agent.dart';
import 'package:alibabacloud_oss_sdk_dart/src/logging/log_agent_level.dart';
import 'package:alibabacloud_oss_sdk_dart/src/sdk_info.dart';

void main() {
  group('LogAgent Tests', () {
    test('testLogAgent', () {
      var logger = LogAgentTest(level: LogAgentLevel.trace);
      logger.trace(
        'trace',
        file: 'test/log_agent_test.dart',
        function: 'testLogAgent',
        line: 11,
      );
      logger.debug(
        'debug',
        file: 'test/log_agent_test.dart',
        function: 'testLogAgent',
        line: 12,
      );
      logger.info(
        'info',
        file: 'test/log_agent_test.dart',
        function: 'testLogAgent',
        line: 13,
      );
      logger.warn(
        'warn',
        file: 'test/log_agent_test.dart',
        function: 'testLogAgent',
        line: 14,
      );
      logger.error(
        'error',
        file: 'test/log_agent_test.dart',
        function: 'testLogAgent',
        line: 15,
      );

      var output =
          '[${SdkInfo.name}] trace trace test/log_agent_test.dart test testLogAgent() 11'
          '[${SdkInfo.name}] debug debug test/log_agent_test.dart test testLogAgent() 12'
          '[${SdkInfo.name}] info info test/log_agent_test.dart test testLogAgent() 13'
          '[${SdkInfo.name}] warn warn test/log_agent_test.dart test testLogAgent() 14'
          '[${SdkInfo.name}] error error test/log_agent_test.dart test testLogAgent() 15';

      expect(logger.data, equals(utf8.encode(output)));

      logger = LogAgentTest(level: LogAgentLevel.info);
      logger.trace(
        'trace',
        file: 'test/log_agent_test.dart',
        function: 'testLogAgent',
        line: 22,
      );
      logger.debug(
        'debug',
        file: 'test/log_agent_test.dart',
        function: 'testLogAgent',
        line: 23,
      );
      logger.info(
        'info',
        file: 'test/log_agent_test.dart',
        function: 'testLogAgent',
        line: 24,
      );
      logger.warn(
        'warn',
        file: 'test/log_agent_test.dart',
        function: 'testLogAgent',
        line: 25,
      );
      logger.error(
        'error',
        file: 'test/log_agent_test.dart',
        function: 'testLogAgent',
        line: 26,
      );

      output =
          '[${SdkInfo.name}] info info test/log_agent_test.dart test testLogAgent() 24'
          '[${SdkInfo.name}] warn warn test/log_agent_test.dart test testLogAgent() 25'
          '[${SdkInfo.name}] error error test/log_agent_test.dart test testLogAgent() 26';

      expect(logger.data, equals(utf8.encode(output)));
    });
  });
}

class LogAgentTest implements LogAgent {
  final LogAgentLevel level;

  List<int> data = [];

  LogAgentTest({required this.level});

  @override
  String get name => 'NSLog';

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
      final logMessage =
          '[${SdkInfo.name}] ${level.rawValue} $message ${file ?? ''} ${source ?? ''} ${function ?? ''}() ${line ?? 0}';
      data.addAll(utf8.encode(logMessage));
    }
  }
}
