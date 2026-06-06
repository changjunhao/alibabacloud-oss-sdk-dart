import '../client.dart';
import '../client_service.dart';
import '../models/model_service.dart';
import '../types/operation_options.dart';
import 'paginator_options.dart';

/// A paginator for the ListBuckets operation that provides async iteration over buckets
///
/// This class implements a Stream-based paginator that automatically handles
/// pagination for listing buckets. It yields ListBucketsResult objects until
/// all buckets have been retrieved.
class ListBucketsPaginator {
  final Client _client;
  final ListBucketsRequest _request;
  final OperationOptions? _options;

  /// Creates a new ListBucketsPaginator
  ///
  /// Parameters:
  /// - [client]: The OSS client to use for requests
  /// - [request]: The initial request parameters
  /// - [options]: Optional operation options
  /// - [paginatorOptions]: Optional paginator configuration
  ListBucketsPaginator({
    required Client client,
    required ListBucketsRequest request,
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) : _client = client,
       _options = options,
       _request = _copyRequestWithLimit(request, paginatorOptions?.limit);

  /// Creates a copy of the request with an optional limit applied
  static ListBucketsRequest _copyRequestWithLimit(
    ListBucketsRequest request,
    int? limit,
  ) {
    return ListBucketsRequest(
      resourceGroupId: request.resourceGroupId,
      prefix: request.prefix,
      marker: request.marker,
      maxKeys: limit ?? request.maxKeys,
      commonProp: request.commonProp,
    );
  }

  /// Returns a Stream that yields ListBucketsResult objects
  ///
  /// The stream will automatically handle pagination by following
  /// nextMarker values until all buckets are retrieved.
  ///
  /// Example usage:
  /// ```dart
  /// final paginator = ListBucketsPaginator(
  ///   client: client,
  ///   request: ListBucketsRequest(
  ///     prefix: 'my-prefix',
  ///     maxKeys: 100,
  ///   ),
  /// );
  ///
  /// await for (final result in paginator.stream) {
  ///   print('Got ${result.buckets?.length ?? 0} buckets');
  ///   // Process buckets...
  /// }
  /// ```
  Stream<ListBucketsResult> get stream async* {
    ListBucketsRequest? currentRequest = _request;

    while (currentRequest != null) {
      try {
        final result = await _client.listBuckets(currentRequest, _options);
        yield result;

        // Check if there are more pages
        if (result.isTruncated == true && result.nextMarker != null) {
          // Prepare request for next page
          currentRequest = ListBucketsRequest(
            resourceGroupId: currentRequest.resourceGroupId,
            prefix: currentRequest.prefix,
            marker: result.nextMarker,
            maxKeys: currentRequest.maxKeys,
            commonProp: currentRequest.commonProp,
          );
        } else {
          // No more pages
          currentRequest = null;
        }
      } catch (e) {
        // Re-throw the exception to let the caller handle it
        rethrow;
      }
    }
  }

  /// Collects all buckets from all pages into a single list
  ///
  /// This is a convenience method that iterates through all pages
  /// and returns a flattened list of all buckets.
  ///
  /// Returns:
  /// - A Future that completes with a list of all buckets
  ///
  /// Example usage:
  /// ```dart
  /// final paginator = ListBucketsPaginator(
  ///   client: client,
  ///   request: request,
  /// );
  ///
  /// final allBuckets = await paginator.collectAllBuckets();
  /// print('Total buckets: ${allBuckets.length}');
  /// ```
  Future<List<BucketSummary>> collectAllBuckets() async {
    final allBuckets = <BucketSummary>[];

    await for (final result in stream) {
      if (result.buckets != null) {
        allBuckets.addAll(result.buckets!);
      }
    }

    return allBuckets;
  }

  /// Collects all results from all pages into a single list
  ///
  /// This method returns all ListBucketsResult objects, which can be
  /// useful if you need access to metadata from each page.
  ///
  /// Returns:
  /// - A Future that completes with a list of all ListBucketsResult objects
  Future<List<ListBucketsResult>> collectAllResults() async {
    final allResults = <ListBucketsResult>[];

    await for (final result in stream) {
      allResults.add(result);
    }

    return allResults;
  }
}
