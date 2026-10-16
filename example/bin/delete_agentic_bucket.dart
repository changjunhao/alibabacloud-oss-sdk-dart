import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'package:args/args.dart';

/// DeleteAgenticBucket example. Only deletes explicitly specified, disabled AgenticBuckets that have satisfied the cooldown period.
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('region', abbr: 'r', mandatory: true)
    ..addOption('account-id', abbr: 'a', mandatory: true)
    ..addOption('endpoint', abbr: 'e')
    ..addOption('bucket',
        abbr: 'b',
        help: 'Logical prefix of the AgenticBucket.',
        mandatory: true)
    ..addFlag('help', abbr: 'h', negatable: false);
  AgenticBucketClient? client;
  try {
    final results = parser.parse(arguments);
    if (results['help'] as bool) {
      print(
          'Usage: dart delete_agentic_bucket.dart [options]\n\n${parser.usage}');
      return;
    }
    client = AgenticBucketClient(Configuration(
      region: results['region'] as String,
      accountId: results['account-id'] as String,
      endpoint: results['endpoint'] as String?,
      credentialsProvider: EnvironmentCredentialsProvider(),
    ));
    final result = await client.deleteAgenticBucket(
        DeleteAgenticBucketRequest(bucket: results['bucket'] as String));
    print('Status Code: ${result.statusCode}');
    print('Request ID: ${result.requestId}');
  } catch (e) {
    print('Error: $e');
    if (e is ArgParserException) exit(1);
  } finally {
    client?.dispose();
  }
}
