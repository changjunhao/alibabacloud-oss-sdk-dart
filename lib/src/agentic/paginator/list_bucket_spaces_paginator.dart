import '../../errors/client_errors.dart';
import '../../models/model_types.dart';
import '../../paginator/paginator_options.dart';
import '../../types/operation_options.dart';
import '../agentic_bucket_client.dart';
import '../agentic_bucket_client_bucket_space.dart';
import '../models/model_agentic_bucket.dart';

/// Fetches BucketSpaces page by page on demand, preserving the parent bucket and filter criteria.
class ListBucketSpacesPaginator {
  final AgenticBucketClient _client;
  final ListBucketSpacesRequest _request;
  final OperationOptions? _options;

  /// Creates the paginator; copies the request and options; CancelToken is still shared with the caller.
  ListBucketSpacesPaginator({
    required AgenticBucketClient client,
    required ListBucketSpacesRequest request,
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) : _client = client,
       _options = options?.copyWith(),
       _request = _copy(request, paginatorOptions?.limit);

  static ListBucketSpacesRequest _copy(
    ListBucketSpacesRequest request, [
    int? limit,
  ]) => ListBucketSpacesRequest(
    bucket: request.bucket,
    prefix: request.prefix,
    startAfter: request.startAfter,
    continuationToken: request.continuationToken,
    maxKeys: limit ?? request.maxKeys,
    commonProp: RequestModelProp(
      headers: request.commonProp.headers == null
          ? null
          : Map.of(request.commonProp.headers!),
      parameters: request.commonProp.parameters == null
          ? null
          : Map.of(request.commonProp.parameters!),
    ),
  );

  /// Each access returns an independent stream.
  ///
  /// Internally performs a shallow copy of the request (copying `continuationToken`, `prefix`, `startAfter`, and `commonProp` Maps),
  /// so each iteration's cursor is local state, does not pollute the original request, and two iterations do not advance each other.
  /// Do not modify mutable fields of the original request after construction.
  ///
  /// Throws PaginationError when the pagination token is missing or did not advance.
  /// Cancelling the subscription stops subsequent pages; in-flight requests are cancelled via an explicit CancelToken.
  Stream<ListBucketSpacesResult> get stream async* {
    final request = _copy(_request);
    while (true) {
      final result = await _client.listBucketSpaces(request, _options);
      yield result;
      if (result.isTruncated != true) return;
      final next = result.nextContinuationToken;
      if (next == null || next.isEmpty || next == request.continuationToken) {
        throw const ClientError(
          code: 'PaginationError',
          message:
              'ListBucketSpaces continuation token is missing or did not advance.',
        );
      }
      request.continuationToken = next;
    }
  }

  /// Explicitly collects all pages; result size determines memory usage.
  Future<List<ListBucketSpacesResult>> collectAllResults() => stream.toList();

  /// Explicitly collects all BucketSpace summaries.
  Future<List<BucketSpaceSummary>> collectAllBucketSpaces() async {
    final result = <BucketSpaceSummary>[];
    await for (final page in stream) {
      result.addAll(page.bucketSpaces ?? const []);
    }
    return result;
  }
}
