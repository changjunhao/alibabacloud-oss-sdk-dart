import 'client.dart';
import 'client_extensions.dart';
import 'models/model_public_access_block.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_public_access_block.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide account-level PublicAccessBlock operations
extension ClientPublicAccessBlock on Client {
  /// Enables or disables Block Public Access for Object Storage Service (OSS) resources.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutPublicAccessBlockResult> putPublicAccessBlock(
    PutPublicAccessBlockRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'PutPublicAccessBlock',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'publicAccessBlock': ''},
    );

    // Validate required fields
    request.publicAccessBlockConfiguration.ensureRequired(
      'request.publicAccessBlockConfiguration',
    );

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdePublicAccessBlock.serializePutPublicAccessBlock,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = PutPublicAccessBlockResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdePublicAccessBlock.deserializePutPublicAccessBlock,
      ],
    );

    return result;
  }

  /// Queries the Block Public Access configurations of OSS resources.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetPublicAccessBlockResult> getPublicAccessBlock(
    GetPublicAccessBlockRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'GetPublicAccessBlock',
      method: 'GET',
      parameters: {'publicAccessBlock': ''},
    );

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdePublicAccessBlock.serializeGetPublicAccessBlock,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = GetPublicAccessBlockResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdePublicAccessBlock.deserializeGetPublicAccessBlock,
      ],
    );

    return result;
  }

  /// Deletes the Block Public Access configurations of OSS resources.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DeletePublicAccessBlockResult> deletePublicAccessBlock(
    DeletePublicAccessBlockRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'DeletePublicAccessBlock',
      method: 'DELETE',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'publicAccessBlock': ''},
    );

    // Serialize input
    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdePublicAccessBlock.serializeDeletePublicAccessBlock,
        Serde.addContentMd5,
      ],
    );

    // Execute operation
    final output = await invokeOperation(input, options);

    // Create and deserialize result
    final result = DeletePublicAccessBlockResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdePublicAccessBlock.deserializeDeletePublicAccessBlock,
      ],
    );

    return result;
  }
}
