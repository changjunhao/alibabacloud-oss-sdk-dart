import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_public_access_block.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_public_access_block.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket PublicAccessBlock operations
extension ClientBucketPublicAccessBlock on Client {
  /// Enables or disables Block Public Access for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketPublicAccessBlockResult> putBucketPublicAccessBlock(
    PutBucketPublicAccessBlockRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutBucketPublicAccessBlock',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'publicAccessBlock': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.publicAccessBlockConfiguration.ensureRequired(
      'request.publicAccessBlockConfiguration',
    );

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketPublicAccessBlock.serializePutBucketPublicAccessBlock,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutBucketPublicAccessBlockResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketPublicAccessBlock.deserializePutBucketPublicAccessBlock,
      ],
    );

    return result;
  }

  /// Queries the Block Public Access configurations of a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketPublicAccessBlockResult> getBucketPublicAccessBlock(
    GetBucketPublicAccessBlockRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketPublicAccessBlock',
      method: 'GET',
      parameters: {'publicAccessBlock': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketPublicAccessBlock.serializeGetBucketPublicAccessBlock,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketPublicAccessBlockResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketPublicAccessBlock.deserializeGetBucketPublicAccessBlock,
      ],
    );

    return result;
  }

  /// Deletes the Block Public Access configurations of a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DeleteBucketPublicAccessBlockResult> deleteBucketPublicAccessBlock(
    DeleteBucketPublicAccessBlockRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'DeleteBucketPublicAccessBlock',
      method: 'DELETE',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'publicAccessBlock': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketPublicAccessBlock.serializeDeleteBucketPublicAccessBlock,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = DeleteBucketPublicAccessBlockResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketPublicAccessBlock.deserializeDeleteBucketPublicAccessBlock,
      ],
    );

    return result;
  }
}
