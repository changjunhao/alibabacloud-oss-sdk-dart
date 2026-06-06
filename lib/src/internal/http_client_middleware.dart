import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../types/request_message.dart';
import '../types/response_message.dart';
import '../types/byte_stream.dart';
import '../logging/log_agent.dart';
import '../errors/client_errors.dart';

import 'execute_context.dart';
import 'execute_middleware.dart';

/// HTTP client middleware using Dio for processing HTTP requests
class HttpClientMiddleware implements ExecuteMiddleware {
  final Dio _dio;
  final LogAgent? logger;

  /// Creates an HTTP client middleware with the given Dio instance and optional logger
  HttpClientMiddleware({Dio? dio, this.logger}) : _dio = dio ?? Dio();

  @override
  Future<ResponseMessage> execute(
    RequestMessage request,
    ExecuteContext context,
  ) async {
    logger?.debug(request.toString());

    try {
      // Create Dio request options
      final options = Options(
        method: request.method,
        headers: request.headers,
        responseType: context.saveToURL == true
            ? ResponseType.stream
            : ResponseType.bytes,
        receiveTimeout: context.readWriteTimeout != null
            ? Duration(milliseconds: context.readWriteTimeout!)
            : null,
        sendTimeout: context.readWriteTimeout != null
            ? Duration(milliseconds: context.readWriteTimeout!)
            : null,
        validateStatus: (status) => true,
      );

      // Prepare request data
      dynamic requestData;
      int? contentLength;
      if (request.content != null) {
        switch (request.content) {
          case DataByteStream dataStream:
            requestData = await dataStream.readData();
            break;
          case FileByteStream fileStream:
            contentLength = await fileStream.getBodyLength();
            requestData = fileStream.file.openRead();
            break;
          case StreamByteStream streamByteStream:
            requestData = streamByteStream.stream;
            break;
          default:
            requestData = null;
        }
      }

      // Set Content-Length for file uploads if not already set
      if (contentLength != null && request.headers['content-length'] == null) {
        request.headers['content-length'] = contentLength.toString();
      }

      // Setup progress callbacks
      ProgressCallback? onSendProgress;
      ProgressCallback? onReceiveProgress;

      if (context.progressDelegate != null) {
        final progressInfo = context.progressDelegate!;

        if (progressInfo.upload) {
          // Upload progress tracking
          var lastSent = 0;
          onSendProgress = (sent, total) {
            final increment = sent - lastSent;
            lastSent = sent;
            progressInfo.delegate.onProgress(increment, sent, total);
          };
        } else {
          // Download progress tracking
          var lastReceived = 0;
          onReceiveProgress = (received, total) {
            final increment = received - lastReceived;
            lastReceived = received;
            progressInfo.delegate.onProgress(increment, received, total);
          };
        }
      }

      // Execute the request
      final response = await _dio.request<dynamic>(
        request.requestUri.toString(),
        data: requestData,
        options: options,
        cancelToken: context.cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      // Process response based on type
      ByteStream? responseContent;

      if (context.saveToURL == true && response.data is ResponseBody) {
        // Handle streaming response for file download
        final responseBodyStream = response.data as ResponseBody;

        // Check if response is successful (2xx status codes)
        if (response.statusCode != null && response.statusCode! >= 300) {
          // For error responses, read the stream into memory
          final bytes = await _readStreamToBytes(responseBodyStream.stream);
          responseContent = ByteStream.fromData(bytes);
        } else {
          // For successful responses, create a temporary file
          final tempFile = await _createTempFile();
          await _writeStreamToFile(responseBodyStream.stream, tempFile);
          responseContent = ByteStream.fromFile(tempFile);
        }
      } else if (response.data is Uint8List) {
        // Handle byte response
        responseContent = ByteStream.fromData(response.data as Uint8List);
      } else if (response.data is List<int>) {
        // Handle list of int response
        responseContent = ByteStream.fromData(
          Uint8List.fromList(response.data as List<int>),
        );
      } else if (response.data != null) {
        // Handle other response types by converting to string then bytes
        final stringData = response.data.toString();
        responseContent = ByteStream.fromData(
          Uint8List.fromList(stringData.codeUnits),
        );
      }

      // Convert Dio response headers to Map<String, String>
      final responseHeaders = <String, String>{};
      response.headers.forEach((key, values) {
        if (values.isNotEmpty) {
          responseHeaders[key] = values.first;
        }
      });

      final responseMessage = ResponseMessage(
        statusCode: response.statusCode ?? 0,
        headers: responseHeaders,
        content: responseContent,
        request: request,
      );

      logger?.debug(responseMessage.toString());
      return responseMessage;
    } catch (error) {
      logger?.error('HTTP request failed: $error');

      // Handle Dio errors
      if (error is DioException) {
        if (error.type == DioExceptionType.cancel) {
          throw ClientError(
            code: 'RequestCancelled',
            message:
                'HTTP request was cancelled: ${error.message ?? 'cancelled'}',
            innerError: error,
          );
        }
        throw ClientError(
          code: 'HttpRequestFailed',
          message: 'HTTP request failed: ${error.message}',
          innerError: error,
        );
      } else {
        throw ClientError(
          code: 'HttpRequestFailed',
          message: 'HTTP request failed: $error',
          innerError: error is Exception ? error : Exception(error.toString()),
        );
      }
    }
  }

  /// Read stream data into bytes
  Future<Uint8List> _readStreamToBytes(Stream<Uint8List> stream) async {
    final chunks = <int>[];
    await for (final chunk in stream) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }

  /// Create a temporary file for storing downloaded data
  Future<File> _createTempFile() async {
    final tempDir = Directory.systemTemp;
    final tempFile = File(
      '${tempDir.path}/oss_download_${DateTime.now().millisecondsSinceEpoch}.tmp',
    );
    return tempFile;
  }

  /// Write stream data to file
  Future<void> _writeStreamToFile(Stream<Uint8List> stream, File file) async {
    final sink = file.openWrite();
    try {
      await for (final chunk in stream) {
        sink.add(chunk);
      }
    } finally {
      await sink.close();
    }
  }
}
