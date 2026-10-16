# Alibaba Cloud OSS SDK for Dart

[![pub package](https://img.shields.io/pub/v/alibabacloud_oss_sdk_dart.svg)](https://pub.dev/packages/alibabacloud_oss_sdk_dart)
[![license](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

alibabacloud-oss-sdk-dart is the Developer Preview for the OSS SDK for the Dart programming language.

## [简体中文](README-CN.md)

## About
> - This Dart SDK is based on the official APIs of [Alibaba Cloud OSS](https://www.aliyun.com/product/oss/).
> - Alibaba Cloud Object Storage Service (OSS) is a cloud storage service provided by Alibaba Cloud, featuring massive capacity, security, a low cost, and high reliability.
> - The OSS can store any type of files and therefore applies to various websites, development enterprises and developers.
> - With this SDK, you can upload, download and manage data on any app anytime and anywhere conveniently.

## Features

### Core Library (`alibabacloud_oss_sdk_dart`)
- Bucket basic operations (create, delete, list, info, location, stat)
- Bucket ACL & versioning
- Object operations (put, get, copy, delete, append, seal append, head, meta)
- Multipart upload (initiate, upload part, upload part copy, complete, abort, list parts)
- Presigned URL generation
- Paginator for list operations
- Object symlink & tagging
- CRC64 data integrity validation
- Multiple signature versions (V1/V4)
- Flexible credentials providers
- Configurable retry policy
- Logging support

### Extension Library (`alibabacloud_oss_sdk_extension`)
- Bucket CORS
- Bucket Encryption
- Bucket Logging
- Bucket Policy
- Bucket Referer
- Bucket Tags
- Bucket Transfer Acceleration
- Bucket WORM (Write Once Read Many)
- Bucket Access Monitor
- Bucket Archive Direct Read
- Bucket HTTPS Config
- Bucket Public Access Block
- Bucket Request Payment
- Bucket Resource Group
- Public Access Block

## Requirements

- Dart SDK >= 3.11.0

## Installing

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  alibabacloud_oss_sdk_dart: ^1.1.0
```

Then run:

```bash
dart pub get
```

## Library Entry Points

The SDK provides three library entry points for on-demand importing:

```dart
// Core library - bucket basic APIs, object APIs, and high-level APIs (paginator, presigner)
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

// Extension library - bucket configuration APIs (CORS, encryption, logging, etc.)
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_extension.dart';

// Agentic library - AgenticBucket management and BucketSpace (re-exports the core library)
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_agentic.dart';
```

> **Note:**
> - `alibabacloud_oss_sdk_dart` provides bucket basic APIs, all object APIs, and high-level APIs (such as paginator, presigner).
> - `alibabacloud_oss_sdk_extension` provides other bucket configuration APIs, such as CORS, encryption, logging, policy, etc.
> - `alibabacloud_oss_sdk_agentic` provides AgenticBucket management (`AgenticBucketClient`) and a `BucketSpaceClient.make` factory that returns an ordinary `Client` transparently rewriting each bucket to its physical `{prefix}-{accountId}-{region}-bs-apsr` name. Requires `accountId` and `region` in `Configuration`. Agentic APIs are validated against the default V4 signer.

## Getting Started

#### Put Object
```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() async {
  final region = 'cn-hangzhou';
  final bucket = 'your-bucket-name';
  final key = 'your-object-key';

  // Using the SDK's default configuration
  // Loading credentials values from the environment variables
  final config = Configuration.defaultConfig()
      .withRegion(region)
      .withCredentialsProvider(EnvironmentCredentialsProvider());
  final client = Client(config);

  final content = 'Hello, OSS!';
  final result = await client.putObject(
    PutObjectRequest(
      bucket: bucket,
      key: key,
      body: ByteStream.fromData(Uint8List.fromList(utf8.encode(content))),
    ),
  );

  print('PutObject done, StatusCode: ${result.statusCode}, RequestId: ${result.requestId}');
}
```

#### Get Object
```dart
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() async {
  final region = 'cn-hangzhou';
  final bucket = 'your-bucket-name';
  final key = 'your-object-key';

  final config = Configuration.defaultConfig()
      .withRegion(region)
      .withCredentialsProvider(EnvironmentCredentialsProvider());
  final client = Client(config);

  final result = await client.getObject(
    GetObjectRequest(bucket: bucket, key: key),
  );

  print('GetObject done, StatusCode: ${result.statusCode}, RequestId: ${result.requestId}');
}
```

#### List Buckets
```dart
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() async {
  final region = 'cn-hangzhou';

  final config = Configuration.defaultConfig()
      .withRegion(region)
      .withCredentialsProvider(EnvironmentCredentialsProvider());
  final client = Client(config);

  final result = await client.listBuckets(ListBucketsRequest());

  for (final bucket in result.buckets ?? []) {
    print('Bucket: ${bucket.name}');
  }
}
```

#### Delete Object
```dart
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() async {
  final region = 'cn-hangzhou';
  final bucket = 'your-bucket-name';
  final key = 'your-object-key';

  final config = Configuration.defaultConfig()
      .withRegion(region)
      .withCredentialsProvider(EnvironmentCredentialsProvider());
  final client = Client(config);

  final result = await client.deleteObject(
    DeleteObjectRequest(bucket: bucket, key: key),
  );

  print('DeleteObject done, StatusCode: ${result.statusCode}, RequestId: ${result.requestId}');
}
```

## Configuration

The `Configuration` class supports fluent builder pattern:

```dart
final config = Configuration.defaultConfig()
    .withRegion('cn-hangzhou')
    .withCredentialsProvider(EnvironmentCredentialsProvider())
    .withEndpoint('https://oss-cn-hangzhou.aliyuncs.com')
    .withRetryMaxAttempts(5)
    .withTimeoutIntervalForRequest(Duration(seconds: 30))
    .withTimeoutIntervalForResource(Duration(hours: 24));
```

| Option | Description | Default |
|--------|-------------|---------|
| `region` | The region in which the bucket is located | - |
| `endpoint` | Custom endpoint domain | - |
| `credentialsProvider` | Credentials provider for signing requests | - |
| `retryMaxAttempts` | Maximum number of retry attempts | 3 |
| `timeoutIntervalForRequest` | Request timeout | 15s |
| `timeoutIntervalForResource` | Single object max time | 24h |
| `httpProtocol` | HTTP protocol (HTTP/HTTPS) | HTTPS |
| `signerVersion` | Signature version (V1/V4) | V4 |
| `usePathStyle` | Use path-style request | false |
| `useCname` | Use CNAME request mode | false |
| `useDualStackEndpoint` | Use dual-stack endpoint (IPv4/IPv6) | false |
| `useInternalEndpoint` | Use internal endpoint | false |
| `useAccelerateEndpoint` | Use transfer acceleration endpoint | false |
| `enableUploadCRC64Validation` | CRC64 validation for uploads | - |
| `enableDownloadCRC64Validation` | CRC64 validation for downloads | - |

## Credentials

The SDK provides multiple credentials providers:

#### Static Credentials
```dart
final provider = StaticCredentialsProvider(
  accessKeyId: 'your-access-key-id',
  accessKeySecret: 'your-access-key-secret',
);
```

#### Environment Variables
```dart
// Reads from: OSS_ACCESS_KEY_ID, OSS_ACCESS_KEY_SECRET, OSS_SESSION_TOKEN (optional)
final provider = EnvironmentCredentialsProvider();
```

#### STS Token (Temporary Credentials)
```dart
final provider = StaticCredentialsProvider(
  accessKeyId: 'your-access-key-id',
  accessKeySecret: 'your-access-key-secret',
  securityToken: 'your-security-token',
);
```

#### Custom Credentials Provider
```dart
final provider = ClosureCredentialsProvider(() async {
  // Fetch credentials from your custom source
  return Credentials(
    accessKeyId: 'your-access-key-id',
    accessKeySecret: 'your-access-key-secret',
  );
});
```

#### Refresh Credentials Provider
```dart
final provider = RefreshCredentialsProvider(
  fetcher: () async {
    // Fetch new credentials (e.g., from STS service)
    return Credentials(
      accessKeyId: 'new-access-key-id',
      accessKeySecret: 'new-access-key-secret',
      securityToken: 'new-security-token',
      expiration: DateTime.now().add(Duration(hours: 1)),
    );
  },
);
```

## Usage Examples

### Bucket Operations

```dart
// Create a bucket
await client.putBucket(PutBucketRequest(bucket: 'my-bucket'));

// Get bucket info
final info = await client.getBucketInfo(GetBucketInfoRequest(bucket: 'my-bucket'));

// Check if bucket exists
final exists = await client.isBucketExist(IsBucketExistRequest(bucket: 'my-bucket'));

// Delete a bucket
await client.deleteBucket(DeleteBucketRequest(bucket: 'my-bucket'));
```

### Multipart Upload

```dart
// Initiate multipart upload
final initResult = await client.initiateMultipartUpload(
  InitiateMultipartUploadRequest(bucket: bucket, key: key),
);
final uploadId = initResult.uploadId;

// Upload parts
final uploadPartResult = await client.uploadPart(
  UploadPartRequest(
    bucket: bucket,
    key: key,
    partNumber: 1,
    uploadId: uploadId,
    body: ByteStream.fromData(partData),
  ),
);

// Complete multipart upload
await client.completeMultipartUpload(
  CompleteMultipartUploadRequest(
    bucket: bucket,
    key: key,
    uploadId: uploadId,
    completeAll: 'yes',
  ),
);
```

### Presigned URL

```dart
// Generate a presigned URL for GetObject
final result = await client.presignGetObject(
  GetObjectRequest(bucket: bucket, key: key),
);
print('Presigned URL: ${result.url}');
print('Expiration: ${result.expiration}');

// Generate a presigned URL for PutObject
final putResult = await client.presignPutObject(
  PutObjectRequest(bucket: bucket, key: key),
);
```

### Object Tagging

```dart
// Put object tagging
await client.putObjectTagging(
  PutObjectTaggingRequest(
    bucket: bucket,
    key: key,
    tagging: Tagging(tagSet: TagSet(tags: [Tag(key: 'env', value: 'test')])),
  ),
);

// Get object tagging
final tagging = await client.getObjectTagging(
  GetObjectTaggingRequest(bucket: bucket, key: key),
);
```

### Delete Multiple Objects

```dart
// Delete multiple objects in a single request.
// Note: the object list is nested under `delete: Delete(...)`.
final result = await client.deleteMultipleObjects(
  DeleteMultipleObjectsRequest(
    bucket: bucket,
    delete: Delete(
      objects: [
        DeleteObject(key: 'object-1'),
        DeleteObject(key: 'object-2'),
      ],
    ),
  ),
);

for (final deleted in result.deletedObjects ?? []) {
  print('Deleted: ${deleted.key}');
}
```

### Seal Append Object

```dart
// Seal an appendable object so that no more data can be appended.
// `position` must equal the current length of the object.
await client.sealAppendObject(
  SealAppendObjectRequest(bucket: bucket, key: key, position: 1024),
);
```

### Cancel Operation

You can cancel any ongoing operation using `CancelToken` from Dio:

```dart
import 'package:dio/dio.dart' show CancelToken;

final cancelToken = CancelToken();
final future = client.putObject(request, OperationOptions(cancelToken: cancelToken));

// Cancel the operation
cancelToken.cancel('user cancelled');
```

To check if an error was caused by cancellation:

```dart
try {
  await client.putObject(request, OperationOptions(cancelToken: cancelToken));
} on ClientError catch (e) {
  if (e.isCancelled) {
    print('Operation was cancelled');
  }
}
```

## Testing

The SDK has comprehensive test coverage:

| Category | Count | Description |
|----------|-------|-------------|
| Unit Tests | 537 | Serialization, credentials, signing, client logic |
| Integration Tests | 227 | Comprehensive coverage of all OSS operations |

### Running Tests

```bash
# Run unit tests
dart test test/

# Run integration tests
dart test integration_test/
```

> **Note:** Integration tests require valid OSS credentials configured via environment variables.

## Complete Example

More example programs can be found in the `example/` directory.

### Running Examples

> - Go to the example directory `example/`.
> - Configure credentials via environment variables:
>   ```bash
>   export OSS_ACCESS_KEY_ID="your access key id"
>   export OSS_ACCESS_KEY_SECRET="your access key secret"
>   ```
> - Run an example (e.g., ListBuckets):
>   ```bash
>   dart run bin/list_buckets.dart --region cn-hangzhou
>   ```

## License
> - Apache-2.0, see [license file](LICENSE)
