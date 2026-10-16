import '../../client.dart';
import '../../configuration.dart';
import '../../enums.dart';
import '../../errors/client_errors.dart';
import '../../types/client_options.dart';
import '../../types/operation_input.dart';

/// Creates a client with a shared execution pipeline for AgenticBucket/BucketSpace without modifying the caller's configuration.
Client makeScopedClient(
  Configuration config,
  String suffix,
  List<ClientOptionsAction> extraActions,
) {
  final accountId = config.accountId ?? '';
  final region = config.region ?? '';
  String buildName(OperationInput input) {
    final bucket = input.bucket;
    if (bucket == null) return '';
    if (accountId.isEmpty) {
      throw ParameterErrors.paramRequiredError('AccountId');
    }
    if (region.isEmpty) {
      throw ParameterErrors.paramRequiredError('Region');
    }
    return '$bucket-$accountId-$region$suffix';
  }

  final existing = config.userAgent;
  final scopedConfig = config.copyWith(
    userAgent: existing == null || existing.isEmpty
        ? 'agentic-client'
        : 'agentic-client/$existing',
  );
  return Client(scopedConfig, [
    ...extraActions,
    (options) {
      options.bucketNameResolver = buildName;
      final endpoint = options.endpoint;
      if (endpoint == null) return;
      // Uri.host does not include IPv6 brackets; the Uri constructor correctly restores the authority.
      final authority = Uri(
        scheme: endpoint.scheme,
        host: endpoint.host,
        port: endpoint.hasPort ? endpoint.port : null,
      ).authority;
      final style = options.addressStyle;
      options.endpointProvider = (input) {
        var host = authority;
        final paths = <String>[];
        if (input.bucket != null) {
          if (style == AddressStyleType.path) {
            paths.add(buildName(input));
            if (input.key == null) paths.add('');
          } else {
            // Consistent with upstream: scoped CNAME also uses physical virtual-hosted routing.
            final label = style == AddressStyleType.virtualHostedAlias
                ? '${input.bucket}-alias$suffix'
                : buildName(input);
            if (label.length > 63) {
              throw ClientError(
                code: 'ValidationError',
                message:
                    'the host label "$label" exceeds the maximum length of 63 characters',
              );
            }
            host = '$label.$authority';
          }
        }
        if (input.key != null) {
          paths.add(Uri.encodeComponent(input.key!).replaceAll('%2F', '/'));
        }
        return '${endpoint.scheme}://$host/${paths.join('/')}';
      };
    },
  ]);
}
