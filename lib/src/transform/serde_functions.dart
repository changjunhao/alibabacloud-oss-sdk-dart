import 'dart:convert';
import 'dart:typed_data';
import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../types/byte_stream.dart';
import '../models/model_types.dart';
import '../errors/client_errors.dart';
import '../utils/mime_utils.dart';
import '../utils/xml_parser.dart';
import 'serde_extensions.dart';

/// Type alias for serialize delegate function
typedef SerdeSerializeDelegate<T extends RequestModel> =
    Future<void> Function(T request, OperationInput input);

/// Type alias for deserialize delegate function
typedef SerdeDeserializeDelegate<T extends ResultModel> =
    Future<void> Function(T result, OperationOutput output);

/// Interface for XML serializable objects
abstract class SerdeSerializeXml {
  /// Creates a SerdeSerializeXml instance.
  const SerdeSerializeXml();

  /// Convert object to XML data
  Future<Uint8List> asXml();
}

/// Serialization and deserialization utilities
class Serde {
  /// Creates a Serde instance.
  Serde();

  /// Serialize input for request
  static Future<void> serializeInput<T extends RequestModel>(
    T request,
    OperationInput input, {
    List<SerdeSerializeDelegate<T>> customSerializers = const [],
  }) async {
    // Headers
    request.commonProp.headers?.forEach((key, value) {
      input.headers[key] = value;
    });

    // Parameters
    request.commonProp.parameters?.forEach((key, value) {
      input.parameters[key] = value;
    });

    // Body - check if request implements SerdeSerializeXml
    if (request is SerdeSerializeXml) {
      final xmlData = await (request as SerdeSerializeXml).asXml();
      input.body = ByteStream.fromData(xmlData);
    }

    // Custom serializers
    for (final serializer in customSerializers) {
      await serializer(request, input);
    }
  }

  /// Add Content-MD5 header if not already present
  static Future<void> addContentMd5<T extends RequestModel>(
    T request,
    OperationInput input,
  ) async {
    if (input.headers.getCaseInsensitive('Content-MD5') != null) {
      return;
    }

    if (input.body != null) {
      switch (input.body) {
        case DataByteStream dataStream:
          final data = await dataStream.readData();
          if (data != null) {
            final md5Hash = data.calculateMd5();
            input.headers['Content-MD5'] = base64Encode(md5Hash);
          }
          break;
        default:
          break;
      }
    }
  }

  /// Add Content-Type header if not already present
  static Future<void> addContentType<T extends RequestModel>(
    T request,
    OperationInput input,
  ) async {
    if (input.headers.getCaseInsensitive('Content-Type') != null) {
      return;
    }

    String? value;

    // Try to get MIME type from object key
    if (input.key != null) {
      value = MimeUtils.getMimeType(
        input.key!,
        defaultMimeType: 'application/octet-stream',
      );
    }

    // Try to get MIME type from file if body is a file
    if (value == null && input.body != null) {
      switch (input.body) {
        case FileByteStream fileStream:
          value = MimeUtils.getMimeType(
            fileStream.file.path,
            defaultMimeType: 'application/octet-stream',
          );
          break;
        default:
          value = 'application/octet-stream';
          break;
      }
    }

    input.headers['Content-Type'] = value ?? 'application/octet-stream';
  }

  /// Deserialize output for result
  static Future<void> deserializeOutput<T extends ResultModel>(
    T result,
    OperationOutput output, {
    List<SerdeDeserializeDelegate<T>> customDeserializers = const [],
  }) async {
    // Common properties
    result.commonProp.statusCode = output.statusCode;
    result.commonProp.headers = output.headers;

    // Custom deserializers
    for (final deserializer in customDeserializers) {
      await deserializer(result, output);
    }
  }

  /// Deserialize XML from ByteStream to Map
  static Future<Map<String, dynamic>> deserializeXml(ByteStream? body) async {
    // Should not be null, and handle the error
    final data = await body?.readData();
    if (data == null) {
      throw SerdeErrors.parseResponseBodyError(
        info: 'Can not get response body.',
      );
    }

    try {
      final (root, error) = DictionaryXMLExtensions.withXMLDataError(data);
      if (error != null) {
        throw SerdeErrors.parseResponseBodyError(
          info: 'Parse response body fail.',
          snapshot: data,
          innerError: error,
        );
      }
      return root;
    } catch (e) {
      throw SerdeErrors.parseResponseBodyError(
        info: 'Parse response body fail.',
        snapshot: data,
        innerError: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Deserialize XML from ByteStream to specific type with root element
  static Future<T> deserializeXmlWithRoot<T>(
    ByteStream? body,
    String xmlRoot,
  ) async {
    if (xmlRoot.isEmpty) {
      throw ParameterErrors.paramNullOrEmptyError('xmlRoot');
    }

    // Should not be null, and handle the error
    final data = await body?.readData();
    if (data == null) {
      throw SerdeErrors.parseResponseBodyError(
        info: 'Can not get response body.',
      );
    }

    try {
      final (root, error) = DictionaryXMLExtensions.withXMLDataError(data);
      if (error != null) {
        throw SerdeErrors.parseResponseBodyError(
          info: 'Parse response body fail.',
          snapshot: data,
          innerError: error,
        );
      }

      final element = root[xmlRoot];
      if (element == null) {
        throw SerdeErrors.parseResponseBodyError(
          info: 'Not found root tag <$xmlRoot>.',
          snapshot: data,
        );
      }

      if (element is! T) {
        throw SerdeErrors.parseResponseBodyError(
          info: 'Root element type mismatch for <$xmlRoot>.',
          snapshot: data,
        );
      }

      return element;
    } catch (e) {
      if (e is ClientError) {
        rethrow;
      }
      throw SerdeErrors.parseResponseBodyError(
        info: 'Parse response body fail.',
        snapshot: data,
        innerError: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
