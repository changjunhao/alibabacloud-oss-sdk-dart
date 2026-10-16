import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'package:args/args.dart';

/// GetAgenticBucket example.
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('region', abbr: 'r', mandatory: true)
    ..addOption('account-id', abbr: 'a', mandatory: true)
    ..addOption('endpoint', abbr: 'e')
    ..addOption('bucket', abbr: 'b', mandatory: true)
    ..addFlag('alias', negatable: false)
    ..addFlag('help', abbr: 'h', negatable: false);
  AgenticBucketClient? client;
  try {
    final results = parser.parse(arguments);
    if (results['help'] as bool) {
      print('Usage: dart get_agentic_bucket.dart [options]\n\n${parser.usage}');
      return;
    }
    client = AgenticBucketClient(Configuration(
      region: results['region'] as String,
      accountId: results['account-id'] as String,
      endpoint: results['endpoint'] as String?,
      useVirtualHostedAlias: (results['alias'] as bool) ? true : null,
      credentialsProvider: EnvironmentCredentialsProvider(),
    ));
    final result = await client.getAgenticBucket(
        GetAgenticBucketRequest(bucket: results['bucket'] as String));
    final info = result.agenticBucketInfo;
    print('Status Code: ${result.statusCode}');
    print(
        'Name: ${info?.name}, Region: ${info?.region}, Status: ${info?.status}');
    print(
        'StorageClass: ${info?.storageClass}, DataRedundancyType: ${info?.dataRedundancyType}');
  } catch (e) {
    print('Error: $e');
    if (e is ArgParserException) exit(1);
  } finally {
    client?.dispose();
  }
}
