import 'client.dart';
import 'client_extensions.dart';
import 'models/model_object_tagging.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_object_tagging.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide object tagging operations
extension ClientObjectTagging on Client {
  /// You can call this operation to add tags to or modify the tags of an object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutObjectTaggingResult> putObjectTagging(
    PutObjectTaggingRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'PutObjectTagging',
      method: 'PUT',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'tagging': ''},
    );

    // Serialize the request
    await SerdeObjectTagging.serializePutObjectTagging(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = PutObjectTaggingResult();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeObjectTagging.deserializePutObjectTagging,
    ]);

    return result;
  }

  /// You can call this operation to query the tags of an object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetObjectTaggingResult> getObjectTagging(
    GetObjectTaggingRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'GetObjectTagging',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
      parameters: {'tagging': ''},
    );

    // Serialize the request
    await SerdeObjectTagging.serializeGetObjectTagging(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = GetObjectTaggingResult();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeObjectTagging.deserializeGetObjectTagging,
    ]);

    return result;
  }

  /// You can call this operation to delete the tags of a specified object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DeleteObjectTaggingResult> deleteObjectTagging(
    DeleteObjectTaggingRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'DeleteObjectTagging',
      method: 'DELETE',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'tagging': ''},
    );

    // Serialize the request
    await SerdeObjectTagging.serializeDeleteObjectTagging(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = DeleteObjectTaggingResult();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeObjectTagging.deserializeDeleteObjectTagging,
    ]);

    return result;
  }
}
