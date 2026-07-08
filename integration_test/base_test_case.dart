import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

/// Base test case for integration tests.
///
/// Provides common utilities including:
/// - Environment variable configuration
/// - Client management (default, custom, invalid)
/// - Random name generation for buckets/objects/files
/// - Bucket lifecycle management (create/clean)
/// - Test file management
/// - Async assertion helpers
class BaseTestCase {
  static const String bucketNamePrefix = 'dart-sdk-test-bucket-';
  static const String objectNamePrefix = 'dart-sdk-test-object-';
  static const String fileNamePrefix = 'dart-sdk-test-file-';

  static final String _randomStrChars = 'abcdefghijklmnopqrstuvwxyz';

  // ---------------------------------------------------------------------------
  // Environment check
  // ---------------------------------------------------------------------------

  /// Whether the required OSS_TEST_* environment variables are configured.
  static bool get isConfigured {
    final endpoint = Platform.environment['OSS_TEST_ENDPOINT'] ?? '';
    final region = Platform.environment['OSS_TEST_REGION'] ?? '';
    final accessKeyId = Platform.environment['OSS_TEST_ACCESS_KEY_ID'] ?? '';
    final accessKeySecret =
        Platform.environment['OSS_TEST_ACCESS_KEY_SECRET'] ?? '';
    return endpoint.isNotEmpty &&
        region.isNotEmpty &&
        accessKeyId.isNotEmpty &&
        accessKeySecret.isNotEmpty;
  }

  /// Returns a skip reason string when credentials are not configured,
  /// or `null` when the environment is ready for integration tests.
  static String? get skipReason => isConfigured
      ? null
      : 'Integration test skipped: OSS_TEST_* environment variables not configured';

  /// Temporary directory for test file isolation
  final String tempDir =
      '${Directory.systemTemp.path}${Platform.pathSeparator}dart-sdk-test_${_generateUuid()}';

  Client? _client;
  Client? _invalidClient;

  // ---------------------------------------------------------------------------
  // Environment variables
  // ---------------------------------------------------------------------------

  /// The OSS endpoint from environment variable `OSS_TEST_ENDPOINT`.
  String get endpoint => Platform.environment['OSS_TEST_ENDPOINT'] ?? '';

  /// The OSS region from environment variable `OSS_TEST_REGION`.
  String get region => Platform.environment['OSS_TEST_REGION'] ?? '';

  /// The access key ID from environment variable `OSS_TEST_ACCESS_KEY_ID`.
  String get accessKeyId =>
      Platform.environment['OSS_TEST_ACCESS_KEY_ID'] ?? '';

  /// The access key secret from environment variable `OSS_TEST_ACCESS_KEY_SECRET`.
  String get accessKeySecret =>
      Platform.environment['OSS_TEST_ACCESS_KEY_SECRET'] ?? '';

  // ---------------------------------------------------------------------------
  // Client management
  // ---------------------------------------------------------------------------

  /// Returns a cached default client configured with environment credentials.
  Client getDefaultClient() {
    if (_client != null) {
      return _client!;
    }

    final credentialsProvider = StaticCredentialsProvider(
      accessKeyId: accessKeyId,
      accessKeySecret: accessKeySecret,
    );

    final config = Configuration(
      endpoint: endpoint,
      region: region,
      credentialsProvider: credentialsProvider,
    );

    _client = Client(config);
    return _client!;
  }

  /// Creates a custom client with the given [region] and [endpoint].
  Client getClient(String region, String endpoint) {
    final credentialsProvider = StaticCredentialsProvider(
      accessKeyId: accessKeyId,
      accessKeySecret: accessKeySecret,
    );

    final config = Configuration(
      endpoint: endpoint,
      region: region,
      credentialsProvider: credentialsProvider,
    );

    return Client(config);
  }

  /// Returns a cached client with invalid credentials for error testing.
  Client getInvalidAkClient() {
    if (_invalidClient != null) {
      return _invalidClient!;
    }

    final credentialsProvider = StaticCredentialsProvider(
      accessKeyId: 'invalid-ak-id',
      accessKeySecret: 'invalid-ak-secret',
    );

    final config = Configuration(
      endpoint: endpoint,
      region: region,
      credentialsProvider: credentialsProvider,
    );

    _invalidClient = Client(config);
    return _invalidClient!;
  }

