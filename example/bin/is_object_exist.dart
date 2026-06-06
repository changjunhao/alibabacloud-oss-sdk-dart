import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:args/args.dart';

/// IsObjectExist operation example
///
/// This example demonstrates how to check if an object exists in a bucket.
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('region',
        abbr: 'r',
        help: 'The region in which the bucket is located.',
        mandatory: true)
    ..addOption('endpoint',
        abbr: 'e',
        help: 'The domain names that other services can use to access OSS.')
    ..addOption('bucket',
        abbr: 'b', help: 'The name of the bucket.', mandatory: true)
    ..addOption('key',
        abbr: 'k', help: 'The name of the object.', mandatory: true)
    ..addFlag('help',
        abbr: 'h', help: 'Show this help message.', negatable: false);

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      print('Usage: dart is_object_exist.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      print('');
      print('Example:');
      print(
          '  dart is_object_exist.dart -r cn-hangzhou -b my-bucket -k my-object');
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

    print('Checking if object exists...');
    print('Bucket: $bucket');
    print('Key: $key');
    print('Region: $region');
    if (endpoint != null) {
      print('Endpoint: $endpoint');
    }
    print('');

    final exists = await client.isObjectExist(bucket, key);

    if (exists) {
      print('✅ Object exists!');
    } else {
      print('❌ Object does not exist.');
    }
  } catch (e) {
    if (e is ArgParserException) {
      print('Error: ${e.message}');
      print('');
      print('Usage: dart is_object_exist.dart [options]');
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
