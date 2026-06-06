import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:args/args.dart';

/// GetObjectToFile operation example
///
/// This example demonstrates how to download an object and save it to a local file.
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
      help: 'The name of the bucket.',
      mandatory: true,
    )
    ..addOption(
      'key',
      abbr: 'k',
      help: 'The name of the object.',
      mandatory: true,
    )
    ..addOption(
      'file',
      abbr: 'f',
      help: 'The local file path to save the object.',
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
      print('Usage: dart get_object_to_file.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      print('');
      print('Example:');
      print(
        '  dart get_object_to_file.dart -r cn-hangzhou -b my-bucket -k my-object -f /tmp/my-file',
      );
      return;
    }

    final region = results['region'] as String;
    final bucket = results['bucket'] as String;
    final endpoint = results['endpoint'] as String?;
    final key = results['key'] as String;
    final file = results['file'] as String;

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

    print('Getting object to file...');
    print('Bucket: $bucket');
    print('Key: $key');
    print('File: $file');
    print('Region: $region');
    if (endpoint != null) {
      print('Endpoint: $endpoint');
    }
    print('');

    final result = await client.getObjectToFile(
      GetObjectRequest(bucket: bucket, key: key),
      file,
    );

    print('✅ Successfully saved object to file!');
    print('Request ID: ${result.requestId}');
    print('Status Code: ${result.statusCode}');
    print('Content-Length: ${result.contentLength}');
  } catch (e) {
    if (e is ArgParserException) {
      print('Error: ${e.message}');
      print('');
      print('Usage: dart get_object_to_file.dart [options]');
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
