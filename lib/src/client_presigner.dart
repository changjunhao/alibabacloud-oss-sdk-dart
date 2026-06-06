import 'client.dart';
import 'client_extensions.dart';
import 'models/model_object_basic.dart';
import 'models/model_object_multipart.dart';
import 'models/model_misc.dart';
import 'types/operation_input.dart';
import 'types/attributes.dart';
import 'transform/serde_object_basic.dart';
import 'transform/serde_object_multipart.dart';

const _expirationKey = AttributeKeys.expirationTime;

/// Extension for Client to provide presign operations
extension ClientPresigner on Client {
  /// Generates the pre-signed URL for GetObject operation.
  /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [expiration]: Optional, The expiration time for the generated presign url.
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PresignResult> presignGetObject(
    GetObjectRequest request, [
    DateTime? expiration,
  ]) async {
    var input = OperationInput(
      operationName: 'GetObject',
      method: 'GET',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
    );

    if (expiration != null) {
      input.metadata.set(_expirationKey, expiration);
    }

    SerdeObjectBasic.serializeGetObject(request, input);

    final output = await presignInner(input);

    return PresignResult(
      method: output.method ?? '',
      url: output.url ?? '',
      expiration: output.expiration,
      signedHeaders: output.signedHeaders,
    );
  }

  /// Generates the pre-signed URL for PutObject operation.
  /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [expiration]: Optional, The expiration time for the generated presign url.
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PresignResult> presignPutObject(
    PutObjectRequest request, [
    DateTime? expiration,
  ]) async {
    var input = OperationInput(
      operationName: 'PutObject',
      method: 'PUT',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
    );

    if (expiration != null) {
      input.metadata.set(_expirationKey, expiration);
    }

    SerdeObjectBasic.serializePutObject(request, input);

    final output = await presignInner(input);

    return PresignResult(
      method: output.method ?? '',
      url: output.url ?? '',
      expiration: output.expiration,
      signedHeaders: output.signedHeaders,
    );
  }

  /// Generates the pre-signed URL for HeadObject operation.
  /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [expiration]: Optional, The expiration time for the generated presign url.
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PresignResult> presignHeadObject(
    HeadObjectRequest request, [
    DateTime? expiration,
  ]) async {
    var input = OperationInput(
      operationName: 'HeadObject',
      method: 'HEAD',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
    );

    if (expiration != null) {
      input.metadata.set(_expirationKey, expiration);
    }

    SerdeObjectBasic.serializeHeadObject(request, input);

    final output = await presignInner(input);

    return PresignResult(
      method: output.method ?? '',
      url: output.url ?? '',
      expiration: output.expiration,
      signedHeaders: output.signedHeaders,
    );
  }

  /// Generates the pre-signed URL for InitiateMultipartUpload operation.
  /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [expiration]: Optional, The expiration time for the generated presign url.
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PresignResult> presignInitiateMultipartUpload(
    InitiateMultipartUploadRequest request, [
    DateTime? expiration,
  ]) async {
    var input = OperationInput(
      operationName: 'InitiateMultipartUpload',
      method: 'POST',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
      parameters: {'uploads': ''},
    );

    if (expiration != null) {
      input.metadata.set(_expirationKey, expiration);
    }

    await SerdeObjectMultipart.serializeInitiateMultipartUpload(request, input);

    final output = await presignInner(input);

    return PresignResult(
      method: output.method ?? '',
      url: output.url ?? '',
      expiration: output.expiration,
      signedHeaders: output.signedHeaders,
    );
  }

  /// Generates the pre-signed URL for UploadPart operation.
  /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [expiration]: Optional, The expiration time for the generated presign url.
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PresignResult> presignUploadPart(
    UploadPartRequest request, [
    DateTime? expiration,
  ]) async {
    var input = OperationInput(
      operationName: 'UploadPart',
      method: 'PUT',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
    );

    if (expiration != null) {
      input.metadata.set(_expirationKey, expiration);
    }

    await SerdeObjectMultipart.serializeUploadPart(request, input);

    final output = await presignInner(input);

    return PresignResult(
      method: output.method ?? '',
      url: output.url ?? '',
      expiration: output.expiration,
      signedHeaders: output.signedHeaders,
    );
  }

  /// Generates the pre-signed URL for CompleteMultipartUpload operation.
  /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [expiration]: Optional, The expiration time for the generated presign url.
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PresignResult> presignCompleteMultipartUpload(
    CompleteMultipartUploadRequest request, [
    DateTime? expiration,
  ]) async {
    var input = OperationInput(
      operationName: 'CompleteMultipartUpload',
      method: 'POST',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
    );

    if (expiration != null) {
      input.metadata.set(_expirationKey, expiration);
    }

    await SerdeObjectMultipart.serializeCompleteMultipartUpload(request, input);

    final output = await presignInner(input);

    return PresignResult(
      method: output.method ?? '',
      url: output.url ?? '',
      expiration: output.expiration,
      signedHeaders: output.signedHeaders,
    );
  }

  /// Generates the pre-signed URL for AbortMultipartUpload operation.
  /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [expiration]: Optional, The expiration time for the generated presign url.
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<PresignResult> presignAbortMultipartUpload(
    AbortMultipartUploadRequest request, [
    DateTime? expiration,
  ]) async {
    var input = OperationInput(
      operationName: 'AbortMultipartUpload',
      method: 'DELETE',
      bucket: request.bucket.ensureRequired('request.bucket'),
      key: request.key.ensureRequired('request.key'),
    );

    if (expiration != null) {
      input.metadata.set(_expirationKey, expiration);
    }

    await SerdeObjectMultipart.serializeAbortMultipartUpload(request, input);

    final output = await presignInner(input);

    return PresignResult(
      method: output.method ?? '',
      url: output.url ?? '',
      expiration: output.expiration,
      signedHeaders: output.signedHeaders,
    );
  }
}
