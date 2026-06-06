import '../client.dart';
import '../client_object_multipart.dart';
import '../models/model_object_multipart.dart';
import '../types/operation_options.dart';
import 'paginator_options.dart';

/// A paginator for the ListParts operation that provides async iteration over parts
///
/// This class implements a Stream-based paginator that automatically handles
/// pagination for listing parts of a multipart upload. It yields ListPartsResult
/// objects until all parts have been retrieved.
class ListPartsPaginator {
  final Client _client;
  final ListPartsRequest _request;
  final OperationOptions? _options;

  /// Creates a new ListPartsPaginator
  ///
  /// Parameters:
  /// - [client]: The OSS client to use for requests
  /// - [request]: The initial request parameters
  /// - [options]: Optional operation options
  /// - [paginatorOptions]: Optional paginator configuration
  ListPartsPaginator({
    required Client client,
    required ListPartsRequest request,
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) : _client = client,
       _options = options,
       _request = _copyRequestWithLimit(request, paginatorOptions?.limit);

  /// Creates a copy of the request with an optional limit applied
  static ListPartsRequest _copyRequestWithLimit(
    ListPartsRequest request,
    int? limit,
  ) {
    return ListPartsRequest(
      bucket: request.bucket,
      key: request.key,
      uploadId: request.uploadId,
      maxParts: limit ?? request.maxParts,
      partNumberMarker: request.partNumberMarker,
      encodingType: request.encodingType,
      commonProp: request.commonProp,
    );
  }

  /// Returns a Stream that yields ListPartsResult objects
  ///
  /// The stream will automatically handle pagination by following
  /// nextPartNumberMarker values until all parts are retrieved.
  ///
  /// Example usage:
  /// ```dart
  /// final paginator = ListPartsPaginator(
  ///   client: client,
  ///   request: ListPartsRequest(
  ///     bucket: 'my-bucket',
  ///     key: 'my-object',
  ///     uploadId: 'upload-id',
  ///   ),
  /// );
  ///
  /// await for (final result in paginator.stream) {
  ///   print('Got ${result.parts?.length ?? 0} parts');
  ///   // Process parts...
  /// }
  /// ```
  Stream<ListPartsResult> get stream async* {
    ListPartsRequest? currentRequest = _request;

    while (currentRequest != null) {
      try {
        final result = await _client.listParts(currentRequest, _options);
        yield result;

        // Check if there are more pages
        if (result.isTruncated == true && result.nextPartNumberMarker != null) {
          // Prepare request for next page
          currentRequest = ListPartsRequest(
            bucket: currentRequest.bucket,
            key: currentRequest.key,
            uploadId: currentRequest.uploadId,
            maxParts: currentRequest.maxParts,
            partNumberMarker: result.nextPartNumberMarker,
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

  /// Collects all parts from all pages into a single list
  ///
  /// This is a convenience method that iterates through all pages
  /// and returns a flattened list of all parts.
  ///
  /// Returns:
  /// - A Future that completes with a list of all parts
  ///
  /// Example usage:
  /// ```dart
  /// final paginator = ListPartsPaginator(
  ///   client: client,
  ///   request: request,
  /// );
  ///
  /// final allParts = await paginator.collectAllParts();
  /// print('Total parts: ${allParts.length}');
  /// ```
  Future<List<Part>> collectAllParts() async {
    final allParts = <Part>[];

    await for (final result in stream) {
      if (result.parts != null) {
        allParts.addAll(result.parts!);
      }
    }

    return allParts;
  }

  /// Collects all results from all pages into a single list
  ///
  /// This method returns all ListPartsResult objects, which can be
  /// useful if you need access to metadata from each page.
  ///
  /// Returns:
  /// - A Future that completes with a list of all ListPartsResult objects
  Future<List<ListPartsResult>> collectAllResults() async {
    final allResults = <ListPartsResult>[];

    await for (final result in stream) {
      allResults.add(result);
    }

    return allResults;
  }
}
