import '../client.dart';
import '../configuration.dart';
import '../types/client_options.dart';
import '../types/operation_input.dart';
import '../types/operation_options.dart';
import '../types/operation_output.dart';
import 'internal/scoped_client.dart';

/// Client for managing AgenticBuckets and their BucketSpaces.
///
/// The bucket in requests is a logical prefix; the physical name and signing are resolved by internal routing.
class AgenticBucketClient {
  final Client _client;

  /// Creates the client; reuses the core signing, retry, and transport implementation.
  AgenticBucketClient(
    Configuration config, [
    List<ClientOptionsAction> actions = const [],
  ]) : _client = makeScopedClient(config, '-ab-apsr', actions);

  /// Executes a custom AgenticBucket operation without rewriting the input.
  Future<OperationOutput> invokeOperation(
    OperationInput input, [
    OperationOptions? options,
  ]) => _client.invokeOperation(input, options);

  /// Releases the transport resources held by this client.
  void dispose() => _client.dispose();
}
