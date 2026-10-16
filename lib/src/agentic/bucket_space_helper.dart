import '../configuration.dart';

/// Converts a BucketSpace logical prefix to the physical full name used by a regular Client.
///
/// Performs name concatenation only; does not perform operation-level validation; do not pass the result back to BucketSpaceClient.
class BucketSpaceHelper {
  final String _accountId;
  final String _region;

  /// Constructs with account UID and region.
  const BucketSpaceHelper({required String accountId, required String region})
    : _accountId = accountId,
      _region = region;

  /// Constructs from a configuration snapshot; missing values default to empty strings.
  BucketSpaceHelper.fromConfiguration(Configuration config)
    : this(accountId: config.accountId ?? '', region: config.region ?? '');

  /// Returns `{prefix}-{accountId}-{region}-bs-apsr`.
  String toBucketName(String prefix) => '$prefix-$_accountId-$_region-bs-apsr';
}
