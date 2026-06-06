import '../client.dart';
import '../client_bucket_basic.dart';
import '../models/model_bucket_basic.dart';

import '../types/operation_options.dart';
import 'paginator_options.dart';

/// A paginator for the ListObjectsV2 operation that provides async iteration over objects
///
/// This class implements a Stream-based paginator that automatically handles
/// pagination for listing objects using the V2 API. It yields ListObjectsV2Result objects until
/// all objects have been retrieved.
class ListObjectsV2Paginator {
  final Client _client;
  final ListObjectsV2Request _request;
  final OperationOptions? _options;

  /// Creates a new ListObjectsV2Paginator
  ///
  /// Parameters:
  /// - [client]: The OSS client to use for requests
  /// - [request]: The initial request parameters
  /// - [options]: Optional operation options
  /// - [paginatorOptions]: Optional paginator configuration
  ListObjectsV2Paginator({
    required Client client,
    required ListObjectsV2Request request,
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) : _client = client,
       _options = options,
       _request = _copyRequestWithLimit(request, paginatorOptions?.limit);

  /// Creates a copy of the request with an optional limit applied
  static ListObjectsV2Request _copyRequestWithLimit(
    ListObjectsV2Request request,
    int? limit,
  ) {
    return ListObjectsV2Request(
      bucket: request.bucket,
      delimiter: request.delimiter,
      maxKeys: limit ?? request.maxKeys,
      prefix: request.prefix,
      encodingType: request.encodingType,
      fetchOwner: request.fetchOwner,
      startAfter: request.startAfter,
      continuationToken: request.continuationToken,
      commonProp: request.commonProp,
    );
  }

  /// Returns a Stream that yields ListObjectsV2Result objects
  ///
  /// The stream will automatically handle pagination by following
  /// nextContinuationToken values until all objects are retrieved.
  ///
  /// Example usage:
  /// ```dart
  /// final paginator = ListObjectsV2Paginator(
  ///   client: client,
  ///   request: ListObjectsV2Request(
  ///     bucket: 'my-bucket',
  ///     prefix: 'my-prefix',
  ///     maxKeys: 100,
  ///   ),
  /// );
  ///
  /// await for (final result in paginator.stream) {
  ///   print('Got ${result.contents?.length ?? 0} objects');
  ///   // Process objects...
  /// }
  /// ```
  Stream<ListObjectsV2Result> get stream async* {
    ListObjectsV2Request? currentRequest = _request;

    while (currentRequest != null) {
      try {
        final result = await _client.listObjectsV2(currentRequest, _options);
        yield result;

        // Check if there are more pages
        if (result.isTruncated == true &&
            result.nextContinuationToken != null) {
          // Prepare request for next page
          currentRequest = ListObjectsV2Request(
            bucket: currentRequest.bucket,
            delimiter: currentRequest.delimiter,
            maxKeys: currentRequest.maxKeys,
            prefix: currentRequest.prefix,
            encodingType: currentRequest.encodingType,
            fetchOwner: currentRequest.fetchOwner,
            startAfter: currentRequest.startAfter,
            continuationToken: result.nextContinuationToken,
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

  /// Collects all objects from all pages into a single list
  ///
  /// This is a convenience method that iterates through all pages
  /// and returns a flattened list of all objects.
  ///
  /// Returns:
  /// - A Future that completes with a list of all objects
  ///
  /// Example usage:
  /// ```dart
  /// final paginator = ListObjectsV2Paginator(
  ///   client: client,
  ///   request: request,
  /// );
  ///
  /// final allObjects = await paginator.collectAllObjects();
  /// print('Total objects: ${allObjects.length}');
  /// ```
  Future<List<ObjectSummary>> collectAllObjects() async {
    final allObjects = <ObjectSummary>[];

    await for (final result in stream) {
      if (result.contents != null) {
        allObjects.addAll(result.contents!);
      }
    }

    return allObjects;
  }

  /// Collects all results from all pages into a single list
  ///
  /// This method returns all ListObjectsV2Result objects, which can be
  /// useful if you need access to metadata from each page.
  ///
  /// Returns:
  /// - A Future that completes with a list of all ListObjectsV2Result objects
  Future<List<ListObjectsV2Result>> collectAllResults() async {
    final allResults = <ListObjectsV2Result>[];

    await for (final result in stream) {
      allResults.add(result);
    }

    return allResults;
  }
}
