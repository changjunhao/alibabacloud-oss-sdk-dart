import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:args/args.dart';

/// DeleteMultipleObjects operation example
///
/// This example demonstrates how to delete multiple objects from a bucket.
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
      'objects',
      abbr: 'o',
      help: 'Comma-separated list of object keys to delete.',
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
      print('Usage: dart delete_multiple_objects.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      print('');
      print('Example:');
      print(
        '  dart delete_multiple_objects.dart -r cn-hangzhou -b my-bucket -o key1,key2,key3',
      );
      return;
    }

    final region = results['region'] as String;
    final bucket = results['bucket'] as String;
    final endpoint = results['endpoint'] as String?;
    final objects = results['objects'] as String;

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

    final deleteObjects = objects
        .split(',')
        .map((key) => DeleteObject(key: key.trim()))
        .toList();

    print('Deleting multiple objects...');
    print('Bucket: $bucket');
    print('Objects: $objects');
    print('Region: $region');
    if (endpoint != null) {
      print('Endpoint: $endpoint');
    }
    print('');

    final result = await client.deleteMultipleObjects(
      DeleteMultipleObjectsRequest(bucket: bucket, objects: deleteObjects),
    );

    print('✅ Successfully deleted multiple objects!');
    print('Request ID: ${result.requestId}');
    print('Status Code: ${result.statusCode}');
  } catch (e) {
    if (e is ArgParserException) {
      print('Error: ${e.message}');
      print('');
      print('Usage: dart delete_multiple_objects.dart [options]');
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
