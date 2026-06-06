import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:args/args.dart';

/// CompleteMultipartUpload operation example
///
/// This example demonstrates how to complete a multipart upload task.
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
      'upload-id',
      help: 'The ID that identifies the multipart upload task.',
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
      print('Usage: dart complete_multipart_upload.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      return;
    }

    final region = results['region'] as String;
    final bucket = results['bucket'] as String;
    final endpoint = results['endpoint'] as String?;
    final key = results['key'] as String;
    final uploadId = results['upload-id'] as String;

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

    // Your parts list - in a real scenario, you would collect ETags from UploadPart results
    final parts = <UploadPart>[];

    final result = await client.completeMultipartUpload(
      CompleteMultipartUploadRequest(
        bucket: bucket,
        key: key,
        uploadId: uploadId,
        completeMultipartUpload: CompleteMultipartUpload(parts: parts),
      ),
    );

    print('result:');
    print('  bucket: ${result.bucket}');
    print('  key: ${result.key}');
    print('  etag: ${result.etag}');
    print('  location: ${result.location}');
    print('  status code: ${result.statusCode}');
    print('  request id: ${result.requestId}');
  } catch (e) {
    if (e is ArgParserException) {
      print('Error: ${e.message}');
      print('');
      print('Usage: dart complete_multipart_upload.dart [options]');
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
