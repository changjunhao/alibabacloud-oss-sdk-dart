import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'models/model_bucket_tags.dart';
import 'transform/serde_bucket_tags.dart';
import 'transform/serde_functions.dart';
import 'client.dart';
import 'client_extensions.dart';

/// Extension for Client to provide bucket tags operations
extension ClientBucketTags on Client {
  /// Adds tags to or modifies the existing tags of a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketTagsResult> putBucketTags(
    PutBucketTagsRequest request, [
    OperationOptions? options,
  ]) async {
    final input = OperationInput(
      operationName: 'PutBucketTags',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'tagging': ''},
    );

    input.bucket = request.bucket.ensureRequired('request.bucket');
    request.tagging.ensureRequired('request.tagging');

    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketTags.serializePutBucketTags,
        Serde.addContentMd5,
      ],
    );

    final output = await invokeOperation(input, options);

    final result = PutBucketTagsResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketTags.deserializePutBucketTags],
    );

    return result;
  }

  /// Queries the tags of a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketTagsResult> getBucketTags(
    GetBucketTagsRequest request, [
    OperationOptions? options,
  ]) async {
    final input = OperationInput(
      operationName: 'GetBucketTags',
      method: 'GET',
      parameters: {'tagging': ''},
    );

    input.bucket = request.bucket.ensureRequired('request.bucket');

    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketTags.serializeGetBucketTags,
        Serde.addContentMd5,
      ],
    );

    final output = await invokeOperation(input, options);

    final result = GetBucketTagsResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketTags.deserializeGetBucketTags],
    );

    return result;
  }

  /// Deletes tags configured for a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DeleteBucketTagsResult> deleteBucketTags(
    DeleteBucketTagsRequest request, [
    OperationOptions? options,
  ]) async {
    final input = OperationInput(
      operationName: 'DeleteBucketTags',
      method: 'DELETE',
      headers: {'Content-Type': 'application/xml'},
      parameters: {'tagging': ''},
    );

    input.bucket = request.bucket.ensureRequired('request.bucket');

    await Serde.serializeInput(
      request,
      input,
      customSerializers: [
        SerdeBucketTags.serializeDeleteBucketTags,
        Serde.addContentMd5,
      ],
    );

    final output = await invokeOperation(input, options);

    final result = DeleteBucketTagsResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeBucketTags.deserializeDeleteBucketTags],
    );

    return result;
  }
}
