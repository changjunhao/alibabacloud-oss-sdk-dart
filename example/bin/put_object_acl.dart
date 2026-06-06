import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:args/args.dart';

/// PutObjectAcl operation example
///
/// This example demonstrates how to configure or modify the access control list (ACL) of an object.
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
      'acl',
      abbr: 'a',
      help:
          'The ACL of the object.\n'
          'Valid values: private, public-read, public-read-write, default',
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
      print('Usage: dart put_object_acl.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      print('');
      print('Example:');
      print(
        '  dart put_object_acl.dart -r cn-hangzhou -b my-bucket -k my-object -a private',
      );
      return;
    }

    final region = results['region'] as String;
    final bucket = results['bucket'] as String;
    final endpoint = results['endpoint'] as String?;
    final key = results['key'] as String;
    final acl = results['acl'] as String;

    // Validate ACL value
    const validAcls = [
      'private',
      'public-read',
      'public-read-write',
      'default',
    ];
    if (!validAcls.contains(acl)) {
      print(
        'Error: Invalid ACL value "$acl". Valid values are: ${validAcls.join(", ")}',
      );
      exit(1);
    }

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

    print('Setting object ACL...');
    print('Bucket: $bucket');
    print('Key: $key');
    print('ACL: $acl');
    print('Region: $region');
    if (endpoint != null) {
      print('Endpoint: $endpoint');
    }
    print('');

    final result = await client.putObjectAcl(
      PutObjectAclRequest(bucket: bucket, key: key, objectAcl: acl),
    );

    print('✅ Successfully set object ACL!');
    print('Request ID: ${result.requestId}');
    print('Status Code: ${result.statusCode}');
  } catch (e) {
    if (e is ArgParserException) {
      print('Error: ${e.message}');
      print('');
      print('Usage: dart put_object_acl.dart [options]');
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
