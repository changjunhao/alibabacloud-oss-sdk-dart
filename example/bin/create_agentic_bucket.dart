import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'package:args/args.dart';

/// CreateAgenticBucket example.
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('region', abbr: 'r', mandatory: true)
    ..addOption('account-id',
        abbr: 'a', help: 'Alibaba Cloud account UID.', mandatory: true)
    ..addOption('endpoint', abbr: 'e')
    ..addOption('bucket',
        abbr: 'b',
        help: 'Logical prefix of the AgenticBucket.',
        mandatory: true)
    ..addOption('storage-class')
    ..addOption('data-redundancy-type')
    ..addFlag('alias', help: 'Use short alias host label.', negatable: false)
    ..addFlag('help', abbr: 'h', negatable: false);

  AgenticBucketClient? client;
  try {
    final results = parser.parse(arguments);
    if (results['help'] as bool) {
      print(
          'Usage: dart create_agentic_bucket.dart [options]\n\n${parser.usage}');
      return;
    }
    final config = Configuration(
      region: results['region'] as String,
      accountId: results['account-id'] as String,
      endpoint: results['endpoint'] as String?,
      useVirtualHostedAlias: (results['alias'] as bool) ? true : null,
      credentialsProvider: EnvironmentCredentialsProvider(),
    );
    client = AgenticBucketClient(config);
    final storageClass = results['storage-class'] as String?;
    final redundancy = results['data-redundancy-type'] as String?;
    final result = await client.createAgenticBucket(CreateAgenticBucketRequest(
      bucket: results['bucket'] as String,
      createAgenticBucketConfiguration:
          storageClass == null && redundancy == null
              ? null
              : CreateAgenticBucketConfiguration(
                  storageClass: storageClass, dataRedundancyType: redundancy),
    ));
    print('Status Code: ${result.statusCode}');
    print('Request ID: ${result.requestId}');
  } catch (e) {
    print('Error: $e');
    if (e is ArgParserException) exit(1);
  } finally {
    client?.dispose();
  }
}
