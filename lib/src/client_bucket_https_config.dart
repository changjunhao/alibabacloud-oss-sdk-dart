import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_https_config.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_https_config.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket HTTPS config operations
extension ClientBucketHttpsConfig on Client {
  /// Enables or disables Transport Layer Security (TLS) version management for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketHttpsConfigResult> putBucketHttpsConfig(
    PutBucketHttpsConfigRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutBucketHttpsConfig',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'httpsConfig': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.httpsConfiguration.ensureRequired('request.httpsConfiguration');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketHttpsConfig.serializePutBucketHttpsConfig,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutBucketHttpsConfigResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketHttpsConfig.deserializePutBucketHttpsConfig,
      ],
    );

    return result;
  }

  /// Queries the Transport Layer Security (TLS) version configurations of a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketHttpsConfigResult> getBucketHttpsConfig(
    GetBucketHttpsConfigRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketHttpsConfig',
      method: 'GET',
      parameters: {'httpsConfig': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketHttpsConfig.serializeGetBucketHttpsConfig,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketHttpsConfigResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketHttpsConfig.deserializeGetBucketHttpsConfig,
      ],
    );

    return result;
  }

  /// Deletes the HTTPS configuration for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DeleteBucketHttpsConfigResult> deleteBucketHttpsConfig(
    DeleteBucketHttpsConfigRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'DeleteBucketHttpsConfig',
      method: 'DELETE',
      parameters: {'httpsConfig': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketHttpsConfig.serializeDeleteBucketHttpsConfig,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = DeleteBucketHttpsConfigResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketHttpsConfig.deserializeDeleteBucketHttpsConfig,
      ],
    );

    return result;
  }
}
