# Integration Tests

## Overview

This directory contains the integration tests for the Alibaba Cloud OSS Dart SDK.
These tests verify real interactions between the SDK and the OSS service and
cover bucket management, object operations, multipart upload, access control,
data protection, presigned URLs, paginators, and extension features.

> **Note**: Integration tests connect to a real Alibaba Cloud OSS service and
> create and delete actual resources.

## Test Statistics

- **Test files**: 28
- **Test cases**: 227
- **API coverage**: Comprehensive coverage of OSS operations

## Environment Variables

Configure the following environment variables before running the integration
tests:

```bash
export OSS_TEST_ENDPOINT=oss-cn-hangzhou.aliyuncs.com
export OSS_TEST_REGION=cn-hangzhou
export OSS_TEST_ACCESS_KEY_ID=<your-access-key-id>
export OSS_TEST_ACCESS_KEY_SECRET=<your-access-key-secret>
```

| Variable | Description |
| --- | --- |
| `OSS_TEST_ENDPOINT` | OSS service endpoint, for example `oss-cn-hangzhou.aliyuncs.com` |
| `OSS_TEST_REGION` | OSS region identifier, for example `cn-hangzhou` |
| `OSS_TEST_ACCESS_KEY_ID` | Alibaba Cloud AccessKey ID |
| `OSS_TEST_ACCESS_KEY_SECRET` | Alibaba Cloud AccessKey Secret |

## Running Tests

```bash
# Run all integration tests
dart test integration_test/

# Run a single test file
dart test integration_test/client_bucket_basic_test.dart

# Run a single test file with expanded output
dart test integration_test/client_object_basic_test.dart --reporter expanded
```

## File Index

### Infrastructure

| File | Description |
| --- | --- |
| `base_test_case.dart` | Shared test base that provides environment setup, client management, random name generation, bucket lifecycle utilities, test file management, and async assertion helpers |

### Bucket Management (17 files, 89 tests)

| File | Tests | Coverage |
| --- | --- | --- |
| `client_bucket_basic_test.dart` | 14 | PutBucket, PutBucket with ACL or storage class, DeleteBucket, GetBucketInfo, GetBucketLocation, GetBucketStat, ListObjects, ListObjectsV2, ListObjectVersions, IsBucketExist, ListBuckets, DescribeRegions |
| `client_bucket_acl_test.dart` | 2 | PutBucketAcl, GetBucketAcl, success and failure cases |
| `client_bucket_cors_test.dart` | 8 | PutBucketCors, GetBucketCors, DeleteBucketCors, OptionObject, success and failure cases |
| `client_bucket_encryption_test.dart` | 4 | PutBucketEncryption, GetBucketEncryption, DeleteBucketEncryption, success and failure cases |
| `client_bucket_logging_test.dart` | 10 | PutBucketLogging, GetBucketLogging, DeleteBucketLogging, success and failure cases |
| `client_bucket_policy_test.dart` | 7 | PutBucketPolicy, GetBucketPolicy, DeleteBucketPolicy, success and failure cases |
| `client_bucket_referer_test.dart` | 3 | PutBucketReferer, GetBucketReferer, success and failure cases |
| `client_bucket_tags_test.dart` | 5 | PutBucketTags, GetBucketTags, DeleteBucketTags, success and failure cases |
| `client_bucket_versioning_test.dart` | 5 | PutBucketVersioning, GetBucketVersioning, success and failure cases |
| `client_bucket_worm_test.dart` | 9 | InitiateBucketWorm, AbortBucketWorm, CompleteBucketWorm, ExtendBucketWorm, GetBucketWorm, success and failure cases |
| `client_bucket_access_monitor_test.dart` | 3 | PutBucketAccessMonitor, GetBucketAccessMonitor, success and failure cases |
| `client_bucket_archive_directread_test.dart` | 3 | PutBucketArchiveDirectRead, GetBucketArchiveDirectRead, success and failure cases |
| `client_bucket_https_config_test.dart` | 3 | PutBucketHttpsConfig, GetBucketHttpsConfig, success and failure cases |
| `client_bucket_resource_group_test.dart` | 3 | PutBucketResourceGroup, GetBucketResourceGroup, success and failure cases |
| `client_bucket_transfer_acceleration_test.dart` | 3 | PutBucketTransferAcceleration, GetBucketTransferAcceleration, success and failure cases |
| `client_bucket_request_payment_test.dart` | 3 | PutBucketRequestPayment, GetBucketRequestPayment, success and failure cases |
| `client_bucket_public_access_block_test.dart` | 4 | PutBucketPublicAccessBlock, GetBucketPublicAccessBlock, DeleteBucketPublicAccessBlock, success and failure cases |

