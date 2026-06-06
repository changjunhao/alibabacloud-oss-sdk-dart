import 'client.dart';
import 'models/model_service.dart';
import 'models/model_bucket_basic.dart';
import 'models/model_bucket_versioning.dart';
import 'models/model_object_multipart.dart';
import 'paginator/paginator_options.dart';
import 'paginator/list_buckets_paginator.dart';
import 'paginator/list_multipart_uploads_paginator.dart';
import 'paginator/list_objects_paginator.dart';
import 'paginator/list_objects_v2_paginator.dart';
import 'paginator/list_object_versions_paginator.dart';
import 'paginator/list_parts_paginator.dart';
import 'types/operation_options.dart';

/// Extension for Client to provide paginator operations
extension ClientPaginator on Client {
  /// Creates a paginator for ListBuckets
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  /// - [paginatorOptions]: Optional, paginator options
  ///
  /// Returns: A paginator instance.
  ListBucketsPaginator listBucketsPaginator(
    ListBucketsRequest request, {
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) {
    return ListBucketsPaginator(
      client: this,
      request: request,
      options: options,
      paginatorOptions: paginatorOptions,
    );
  }

  /// Creates a paginator for ListMultipartUploads
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  /// - [paginatorOptions]: Optional, paginator options
  ///
  /// Returns: A paginator instance.
  ListMultipartUploadsPaginator listMultipartUploadsPaginator(
    ListMultipartUploadsRequest request, {
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) {
    return ListMultipartUploadsPaginator(
      client: this,
      request: request,
      options: options,
      paginatorOptions: paginatorOptions,
    );
  }

  /// Creates a paginator for ListObjects
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  /// - [paginatorOptions]: Optional, paginator options
  ///
  /// Returns: A paginator instance.
  ListObjectsPaginator listObjectsPaginator(
    ListObjectsRequest request, {
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) {
    return ListObjectsPaginator(
      client: this,
      request: request,
      options: options,
      paginatorOptions: paginatorOptions,
    );
  }

  /// Creates a paginator for ListObjectsV2
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  /// - [paginatorOptions]: Optional, paginator options
  ///
  /// Returns: A paginator instance.
  ListObjectsV2Paginator listObjectsV2Paginator(
    ListObjectsV2Request request, {
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) {
    return ListObjectsV2Paginator(
      client: this,
      request: request,
      options: options,
      paginatorOptions: paginatorOptions,
    );
  }

  /// Creates a paginator for ListObjectVersions
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  /// - [paginatorOptions]: Optional, paginator options
  ///
  /// Returns: A paginator instance.
  ListObjectVersionsPaginator listObjectVersionsPaginator(
    ListObjectVersionsRequest request, {
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) {
    return ListObjectVersionsPaginator(
      client: this,
      request: request,
      options: options,
      paginatorOptions: paginatorOptions,
    );
  }

  /// Creates a paginator for ListParts
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  /// - [paginatorOptions]: Optional, paginator options
  ///
  /// Returns: A paginator instance.
  ListPartsPaginator listPartsPaginator(
    ListPartsRequest request, {
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) {
    return ListPartsPaginator(
      client: this,
      request: request,
      options: options,
      paginatorOptions: paginatorOptions,
    );
  }
}
