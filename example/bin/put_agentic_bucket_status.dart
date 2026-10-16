import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'package:args/args.dart';

/// PutAgenticBucketStatus example. Note: after disabling, it takes approximately 24 hours before deletion.
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('region', abbr: 'r', mandatory: true)
    ..addOption('account-id', abbr: 'a', mandatory: true)
    ..addOption('endpoint', abbr: 'e')
    ..addOption('bucket', abbr: 'b', mandatory: true)
    ..addOption('status',
        abbr: 's', help: 'Enabled or Disabled.', mandatory: true)
    ..addFlag('help', abbr: 'h', negatable: false);
  AgenticBucketClient? client;
  try {
    final results = parser.parse(arguments);
    if (results['help'] as bool) {
      print(
          'Usage: dart put_agentic_bucket_status.dart [options]\n\n${parser.usage}');
      return;
    }
    client = AgenticBucketClient(Configuration(
      region: results['region'] as String,
      accountId: results['account-id'] as String,
      endpoint: results['endpoint'] as String?,
      credentialsProvider: EnvironmentCredentialsProvider(),
    ));
    final result = await client.putAgenticBucketStatus(
        PutAgenticBucketStatusRequest(
            bucket: results['bucket'] as String,
            status: results['status'] as String));
    print('Status Code: ${result.statusCode}');
    print('Request ID: ${result.requestId}');
  } catch (e) {
    print('Error: $e');
    if (e is ArgParserException) exit(1);
  } finally {
    client?.dispose();
  }
}
