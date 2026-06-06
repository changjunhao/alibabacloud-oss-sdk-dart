import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_access_monitor.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_access_monitor.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket AccessMonitor operations
extension ClientBucketAccessMonitor on Client {
  /// Modifies the access tracking status of a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketAccessMonitorResult> putBucketAccessMonitor(
    PutBucketAccessMonitorRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutBucketAccessMonitor',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'accessmonitor': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.accessMonitorConfiguration.ensureRequired(
      'request.accessMonitorConfiguration',
    );

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketAccessMonitor.serializePutBucketAccessMonitor,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutBucketAccessMonitorResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketAccessMonitor.deserializePutBucketAccessMonitor,
      ],
    );

    return result;
  }

  /// Queries the access tracking status of a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketAccessMonitorResult> getBucketAccessMonitor(
    GetBucketAccessMonitorRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketAccessMonitor',
      method: 'GET',
      parameters: {'accessmonitor': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketAccessMonitor.serializeGetBucketAccessMonitor,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketAccessMonitorResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketAccessMonitor.deserializeGetBucketAccessMonitor,
      ],
    );

    return result;
  }
}