### Object Operations (5 files, 87 tests)

| File | Tests | Coverage |
| --- | --- | --- |
| `client_object_basic_test.dart` | 50 | PutObject with data, stream, progress, metadata, ACL, forbid overwrite, CRC, callback, and cancel scenarios; GetObject with range, file download, conditional headers, and CRC; HeadObject, GetObjectMeta, CopyObject, AppendObject, DeleteObject, DeleteMultipleObjects, IsObjectExist, RestoreObject, async and concurrency cases |
| `client_object_multipart_test.dart` | 27 | InitiateMultipartUpload with overwrite, storage class, and metadata; UploadPart with progress and error cases; CompleteMultipartUpload with callback, overwrite, and part variations; AbortMultipartUpload; ListMultipartUploads; ListParts; UploadPartCopy; full multipart upload flow |
| `client_object_acl_test.dart` | 2 | PutObjectAcl and GetObjectAcl |
| `client_object_tagging_test.dart` | 3 | PutObjectTagging, GetObjectTagging, DeleteObjectTagging |
| `client_object_symlink_test.dart` | 5 | PutSymlink, GetSymlink, and PutSymlink with metadata, forbid overwrite, and storage class |

### Advanced Features (6 files, 45 tests)

| File | Tests | Coverage |
| --- | --- | --- |
| `client_presigner_test.dart` | 7 | PresignPutObject, PresignGetObject, PresignHeadObject, PresignInitiateMultipartUpload, PresignUploadPart, PresignCompleteMultipartUpload, PresignAbortMultipartUpload |
| `client_paginator_test.dart` | 12 | ListObjectsPaginator, ListObjectsV2Paginator, ListBucketsPaginator, ListObjectVersionsPaginator, ListPartsPaginator, ListMultipartUploadsPaginator, success and failure cases |
| `client_extensions_test.dart` | 5 | IsBucketExist, IsObjectExist, GetObjectToFile, success and failure cases |
| `client_integration_test.dart` | 8 | InvokeOperation for Put, Get, Head, and Delete in success and failure cases |
| `client_misc_test.dart` | 9 | Multiple `ByteStream` types, upload and download progress callbacks, auto MIME detection, CRC64 checks, and special-character query and key handling |
| `client_public_access_block_test.dart` | 4 | PutPublicAccessBlock, GetPublicAccessBlock, DeletePublicAccessBlock, success and failure cases |

## Coverage Summary

This integration test suite provides broad coverage for OSS APIs and scenarios:

- **Bucket management**: Basic operations plus 17 bucket configuration features, including ACL, CORS, encryption, logging, policy, referer, tags, versioning, WORM, access monitoring, archive direct read, HTTPS configuration, resource groups, transfer acceleration, request payment, and public access block
- **Object operations**: Core CRUD flows, multipart upload, ACL, tagging, and symlink support
- **Advanced features**: Seven presigned URL flows, six paginator types, extension helpers, low-level `invokeOperation`, and miscellaneous transport features
- **Public access block**: Account-level public access control

## Notes

1. **Real OSS account required**: Integration tests require valid Alibaba Cloud credentials and a reachable OSS endpoint.
2. **Resources are created and deleted**: Tests create buckets and objects and clean them up after execution.
3. **Automatic cleanup**: Each test creates its own bucket in `setUp` and calls `cleanBucket` in `tearDown` to remove objects, delete markers, and in-progress multipart uploads before deleting the bucket.
4. **Naming convention**: Test resources use `dart-sdk-test-bucket-`, `dart-sdk-test-object-`, and `dart-sdk-test-file-` prefixes plus random suffixes and timestamps to avoid collisions.
5. **Network dependency**: The test environment must be able to reach the OSS endpoint.
6. **Not run by default**: `dart test` does not include the `integration_test/` directory unless the path is specified explicitly.
