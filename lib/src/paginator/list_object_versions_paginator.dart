import '../client.dart';
import '../client_bucket_versioning.dart';
import '../models/model_bucket_versioning.dart';
import '../types/operation_options.dart';
import 'paginator_options.dart';

/// A paginator for the ListObjectVersions operation that provides async iteration over object versions
///
/// This class implements a Stream-based paginator that automatically handles
/// pagination for listing object versions in a bucket. It yields ListObjectVersionsResult
/// objects until all object versions have been retrieved.
class ListObjectVersionsPaginator {
  final Client _client;
  final ListObjectVersionsRequest _request;
  final OperationOptions? _options;

  /// Creates a new ListObjectVersionsPaginator
  ///
  /// Parameters:
  /// - [client]: The OSS client to use for requests
  /// - [request]: The initial request parameters
  /// - [options]: Optional operation options
  /// - [paginatorOptions]: Optional paginator configuration
  ListObjectVersionsPaginator({
    required Client client,
    required ListObjectVersionsRequest request,
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) : _client = client,
       _options = options,
       _request = _copyRequestWithLimit(request, paginatorOptions?.limit);

  /// Creates a copy of the request with an optional limit applied
  static ListObjectVersionsRequest _copyRequestWithLimit(
    ListObjectVersionsRequest request,
    int? limit,
  ) {
    return ListObjectVersionsRequest(
      bucket: request.bucket,
      delimiter: request.delimiter,
      keyMarker: request.keyMarker,
      versionIdMarker: request.versionIdMarker,
      maxKeys: limit ?? request.maxKeys,
      prefix: request.prefix,
      encodingType: request.encodingType,
      commonProp: request.commonProp,
    );
  }

  /// Returns a Stream that yields ListObjectVersionsResult objects
  ///
  /// The stream will automatically handle pagination by following
  /// nextKeyMarker and nextVersionIdMarker values until all object versions are retrieved.
  ///
  /// Example usage:
  /// ```dart
  /// final paginator = ListObjectVersionsPaginator(
  ///   client: client,
  ///   request: ListObjectVersionsRequest(
  ///     bucket: 'my-bucket',
  ///     prefix: 'my-prefix/',
  ///   ),
  /// );
  ///
  /// await for (final result in paginator.stream) {
  ///   print('Got ${result.versions?.length ?? 0} object versions');
  ///   // Process object versions...
  /// }
  /// ```
  Stream<ListObjectVersionsResult> get stream async* {
    ListObjectVersionsRequest? currentRequest = _request;

    while (currentRequest != null) {
      try {
        final result = await _client.listObjectVersions(
          currentRequest,
          _options,
        );
        yield result;

        // Check if there are more pages
        if (result.isTruncated == true && result.nextKeyMarker != null) {
          // Prepare request for next page
          currentRequest = ListObjectVersionsRequest(
            bucket: currentRequest.bucket,
            delimiter: currentRequest.delimiter,
            keyMarker: result.nextKeyMarker,
            versionIdMarker: result.nextVersionIdMarker,
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

  /// Collects all object versions from all pages into a single list
  ///
  /// This is a convenience method that iterates through all pages
  /// and returns a flattened list of all object versions.
  ///
  /// Returns:
  /// - A Future that completes with a list of all object versions
  ///
  /// Example usage:
  /// ```dart
  /// final paginator = ListObjectVersionsPaginator(
  ///   client: client,
  ///   request: request,
  /// );
  ///
  /// final allVersions = await paginator.collectAllVersions();
  /// print('Total object versions: ${allVersions.length}');
  /// ```
  Future<List<ObjectVersion>> collectAllVersions() async {
    final allVersions = <ObjectVersion>[];

    await for (final result in stream) {
      if (result.versions != null) {
        allVersions.addAll(result.versions!);
      }
    }

    return allVersions;
  }

  /// Collects all delete markers from all pages into a single list
  ///
  /// This is a convenience method that iterates through all pages
  /// and returns a flattened list of all delete markers.
  ///
  /// Returns:
  /// - A Future that completes with a list of all delete markers
  ///
  /// Example usage:
  /// ```dart
  /// final paginator = ListObjectVersionsPaginator(
  ///   client: client,
  ///   request: request,
  /// );
  ///
  /// final allDeleteMarkers = await paginator.collectAllDeleteMarkers();
  /// print('Total delete markers: ${allDeleteMarkers.length}');
  /// ```
  Future<List<DeleteMarkerEntry>> collectAllDeleteMarkers() async {
    final allDeleteMarkers = <DeleteMarkerEntry>[];

    await for (final result in stream) {
      if (result.deleteMarkers != null) {
        allDeleteMarkers.addAll(result.deleteMarkers!);
      }
    }

    return allDeleteMarkers;
  }

  /// Collects all results from all pages into a single list
  ///
  /// This method returns all ListObjectVersionsResult objects, which can be
  /// useful if you need access to metadata from each page.
  ///
  /// Returns:
  /// - A Future that completes with a list of all ListObjectVersionsResult objects
  Future<List<ListObjectVersionsResult>> collectAllResults() async {
    final allResults = <ListObjectVersionsResult>[];

    await for (final result in stream) {
      allResults.add(result);
    }

    return allResults;
  }
}
