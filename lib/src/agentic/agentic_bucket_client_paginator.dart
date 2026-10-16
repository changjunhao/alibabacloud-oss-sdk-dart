import '../paginator/paginator_options.dart';
import '../types/operation_options.dart';
import 'agentic_bucket_client.dart';
import 'models/model_agentic_bucket.dart';
import 'paginator/list_agentic_buckets_paginator.dart';
import 'paginator/list_bucket_spaces_paginator.dart';

/// Pagination entry points for the Agentic management client.
extension AgenticBucketClientPaginator on AgenticBucketClient {
  /// Returns a lazy paginator for AgenticBuckets in the region.
  ListAgenticBucketsPaginator listAgenticBucketsPaginator(
    ListAgenticBucketsRequest request, {
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) => ListAgenticBucketsPaginator(
    client: this,
    request: request,
    options: options,
    paginatorOptions: paginatorOptions,
  );

  /// Returns a lazy paginator for BucketSpaces under the specified AgenticBucket.
  ListBucketSpacesPaginator listBucketSpacesPaginator(
    ListBucketSpacesRequest request, {
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) => ListBucketSpacesPaginator(
    client: this,
    request: request,
    options: options,
    paginatorOptions: paginatorOptions,
  );
}
