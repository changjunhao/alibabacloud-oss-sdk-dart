import '../client.dart';
import '../configuration.dart';
import '../types/client_options.dart';
import 'internal/scoped_client.dart';

/// Creates a regular OSS Client that uses BucketSpace logical prefixes.
abstract final class BucketSpaceClient {
  /// Reuses regular object, bucket, paginator, and presigner APIs; dispose the returned client when done.
  static Client make(
    Configuration config, [
    List<ClientOptionsAction> actions = const [],
  ]) => makeScopedClient(config, '-bs-apsr', actions);
}
