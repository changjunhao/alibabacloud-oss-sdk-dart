import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_archive_directread.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_archive_directread.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket ArchiveDirectRead operations
extension ClientBucketArchiveDirectread on Client {
  /// View storage space archive direct read status.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketArchiveDirectReadResult> getBucketArchiveDirectRead(
    GetBucketArchiveDirectReadRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketArchiveDirectRead',
      method: 'GET',
      parameters: {'bucketArchiveDirectRead': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketArchiveDirectread.serializeGetBucketArchiveDirectRead,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketArchiveDirectReadResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketArchiveDirectread.deserializeGetBucketArchiveDirectRead,
      ],
    );

    return result;
  }

  /// Enable or disable the storage space archive direct read function.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketArchiveDirectReadResult> putBucketArchiveDirectRead(
    PutBucketArchiveDirectReadRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutBucketArchiveDirectRead',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'bucketArchiveDirectRead': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.archiveDirectReadConfiguration.ensureRequired(
      'request.archiveDirectReadConfiguration',
    );

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketArchiveDirectread.serializePutBucketArchiveDirectRead,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutBucketArchiveDirectReadResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketArchiveDirectread.deserializePutBucketArchiveDirectRead,
      ],
    );

    return result;
  }
}
