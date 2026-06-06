import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:args/args.dart';

/// DeleteObject operation example
///
/// This example demonstrates how to delete an object from a bucket.
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
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show this help message.',
      negatable: false,
    );

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      print('Usage: dart delete_object.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      print('');
      print('Example:');
      print(
        '  dart delete_object.dart -r cn-hangzhou -b my-bucket -k my-object',
      );
      return;
    }

    final region = results['region'] as String;
    final bucket = results['bucket'] as String;
    final endpoint = results['endpoint'] as String?;
    final key = results['key'] as String;

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

    print('Deleting object...');
    print('Bucket: $bucket');
    print('Key: $key');
    print('Region: $region');
    if (endpoint != null) {
      print('Endpoint: $endpoint');
    }
    print('');

    final result = await client.deleteObject(
      DeleteObjectRequest(bucket: bucket, key: key),
    );

    print('✅ Successfully deleted object!');
    print('Request ID: ${result.requestId}');
    print('Status Code: ${result.statusCode}');
  } catch (e) {
    if (e is ArgParserException) {
      print('Error: ${e.message}');
      print('');
      print('Usage: dart delete_object.dart [options]');
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
