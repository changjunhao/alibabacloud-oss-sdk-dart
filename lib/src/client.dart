import 'configuration.dart';
import 'types/client_options.dart';
import 'types/operation_input.dart';
import 'types/operation_output.dart';
import 'types/operation_options.dart';
import 'enums.dart';
import 'internal/client_impl.dart';

/// Main OSS client class for performing operations
///
/// This is the primary interface for interacting with Alibaba Cloud OSS.
/// It provides a high-level API for executing operations such as uploading,
/// downloading, and managing objects and buckets.
class Client {
  late final ClientImpl _clientImpl;

  /// Creates a new OSS client with the given configuration and options
  ///
  /// Parameters:
  /// - [config]: The configuration for the client
  /// - [actions]: Optional list of client option actions to customize the client
  Client(Configuration config, [List<ClientOptionsAction> actions = const []]) {
    _clientImpl = ClientImpl(config, actions);
  }

  /// Invokes an operation with the given input and options
  ///
  /// This is the main method for executing OSS operations. It handles
  /// the complete request lifecycle including signing, retries, and
  /// response processing.
  ///
  /// Parameters:
  /// - [input]: The operation input containing request details
  /// - [options]: Optional operation-specific options
  ///
  /// Returns:
  /// - A Future that completes with the operation output
  ///
  /// Throws:
  /// - Various OSS-specific exceptions based on the operation result
  Future<OperationOutput> invokeOperation(
    OperationInput input, [
    OperationOptions? options,
  ]) async {
    return await _clientImpl.execute(input, operationOptions: options);
  }

  /// Disposes the client and releases associated resources
  ///
  /// This method should be called when the client is no longer needed
  /// to properly clean up resources such as HTTP connections.
  void dispose() {
    _clientImpl.dispose();
  }

  /// Checks if a specific feature flag is enabled
  ///
  /// Parameters:
  /// - [flag]: The feature flag to check
  ///
  /// Returns:
  /// - true if the feature flag is enabled, false otherwise
  bool hasFeatureFlag(FeatureFlag flag) {
    return _clientImpl.hasFeatureFlag(flag);
  }

  /// Presigns a request and returns presign information
  ///
  /// This is an internal method used by presign extensions
  ///
  /// Parameters:
  /// - [input]: The operation input containing request details
  /// - [options]: Optional operation-specific options
  ///
  /// Returns:
  /// - A Future that completes with the presign inner result
  Future<dynamic> presignInner(
    OperationInput input, [
    OperationOptions? options,
  ]) async {
    return await _clientImpl.presignInner(input, operationOptions: options);
  }
}