  // ---------------------------------------------------------------------------
  // Random name generation
  // ---------------------------------------------------------------------------

  /// Generates a random lowercase alphabetic string of the given [length].
  static String randomStr(int length) {
    final random = Random();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(_randomStrChars[random.nextInt(_randomStrChars.length)]);
    }
    return buffer.toString();
  }

  /// Generates a random bucket name with prefix and timestamp.
  ///
  /// Format: `dart-sdk-test-bucket-{6chars}-{timestamp}`
  String randomBucketName() {
    final ranStr = randomStr(6);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return '$bucketNamePrefix$ranStr-$timestamp';
  }

  /// Generates a random object name with prefix and timestamp.
  ///
  /// Format: `dart-sdk-test-object-{6chars}-{timestamp}`
  String randomObjectName() {
    final ranStr = randomStr(6);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return '$objectNamePrefix$ranStr-$timestamp';
  }

  /// Generates a random file name with prefix and timestamp.
  ///
  /// Format: `dart-sdk-test-file-{6chars}-{timestamp}`
  String randomFileName() {
    final ranStr = randomStr(6);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return '$fileNamePrefix$ranStr-$timestamp';
  }

  // ---------------------------------------------------------------------------
  // Bucket lifecycle management
  // ---------------------------------------------------------------------------

  /// Creates a bucket with the given [bucket] name using the specified [client].
  Future<void> createBucket(Client client, String bucket) async {
    final request = PutBucketRequest(bucket: bucket);
    await client.putBucket(request);
  }

  /// Cleans a single bucket by removing all objects, versions, and uploads,
  /// then deletes the bucket itself.
  ///
  /// All errors during cleanup are caught and ignored to ensure the
  /// cleanup process continues.
  Future<void> cleanBucket(Client client, String bucket) async {
    // 1. Delete all object versions (including delete markers)
    try {
      final listVersionRequest = ListObjectVersionsRequest(bucket: bucket);
      final listVersionResult = await client.listObjectVersions(
        listVersionRequest,
      );

      // Delete versioned objects
      if (listVersionResult.versions != null &&
          listVersionResult.versions!.isNotEmpty) {
        final objects = listVersionResult.versions!
            .map((v) => DeleteObject(key: v.key, versionId: v.versionId))
            .toList();
        final deleteRequest = DeleteMultipleObjectsRequest(
          bucket: bucket,
          delete: Delete(objects: objects, quiet: true),
        );
        try {
          await client.deleteMultipleObjects(deleteRequest);
        } catch (_) {}
      }

      // Delete markers
      if (listVersionResult.deleteMarkers != null &&
          listVersionResult.deleteMarkers!.isNotEmpty) {
        final objects = listVersionResult.deleteMarkers!
            .map((dm) => DeleteObject(key: dm.key, versionId: dm.versionId))
            .toList();
        final deleteRequest = DeleteMultipleObjectsRequest(
          bucket: bucket,
          delete: Delete(objects: objects, quiet: true),
        );
        try {
          await client.deleteMultipleObjects(deleteRequest);
        } catch (_) {}
      }
    } catch (_) {}

    // 2. Delete all ordinary objects
    try {
      final listRequest = ListObjectsV2Request(bucket: bucket);
      final result = await client.listObjectsV2(listRequest);

      if (result.contents != null && result.contents!.isNotEmpty) {
        final objects = result.contents!
            .map((obj) => DeleteObject(key: obj.key))
            .toList();
        final deleteRequest = DeleteMultipleObjectsRequest(
          bucket: bucket,
          delete: Delete(objects: objects, quiet: true),
        );
        try {
          await client.deleteMultipleObjects(deleteRequest);
        } catch (_) {}
      }
    } catch (_) {}

    // 3. Abort all in-progress multipart uploads
    try {
      final listUploadsRequest = ListMultipartUploadsRequest(bucket: bucket);
      final listResult = await client.listMultipartUploads(listUploadsRequest);

      if (listResult.uploads != null && listResult.uploads!.isNotEmpty) {
        for (final upload in listResult.uploads!) {
          try {
            final abortRequest = AbortMultipartUploadRequest(
              bucket: bucket,
              key: upload.key,
              uploadId: upload.uploadId,
            );
            await client.abortMultipartUpload(abortRequest);
          } catch (_) {}
        }
      }
    } catch (_) {}

    // 4. Delete the bucket
    try {
      final deleteBucketRequest = DeleteBucketRequest(bucket: bucket);
      await client.deleteBucket(deleteBucketRequest);
    } catch (_) {}
  }

  /// Lists all buckets matching [prefix] and cleans each one.
  ///
  /// Uses the default client to list buckets.
  Future<void> cleanBuckets(String prefix) async {
    try {
      final client = getDefaultClient();
      final listBucketsRequest = ListBucketsRequest(prefix: prefix);
      final listBucketsResult = await client.listBuckets(listBucketsRequest);

      if (listBucketsResult.buckets != null) {
        for (final bucket in listBucketsResult.buckets!) {
          if (bucket.name == null) continue;

          // Use the bucket's region/endpoint if available, otherwise use default
          final bucketRegion = bucket.region ?? region;
          final bucketEndpoint = bucket.extranetEndpoint ?? endpoint;
          final bucketClient = getClient(bucketRegion, bucketEndpoint);

          await cleanBucket(bucketClient, bucket.name!);
        }
      }
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Test file management
  // ---------------------------------------------------------------------------

  /// Creates a test file with the given [fileName] and string [contents].
  ///
  /// Returns the absolute path to the created file, or `null` on failure.
  Future<String?> createTestFile(String fileName, String contents) async {
    try {
      final filePath = '$tempDir${Platform.pathSeparator}$fileName';
      final directory = Directory(tempDir);
      await directory.create(recursive: true);

      final file = File(filePath);
      await file.writeAsString(contents);
      return filePath;
    } catch (_) {
      return null;
    }
  }

  /// Creates a test file of the specified [size] in bytes with random content.
  ///
  /// Returns the absolute path to the created file, or `null` on failure.
  Future<String?> createTestFileWithSize(String fileName, int size) async {
    try {
      final filePath = '$tempDir${Platform.pathSeparator}$fileName';
      final directory = Directory(tempDir);
      await directory.create(recursive: true);

      final file = File(filePath);
      // Write random bytes in chunks to handle large sizes efficiently
      final sink = file.openWrite();
      const chunkSize = 1024 * 1024; // 1MB chunks
      var remaining = size;
      final random = Random();

      while (remaining > 0) {
        final writeSize = remaining < chunkSize ? remaining : chunkSize;
        final bytes = Uint8List(writeSize);
        for (var i = 0; i < writeSize; i++) {
          bytes[i] = random.nextInt(256);
        }
        sink.add(bytes);
        remaining -= writeSize;
      }

      await sink.flush();
      await sink.close();
      return filePath;
    } catch (_) {
      return null;
    }
  }

  /// Removes the test file at [location].
  ///
  /// Errors are silently ignored.
  Future<void> removeTestFile(String location) async {
    try {
      final file = File(location);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore errors when removing test files
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Generates a UUID-like string for directory isolation.
  static String _generateUuid() {
    final random = Random();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

// -----------------------------------------------------------------------------
// Async assertion helpers (top-level functions)
// -----------------------------------------------------------------------------

/// Asserts that the given async [expression] throws an error.
///
/// If no error is thrown, the test fails with [message].
/// An optional [errorHandler] can be provided to inspect the thrown error.
Future<void> expectAsyncError<T>(
  Future<T> Function() expression, {
  String message = '',
  void Function(Object error)? errorHandler,
}) async {
  try {
    await expression();
    final customMessage = message.isEmpty
        ? 'Asynchronous call did not throw an error.'
        : message;
    fail(customMessage);
  } catch (error) {
    if (error is TestFailure) rethrow;
    if (errorHandler != null) {
      errorHandler(error);
    }
  }
}

/// Asserts that the given async [expression] does NOT throw an error.
///
/// If an error is thrown, the test fails with a descriptive message.
Future<T> expectNoAsyncError<T>(Future<T> Function() expression) async {
  try {
    return await expression();
  } catch (error) {
    fail('Expected no error but threw: $error');
  }
}
