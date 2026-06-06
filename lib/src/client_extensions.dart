import 'dart:io';
import 'errors/client_errors.dart';
import 'errors/server_error.dart';
import 'models/model_bucket_acl.dart';
import 'models/model_object_basic.dart';
import 'types/operation_options.dart';
import 'types/byte_stream.dart';
import 'client.dart';
import 'client_bucket_acl.dart';
import 'client_object_basic.dart';

/// Extension for nullable types to ensure required values
extension OptionalExtensions<T> on T? {
  /// Ensures that the optional value is not null, throwing an error if it is
  ///
  /// Returns the unwrapped value if it exists, otherwise throws a ClientError
  ///
  /// [field] - The name of the field for error reporting
  T ensureRequired(String field) {
    if (this != null) {
      return this!;
    }
    throw ParameterErrors.paramRequiredError(field);
  }
}

/// Extension for Client to provide additional utility methods
extension ClientExtensions on Client {
  /// Checks if the bucket exists
  ///
  /// Parameters:
  /// - [bucket]: The bucket name to check
  ///
  /// Returns: True if the bucket exists, else False.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<bool> isBucketExist(String bucket) async {
    try {
      final request = GetBucketAclRequest(bucket: bucket);
      await getBucketAcl(request);
      return true;
    } catch (error) {
      if (error is ServerError && error.code == 'NoSuchBucket') {
        return false;
      }
      rethrow;
    }
  }

  /// You can call this operation to query an object.
  ///
  /// Parameters:
  /// - [request]: The request parameter to send
  /// - [file]: File path to save the object
  /// - [options]: Optional operation options
  ///
  /// Returns: The result instance.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<GetObjectResult> getObjectToFile(
    GetObjectRequest request,
    String file, [
    OperationOptions? options,
  ]) async {
    var modifiedOptions = options ?? OperationOptions();
    modifiedOptions.saveToURL = true;

    var result = await getObject(request, modifiedOptions);

    // Remove any existing file
    final targetFile = File(file);
    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    if (result.body is FileByteStream) {
      final fileByteStream = result.body as FileByteStream;
      final tempFile = fileByteStream.file;
      await tempFile.copy(file);
      result.body = FileByteStream(File(file));
    } else {
      throw ParameterErrors.paramInvalidError('result.body');
    }
    return result;
  }

  /// Checks if the object exists
  ///
  /// Parameters:
  /// - [bucket]: The name of the bucket
  /// - [key]: The full path of the object
  /// - [versionId]: The version ID of the object (optional)
  ///
  /// Returns: True if the object exists, else False.
  ///
  /// Throws: Various OSS-specific exceptions based on the operation result
  Future<bool> isObjectExist(
    String bucket,
    String key, [
    String? versionId,
  ]) async {
    try {
      final request = GetObjectMetaRequest(
        bucket: bucket,
        key: key,
        versionId: versionId,
      );
      await getObjectMeta(request);
      return true;
    } catch (error) {
      if (error is ServerError) {
        if (error.code == 'NoSuchKey') {
          return false;
        }
        if (error.statusCode == 404 && error.code == 'BadErrorResponse') {
          return false;
        }
      }
      rethrow;
    }
  }
}
