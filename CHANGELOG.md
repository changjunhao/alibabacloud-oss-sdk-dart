# Changelog

## 1.2.0

### Added

- **AgenticBucket/BucketSpace**: New entry point `alibabacloud_oss_sdk_agentic.dart`, providing
  `AgenticBucketClient` (six management APIs: create/delete/get/list/putStatus/listBucketSpaces)
  and `BucketSpaceClient.make` (returns a `Client` reusing the ordinary object/bucket/paginator/presigner APIs).
- **BucketSpaceHelper**: Exported from the core entry point; converts a logical prefix into the
  physical full name `{prefix}-{accountId}-{region}-bs-apsr`.
- **Configuration**: Added `accountId` and `useVirtualHostedAlias`; a non-empty accountId uses
  deferred validation (construction does not throw; `ValidationError` is surfaced before the first
  operation/presign, and only ASCII digits are allowed).
- **Physical-name addressing**: Signing uses the physical bucket name; URLs support three label
  styles: virtual-hosted, path, and short alias. The alias and physical labels honor the 63-character
  DNS limit; path-style does not check this length.
- **Paginators**: `ListAgenticBucketsPaginator` and `ListBucketSpacesPaginator`, lazy `.stream`,
  throwing `PaginationError` on a missing or non-advancing continuation token.
- Added 8 Agentic/BucketSpace examples with the corresponding unit and controlled integration tests.

### Changed

- **PutBucket**: No longer sends an empty XML body when `createBucketConfiguration` is absent (BucketSpace
  creation requires no body); added an optional `agenticBucket` → `x-oss-agentic-bucket` header.
- **Bucket/GetBucketInfo**: Added parsing of `bucketResourceType` and `agenticBucketName`.

### Compatibility

- `virtualHostedAlias` is appended to the end of `AddressStyleType`; downstream exhaustive switches
  may need a new branch.
- The two new optional hooks `ClientOptions.bucketNameResolver`/`endpointProvider` default to null and
  preserve ordinary OSS behavior when unset.

## 1.1.0

### Added

- **SealAppendObject**: New API to seal an appendable object.
- **XML Escape**: Enhanced `escape()` to handle control characters (`\t`, `\n`, `\r`), other C0 control characters, and invalid XML characters.

### Changed

- **Object Tagging**: Tag `Key`/`Value` are now XML-escaped during serialization.

### Breaking Changes

- **DeleteMultipleObjects**: `DeleteMultipleObjectsRequest` no longer exposes top-level `quiet`/`objects`. Use the new nested `delete: Delete(quiet: ..., objects: ...)` instead.

## 1.0.2

### Bug Fixes

- **SignerV1**: Fixed `Content-MD5` / `Content-Type` header lookup to use lowercase keys (`content-md5` / `content-type`), matching the lowercased header map produced by `ClientImpl`. Previously these headers were never found, causing them to always be empty in the StringToSign, which could result in `SignatureDoesNotMatch` errors from the server.
- **SignerV1**: Fixed `canonicalizedOSSHeaders` to check `x-oss-*` header count instead of total header count when deciding whether to append a trailing `\n`. Previously, when no `x-oss-*` headers were present but other headers existed (e.g. `Date`), an extra empty line was incorrectly added to the StringToSign, causing signature mismatches.

## 1.0.1

### Improvements

- Updated package metadata for `pub.dev`, including repository and issue tracker URLs
- Added package badges and secure links in `README.md` and `README-CN.md`
- Added a top-level `example/main.dart` for package layout and `pub.dev` example detection
- Expanded `dartdoc` coverage across public API surfaces to improve generated documentation quality
- Refined formatting and package metadata to improve local `pana` validation results

## 1.0.0

### Features

