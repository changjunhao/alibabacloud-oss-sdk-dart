import '../types/request_message.dart';
import '../types/response_message.dart';
import '../logging/log_agent.dart';
import 'execute_context.dart';
import 'execute_middleware.dart';
import 'response_handler.dart';

/// Response checker middleware that processes responses through registered handlers
class ResponseCheckerMiddleware implements ExecuteMiddleware {
  /// The next middleware in the execution chain
  final ExecuteMiddleware nextHandler;

  /// Logger for debugging purposes
  final LogAgent? logger;

  /// Creates a response checker middleware
  ResponseCheckerMiddleware({required this.nextHandler, this.logger});

  @override
  Future<ResponseMessage> execute(
    RequestMessage request,
    ExecuteContext context,
  ) async {
    final response = await nextHandler.execute(request, context);

    final handlers = context.responseHandlers;
    if (handlers != null) {
      for (final handler in handlers) {
        logger?.debug('Should call handler: $handler');

        // Check if handler supports async operations
        if (handler is ResponseHandlerAsync) {
          await handler.onResponseAsync(request, response);
        } else {
          handler.onResponse(request, response);
        }
      }
    }

    return response;
  }
}
