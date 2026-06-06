import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';
import 'package:args/args.dart';

/// Presign operation example
///
/// This example demonstrates how to generate pre-signed URLs for various operations.
/// Use the --api option to select different presign operations:
///   putObject, getObject, headObject, initiateMultipartUpload,
///   uploadPart, completeMultipartUpload, abortMultipartUpload
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
    ..addOption('api',
        abbr: 'a',
        help: 'The API name for presign.\n'
            'Valid values: putObject, getObject, headObject,\n'
            '  initiateMultipartUpload, uploadPart,\n'
            '  completeMultipartUpload, abortMultipartUpload',
        mandatory: true)
    ..addOption('upload-id',
        help:
            'The upload ID (required for uploadPart, completeMultipartUpload, abortMultipartUpload).')
    ..addFlag('help',
        abbr: 'h', help: 'Show this help message.', negatable: false);

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      print('Usage: dart presign.dart [options]');
      print('');
      print('Options:');
      print(parser.usage);
      return;
    }

    final region = results['region'] as String;
    final bucket = results['bucket'] as String;
    final endpoint = results['endpoint'] as String?;
    final key = results['key'] as String;
    final api = results['api'] as String;
    final uploadId = results['upload-id'] as String?;

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

    switch (api.toLowerCase()) {
      case 'putobject':
        await _presignPutObject(client, bucket, key);
        break;
      case 'getobject':
        await _presignGetObject(client, bucket, key);
        break;
      case 'headobject':
        await _presignHeadObject(client, bucket, key);
        break;
      case 'initiatemultipartupload':
        await _presignInitiateMultipartUpload(client, bucket, key);
        break;
      case 'uploadpart':
        await _presignUploadPart(client, bucket, key, uploadId);
        break;
      case 'completemultipartupload':
        await _presignCompleteMultipartUpload(client, bucket, key, uploadId);
        break;
      case 'abortmultipartupload':
        await _presignAbortMultipartUpload(client, bucket, key, uploadId);
        break;
      default:
        print('Error: Unknown API "$api".');
        print(
            'Valid values: putObject, getObject, headObject, initiateMultipartUpload, uploadPart, completeMultipartUpload, abortMultipartUpload');
        exit(1);
    }
  } catch (e) {
    if (e is ArgParserException) {
      print('Error: ${e.message}');
      print('');
      print('Usage: dart presign.dart [options]');
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

void _printPresignResult(PresignResult result) {
  print('presign result:');
  print('  method: ${result.method}');
  print('  url: ${result.url}');
  print('  expiration: ${result.expiration}');
  if (result.signedHeaders != null && result.signedHeaders!.isNotEmpty) {
    print('  signed headers:');
    for (final entry in result.signedHeaders!.entries) {
      print('    ${entry.key}: ${entry.value}');
    }
  }
}

Future<void> _presignGetObject(Client client, String bucket, String key) async {
  final result = await client.presignGetObject(
    GetObjectRequest(
      bucket: bucket,
      key: key,
    ),
  );
  _printPresignResult(result);
}

Future<void> _presignPutObject(Client client, String bucket, String key) async {
  final result = await client.presignPutObject(
    PutObjectRequest(
      bucket: bucket,
      key: key,
    ),
  );
  _printPresignResult(result);
}

Future<void> _presignHeadObject(
    Client client, String bucket, String key) async {
  final result = await client.presignHeadObject(
    HeadObjectRequest(
      bucket: bucket,
      key: key,
    ),
  );
  _printPresignResult(result);
}

Future<void> _presignInitiateMultipartUpload(
    Client client, String bucket, String key) async {
  final result = await client.presignInitiateMultipartUpload(
    InitiateMultipartUploadRequest(
      bucket: bucket,
      key: key,
    ),
  );
  _printPresignResult(result);
}

Future<void> _presignUploadPart(
    Client client, String bucket, String key, String? uploadId) async {
  final result = await client.presignUploadPart(
    UploadPartRequest(
      bucket: bucket,
      key: key,
      partNumber: 1,
      uploadId: uploadId,
    ),
  );
  _printPresignResult(result);
}

Future<void> _presignCompleteMultipartUpload(
    Client client, String bucket, String key, String? uploadId) async {
  final result = await client.presignCompleteMultipartUpload(
    CompleteMultipartUploadRequest(
      bucket: bucket,
      key: key,
      completeAll: 'yes',
      uploadId: uploadId,
    ),
  );
  _printPresignResult(result);
}

Future<void> _presignAbortMultipartUpload(
    Client client, String bucket, String key, String? uploadId) async {
  final result = await client.presignAbortMultipartUpload(
    AbortMultipartUploadRequest(
      bucket: bucket,
      key: key,
      uploadId: uploadId,
    ),
  );
  _printPresignResult(result);
}
