import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'package:args/args.dart';

/// CreateBucketSpace example. Uses the BucketSpace client to call regular PutBucket,
/// specifies the physical full name of the parent AgenticBucket via the x-oss-agentic-bucket header,
/// and does not carry a CreateBucketConfiguration body.
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('region', abbr: 'r', mandatory: true)
    ..addOption('account-id', abbr: 'a', mandatory: true)
    ..addOption('endpoint', abbr: 'e')
    ..addOption('bucket',
        abbr: 'b', help: 'Logical prefix of the BucketSpace.', mandatory: true)
    ..addOption('agentic-bucket',
        help: 'Logical prefix of the parent AgenticBucket.', mandatory: true)
    ..addFlag('help', abbr: 'h', negatable: false);
  Client? client;
  try {
    final results = parser.parse(arguments);
    if (results['help'] as bool) {
      print(
          'Usage: dart create_bucket_space.dart [options]\n\n${parser.usage}');
      return;
    }
    final accountId = results['account-id'] as String;
    final region = results['region'] as String;
    client = BucketSpaceClient.make(Configuration(
      region: region,
      accountId: accountId,
      endpoint: results['endpoint'] as String?,
      credentialsProvider: EnvironmentCredentialsProvider(),
    ));
    final result = await client.putBucket(PutBucketRequest(
      bucket: results['bucket'] as String,
      // The parent AgenticBucket must use the full physical name, not the short prefix.
      agenticBucket: '${results['agentic-bucket']}-$accountId-$region-ab-apsr',
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
