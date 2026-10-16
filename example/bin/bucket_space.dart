import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import 'package:args/args.dart';

/// BucketSpace object read/write example. The regular Client returned by BucketSpaceClient.make rewrites
/// each bucket logical prefix to the physical BucketSpace name, so object operations hit transparently.
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('region', abbr: 'r', mandatory: true)
    ..addOption('account-id', abbr: 'a', mandatory: true)
    ..addOption('endpoint', abbr: 'e')
    ..addOption('bucket',
        abbr: 'b', help: 'Logical prefix of the BucketSpace.', mandatory: true)
    ..addOption('key', abbr: 'k', mandatory: true)
    ..addFlag('help', abbr: 'h', negatable: false);
  Client? client;
  try {
    final results = parser.parse(arguments);
    if (results['help'] as bool) {
      print('Usage: dart bucket_space.dart [options]\n\n${parser.usage}');
      return;
    }
    client = BucketSpaceClient.make(Configuration(
      region: results['region'] as String,
      accountId: results['account-id'] as String,
      endpoint: results['endpoint'] as String?,
      credentialsProvider: EnvironmentCredentialsProvider(),
    ));
    final bucket = results['bucket'] as String;
    final key = results['key'] as String;
    final data = Uint8List.fromList(utf8.encode('hello agentic'));
    final put = await client.putObject(PutObjectRequest(
        bucket: bucket, key: key, body: ByteStream.fromData(data)));
    print('PutObject Status Code: ${put.statusCode}');
    final get =
        await client.getObject(GetObjectRequest(bucket: bucket, key: key));
    print('GetObject body: ${utf8.decode((await get.body!.readData())!)}');
  } catch (e) {
    print('Error: $e');
    if (e is ArgParserException) exit(1);
  } finally {
    client?.dispose();
  }
}
