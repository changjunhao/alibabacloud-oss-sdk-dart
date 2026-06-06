import '../errors/server_error.dart';
import '../logging/log_agent.dart';
import '../retry/retryer.dart';
import '../transform/serde_extensions.dart';
import '../types/request_message.dart';
import '../types/response_message.dart';
import 'execute_context.dart';
import 'execute_middleware.dart';

/// Handler interface for retry operations
abstract class RetryHandler {
  /// Called when a retry is about to be performed
  ///
  /// Parameters:
  /// - [request]: The request message being retried
  /// - [context]: The execution context
  /// - [error]: The error that caused the retry
  void retrying(
    RequestMessage request,
    ExecuteContext context,
    Exception error,
  );
}

/// Fix time retry handler that adjusts clock offset based on server time
class FixTimeRetryHandler implements RetryHandler {
  /// Creates a new FixTimeRetryHandler
  const FixTimeRetryHandler();

  @override
  void retrying(
    RequestMessage request,
    ExecuteContext context,
    Exception error,
  ) {
    // Fix time offset based on server error
    if (error is! ServerError) {
      return;
    }

    final serverError = error;

    // Check for time-related errors
    if (serverError.code == 'RequestTimeTooSkewed' ||
        (serverError.code == 'InvalidArgument' &&
            serverError.message ==
                'Invalid signing date in Authorization header.')) {
      // Try to get server time from error fields first
      final serverTimeStr = serverError.errorFields['ServerTime'];
      if (serverTimeStr != null) {
        final serverTime = DateFormatters.iso8601DateTimeSeconds.tryParse(
          serverTimeStr,
        );
        if (serverTime != null && context.signingContext != null) {
          context.signingContext!.clockOffset = serverTime.difference(
            DateTime.now(),
          );
        }
      } else {
        // Fallback to Date header
        final dateStr = serverError.headers.getCaseInsensitive('Date');
        if (dateStr != null) {
          final serverTime = DateFormatters.rfc5322DateTime.tryParse(dateStr);
          if (serverTime != null && context.signingContext != null) {
            context.signingContext!.clockOffset = serverTime.difference(
              DateTime.now(),
            );
          }
        }
      }
    }
  }
}

/// Middleware that handles request retries using the configured retryer
///
/// This middleware:
/// 1. Attempts to execute the request
/// 2. If it fails, checks if the error is retryable
/// 3. If retryable, waits for the specified delay and retries
/// 4. Continues until max attempts are reached or the request succeeds
class RetryerMiddleware implements ExecuteMiddleware {
  /// The next middleware in the execution chain
  final ExecuteMiddleware nextHandler;

  /// The retryer to use for retry logic
  final Retryer retryer;

  /// Maximum number of attempts (including the initial attempt)
  final int maxAttempts;

  /// Optional logger for debugging
  final LogAgent? logger;

  /// Optional retry handler for custom retry logic
  final RetryHandler? retryHandler;

  /// Creates a new RetryerMiddleware
  ///
  /// Parameters:
  /// - [nextHandler]: The next middleware in the execution chain
  /// - [retryer]: The retryer to use for retry logic
  /// - [logger]: Optional logger for debugging
  /// - [retryHandler]: Optional retry handler for custom retry logic
  RetryerMiddleware({
    required this.nextHandler,
    required this.retryer,
    this.logger,
    this.retryHandler,
  }) : maxAttempts = (retryer.maxAttempts() > 1) ? retryer.maxAttempts() : 1;

  @override
  Future<ResponseMessage> execute(
    RequestMessage request,
    ExecuteContext context,
  ) async {
    int attempt = 0;

    while (true) {
      try {
        return await nextHandler.execute(request, context);
      } catch (error) {
        attempt++;

        // If we've reached max attempts, throw the error
        if (attempt >= maxAttempts) {
          rethrow;
        }

        // Check if request content is seekable (can be retried)
        final content = request.content;
        if (content != null && content.isSeekable == false) {
          rethrow;
        }

        // Check if the error is retryable
        final shouldRetry = retryer.isErrorRetryable(error as Exception);
        if (!shouldRetry) {
          rethrow;
        }

        // Calculate retry delay
        final delay = retryer.retryDelay(attempt, error);

        // Wait for the specified delay
        await Future.delayed(delay);

        // Call retry handler if provided
        retryHandler?.retrying(request, context, error);

        // Log retry information
        logger?.debug(
          'Should retry. Current attempt: $attempt, delay: ${delay.inMilliseconds}ms, error: ${error.toString()}',
        );
      }
    }
  }
}
