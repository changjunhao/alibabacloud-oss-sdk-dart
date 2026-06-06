import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:args/args.dart';

/// CopyObject operation example
///
/// This example demonstrates how to copy an object within OSS.
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'region',
      abbr: 'r',
      help: 'The region in which the bucket is located.',
      mandatory: true,
    )
    ..addOption(
      'endpoint',
      abbr: 'e',
      help: 'The domain names that other services can use to access OSS.',
    )
    ..addOption(
      'bucket',
      abbr: 'b',
      help: 'The name of the destination bucket.',
      mandatory: true,
    )
    ..addOption(
      'key',
      abbr: 'k',
      help: 'The name of the destination object.',
      mandatory: true,
    )
    ..addOption(
      'source-bucket',
      help: 'The name of the source bucket.',
      mandatory: true,
    )
    ..addOption(
      'source-key',
      help: 'The name of the source object.',
      mandatory: true,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show this help message.',
      negatable: false,
    );

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      print('Usage: dart copy_object.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      print('');
      print('Example:');
      print(
        '  dart copy_object.dart -r cn-hangzhou -b dest-bucket -k dest-key --source-bucket src-bucket --source-key src-key',
      );
      return;
    }

    final region = results['region'] as String;
    final bucket = results['bucket'] as String;
    final endpoint = results['endpoint'] as String?;
    final key = results['key'] as String;
    final sourceBucket = results['source-bucket'] as String;
    final sourceKey = results['source-key'] as String;

    // Using the SDK's default configuration
    // Loading credentials values from the environment variables
    final credentialsProvider = EnvironmentCredentialsProvider();

    var config = Configuration.defaultConfig()
        .withRegion(region)
        .withCredentialsProvider(credentialsProvider);

    if (endpoint != null) {
      config = config.withEndpoint(endpoint);
    }

    final client = Client(config);

    print('Copying object...');
    print('Source: $sourceBucket/$sourceKey');
    print('Destination: $bucket/$key');
    print('Region: $region');
    if (endpoint != null) {
      print('Endpoint: $endpoint');
    }
    print('');

    final result = await client.copyObject(
      CopyObjectRequest(
        bucket: bucket,
        key: key,
        sourceBucket: sourceBucket,
        sourceKey: sourceKey,
      ),
    );

    print('✅ Successfully copied object!');
    print('Request ID: ${result.requestId}');
    print('Status Code: ${result.statusCode}');
  } catch (e) {
    if (e is ArgParserException) {
      print('Error: ${e.message}');
      print('');
      print('Usage: dart copy_object.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      exit(1);
    } else {
      print('❌ Error occurred: $e');
      exit(1);
    }
  }
}
