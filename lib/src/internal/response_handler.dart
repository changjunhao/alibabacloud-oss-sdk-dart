import 'dart:convert';
import 'dart:typed_data';
import '../types/request_message.dart';
import '../types/response_message.dart';
import '../errors/server_error.dart';
import '../errors/client_errors.dart';
import '../transform/serde_extensions.dart';
import '../utils/xml_parser.dart';

/// Response handler interface for processing HTTP responses
abstract class ResponseHandler {
  /// Called when a response is received
  void onResponse(RequestMessage request, ResponseMessage response);
}

/// Async response handler interface for processing HTTP responses asynchronously
abstract class ResponseHandlerAsync extends ResponseHandler {
  /// Called when a response is received asynchronously
  Future<void> onResponseAsync(
    RequestMessage request,
    ResponseMessage response,
  );

  @override
  void onResponse(RequestMessage request, ResponseMessage response) {
    // Default implementation does nothing for sync calls
  }
}

/// Server response handler that processes server errors
class ServerResponseHandler implements ResponseHandlerAsync {
  @override
  void onResponse(RequestMessage request, ResponseMessage response) {
    // Default implementation does nothing for sync calls
  }

  @override
  Future<void> onResponseAsync(
    RequestMessage request,
    ResponseMessage response,
  ) async {
    // If response is successful (2xx), return early
    if (response.statusCode ~/ 100 == 2) {
      return;
    }

    Map<String, String> errorFields = <String, String>{};
    Uint8List? body;

    try {
      body = await response.content?.readData();
    } catch (e) {
      // Ignore read errors, body will remain null
    }

    // Read from x-oss-error header if body is empty
    if (body == null || body.isEmpty) {
      final errorHeader = response.headers.getCaseInsensitive('x-oss-error');
      if (errorHeader != null) {
        try {
          body = base64.decode(errorHeader);
        } catch (e) {
          // Ignore base64 decode errors
        }
      }
    }

    // Try to parse error message from XML
    if (body != null && body.isNotEmpty) {
      try {
        final dict = DictionaryXMLExtensions.withXMLData(body);
        final error = dict['Error'];
        if (error != null && error is Map<String, dynamic>) {
          for (final entry in error.entries) {
            if (entry.value is String) {
              errorFields[entry.key] = entry.value as String;
            }
          }
        } else {
          final bodyStr = String.fromCharCodes(body);
          final truncatedBody = bodyStr.length > 256
              ? bodyStr.substring(0, 256)
              : bodyStr;
          errorFields['Message'] =
              'Not found tag <Error>, part response body $truncatedBody';
        }
      } catch (e) {
        final bodyStr = String.fromCharCodes(body);
        final truncatedBody = bodyStr.length > 256
            ? bodyStr.substring(0, 256)
            : bodyStr;
        errorFields['Message'] =
            'Failed to parse xml from response body, part response body $truncatedBody';
      }
    }

    throw ServerError(
      statusCode: response.statusCode,
      headers: response.headers,
      errorFields: errorFields,
      requestTarget: '${request.method} ${request.requestUri}',
      snapshot: body,
    );
  }
}

/// Response handler for checking upload CRC validation
class CheckerUploadCrcResponseHandler implements ResponseHandlerAsync {
  final int? crc;

  const CheckerUploadCrcResponseHandler({this.crc});

  @override
  void onResponse(RequestMessage request, ResponseMessage response) {
    // Default implementation does nothing for sync calls
  }

  @override
  Future<void> onResponseAsync(
    RequestMessage request,
    ResponseMessage response,
  ) async {
    // Only check CRC for successful responses
    if (response.statusCode ~/ 100 != 2) {
      return;
    }

    final serverCrcStr = response.headers.getCaseInsensitive(
      'x-oss-hash-crc64ecma',
    );
    if (serverCrcStr != null) {
      final serverCrc = serverCrcStr.toUInt64();
      if (serverCrc != null) {
        final clientCrc = await request.content?.hashCrc64ecma(crc: crc ?? 0);
        if (clientCrc != null && serverCrc != clientCrc) {
          throw CrcErrors.inconsistentError(clientCrc, serverCrc);
        }
      }
    }
  }
}

/// Response handler for checking download CRC validation
class CheckerDownloadCrcResponseHandler implements ResponseHandlerAsync {
  const CheckerDownloadCrcResponseHandler();

  @override
  void onResponse(RequestMessage request, ResponseMessage response) {
    // Default implementation does nothing for sync calls
  }

  @override
  Future<void> onResponseAsync(
    RequestMessage request,
    ResponseMessage response,
  ) async {
    // Only check CRC for successful responses (but not partial content)
    if (response.statusCode ~/ 100 != 2 || response.statusCode == 206) {
      return;
    }

    final serverCrcStr = response.headers.getCaseInsensitive(
      'x-oss-hash-crc64ecma',
    );
    if (serverCrcStr != null) {
      final serverCrc = serverCrcStr.toUInt64();
      if (serverCrc != null) {
        final clientCrc = await response.content?.hashCrc64ecma();
        if (clientCrc != null && serverCrc != clientCrc) {
          throw CrcErrors.inconsistentError(clientCrc, serverCrc);
        }
      }
    }
  }
}
