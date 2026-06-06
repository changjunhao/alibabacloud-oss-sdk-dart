import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_logging.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_logging.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket Logging operations
extension ClientBucketLogging on Client {
  /// Enables logging for a bucket. After you enable logging for a bucket,
  /// Object Storage Service (OSS) generates logs every hour based on the
  /// defined naming rule and stores the logs as objects in the specified
  /// destination bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketLoggingResult> putBucketLogging(
    PutBucketLoggingRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutBucketLogging',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'logging': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.bucketLoggingStatus.ensureRequired('request.bucketLoggingStatus');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketLogging.serializePutBucketLogging,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutBucketLoggingResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketLogging.deserializePutBucketLogging],
    );

    return result;
  }

  /// Queries the configurations of access log collection of a bucket.
  /// Only the owner of a bucket can query the configurations of access
  /// log collection of the bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketLoggingResult> getBucketLogging(
    GetBucketLoggingRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketLogging',
      method: 'GET',
      parameters: {'logging': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketLogging.serializeGetBucketLogging,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketLoggingResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketLogging.deserializeGetBucketLogging],
    );

    return result;
  }

  /// Disables the logging feature for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DeleteBucketLoggingResult> deleteBucketLogging(
    DeleteBucketLoggingRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'DeleteBucketLogging',
      method: 'DELETE',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'logging': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketLogging.serializeDeleteBucketLogging,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = DeleteBucketLoggingResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketLogging.deserializeDeleteBucketLogging],
    );

    return result;
  }

  /// Customizes the user_defined_log_fields field in real-time logs by
  /// adding custom request headers or query parameters to the field for
  /// subsequent analysis of requests.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutUserDefinedLogFieldsConfigResult> putUserDefinedLogFieldsConfig(
    PutUserDefinedLogFieldsConfigRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutUserDefinedLogFieldsConfig',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'userDefinedLogFieldsConfig': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.userDefinedLogFieldsConfiguration.ensureRequired(
      'request.userDefinedLogFieldsConfiguration',
    );

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketLogging.serializePutUserDefinedLogFieldsConfig,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutUserDefinedLogFieldsConfigResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketLogging.deserializePutUserDefinedLogFieldsConfig,
      ],
    );

    return result;
  }

  /// Queries the custom configurations of the user_defined_log_fields
  /// field in the real-time logs of a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetUserDefinedLogFieldsConfigResult> getUserDefinedLogFieldsConfig(
    GetUserDefinedLogFieldsConfigRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetUserDefinedLogFieldsConfig',
      method: 'GET',
      parameters: {'userDefinedLogFieldsConfig': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketLogging.serializeGetUserDefinedLogFieldsConfig,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetUserDefinedLogFieldsConfigResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketLogging.deserializeGetUserDefinedLogFieldsConfig,
      ],
    );

    return result;
  }

  /// Deletes the custom configurations of the user_defined_log_fields
  /// field in the real-time logs of a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DeleteUserDefinedLogFieldsConfigResult>
  deleteUserDefinedLogFieldsConfig(
    DeleteUserDefinedLogFieldsConfigRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'DeleteUserDefinedLogFieldsConfig',
      method: 'DELETE',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'userDefinedLogFieldsConfig': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketLogging.serializeDeleteUserDefinedLogFieldsConfig,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = DeleteUserDefinedLogFieldsConfigResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketLogging.deserializeDeleteUserDefinedLogFieldsConfig,
      ],
    );

    return result;
  }
}
