import 'dart:async';
import 'package:dio/dio.dart';
import '../types/request_message.dart';
import '../types/response_message.dart';
import '../logging/log_agent.dart';
import 'execute_context.dart';
import 'execute_middleware.dart';
import 'http_client_middleware.dart';

/// Type definition for middleware factory function
typedef CreateMiddleware = ExecuteMiddleware Function(ExecuteMiddleware next);

/// Execute stack for managing middleware chain
///
/// This class manages a stack of middleware that process requests in order.
/// It provides caching for the resolved middleware chain and thread-safe operations.
/// Uses Dart's native Completer for proper async synchronization.
class ExecuteStack {
  /// The base handler (usually HttpClientMiddleware)
  final ExecuteMiddleware _handler;

  /// Stack of middleware factories with their names
  final List<(CreateMiddleware, String)> _stack = [];

  /// Cached resolved middleware chain
  ExecuteMiddleware? _cached;

  /// Completer for thread-safe operations - acts as an async lock
  Completer<void>? _lockCompleter;

  /// Creates an execute stack with URLSession-like behavior
  ///
  /// Parameters:
  /// - [dio]: Dio instance for HTTP requests (optional)
  /// - [logger]: Logger for debugging (optional)
  ExecuteStack.withDio({Dio? dio, LogAgent? logger})
    : _handler = HttpClientMiddleware(dio: dio, logger: logger);

  /// Creates an execute stack with a custom handler
  ///
  /// Parameters:
  /// - [handler]: The base middleware handler
  ExecuteStack.withHandler(ExecuteMiddleware handler) : _handler = handler;

  /// Pushes a middleware factory onto the stack
  ///
  /// Parameters:
  /// - [create]: Factory function that creates middleware
  /// - [name]: Name of the middleware for debugging
  void push(CreateMiddleware create, String name) {
    _stack.add((create, name));
    _cached = null;
  }

  /// Resolves the middleware chain
  ///
  /// Returns the cached middleware chain if available, otherwise builds a new one.
  /// This method is thread-safe using Completer and ensures only one resolution happens at a time.
  Future<ExecuteMiddleware> resolve() async {
    // Return cached result if available
    if (_cached != null) {
      return _cached!;
    }

    // Wait for any ongoing resolution to complete
    if (_lockCompleter != null) {
      await _lockCompleter!.future;
      // Check again after waiting - another thread might have resolved it
      if (_cached != null) {
        return _cached!;
      }
    }

    // Double-check pattern: check again if cached is available
    if (_cached != null) {
      return _cached!;
    }

    // Create a new completer to act as a lock
    _lockCompleter = Completer<void>();

    try {
      // Build the middleware chain from bottom to top
      ExecuteMiddleware prev = _handler;

      // Process stack in reverse order (last added middleware wraps first)
      for (final (create, _) in _stack.reversed) {
        prev = create(prev);
      }

      _cached = prev;
      return prev;
    } catch (error) {
      // Complete the lock completer with error to unblock waiting threads
      if (!_lockCompleter!.isCompleted) {
        _lockCompleter!.completeError(error);
      }
      rethrow;
    } finally {
      // Complete the lock completer to unblock waiting threads
      if (!_lockCompleter!.isCompleted) {
        _lockCompleter!.complete();
      }
      _lockCompleter = null;
    }
  }

  /// Executes a request through the middleware chain
  ///
  /// Parameters:
  /// - [request]: The request message to execute
  /// - [context]: The execution context
  ///
  /// Returns the response message
  Future<ResponseMessage> execute(
    RequestMessage request,
    ExecuteContext context,
  ) async {
    final handler = await resolve();
    return await handler.execute(request, context);
  }

  /// Clears the cached middleware chain
  ///
  /// This forces the next call to [resolve] to rebuild the middleware chain.
  /// Thread-safe operation that respects ongoing resolutions.
  void clearCache() {
    _cached = null;
  }

  /// Gets the current stack size
  int get stackSize => _stack.length;

  /// Gets the names of all middleware in the stack
  List<String> get middlewareNames => _stack.map((entry) => entry.$2).toList();

  /// Removes all middleware from the stack
  void clear() {
    _stack.clear();
    _cached = null;
  }
}
