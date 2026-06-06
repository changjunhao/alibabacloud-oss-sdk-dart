import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:args/args.dart';

/// PutSymlink operation example
///
/// This example demonstrates how to create a symbolic link that points to a target object.
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
        abbr: 'k', help: 'The name of the symlink object.', mandatory: true)
    ..addOption('target',
        abbr: 't',
        help: 'The target object to which the symbolic link points.',
        mandatory: true)
    ..addFlag('help',
        abbr: 'h', help: 'Show this help message.', negatable: false);

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      print('Usage: dart put_symlink.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      return;
    }

    final region = results['region'] as String;
    final bucket = results['bucket'] as String;
    final endpoint = results['endpoint'] as String?;
    final key = results['key'] as String;
    final target = results['target'] as String;

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

    final result = await client.putSymlink(
      PutSymlinkRequest(
        bucket: bucket,
        key: key,
        symlinkTarget: target,
      ),
    );

    print('result:');
    print('  status code: ${result.statusCode}');
    print('  request id: ${result.requestId}');
  } catch (e) {
    if (e is ArgParserException) {
      print('Error: ${e.message}');
      print('');
      print('Usage: dart put_symlink.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      exit(1);
    } else {
      print('Error: $e');
      exit(1);
    }
  }
}
