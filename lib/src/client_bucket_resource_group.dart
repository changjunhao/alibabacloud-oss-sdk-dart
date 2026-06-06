import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_resource_group.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_resource_group.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket resource group operations
extension ClientBucketResourceGroup on Client {
  /// Queries the ID of the resource group to which a bucket belongs.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketResourceGroupResult> getBucketResourceGroup(
    GetBucketResourceGroupRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetBucketResourceGroup',
      method: 'GET',
      parameters: {'resourceGroup': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketResourceGroup.serializeGetBucketResourceGroup,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetBucketResourceGroupResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketResourceGroup.deserializeGetBucketResourceGroup,
      ],
    );

    return result;
  }

  /// Modifies the ID of the resource group to which a bucket belongs.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketResourceGroupResult> putBucketResourceGroup(
    PutBucketResourceGroupRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutBucketResourceGroup',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'resourceGroup': ''},
    );

    // Set bucket from request
    input.bucket = request.bucket.ensureRequired('request.bucket');

    // Validate required fields
    request.bucketResourceGroupConfiguration.ensureRequired(
      'request.bucketResourceGroupConfiguration',
    );

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketResourceGroup.serializePutBucketResourceGroup,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutBucketResourceGroupResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeBucketResourceGroup.deserializePutBucketResourceGroup,
      ],
    );

    return result;
  }
}
