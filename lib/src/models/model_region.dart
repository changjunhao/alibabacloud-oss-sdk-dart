import 'model_types.dart';

/// The information about the region.
class RegionInfo {
  /// The region ID.
  String? region;

  /// The public endpoint of the region.
  String? internetEndpoint;

  /// The internal endpoint of the region.
  String? internalEndpoint;

  /// The acceleration endpoint of the region. The value is always oss-accelerate.aliyuncs.com.
  String? accelerateEndpoint;

  RegionInfo({
    this.region,
    this.internetEndpoint,
    this.internalEndpoint,
    this.accelerateEndpoint,
  });

  /// Creates a RegionInfo instance from a JSON map
  factory RegionInfo.fromJson(Map<String, dynamic> json) {
    return RegionInfo(
      region: json['region'] as String?,
      internetEndpoint: json['internetEndpoint'] as String?,
      internalEndpoint: json['internalEndpoint'] as String?,
      accelerateEndpoint: json['accelerateEndpoint'] as String?,
    );
  }

  /// Converts the RegionInfo instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'internetEndpoint': internetEndpoint,
      'internalEndpoint': internalEndpoint,
      'accelerateEndpoint': accelerateEndpoint,
    };
  }
}

/// The information about the regions.
class RegionInfoList {
  /// The information about the regions.
  List<RegionInfo>? regionInfos;

  RegionInfoList({this.regionInfos});

  /// Creates a RegionInfoList instance from a JSON map
  factory RegionInfoList.fromJson(Map<String, dynamic> json) {
    return RegionInfoList(
      regionInfos: (json['regionInfos'] as List<dynamic>?)
          ?.map((e) => RegionInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts the RegionInfoList instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'regionInfos': regionInfos?.map((e) => e.toJson()).toList()};
  }
}

/// The request for the DescribeRegions operation.
class DescribeRegionsRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The region ID of the request.
  String? regions;

  DescribeRegionsRequest({this.regions, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a DescribeRegionsRequest instance from a JSON map
  factory DescribeRegionsRequest.fromJson(Map<String, dynamic> json) {
    return DescribeRegionsRequest(regions: json['regions'] as String?);
  }

  /// Converts the DescribeRegionsRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'regions': regions};
  }
}

/// The result for the DescribeRegions operation.
class DescribeRegionsResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The information about the regions.
  RegionInfoList? regionInfoList;

  DescribeRegionsResult({this.regionInfoList, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a DescribeRegionsResult instance from a JSON map
  factory DescribeRegionsResult.fromJson(Map<String, dynamic> json) {
    return DescribeRegionsResult(
      regionInfoList: json['regionInfoList'] != null
          ? RegionInfoList.fromJson(
              json['regionInfoList'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the DescribeRegionsResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'regionInfoList': regionInfoList?.toJson()};
  }
}
