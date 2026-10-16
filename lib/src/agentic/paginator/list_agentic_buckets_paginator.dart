import '../../errors/client_errors.dart';
import '../../models/model_types.dart';
import '../../paginator/paginator_options.dart';
import '../../types/operation_options.dart';
import '../agentic_bucket_client.dart';
import '../agentic_bucket_client_basic.dart';
import '../models/model_agentic_bucket.dart';

/// Fetches AgenticBuckets page by page on demand without prefetching or modifying the caller's request.
class ListAgenticBucketsPaginator {
  final AgenticBucketClient _client;
  final ListAgenticBucketsRequest _request;
  final OperationOptions? _options;

  /// Creates the paginator; limit overrides per-page maxKeys rather than total count.
  ListAgenticBucketsPaginator({
    required AgenticBucketClient client,
    required ListAgenticBucketsRequest request,
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) : _client = client,
       _options = options?.copyWith(),
       _request = _copy(request, paginatorOptions?.limit);

  static ListAgenticBucketsRequest _copy(
    ListAgenticBucketsRequest request, [
    int? limit,
  ]) => ListAgenticBucketsRequest(
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

  /// Each access returns a single-subscription stream with an independent cursor.
  ///
  /// Internally performs a shallow copy of the request (copying `continuationToken` and `commonProp` Maps),
  /// so each iteration's cursor is local state, does not pollute the original request, and two iterations do not advance each other.
  /// Do not modify mutable fields of the original request after construction.
  ///
  /// Throws PaginationError when the server indicates more pages but the token is missing or did not advance.
  /// Cancelling the subscription stops subsequent pages; aborting in-flight requests requires OperationOptions.cancelToken.
  Stream<ListAgenticBucketsResult> get stream async* {
    final request = _copy(_request);
    while (true) {
      final result = await _client.listAgenticBuckets(request, _options);
      yield result;
      if (result.isTruncated != true) return;
      final next = result.nextContinuationToken;
      if (next == null || next.isEmpty || next == request.continuationToken) {
        throw const ClientError(
          code: 'PaginationError',
          message:
              'ListAgenticBuckets continuation token is missing or did not advance.',
        );
      }
      request.continuationToken = next;
    }
  }

  /// Explicitly collects all pages; result size determines memory usage.
  Future<List<ListAgenticBucketsResult>> collectAllResults() => stream.toList();

  /// Explicitly collects all AgenticBucket summaries.
  Future<List<AgenticBucketSummary>> collectAllAgenticBuckets() async {
    final result = <AgenticBucketSummary>[];
    await for (final page in stream) {
      result.addAll(page.agenticBuckets ?? const []);
    }
    return result;
  }
}
