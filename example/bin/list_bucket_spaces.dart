import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'package:args/args.dart';

/// ListBucketSpaces example, using the paginator to iterate through BucketSpaces under a parent AgenticBucket.
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('region', abbr: 'r', mandatory: true)
    ..addOption('account-id', abbr: 'a', mandatory: true)
    ..addOption('endpoint', abbr: 'e')
    ..addOption('bucket',
        abbr: 'b',
        help: 'Logical prefix of the parent AgenticBucket.',
        mandatory: true)
    ..addFlag('help', abbr: 'h', negatable: false);
  AgenticBucketClient? client;
  try {
    final results = parser.parse(arguments);
    if (results['help'] as bool) {
      print('Usage: dart list_bucket_spaces.dart [options]\n\n${parser.usage}');
      return;
    }
    client = AgenticBucketClient(Configuration(
      region: results['region'] as String,
      accountId: results['account-id'] as String,
      endpoint: results['endpoint'] as String?,
      credentialsProvider: EnvironmentCredentialsProvider(),
    ));
    await for (final page in client
        .listBucketSpacesPaginator(
            ListBucketSpacesRequest(bucket: results['bucket'] as String))
        .stream) {
      for (final space in page.bucketSpaces ?? <BucketSpaceSummary>[]) {
        print(
            'BucketSpace: ${space.name}, StorageClass: ${space.storageClass}');
      }
    }
  } catch (e) {
    print('Error: $e');
    if (e is ArgParserException) exit(1);
  } finally {
    client?.dispose();
  }
}
