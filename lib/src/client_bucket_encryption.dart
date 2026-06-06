import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_encryption.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_encryption.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket encryption operations
extension ClientBucketEncryption on Client {
  /// Configures encryption rules for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketEncryptionResult> putBucketEncryption(
    PutBucketEncryptionRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutBucketEncryption',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'encryption': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.serverSideEncryptionRule.ensureRequired(
      'request.serverSideEncryptionRule',
    );

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketEncryption.serializePutBucketEncryption,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutBucketEncryptionResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketEncryption.deserializePutBucketEncryption,
      ],
    );

    return result;
  }

  /// Queries the encryption rules configured for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketEncryptionResult> getBucketEncryption(
    GetBucketEncryptionRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketEncryption',
      method: 'GET',
      parameters: {'encryption': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketEncryption.serializeGetBucketEncryption,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketEncryptionResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketEncryption.deserializeGetBucketEncryption,
      ],
    );

    return result;
  }

  /// Deletes encryption rules for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DeleteBucketEncryptionResult> deleteBucketEncryption(
    DeleteBucketEncryptionRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'DeleteBucketEncryption',
      method: 'DELETE',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'encryption': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketEncryption.serializeDeleteBucketEncryption,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = DeleteBucketEncryptionResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketEncryption.deserializeDeleteBucketEncryption,
      ],
    );

    return result;
  }
}
