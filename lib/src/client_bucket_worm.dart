import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_worm.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_worm.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket WORM (compliance retention) operations
extension ClientBucketWorm on Client {
  /// Creates a retention policy.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<InitiateBucketWormResult> initiateBucketWorm(
    InitiateBucketWormRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'InitiateBucketWorm',
      method: 'POST',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'worm': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.initiateWormConfiguration.ensureRequired(
      'request.initiateWormConfiguration',
    );

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketWorm.serializeInitiateBucketWorm,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = InitiateBucketWormResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketWorm.deserializeInitiateBucketWorm],
    );

    return result;
  }

  /// Deletes an unlocked retention policy for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<AbortBucketWormResult> abortBucketWorm(
    AbortBucketWormRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'AbortBucketWorm',
      method: 'DELETE',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'worm': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketWorm.serializeAbortBucketWorm,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = AbortBucketWormResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketWorm.deserializeAbortBucketWorm],
    );

    return result;
  }

  /// Locks a retention policy.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<CompleteBucketWormResult> completeBucketWorm(
    CompleteBucketWormRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'CompleteBucketWorm',
      method: 'POST',
      headers: {'Content-Type': 'application/xml'},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.wormId.ensureRequired('request.wormId');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketWorm.serializeCompleteBucketWorm,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = CompleteBucketWormResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketWorm.deserializeCompleteBucketWorm],
    );

    return result;
  }

  /// Extends the retention period of objects in a bucket for which a
  /// retention policy is locked.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<ExtendBucketWormResult> extendBucketWorm(
    ExtendBucketWormRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'ExtendBucketWorm',
      method: 'POST',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'wormExtend': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.wormId.ensureRequired('request.wormId');
    request.extendWormConfiguration.ensureRequired(
      'request.extendWormConfiguration',
    );

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketWorm.serializeExtendBucketWorm,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = ExtendBucketWormResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketWorm.deserializeExtendBucketWorm],
    );

    return result;
  }

  /// Queries the retention policy configured for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketWormResult> getBucketWorm(
    GetBucketWormRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketWorm',
      method: 'GET',
      parameters: {'worm': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketWorm.serializeGetBucketWorm,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketWormResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketWorm.deserializeGetBucketWorm],
    );

    return result;
  }
}
