import 'model_types.dart';
import 'model_shared.dart';
import '../transform/serde_extensions.dart';

/// The container that stores the information about the bucket.
class BucketSummary {
  /// The time when the bucket was created. Format: `yyyy-mm-ddThh:mm:ss.timezone`.
  DateTime? creationDate;

  /// The public endpoint of the region in which the bucket resides.
  String? extranetEndpoint;

  /// The internal endpoint of the region in which the bucket you access from ECS instances resides. The bucket and ECS instances are in the same region.
  String? intranetEndpoint;

  /// The data center in which the bucket is located.
  String? location;

  /// The name of the bucket.
  String? name;

  /// The storage class of the bucket. Valid values: Standard, IA, Archive, and ColdArchive.
  /// Sees StorageClassType for supported values.
  String? storageClass;

  /// The region in which the bucket is located.
  String? region;

  BucketSummary({
    this.creationDate,
    this.extranetEndpoint,
    this.intranetEndpoint,
    this.location,
    this.name,
    this.storageClass,
    this.region,
  });

  /// Creates a BucketSummary instance from a JSON map
  factory BucketSummary.fromJson(Map<String, dynamic> json) {
    return BucketSummary(
      creationDate: (json['CreationDate'] as String?)?.toDate(),
      extranetEndpoint: json['ExtranetEndpoint'] as String?,
      intranetEndpoint: json['IntranetEndpoint'] as String?,
      location: json['Location'] as String?,
      name: json['Name'] as String?,
      storageClass: json['StorageClass'] as String?,
      region: json['Region'] as String?,
    );
  }

  /// Converts the BucketSummary instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'CreationDate': creationDate?.toIso8601String(),
      'ExtranetEndpoint': extranetEndpoint,
      'IntranetEndpoint': intranetEndpoint,
      'Location': location,
      'Name': name,
      'StorageClass': storageClass,
      'Region': region,
    };
  }
}

/// The request for the ListBuckets operation.
class ListBucketsRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The ID of the resource group to which the bucket belongs.
  String? resourceGroupId;

  /// The prefix that the names of returned buckets must contain. If this parameter is not specified, prefixes are not used to filter returned buckets. By default, this parameter is left empty.
  String? prefix;

  /// The name of the bucket from which the buckets start to return. The buckets whose names are alphabetically after the value of marker are returned. If this parameter is not specified, all results are returned. By default, this parameter is left empty.
  String? marker;

  /// The maximum number of buckets that can be returned. Valid values: 1 to 1000. Default value: 100
  int? maxKeys;

  ListBucketsRequest({
    this.resourceGroupId,
    this.prefix,
    this.marker,
    this.maxKeys,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a ListBucketsRequest instance from a JSON map
  factory ListBucketsRequest.fromJson(Map<String, dynamic> json) {
    return ListBucketsRequest(
      resourceGroupId: json['resourceGroupId'] as String?,
      prefix: json['prefix'] as String?,
      marker: json['marker'] as String?,
      maxKeys: json['maxKeys'] as int?,
    );
  }

  /// Converts the ListBucketsRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'resourceGroupId': resourceGroupId,
      'prefix': prefix,
      'marker': marker,
      'maxKeys': maxKeys,
    };
  }
}

/// The result for the ListBuckets operation.
class ListBucketsResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The maximum number of buckets that can be returned.
  int? maxKeys;

  /// Indicates whether all results are returned. Valid values:- true: All results are not returned in the response. - false: All results are returned in the response.
  bool? isTruncated;

  /// The marker for the next ListBuckets (GetService) request. You can use the value of this parameter as the value of marker in the next ListBuckets (GetService) request to retrieve the unreturned results.
  String? nextMarker;

  /// The container that stores the information about multiple buckets.
  List<BucketSummary>? buckets;

  /// The container that stores the information about the bucket owner.
  Owner? owner;

  /// The prefix contained in the names of returned buckets.
  String? prefix;

  /// The name of the bucket from which the buckets are returned.
  String? marker;

  ListBucketsResult({
    this.maxKeys,
    this.isTruncated,
    this.nextMarker,
    this.buckets,
    this.owner,
    this.prefix,
    this.marker,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a ListBucketsResult instance from a JSON map
  factory ListBucketsResult.fromJson(Map<String, dynamic> json) {
    return ListBucketsResult(
      maxKeys: json['maxKeys'] as int?,
      isTruncated: json['isTruncated'] as bool?,
      nextMarker: json['nextMarker'] as String?,
      buckets: (json['buckets'] as List<dynamic>?)
          ?.map((e) => BucketSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      owner: json['owner'] != null
          ? Owner.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      prefix: json['prefix'] as String?,
      marker: json['marker'] as String?,
    );
  }

  /// Converts the ListBucketsResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'maxKeys': maxKeys,
      'isTruncated': isTruncated,
      'nextMarker': nextMarker,
      'buckets': buckets?.map((e) => e.toJson()).toList(),
      'owner': owner?.toJson(),
      'prefix': prefix,
      'marker': marker,
    };
  }
}
