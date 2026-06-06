import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../models/model_service.dart';
import '../models/model_shared.dart';
import 'serde_functions.dart';
import 'serde_extensions.dart';

/// Serialization and deserialization for service operations
class SerdeService {
  /// Creates a SerdeService instance.
  SerdeService();

  // MARK: - ListBuckets

  /// Serialize ListBuckets request
  static Future<void> serializeListBuckets(
    ListBucketsRequest request,
    OperationInput input,
  ) async {
    if (request.resourceGroupId != null) {
      input.headers['x-oss-resource-group-id'] = request.resourceGroupId!;
    }

    if (request.prefix != null) {
      input.parameters['prefix'] = request.prefix!;
    }

    if (request.marker != null) {
      input.parameters['marker'] = request.marker!;
    }

    if (request.maxKeys != null) {
      input.parameters['max-keys'] = request.maxKeys.toString();
    }
  }

  /// Deserialize ListBuckets result
  static Future<void> deserializeListBuckets(
    ListBucketsResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'ListAllMyBucketsResult',
    );

    result.prefix = body['Prefix'] as String?;
    result.marker = body['Marker'] as String?;
    result.nextMarker = body['NextMarker'] as String?;
    result.maxKeys = (body['MaxKeys'] as String?)?.toInt();
    result.isTruncated = (body['IsTruncated'] as String?)?.toBool();

    // Handle Owner
    final ownerData = body['Owner'];
    if (ownerData is Map<String, dynamic>) {
      result.owner = Owner(
        displayName: ownerData['DisplayName'] as String?,
        id: ownerData['ID'] as String?,
      );
    }

    // Handle Buckets
    final bucketContents = body['Buckets'];
    if (bucketContents is Map<String, dynamic>) {
      final contents = bucketContents['Bucket'];
      if (contents != null) {
        final buckets = <BucketSummary>[];

        List<Map<String, dynamic>> responseBuckets = [];
        if (contents is List) {
          for (final content in contents) {
            if (content is Map<String, dynamic>) {
              responseBuckets.add(content);
            }
          }
        } else if (contents is Map<String, dynamic>) {
          responseBuckets.add(contents);
        }

        for (final responseBucket in responseBuckets) {
          final bucket = BucketSummary(
            name: responseBucket['Name'] as String?,
            location: responseBucket['Location'] as String?,
            extranetEndpoint: responseBucket['ExtranetEndpoint'] as String?,
            intranetEndpoint: responseBucket['IntranetEndpoint'] as String?,
            region: responseBucket['Region'] as String?,
            storageClass: responseBucket['StorageClass'] as String?,
            creationDate: (responseBucket['CreationDate'] as String?)?.toDate(),
          );
          buckets.add(bucket);
        }
        result.buckets = buckets;
      }
    }
  }
}
