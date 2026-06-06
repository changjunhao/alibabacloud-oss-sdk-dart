import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_versioning.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_versioning.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket versioning operations
extension ClientBucketVersioning on Client {
  /// Configures the versioning state for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketVersioningResult> putBucketVersioning(
    PutBucketVersioningRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'PutBucketVersioning',
      method: 'PUT',
      bucket: request.bucket.ensureRequired('request.bucket'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'versioning': ''},
    );

    // Validate required configuration
    request.versioningConfiguration.ensureRequired(
      'request.versioningConfiguration',
    );

    // Serialize the request
    await SerdeBucketVersioning.serializePutBucketVersioning(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = PutBucketVersioningResult();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeBucketVersioning.deserializePutBucketVersioning,
    ]);

    return result;
  }

  /// Queries the versioning state of a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketVersioningResult> getBucketVersioning(
    GetBucketVersioningRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'GetBucketVersioning',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      parameters: {'versioning': ''},
    );

    // Serialize the request
    await SerdeBucketVersioning.serializeGetBucketVersioning(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = GetBucketVersioningResult();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeBucketVersioning.deserializeGetBucketVersioning,
    ]);

    return result;
  }

  /// Queries the information about the versions of all objects in a bucket, including the delete markers.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<ListObjectVersionsResult> listObjectVersions(
    ListObjectVersionsRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'ListObjectVersions',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      parameters: {'versions': '', 'encoding-type': 'url'},
    );

    // Serialize the request
    await SerdeBucketVersioning.serializeListObjectVersions(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = ListObjectVersionsResult();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeBucketVersioning.deserializeListObjectVersions,
    ]);

    return result;
  }
}
