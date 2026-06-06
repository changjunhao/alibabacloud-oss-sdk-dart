import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_cors.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_cors.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket CORS operations
extension ClientBucketCors on Client {
  /// Configures cross-origin resource sharing (CORS) rules for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketCorsResult> putBucketCors(
    PutBucketCorsRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutBucketCors',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'cors': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.corsConfiguration.ensureRequired('request.corsConfiguration');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketCors.serializePutBucketCors,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutBucketCorsResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketCors.deserializePutBucketCors],
    );

    return result;
  }

  /// Queries the cross-origin resource sharing (CORS) rules that are configured for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketCorsResult> getBucketCors(
    GetBucketCorsRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketCors',
      method: 'GET',
      parameters: {'cors': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketCors.serializeGetBucketCors,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketCorsResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketCors.deserializeGetBucketCors],
    );

    return result;
  }

  /// Disables the cross-origin resource sharing (CORS) feature and deletes all CORS rules for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DeleteBucketCorsResult> deleteBucketCors(
    DeleteBucketCorsRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'DeleteBucketCors',
      method: 'DELETE',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'cors': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketCors.serializeDeleteBucketCors,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = DeleteBucketCorsResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketCors.deserializeDeleteBucketCors],
    );

    return result;
  }

  /// Determines whether to send a cross-origin request. Before a cross-origin request is sent, the browser sends a preflight OPTIONS request that includes a specific origin, HTTP method, and header information to Object Storage Service (OSS) to determine whether to send the cross-origin request.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<OptionObjectResult> optionObject(
    OptionObjectRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'OptionObject',
      method: 'OPTIONS',
      headers: {'Content-Type': 'application/xml'},
    );

    // Set bucket and key from request
    input.bucket = request.bucket.ensureRequired('request.bucket');
    input.key = request.key.ensureRequired('request.key');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketCors.serializeOptionObject,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = OptionObjectResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketCors.deserializeOptionObject],
    );

    return result;
  }
}
