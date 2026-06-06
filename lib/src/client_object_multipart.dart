import 'client.dart';
import 'client_extensions.dart';
import 'models/model_object_multipart.dart';
import 'types/operation_input.dart';
import 'types/operation_options.dart';
import 'transform/serde_object_multipart.dart';
import 'transform/serde_functions.dart';
import 'progress.dart';

/// Extension for Client to provide object multipart operations
extension ClientObjectMultipart on Client {
  /// Initiates a multipart upload task.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<InitiateMultipartUploadResult> initiateMultipartUpload(
    InitiateMultipartUploadRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'InitiateMultipartUpload',
      method: 'POST',
      parameters: {'uploads': ''},
    );

    input.bucket = request.bucket.ensureRequired('request.bucket');
    input.key = request.key.ensureRequired('request.key');

    var customSerializers =
        <SerdeSerializeDelegate<InitiateMultipartUploadRequest>>[
          SerdeObjectMultipart.serializeInitiateMultipartUpload,
          Serde.addContentMd5,
        ];

    // Auto detect MIME type if enabled
    // Note: Feature flag checking would need client implementation access
    // For now, we'll use a simple approach
    customSerializers.add(Serde.addContentType);

    await Serde.serializeInput(
      request,
      input,
      customSerializers: customSerializers,
    );

    final output = await invokeOperation(input, options);

    final result = InitiateMultipartUploadResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeObjectMultipart.deserializeInitiateMultipartUpload,
      ],
    );

    return result;
  }

  /// You can call this operation to upload an object by part based on the object name and the upload ID that you specify.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<UploadPartResult> uploadPart(
    UploadPartRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(operationName: 'UploadPart', method: 'PUT');

    input.bucket = request.bucket.ensureRequired('request.bucket');
    input.key = request.key.ensureRequired('request.key');
    request.uploadId.ensureRequired('request.uploadId');
    request.partNumber.ensureRequired('request.partNumber');

    // Set progress delegate if provided
    if (request.progress != null) {
      input.metadata.set(
        ProgressAttributeKeys.progressDelegate,
        ProgressDelegateDesc(delegate: request.progress!, upload: true),
      );
    }

    await Serde.serializeInput(
      request,
      input,
      customSerializers: <SerdeSerializeDelegate<UploadPartRequest>>[
        SerdeObjectMultipart.serializeUploadPart,
        Serde.addContentMd5,
        Serde.addContentType,
      ],
    );

    final output = await invokeOperation(input, options);

    final result = UploadPartResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectMultipart.deserializeUploadPart],
    );

    return result;
  }

  /// You can call this operation to complete the multipart upload task of an object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<CompleteMultipartUploadResult> completeMultipartUpload(
    CompleteMultipartUploadRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'CompleteMultipartUpload',
      method: 'POST',
      headers: {'Content-Type': 'application/xml'},
    );

    input.bucket = request.bucket.ensureRequired('request.bucket');
    input.key = request.key.ensureRequired('request.key');
    request.uploadId.ensureRequired('request.uploadId');

    await Serde.serializeInput(
      request,
      input,
      customSerializers:
          <SerdeSerializeDelegate<CompleteMultipartUploadRequest>>[
            SerdeObjectMultipart.serializeCompleteMultipartUpload,
          ],
    );

    final output = await invokeOperation(input, options);

    final result = CompleteMultipartUploadResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeObjectMultipart.deserializeCompleteMultipartUpload,
      ],
    );

    return result;
  }

  /// Uploads a single part by copying data from an existing object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<UploadPartCopyResult> uploadPartCopy(
    UploadPartCopyRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'UploadPartCopy',
      method: 'PUT',
      headers: {'Content-Type': 'application/xml'},
    );

    input.bucket = request.bucket.ensureRequired('request.bucket');
    input.key = request.key.ensureRequired('request.key');
    request.uploadId.ensureRequired('request.uploadId');
    request.partNumber.ensureRequired('request.partNumber');

    await Serde.serializeInput(
      request,
      input,
      customSerializers: <SerdeSerializeDelegate<UploadPartCopyRequest>>[
        SerdeObjectMultipart.serializeUploadPartCopy,
      ],
    );

    final output = await invokeOperation(input, options);

    final result = UploadPartCopyResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectMultipart.deserializeUploadPartCopy],
    );

    return result;
  }

  /// You can call this operation to cancel a multipart upload task and delete the parts that are uploaded by the multipart upload task.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<AbortMultipartUploadResult> abortMultipartUpload(
    AbortMultipartUploadRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'AbortMultipartUpload',
      method: 'DELETE',
      headers: {'Content-Type': 'application/xml'},
    );

    input.bucket = request.bucket.ensureRequired('request.bucket');
    input.key = request.key.ensureRequired('request.key');
    request.uploadId.ensureRequired('request.uploadId');

    await Serde.serializeInput(
      request,
      input,
      customSerializers: <SerdeSerializeDelegate<AbortMultipartUploadRequest>>[
        SerdeObjectMultipart.serializeAbortMultipartUpload,
      ],
    );

    final output = await invokeOperation(input, options);

    final result = AbortMultipartUploadResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeObjectMultipart.deserializeAbortMultipartUpload,
      ],
    );

    return result;
  }

  /// You can call this operation to list all ongoing multipart upload tasks.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<ListMultipartUploadsResult> listMultipartUploads(
    ListMultipartUploadsRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'ListMultipartUploads',
      method: 'GET',
      parameters: {'uploads': '', 'encoding-type': 'url'},
    );

    input.bucket = request.bucket.ensureRequired('request.bucket');

    await Serde.serializeInput(
      request,
      input,
      customSerializers: <SerdeSerializeDelegate<ListMultipartUploadsRequest>>[
        SerdeObjectMultipart.serializeListMultipartUploads,
      ],
    );

    final output = await invokeOperation(input, options);

    final result = ListMultipartUploadsResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [
        SerdeObjectMultipart.deserializeListMultipartUploads,
      ],
    );

    return result;
  }

  /// You can call this operation to list all parts that are uploaded by using a specified upload ID.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [options]: Optional, operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<ListPartsResult> listParts(
    ListPartsRequest request, [
    OperationOptions? options,
  ]) async {
    // Create operation input
    final input = OperationInput(
      operationName: 'ListParts',
      method: 'GET',
      parameters: {'encoding-type': 'url'},
    );

    input.bucket = request.bucket.ensureRequired('request.bucket');
    input.key = request.key.ensureRequired('request.key');
    request.uploadId.ensureRequired('request.uploadId');

    await Serde.serializeInput(
      request,
      input,
      customSerializers: <SerdeSerializeDelegate<ListPartsRequest>>[
        SerdeObjectMultipart.serializeListParts,
      ],
    );

    final output = await invokeOperation(input, options);

    final result = ListPartsResult();
    await Serde.deserializeOutput(
      result,
      output,
      customDeserializers: [SerdeObjectMultipart.deserializeListParts],
    );

    return result;
  }
}
