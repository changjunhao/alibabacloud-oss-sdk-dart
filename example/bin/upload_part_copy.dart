import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:args/args.dart';

/// UploadPartCopy operation example
///
/// This example demonstrates how to copy data from an existing object to upload a part.
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
    ..addOption(
      'upload-id',
      help: 'The ID that identifies the multipart upload task.',
      mandatory: true,
    )
    ..addOption(
      'part-number',
      help: 'The part number (1-10000).',
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
      print('Usage: dart upload_part_copy.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      return;
    }

    final region = results['region'] as String;
    final bucket = results['bucket'] as String;
    final endpoint = results['endpoint'] as String?;
    final key = results['key'] as String;
    final sourceBucket = results['source-bucket'] as String;
    final sourceKey = results['source-key'] as String;
    final uploadId = results['upload-id'] as String;
    final partNumber = int.parse(results['part-number'] as String);

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

    final result = await client.uploadPartCopy(
      UploadPartCopyRequest(
        bucket: bucket,
        key: key,
        sourceBucket: sourceBucket,
        sourceKey: sourceKey,
        partNumber: partNumber,
        uploadId: uploadId,
      ),
    );

    print('result:');
    print('  etag: ${result.copyPartResult?.etag}');
    print('  last modified: ${result.copyPartResult?.lastModified}');
    print('  status code: ${result.statusCode}');
    print('  request id: ${result.requestId}');
  } catch (e) {
    if (e is ArgParserException) {
      print('Error: ${e.message}');
      print('');
      print('Usage: dart upload_part_copy.dart [options]');
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
