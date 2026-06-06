import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:args/args.dart';

/// AppendObject operation example
///
/// This example demonstrates how to append content to an appendable object.
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
      print('Usage: dart append_object.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      print('');
      print('Example:');
      print(
        '  dart append_object.dart -r cn-hangzhou -b my-bucket -k my-object',
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
        .withCredentialsProvider(credentialsProvider)
        .withUploadCRC64Validation(false);

    if (endpoint != null) {
      config = config.withEndpoint(endpoint);
    }

    final client = Client(config);

    final content1 = 'Hello';
    final content2 = ', OSS!';

    print('Appending object...');
    print('Bucket: $bucket');
    print('Key: $key');
    print('Region: $region');
    if (endpoint != null) {
      print('Endpoint: $endpoint');
    }
    print('');

    // First append
    var result = await client.appendObject(
      AppendObjectRequest(
        bucket: bucket,
        key: key,
        position: 0,
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(content1))),
      ),
    );

    print('First append successful!');
    print('Next Append Position: ${result.nextAppendPosition}');

    // Second append
    result = await client.appendObject(
      AppendObjectRequest(
        bucket: bucket,
        key: key,
        position: result.nextAppendPosition,
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(content2))),
      ),
    );

    print('Second append successful!');
    print('');
    print('✅ Successfully appended object!');
    print('Request ID: ${result.requestId}');
    print('Status Code: ${result.statusCode}');
    print('Next Append Position: ${result.nextAppendPosition}');
  } catch (e) {
    if (e is ArgParserException) {
      print('Error: ${e.message}');
      print('');
      print('Usage: dart append_object.dart [options]');
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
