import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'package:args/args.dart';

/// ListAgenticBuckets example, using the paginator to iterate through pages.
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('region', abbr: 'r', mandatory: true)
    ..addOption('account-id', abbr: 'a', mandatory: true)
    ..addOption('endpoint', abbr: 'e')
    ..addFlag('help', abbr: 'h', negatable: false);
  AgenticBucketClient? client;
  try {
    final results = parser.parse(arguments);
    if (results['help'] as bool) {
      print(
          'Usage: dart list_agentic_buckets.dart [options]\n\n${parser.usage}');
      return;
    }
    client = AgenticBucketClient(Configuration(
      region: results['region'] as String,
      accountId: results['account-id'] as String,
      endpoint: results['endpoint'] as String?,
      credentialsProvider: EnvironmentCredentialsProvider(),
    ));
    await for (final page in client
        .listAgenticBucketsPaginator(ListAgenticBucketsRequest())
        .stream) {
      for (final bucket in page.agenticBuckets ?? <AgenticBucketSummary>[]) {
        print(
            'AgenticBucket: ${bucket.name}, StorageClass: ${bucket.storageClass}');
      }
    }
  } catch (e) {
    print('Error: $e');
    if (e is ArgParserException) exit(1);
  } finally {
    client?.dispose();
  }
}
