import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

/// Minimal example for `pub.dev`.
///
/// Before running:
/// - Set `OSS_ACCESS_KEY_ID`
/// - Set `OSS_ACCESS_KEY_SECRET`
/// - Replace the region, bucket, and object key placeholders
Future<void> main() async {
  const region = 'cn-hangzhou';
  const bucket = 'example-bucket';
  const key = 'example-object.txt';

  final config = Configuration.defaultConfig()
      .withRegion(region)
      .withCredentialsProvider(EnvironmentCredentialsProvider());

  final client = Client(config);

  final result = await client.headObject(
    HeadObjectRequest(bucket: bucket, key: key),
  );

  print('HeadObject status: ${result.statusCode}');
  print('Request ID: ${result.requestId}');
}
