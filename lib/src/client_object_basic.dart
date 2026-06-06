import 'client.dart';
import 'client_extensions.dart';
import 'models/model_object_basic.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_object_basic.dart';
import 'transform/serde_functions.dart';
import 'progress.dart';
import 'enums.dart';
import 'internal/response_handler.dart';
import 'types/attributes.dart';

/// Extension for Client to provide object basic operations
extension ClientObjectBasic on Client {
  /// You can call this operation to upload an object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PutObjectResult> putObject(
    PutObjectRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'PutObject',
      method: 'PUT',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
    );

    // Handle progress tracking
    if (request.progress != null) {
      input.metadata.set(
        ProgressAttributeKeys.progressDelegate,
        ProgressDelegateDesc(
          delegate: ProgressWithRetry(request.progress!),
          upload: true,
        ),
      );
    }

    // Handle CRC64 check if enabled
    if (hasFeatureFlag(FeatureFlag.enableCRC64CheckUpload)) {
      input.metadata.append(
        AttributeKeys.responseHandlers,
        CheckerUploadCrcResponseHandler(),
      );
    }

    // Serialize the request
    await Serde.serializeInput(request, input);
    SerdeObjectBasic.serializePutObject(request, input);

    // Add content type detection if enabled
    if (hasFeatureFlag(FeatureFlag.autoDetectMimeType)) {
      await Serde.addContentType(request, input);
    }

    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = PutObjectResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectBasic.deserializePutObject],
    );

    return result;
  }

  /// Copies objects within a bucket or between buckets in the same region.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<CopyObjectResult> copyObject(
    CopyObjectRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'CopyObject',
      method: 'PUT',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
    );

    // Serialize the request
    SerdeObjectBasic.serializeCopyObject(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = CopyObjectResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectBasic.deserializeCopyObject],
    );

    return result;
  }

  /// You can call this operation to query an object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetObjectResult> getObject(
    GetObjectRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'GetObject',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
    );

    // Handle progress tracking
    if (request.progress != null) {
      input.metadata.set(
        ProgressAttributeKeys.progressDelegate,
        ProgressDelegateDesc(
          delegate: ProgressWithRetry(request.progress!),
          upload: false,
        ),
      );
    }

    // Handle CRC64 check if enabled
    if (hasFeatureFlag(FeatureFlag.enableCRC64CheckDownload)) {
      input.metadata.append(
        AttributeKeys.responseHandlers,
        CheckerDownloadCrcResponseHandler(),
      );
    }

    // Serialize the request
    SerdeObjectBasic.serializeGetObject(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = GetObjectResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectBasic.deserializeGetObject],
    );

    return result;
  }

  /// You can call this operation to upload an object by appending the object to an existing object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<AppendObjectResult> appendObject(
    AppendObjectRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'AppendObject',
      method: 'POST',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
      parameters: {'append': ''},
    );

    // Handle progress tracking
    if (request.progress != null) {
      input.metadata.set(
        ProgressAttributeKeys.progressDelegate,
        ProgressDelegateDesc(
          delegate: ProgressWithRetry(request.progress!),
          upload: true,
        ),
      );
    }

    // Handle CRC64 check if enabled
    if (hasFeatureFlag(FeatureFlag.enableCRC64CheckUpload)) {
      input.metadata.append(
        AttributeKeys.responseHandlers,
        CheckerUploadCrcResponseHandler(crc: request.initHashCrc64),
      );
    }

    // Serialize the request
    SerdeObjectBasic.serializeAppendObject(request, input);

    // Add content type detection if enabled
    if (hasFeatureFlag(FeatureFlag.autoDetectMimeType)) {
      await Serde.addContentType(request, input);
    } else {
      // Dio/URLSession adds Content-Type:application/x-www-form-urlencoded by default
      request.contentType ??= 'application/octet-stream';
    }

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = AppendObjectResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectBasic.deserializeAppendObject],
    );

    return result;
  }

  /// You can call this operation to delete an object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DeleteObjectResult> deleteObject(
    DeleteObjectRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'DeleteObject',
      method: 'DELETE',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
      headers: {'Content-Type': 'application/xml'},
    );

    // Serialize the request
    SerdeObjectBasic.serializeDeleteObject(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = DeleteObjectResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectBasic.deserializeDeleteObject],
    );

    return result;
  }

  /// You can call this operation to query the metadata of an object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<HeadObjectResult> headObject(
    HeadObjectRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'HeadObject',
      method: 'HEAD',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
    );

    // Serialize the request
    SerdeObjectBasic.serializeHeadObject(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = HeadObjectResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectBasic.deserializeHeadObject],
    );

    return result;
  }

  /// You can call this operation to query the metadata of an object, including ETag, Size, and LastModified. The content of the object is not returned.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetObjectMetaResult> getObjectMeta(
    GetObjectMetaRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'GetObjectMeta',
      method: 'HEAD',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
      parameters: {'objectMeta': ''},
    );

    // Serialize the request
    SerdeObjectBasic.serializeGetObjectMeta(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = GetObjectMetaResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectBasic.deserializeGetObjectMeta],
    );

    return result;
  }

  /// Deletes multiple objects from a bucket.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<DeleteMultipleObjectsResult> deleteMultipleObjects(
    DeleteMultipleObjectsRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'DeleteMultipleObjects',
      method: 'POST',
      bucket: request.bucket.ensureRequired('request.bucket'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'delete': ''},
    );

    // Serialize the request
    SerdeObjectBasic.serializeDeleteMultipleObjects(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = DeleteMultipleObjectsResult();

    // Only deserialize body if not in quiet mode
    if (!(request.quiet ?? false)) {
      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeObjectBasic.deserializeDeleteMultipleObjects,
        ],
      );
    } else {
      // Always set common properties from output
      result.commonProp.statusCode = output.statusCode;
      result.commonProp.headers = output.headers;
    }

    return result;
  }

  /// You can call this operation to restore objects of the Archive and Cold Archive storage classes.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<RestoreObjectResult> restoreObject(
    RestoreObjectRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'RestoreObject',
      method: 'POST',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'restore': ''},
    );

    // Serialize the request
    SerdeObjectBasic.serializeRestoreObject(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = RestoreObjectResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectBasic.deserializeRestoreObject],
    );

    return result;
  }

  /// You can call this operation to clean an object restored from Archive or Cold Archive state. After that, the restored object returns to the frozen state.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<CleanRestoredObjectResult> cleanRestoredObject(
    CleanRestoredObjectRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    var input = OperationInput(
      operationName: 'CleanRestoredObject',
      method: 'POST',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
      headers: {'Content-Type': 'application/xml'},
      parameters: {'cleanRestoredObject': ''},
    );

    // Serialize the request
    SerdeObjectBasic.serializeCleanRestoredObject(request, input);
    await Serde.addContentMd5(request, input);

    // Execute the operation
    var output = await invokeOperation(input, options);

    // Create and deserialize the result
    var result = CleanRestoredObjectResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectBasic.deserializeCleanRestoredObject],
    );

    return result;
  }
}