#### Core Library (`alibabacloud_oss_sdk_dart.dart`)
- **Bucket Operations**: PutBucket, DeleteBucket, GetBucketInfo, GetBucketLocation, GetBucketStat, ListObjects, ListObjectsV2
- **Bucket ACL**: PutBucketAcl, GetBucketAcl
- **Bucket Versioning**: PutBucketVersioning, GetBucketVersioning, ListObjectVersions
- **Object Operations**: PutObject, GetObject, CopyObject, AppendObject, DeleteObject, DeleteMultipleObjects, HeadObject, GetObjectMeta, RestoreObject, CleanRestoredObject
- **Object ACL**: PutObjectAcl, GetObjectAcl
- **Object Tagging**: PutObjectTagging, GetObjectTagging, DeleteObjectTagging
- **Object Symlink**: PutSymlink, GetSymlink
- **Multipart Upload**: InitiateMultipartUpload, UploadPart, UploadPartCopy, CompleteMultipartUpload, AbortMultipartUpload, ListMultipartUploads, ListParts
- **Pre-signed URLs**: Support for 7 operations (GetObject, PutObject, HeadObject, InitiateMultipartUpload, UploadPart, CompleteMultipartUpload, AbortMultipartUpload)
- **Paginators**: ListBuckets, ListObjects, ListObjectsV2, ListObjectVersions, ListMultipartUploads, ListParts
- **Convenience**: IsBucketExist, IsObjectExist, GetObjectToFile
- **Service**: ListBuckets, DescribeRegions

#### Extension Library (`alibabacloud_oss_sdk_extension.dart`)
- **Bucket CORS**: PutBucketCors, GetBucketCors, DeleteBucketCors, OptionObject
- **Bucket Tags**: PutBucketTags, GetBucketTags, DeleteBucketTags
- **Bucket Encryption**: PutBucketEncryption, GetBucketEncryption, DeleteBucketEncryption
- **Bucket Policy**: PutBucketPolicy, GetBucketPolicy, DeleteBucketPolicy, GetBucketPolicyStatus
- **Bucket Logging**: PutBucketLogging, GetBucketLogging, DeleteBucketLogging, PutUserDefinedLogFieldsConfig, GetUserDefinedLogFieldsConfig, DeleteUserDefinedLogFieldsConfig
- **Bucket Referer**: PutBucketReferer, GetBucketReferer
- **Bucket WORM**: InitiateBucketWorm, AbortBucketWorm, CompleteBucketWorm, ExtendBucketWorm, GetBucketWorm
- **Bucket Transfer Acceleration**: PutBucketTransferAcceleration, GetBucketTransferAcceleration
- **Bucket HTTPS Config**: PutBucketHttpsConfig, GetBucketHttpsConfig, DeleteBucketHttpsConfig
- **Bucket Request Payment**: PutBucketRequestPayment, GetBucketRequestPayment
- **Bucket Public Access Block**: PutBucketPublicAccessBlock, GetBucketPublicAccessBlock, DeleteBucketPublicAccessBlock
- **Account Public Access Block**: PutPublicAccessBlock, GetPublicAccessBlock, DeletePublicAccessBlock
- **Bucket Resource Group**: PutBucketResourceGroup, GetBucketResourceGroup
- **Bucket Access Monitor**: PutBucketAccessMonitor, GetBucketAccessMonitor
- **Bucket Archive Direct Read**: PutBucketArchiveDirectread, GetBucketArchiveDirectread

### Infrastructure
- Multiple credential providers (Static, Environment, Anonymous, Closure, Refresh)
- Signature V1 and V4 support (including remote signing)
- Configurable retry with multiple backoff strategies
- Request cancellation via `OperationOptions(cancelToken:)`
- CRC64 data integrity verification
- Progress tracking for uploads and downloads
- Comprehensive logging system
- 41 example programs

### Tests
- 537 unit tests
- 227 integration tests, comprehensive coverage of all OSS operations
- Integration tests cover: Bucket basic/extension operations, Object CRUD/Multipart/Symlink/Tagging/ACL, Presigner, Paginator
