import '../types/request_message.dart';
import '../types/response_message.dart';
import 'execute_context.dart';

/// Execute middleware interface for processing requests and responses
abstract class ExecuteMiddleware {
  /// Creates an ExecuteMiddleware instance.
  const ExecuteMiddleware();

  /// Execute the request with the given context and return a response
  Future<ResponseMessage> execute(
    RequestMessage request,
    ExecuteContext context,
  );
}
