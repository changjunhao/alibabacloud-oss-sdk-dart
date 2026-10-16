import 'dart:io';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
import '../base_test_case.dart';

/// Only manages resources created by the current run; does not scan or reclaim historical buckets.
class AgenticTestSupport extends BaseTestCase {
  static String? get agenticSkipReason {
    if (Platform.environment['OSS_TEST_ENABLE_AGENTIC'] != 'true') {
      return 'OSS_TEST_ENABLE_AGENTIC=true not explicitly set; no real Agentic resources will be created';
    }
    if (!BaseTestCase.isConfigured ||
        (Platform.environment['OSS_TEST_USER_ID'] ?? '').isEmpty) {
      return 'Agentic tests require OSS_TEST_* configuration and OSS_TEST_USER_ID';
    }
    return null;
  }

  String get accountId => Platform.environment['OSS_TEST_USER_ID'] ?? '';
  final _buckets = <String>[];
  final _spaces = <String>[];
  final _objects = <(String, String)>[];
  final _uploads = <(String, String, String)>[];
  final _disabled = <String>{};
  final _disposers = <void Function()>[];
  AgenticBucketClient? _agentic;
  Client? _spaceClient;

  Configuration configuration({
    bool path = false,
    bool alias = false,
    bool invalidCredentials = false,
  }) => Configuration(
    region: region,
    endpoint: endpoint,
    accountId: accountId,
    usePathStyle: path,
    useVirtualHostedAlias: alias,
    credentialsProvider: StaticCredentialsProvider(
      accessKeyId: invalidCredentials ? 'invalid-ak' : accessKeyId,
      accessKeySecret: invalidCredentials ? 'invalid-sk' : accessKeySecret,
    ),
  );

  AgenticBucketClient get agentic => _agentic ??= makeAgentic();
  Client get spaces => _spaceClient ??= makeSpaces();

  AgenticBucketClient makeAgentic({
    bool path = false,
    bool alias = false,
    bool invalidCredentials = false,
  }) {
    final client = AgenticBucketClient(
      configuration(
        path: path,
        alias: alias,
        invalidCredentials: invalidCredentials,
      ),
    );
    _disposers.add(client.dispose);
    return client;
  }

  Client makeSpaces({bool path = false, bool alias = false}) {
    final client = BucketSpaceClient.make(
      configuration(path: path, alias: alias),
    );
    _disposers.add(client.dispose);
    return client;
  }

  String newPrefix() => 'dart-agt-${BaseTestCase.randomStr(8)}';
  String fullBucketName(String prefix) => '$prefix-$accountId-$region-ab-apsr';
  String fullSpaceName(String prefix) => '$prefix-$accountId-$region-bs-apsr';

  Future<String> createBucketFixture({
    CreateAgenticBucketConfiguration? config,
  }) async {
    final prefix = newPrefix();
    final result = await agentic.createAgenticBucket(
      CreateAgenticBucketRequest(
        bucket: prefix,
        createAgenticBucketConfiguration: config,
      ),
    );
    _buckets.add(prefix);
    print('Created AgenticBucket logical prefix: $prefix');
    expect(result.statusCode, 200);
    return prefix;
  }

  Future<String> createSpaceFixture(String parent) async {
    final prefix = newPrefix();
    final result = await spaces.putBucket(
      PutBucketRequest(bucket: prefix, agenticBucket: fullBucketName(parent)),
    );
    _spaces.add(prefix);
    print('Created BucketSpace logical prefix: $prefix');
    expect(result.statusCode, 200);
    return prefix;
  }

  /// Registers the generated object key before writing so cleanup can attempt recovery even on failure.
  void trackObject(String space, String key) => _objects.add((space, key));
  void trackUpload(String space, String key, String uploadId) =>
      _uploads.add((space, key, uploadId));

  Future<void> disableBucket(String prefix) async {
    final result = await agentic.putAgenticBucketStatus(
      PutAgenticBucketStatusRequest(bucket: prefix, status: 'Disabled'),
    );
    expect(result.statusCode, 200);
    _disabled.add(prefix);
    print('Disabled AgenticBucket logical prefix: $prefix');
  }

  Future<void> cleanup() async {
    final failures = <String>[];
    Future<void> attempt(
      String resource,
      Future<void> Function() action,
    ) async {
      try {
        await action();
      } on ServerError catch (error) {
        final absent =
            error.statusCode == 404 &&
            {
              'NoSuchKey',
              'NoSuchBucket',
              'NoSuchAgenticBucket',
              'NoSuchUpload',
            }.contains(error.code);
        if (absent) {
          return;
        }
        failures.add('$resource: ${error.statusCode}/${error.code}');
      } catch (error) {
        failures.add('$resource: ${error.runtimeType}');
      }
    }

    try {
      for (final upload in _uploads.reversed) {
        await attempt('Multipart ${upload.$1}/${upload.$2}', () async {
          await spaces.abortMultipartUpload(
            AbortMultipartUploadRequest(
              bucket: upload.$1,
              key: upload.$2,
              uploadId: upload.$3,
            ),
          );
        });
      }
      for (final object in _objects.reversed) {
        await attempt('Object ${object.$1}/${object.$2}', () async {
          await spaces.deleteObject(
            DeleteObjectRequest(bucket: object.$1, key: object.$2),
          );
        });
      }
      for (final space in _spaces.reversed) {
        await attempt('BucketSpace $space', () async {
          await spaces.deleteBucket(DeleteBucketRequest(bucket: space));
        });
      }
      for (final bucket in _buckets.reversed) {
        if (!_disabled.contains(bucket)) {
          await attempt('Disable $bucket', () => disableBucket(bucket));
        }
        await attempt('Delete $bucket', () async {
          try {
            final result = await agentic.deleteAgenticBucket(
              DeleteAgenticBucketRequest(bucket: bucket),
            );
            expect(result.statusCode, 204);
            print('Deleted AgenticBucket logical prefix: $bucket');
          } on ServerError catch (error) {
            if (error.statusCode == 409 &&
                error.code == 'AgenticBucketNotReady') {
              print(
                'Pending cooldown cleanup: $bucket; use delete_agentic_bucket example after ~24h to explicitly delete',
              );
            } else {
              rethrow;
            }
          }
        });
      }
    } finally {
      for (final dispose in _disposers.reversed) {
        dispose();
      }
    }
    for (final failure in failures) {
      print('Resource cleanup failed: $failure');
    }
    expect(
      failures,
      isEmpty,
      reason:
          'Resource cleanup still failing for this run; not scanning other resources',
    );
  }
}
