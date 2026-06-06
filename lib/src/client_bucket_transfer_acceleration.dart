import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_transfer_acceleration.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_transfer_acceleration.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket transfer acceleration operations
extension ClientBucketTransferAcceleration on Client {
  /// Configures transfer acceleration for a bucket.
  ///
  /// After you enable transfer acceleration for a bucket, the object access
  /// speed is accelerated for users worldwide. The transfer acceleration
  /// feature is applicable to scenarios where data needs to be transferred
  /// over long geographical distances.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketTransferAccelerationResult> putBucketTransferAcceleration(
    PutBucketTransferAccelerationRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutBucketTransferAcceleration',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'transferAcceleration': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.transferAccelerationConfiguration.ensureRequired(
      'request.transferAccelerationConfiguration',
    );

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketTransferAcceleration.serializePutBucketTransferAcceleration,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutBucketTransferAccelerationResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketTransferAcceleration
            .deserializePutBucketTransferAcceleration,
      ],
    );

    return result;
  }

  /// Queries the transfer acceleration configurations of a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketTransferAccelerationResult> getBucketTransferAcceleration(
    GetBucketTransferAccelerationRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketTransferAcceleration',
      method: 'GET',
      parameters: {'transferAcceleration': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketTransferAcceleration.serializeGetBucketTransferAcceleration,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketTransferAccelerationResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketTransferAcceleration
            .deserializeGetBucketTransferAcceleration,
      ],
    );

    return result;
  }
}
