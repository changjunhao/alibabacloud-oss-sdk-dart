import '../types/operation_input.dart';
import '../types/operation_output.dart';
import '../models/model_region.dart';
import 'serde_functions.dart';

/// Serialization and deserialization for region operations
class SerdeRegion {
  // MARK: - DescribeRegions

  /// Serialize DescribeRegions request
  static Future<void> serializeDescribeRegions(
    DescribeRegionsRequest request,
    OperationInput input,
  ) async {
    if (request.regions != null) {
      input.parameters['regions'] = request.regions!;
    }
  }

  /// Deserialize DescribeRegions result
  static Future<void> deserializeDescribeRegions(
    DescribeRegionsResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'RegionInfoList',
    );

    // Handle RegionInfo - can be either a list or a single object
    final regionInfoData = body['RegionInfo'];
    final regionInfos = <RegionInfo>[];

    if (regionInfoData != null) {
      List<Map<String, dynamic>> responseRegions = [];

      if (regionInfoData is List) {
        for (final region in regionInfoData) {
          if (region is Map<String, dynamic>) {
            responseRegions.add(region);
          }
        }
      } else if (regionInfoData is Map<String, dynamic>) {
        responseRegions.add(regionInfoData);
      }

      for (final responseRegion in responseRegions) {
        final regionInfo = RegionInfo(
          region: responseRegion['Region'] as String?,
          accelerateEndpoint: responseRegion['AccelerateEndpoint'] as String?,
          internalEndpoint: responseRegion['InternalEndpoint'] as String?,
          internetEndpoint: responseRegion['InternetEndpoint'] as String?,
        );
        regionInfos.add(regionInfo);
      }
    }

    result.regionInfoList = RegionInfoList(regionInfos: regionInfos);
  }
}
