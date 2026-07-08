import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:args/args.dart';

/// SealAppendObject operation example
///
/// This example demonstrates how to seal an appendable object so that no more
/// data can be appended to it. It first appends data to the object, then seals
/// the object using the current length as the expected position.
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
      print('Usage: dart seal_append_object.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      print('');
      print('Example:');
      print(
        '  dart seal_append_object.dart -r cn-hangzhou -b my-bucket -k my-object',
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

    final content = 'Hello, OSS!';

    print('Sealing appendable object...');
    print('Bucket: $bucket');
    print('Key: $key');
    print('Region: $region');
    if (endpoint != null) {
      print('Endpoint: $endpoint');
    }
    print('');

    // Step 1: append data to create/extend the appendable object.
    final appendResult = await client.appendObject(
      AppendObjectRequest(
        bucket: bucket,
        key: key,
        position: 0,
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(content))),
      ),
    );

    print('Append successful!');
    print('Next Append Position: ${appendResult.nextAppendPosition}');

    // Step 2: seal the appendable object using the current length as position.
    final sealResult = await client.sealAppendObject(
      SealAppendObjectRequest(
        bucket: bucket,
        key: key,
        position: appendResult.nextAppendPosition,
      ),
    );

    print('');
    print('✅ Successfully sealed appendable object!');
    print('Request ID: ${sealResult.requestId}');
    print('Status Code: ${sealResult.statusCode}');
    print('Sealed Time: ${sealResult.sealedTime}');
  } catch (e) {
    if (e is ArgParserException) {
      print('Error: ${e.message}');
      print('');
      print('Usage: dart seal_append_object.dart [options]');
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
