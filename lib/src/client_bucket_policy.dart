import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_policy.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_policy.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket policy operations
extension ClientBucketPolicy on Client {
  /// Configures a policy for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketPolicyResult> putBucketPolicy(
    PutBucketPolicyRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutBucketPolicy',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'policy': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.body.ensureRequired('request.body');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketPolicy.serializePutBucketPolicy,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutBucketPolicyResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketPolicy.deserializePutBucketPolicy],
    );

    return result;
  }

  /// Queries the policies configured for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketPolicyResult> getBucketPolicy(
    GetBucketPolicyRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketPolicy',
      method: 'GET',
      parameters: {'policy': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketPolicy.serializeGetBucketPolicy,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketPolicyResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketPolicy.deserializeGetBucketPolicy],
    );

    return result;
  }

  /// Deletes a policy for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DeleteBucketPolicyResult> deleteBucketPolicy(
    DeleteBucketPolicyRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'DeleteBucketPolicy',
      method: 'DELETE',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'policy': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketPolicy.serializeDeleteBucketPolicy,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = DeleteBucketPolicyResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketPolicy.deserializeDeleteBucketPolicy],
    );

    return result;
  }

  /// Checks whether the current bucket policy allows public access.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketPolicyStatusResult> getBucketPolicyStatus(
    GetBucketPolicyStatusRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketPolicyStatus',
      method: 'GET',
      parameters: {'policyStatus': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketPolicy.serializeGetBucketPolicyStatus,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketPolicyStatusResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketPolicy.deserializeGetBucketPolicyStatus],
    );

    return result;
  }
}
