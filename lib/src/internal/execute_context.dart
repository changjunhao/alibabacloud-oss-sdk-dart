import 'package:dio/dio.dart';
import '../signer/signing_context.dart';
import '../progress.dart';
import 'response_handler.dart';

/// Execute context containing information needed for request execution
class ExecuteContext {
  /// Maximum retry attempts
  final int? retryMaxAttempts;

  /// Read/write timeout in milliseconds
  final int? readWriteTimeout;

  /// Signing context for request signing
  SigningContext? signingContext;

  /// Progress delegate for tracking upload/download progress
  ProgressDelegateDesc? progressDelegate;

  /// Response handlers for processing responses
  final List<ResponseHandler>? responseHandlers;

  /// Whether to save response to URL/file
  final bool? saveToURL;

  /// Cancel token for cancelling in-flight requests
  final CancelToken? cancelToken;

  /// Creates an execute context with the given parameters
  ExecuteContext({
    this.retryMaxAttempts,
    this.readWriteTimeout,
    this.signingContext,
    this.progressDelegate,
    this.responseHandlers,
    this.saveToURL,
    this.cancelToken,
  });
}
