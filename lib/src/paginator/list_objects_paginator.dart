import '../client.dart';
import '../client_bucket_basic.dart';
import '../models/model_bucket_basic.dart';

import '../types/operation_options.dart';
import 'paginator_options.dart';

/// A paginator for the ListObjects operation that provides async iteration over objects
///
/// This class implements a Stream-based paginator that automatically handles
/// pagination for listing objects. It yields ListObjectsResult objects until
/// all objects have been retrieved.
class ListObjectsPaginator {
  final Client _client;
  final ListObjectsRequest _request;
  final OperationOptions? _options;

  /// Creates a new ListObjectsPaginator
  ///
  /// Parameters:
  /// - [client]: The OSS client to use for requests
  /// - [request]: The initial request parameters
  /// - [options]: Optional operation options
  /// - [paginatorOptions]: Optional paginator configuration
  ListObjectsPaginator({
    required Client client,
    required ListObjectsRequest request,
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) : _client = client,
       _options = options,
       _request = _copyRequestWithLimit(request, paginatorOptions?.limit);

  /// Creates a copy of the request with an optional limit applied
  static ListObjectsRequest _copyRequestWithLimit(
    ListObjectsRequest request,
    int? limit,
  ) {
    return ListObjectsRequest(
      bucket: request.bucket,
      delimiter: request.delimiter,
      marker: request.marker,
      maxKeys: limit ?? request.maxKeys,
      prefix: request.prefix,
      encodingType: request.encodingType,
      commonProp: request.commonProp,
    );
  }

  /// Returns a Stream that yields ListObjectsResult objects
  ///
  /// The stream will automatically handle pagination by following
  /// nextMarker values until all objects are retrieved.
  ///
  /// Example usage:
  /// ```dart
  /// final paginator = ListObjectsPaginator(
  ///   client: client,
  ///   request: ListObjectsRequest(
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
  Stream<ListObjectsResult> get stream async* {
    ListObjectsRequest? currentRequest = _request;

    while (currentRequest != null) {
      try {
        final result = await _client.listObjects(currentRequest, _options);
        yield result;

        // Check if there are more pages
        if (result.isTruncated == true && result.nextMarker != null) {
          // Prepare request for next page
          currentRequest = ListObjectsRequest(
            bucket: currentRequest.bucket,
            delimiter: currentRequest.delimiter,
            marker: result.nextMarker,
            maxKeys: currentRequest.maxKeys,
            prefix: currentRequest.prefix,
            encodingType: currentRequest.encodingType,
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
  /// final paginator = ListObjectsPaginator(
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
  /// This method returns all ListObjectsResult objects, which can be
  /// useful if you need access to metadata from each page.
  ///
  /// Returns:
  /// - A Future that completes with a list of all ListObjectsResult objects
  Future<List<ListObjectsResult>> collectAllResults() async {
    final allResults = <ListObjectsResult>[];

    await for (final result in stream) {
      allResults.add(result);
    }

    return allResults;
  }
}
