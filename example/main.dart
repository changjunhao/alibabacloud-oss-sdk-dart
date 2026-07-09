import 'dart:convert';
import 'dart:typed_data';

import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

/// Comprehensive example for `pub.dev`.
///
/// Demonstrates the most common OSS operations:
///   - Create a client
///   - Upload an object (PutObject)
///   - Download an object (GetObject)
///   - Copy an object (CopyObject)
///   - List objects (ListObjectsV2)
///   - Delete an object (DeleteObject)
///   - Generate a pre-signed URL (Presign)
///
/// Before running:
/// - Set environment variable `OSS_ACCESS_KEY_ID`
/// - Set environment variable `OSS_ACCESS_KEY_SECRET`
/// - Replace the `region`, `bucket`, and `key` values below
Future<void> main() async {
  // ─── Configuration ───────────────────────────────────────────────
  const region = 'cn-hangzhou';
  const bucket = 'example-bucket';
  const key = 'example-object.txt';
  const copyKey = 'example-object-copy.txt';

  final config = Configuration.defaultConfig()
      .withRegion(region)
      .withCredentialsProvider(EnvironmentCredentialsProvider());

  final client = Client(config);

  // ─── 1. Upload an object ─────────────────────────────────────────
  final content = 'Hello, Alibaba Cloud OSS!';
  final putResult = await client.putObject(
    PutObjectRequest(
      bucket: bucket,
      key: key,
      body: ByteStream.fromData(
        Uint8List.fromList(utf8.encode(content)),
      ),
    ),
  );
  print('[PutObject] uploaded, ETag: ${putResult.etag}');

  // ─── 2. Download an object ───────────────────────────────────────
  final getResult = await client.getObject(
    GetObjectRequest(bucket: bucket, key: key),
  );
  final body = await getResult.body?.readData();
  print('[GetObject] downloaded ${getResult.contentLength} bytes, '
      'content: ${body != null ? utf8.decode(body) : "<empty>"}');

  // ─── 3. Copy an object ───────────────────────────────────────────
  final copyResult = await client.copyObject(
    CopyObjectRequest(
      bucket: bucket,
      key: copyKey,
      sourceBucket: bucket,
      sourceKey: key,
    ),
  );
  print('[CopyObject] copied to $copyKey, '
      'status: ${copyResult.statusCode}');

  // ─── 4. List objects ─────────────────────────────────────────────
  final listResult = await client.listObjectsV2(
    ListObjectsV2Request(
      bucket: bucket,
      prefix: 'example-',
      maxKeys: 100,
    ),
  );
  print('[ListObjectsV2] found ${listResult.contents?.length ?? 0} objects:');
  for (final obj in listResult.contents ?? []) {
    print('  - ${obj.key} (${obj.size} bytes)');
  }

  // ─── 5. Generate a pre-signed URL ────────────────────────────────
  final presignResult = await client.presignGetObject(
    GetObjectRequest(bucket: bucket, key: key),
  );
  print('[PresignGetObject] URL: ${presignResult.url}');
  print('  expires at: ${presignResult.expiration}');

  // ─── 6. Delete objects ───────────────────────────────────────────
  final deleteResult = await client.deleteMultipleObjects(
    DeleteMultipleObjectsRequest(
      bucket: bucket,
      delete: Delete(
        objects: [
          DeleteObject(key: key),
          DeleteObject(key: copyKey),
        ],
      ),
    ),
  );
  print('[DeleteMultipleObjects] deleted:');
  for (final deleted in deleteResult.deletedObjects ?? []) {
    print('  - ${deleted.key}');
  }

  // ─── Clean up ────────────────────────────────────────────────────
  client.dispose();
  print('\nDone!');
}
