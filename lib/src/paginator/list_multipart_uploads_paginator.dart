import '../client.dart';
import '../client_object_multipart.dart';
import '../models/model_object_multipart.dart';
import '../types/operation_options.dart';
import 'paginator_options.dart';

/// A paginator for the ListMultipartUploads operation that provides async iteration over multipart uploads
///
/// This class implements a Stream-based paginator that automatically handles
/// pagination for listing multipart uploads in a bucket. It yields ListMultipartUploadsResult
/// objects until all multipart uploads have been retrieved.
class ListMultipartUploadsPaginator {
  final Client _client;
  final ListMultipartUploadsRequest _request;
  final OperationOptions? _options;

  /// Creates a new ListMultipartUploadsPaginator
  ///
  /// Parameters:
  /// - [client]: The OSS client to use for requests
  /// - [request]: The initial request parameters
  /// - [options]: Optional operation options
  /// - [paginatorOptions]: Optional paginator configuration
  ListMultipartUploadsPaginator({
    required Client client,
    required ListMultipartUploadsRequest request,
    OperationOptions? options,
    PaginatorOptions? paginatorOptions,
  }) : _client = client,
       _options = options,
       _request = _copyRequestWithLimit(request, paginatorOptions?.limit);

  /// Creates a copy of the request with an optional limit applied
  static ListMultipartUploadsRequest _copyRequestWithLimit(
    ListMultipartUploadsRequest request,
    int? limit,
  ) {
    return ListMultipartUploadsRequest(
      bucket: request.bucket,
      delimiter: request.delimiter,
      maxUploads: limit ?? request.maxUploads,
      keyMarker: request.keyMarker,
      prefix: request.prefix,
      uploadIdMarker: request.uploadIdMarker,
      encodingType: request.encodingType,
      commonProp: request.commonProp,
    );
  }

  /// Returns a Stream that yields ListMultipartUploadsResult objects
  ///
  /// The stream will automatically handle pagination by following
  /// nextKeyMarker and nextUploadIdMarker values until all multipart uploads are retrieved.
  ///
  /// Example usage:
  /// ```dart
  /// final paginator = ListMultipartUploadsPaginator(
  ///   client: client,
  ///   request: ListMultipartUploadsRequest(
  ///     bucket: 'my-bucket',
  ///     prefix: 'my-prefix/',
  ///     maxUploads: 100,
  ///   ),
  /// );
  ///
  /// await for (final result in paginator.stream) {
  ///   print('Got ${result.uploads?.length ?? 0} multipart uploads');
  ///   // Process uploads...
  /// }
  /// ```
  Stream<ListMultipartUploadsResult> get stream async* {
    ListMultipartUploadsRequest? currentRequest = _request;

    while (currentRequest != null) {
      try {
        final result = await _client.listMultipartUploads(
          currentRequest,
          _options,
        );
        yield result;

        // Check if there are more pages
        if (result.isTruncated == true &&
            (result.nextKeyMarker != null ||
                result.nextUploadIdMarker != null)) {
          // Prepare request for next page
          currentRequest = ListMultipartUploadsRequest(
            bucket: currentRequest.bucket,
            delimiter: currentRequest.delimiter,
            maxUploads: currentRequest.maxUploads,
            keyMarker: result.nextKeyMarker,
            prefix: currentRequest.prefix,
            uploadIdMarker: result.nextUploadIdMarker,
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

  /// Collects all multipart uploads from all pages into a single list
  ///
  /// This is a convenience method that iterates through all pages
  /// and returns a flattened list of all multipart uploads.
  ///
  /// Returns:
  /// - A Future that completes with a list of all multipart uploads
  ///
  /// Example usage:
  /// ```dart
  /// final paginator = ListMultipartUploadsPaginator(
  ///   client: client,
  ///   request: request,
  /// );
  ///
  /// final allUploads = await paginator.collectAllUploads();
  /// print('Total multipart uploads: ${allUploads.length}');
  /// ```
  Future<List<Upload>> collectAllUploads() async {
    final allUploads = <Upload>[];

    await for (final result in stream) {
      if (result.uploads != null) {
        allUploads.addAll(result.uploads!);
      }
    }

    return allUploads;
  }

  /// Collects all results from all pages into a single list
  ///
  /// This method returns all ListMultipartUploadsResult objects, which can be
  /// useful if you need access to metadata from each page.
  ///
  /// Returns:
  /// - A Future that completes with a list of all ListMultipartUploadsResult objects
  Future<List<ListMultipartUploadsResult>> collectAllResults() async {
    final allResults = <ListMultipartUploadsResult>[];

    await for (final result in stream) {
      allResults.add(result);
    }

    return allResults;
  }
}
