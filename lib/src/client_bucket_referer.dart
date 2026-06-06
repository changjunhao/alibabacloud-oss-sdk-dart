import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_referer.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_referer.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket Referer operations
extension ClientBucketReferer on Client {
  /// Configures a Referer whitelist for an Object Storage Service (OSS) bucket.
  /// You can specify whether to allow the requests whose Referer field is empty
  /// or whose query strings are truncated.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketRefererResult> putBucketReferer(
    PutBucketRefererRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutBucketReferer',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'referer': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.refererConfiguration.ensureRequired('request.refererConfiguration');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketReferer.serializePutBucketReferer,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutBucketRefererResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketReferer.deserializePutBucketReferer],
    );

    return result;
  }

  /// Queries the hotlink protection configurations for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketRefererResult> getBucketReferer(
    GetBucketRefererRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketReferer',
      method: 'GET',
      parameters: {'referer': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketReferer.serializeGetBucketReferer,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketRefererResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketReferer.deserializeGetBucketReferer],
    );

    return result;
  }
}
