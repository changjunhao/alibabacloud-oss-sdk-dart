import 'client.dart';
import 'client_extensions.dart';
import 'models/model_bucket_basic.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_bucket_basic.dart';
import 'transform/serde_functions.dart';

/// Extension for Client to provide bucket basic operations
extension ClientBucketBasic on Client {
  /// Queries the storage capacity of a bucket and the number of objects that are stored in the bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketStatResult> getBucketStat(
    GetBucketStatRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'GetBucketStat',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      parameters: {'stat': ''},
    );

    // Serialize the request
    await SerdeBucketBasic.serializeGetBucketStat(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = GetBucketStatResult();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeBucketBasic.deserializeGetBucketStat,
    ]);

    return result;
  }

  /// Creates a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutBucketResult> putBucket(
    PutBucketRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'PutBucket',
      method: 'PUT',
      bucket: request.bucket.ensureRequired('request.bucket'),
      headers: {'Content-Type': 'application/xml'},
    );

    // Serialize the request
    await SerdeBucketBasic.serializePutBucket(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = PutBucketResult();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeBucketBasic.deserializePutBucket,
    ]);

    return result;
  }

  /// Deletes a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DeleteBucketResult> deleteBucket(
    DeleteBucketRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'DeleteBucket',
      method: 'DELETE',
      bucket: request.bucket.ensureRequired('request.bucket'),
      headers: {'Content-Type': 'application/xml'},
    );

    // Serialize the request
    await SerdeBucketBasic.serializeDeleteBucket(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = DeleteBucketResult();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeBucketBasic.deserializeDeleteBucket,
    ]);

    return result;
  }

  /// Queries the information about all objects in a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<ListObjectsResult> listObjects(
    ListObjectsRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'ListObjects',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      parameters: {'encoding-type': 'url'},
    );

    // Serialize the request
    await SerdeBucketBasic.serializeListObjects(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = ListObjectsResult();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeBucketBasic.deserializeListObjects,
    ]);

    return result;
  }

  /// Queries the information about all objects in a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<ListObjectsV2Result> listObjectsV2(
    ListObjectsV2Request request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'ListObjectsV2',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      parameters: {'list-type': '2', 'encoding-type': 'url'},
    );

    // Serialize the request
    await SerdeBucketBasic.serializeListObjectsV2(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = ListObjectsV2Result();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeBucketBasic.deserializeListObjectsV2,
    ]);

    return result;
  }

  /// Queries the information about a bucket. Only the owner of a bucket can query the information about the bucket. You can call this operation from an Object Storage Service (OSS) endpoint.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketInfoResult> getBucketInfo(
    GetBucketInfoRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'GetBucketInfo',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      parameters: {'bucketInfo': ''},
    );

    // Serialize the request
    await SerdeBucketBasic.serializeGetBucketInfo(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = GetBucketInfoResult();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeBucketBasic.deserializeGetBucketInfo,
    ]);

    return result;
  }

  /// Queries the region in which a bucket resides. Only the owner of a bucket can query the region in which the bucket resides.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetBucketLocationResult> getBucketLocation(
    GetBucketLocationRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'GetBucketLocation',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      parameters: {'location': ''},
    );

    // Serialize the request
    await SerdeBucketBasic.serializeGetBucketLocation(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = GetBucketLocationResult();
    await Serde.deserializeOutput(result, output, customDeserializers: [
      SerdeBucketBasic.deserializeGetBucketLocation,
    ]);

    return result;
  }
}
