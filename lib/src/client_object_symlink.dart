import 'client.dart';
import 'client_extensions.dart';
import 'models/model_object_symlink.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_object_symlink.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide object symlink operations
extension ClientObjectSymlink on Client {
  /// You can create a symbolic link for a target object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutSymlinkResult> putSymlink(
    PutSymlinkRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'PutSymlink',
      method: 'PUT',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'symlink': ''},
    );

    // Serialize the request
    await Serde.serializeInput(request, input);
    await SerdeObjectSymlink.serializePutSymlink(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = PutSymlinkResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectSymlink.deserializePutSymlink],
    );

    return result;
  }

  /// You can call this operation to query a symbolic link of an object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetSymlinkResult> getSymlink(
    GetSymlinkRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'GetSymlink',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
      parameters: {'symlink': ''},
    );

    // Serialize the request
    await SerdeObjectSymlink.serializeGetSymlink(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = GetSymlinkResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectSymlink.deserializeGetSymlink],
    );

    return result;
  }
}
