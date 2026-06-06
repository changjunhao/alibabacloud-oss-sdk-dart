import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_request_payment.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_request_payment.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket request payment operations
extension ClientBucketRequestPayment on Client {
  /// Enables pay-by-requester for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketRequestPaymentResult> putBucketRequestPayment(
    PutBucketRequestPaymentRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutBucketRequestPayment',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'requestPayment': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.requestPaymentConfiguration.ensureRequired(
      'request.requestPaymentConfiguration',
    );

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketRequestPayment.serializePutBucketRequestPayment,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutBucketRequestPaymentResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketRequestPayment.deserializePutBucketRequestPayment,
      ],
    );

    return result;
  }

  /// Queries pay-by-requester configurations for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketRequestPaymentResult> getBucketRequestPayment(
    GetBucketRequestPaymentRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketRequestPayment',
      method: 'GET',
      parameters: {'requestPayment': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketRequestPayment.serializeGetBucketRequestPayment,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketRequestPaymentResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketRequestPayment.deserializeGetBucketRequestPayment,
      ],
    );

    return result;
  }
}
