import 'client.dart';
import 'models/model_bucket_acl.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_acl.dart';
import 'transform/serde_functions.dart';
import 'client_extensions.dart';

/// Extension for Client to provide bucket ACL operations
extension ClientBucketAcl on Client {
  /// Configures or modifies the access control list (ACL) for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketAclResponse> putBucketAcl(
    PutBucketAclRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'PutBucketAcl',
      method: 'PUT',
      bucket: request.bucket.ensureRequired('request.bucket'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'acl': ''},
    );

    // Serialize the request
    await SerdeBucketAcl.serializePutBucketAcl(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = PutBucketAclResponse();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketAcl.deserializePutBucketAcl],
    );

    return result;
  }

  /// Queries the access control list (ACL) of a bucket. Only the owner of a bucket can query the ACL of the bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketAclResponse> getBucketAcl(
    GetBucketAclRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'GetBucketAcl',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      parameters: {'acl': ''},
    );

    // Serialize the request
    await SerdeBucketAcl.serializeGetBucketAcl(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = GetBucketAclResponse();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketAcl.deserializeGetBucketAcl],
    );

    return result;
  }
}
