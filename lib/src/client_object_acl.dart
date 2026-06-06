import 'client.dart';
import 'models/model_object_acl.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_object_acl.dart';
import 'transform/serde_functions.dart';
import 'client_extensions.dart';

/// Extension for Client to provide object ACL operations
extension ClientObjectAcl on Client {
  /// Configures or modifies the access control list (ACL) for an object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutObjectAclResult> putObjectAcl(
    PutObjectAclRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'PutObjectAcl',
      method: 'PUT',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'acl': ''},
    );

    // Serialize the request
    await SerdeObjectAcl.serializePutObjectAcl(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = PutObjectAclResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectAcl.deserializePutObjectAcl],
    );

    return result;
  }

  /// Queries the access control list (ACL) of an object. Only the owner of an object can query the ACL of the object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetObjectAclResult> getObjectAcl(
    GetObjectAclRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'GetObjectAcl',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
      parameters: {'acl': ''},
    );

    // Serialize the request
    await SerdeObjectAcl.serializeGetObjectAcl(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = GetObjectAclResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectAcl.deserializeGetObjectAcl],
    );

    return result;
  }
}
