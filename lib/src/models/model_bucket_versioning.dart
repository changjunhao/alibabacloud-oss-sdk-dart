import 'model_shared.dart';
import 'model_types.dart';
import 'model_bucket_basic.dart';

/// Specifies the encoding method to use
enum EncodeType {
  url('url');

  const EncodeType(this.value);

  /// The serialized string value of this enum item.
  final String value;
}

/// The container that stores the versioning state of the bucket.
class VersioningConfiguration {
  /// The versioning state of the bucket.
  /// See BucketVersioningStatusType for supported values.
  final String? status;

  /// Creates a VersioningConfiguration instance.
  const VersioningConfiguration({this.status});

  /// Creates a VersioningConfiguration from JSON
  factory VersioningConfiguration.fromJson(Map<String, dynamic> json) {
    return VersioningConfiguration(status: json['Status'] as String?);
  }

  /// Converts VersioningConfiguration to JSON
  Map<String, dynamic> toJson() {
    return {'Status': status};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VersioningConfiguration && other.status == status;
  }

  @override
  /// Returns the `hashCode` value.
  int get hashCode => status.hashCode;

  @override
  String toString() {
    return 'VersioningConfiguration(status: $status)';
  }
}

/// The container that stores delete markers.
class DeleteMarkerEntry {
  /// The time when the object was last modified.
  DateTime? lastModified;

  /// The container that stores the information about the bucket owner.
  Owner? owner;

  /// The name of the object.
  String? key;

  /// The version ID of the object.
  String? versionId;

  /// Indicates whether the version is the current version. Valid values: true: The version is the current version. false: The version is a previous version.
  bool? isLatest;

  /// Creates a DeleteMarkerEntry instance.
  DeleteMarkerEntry({
    this.lastModified,
    this.owner,
    this.key,
    this.versionId,
    this.isLatest,
  });

  /// Creates a DeleteMarkerEntry from JSON
  factory DeleteMarkerEntry.fromJson(Map<String, dynamic> json) {
    return DeleteMarkerEntry(
      lastModified: json['LastModified'] != null
          ? DateTime.parse(json['LastModified'] as String)
          : null,
      owner: json['Owner'] != null
          ? Owner.fromJson(json['Owner'] as Map<String, dynamic>)
          : null,
      key: json['Key'] as String?,
      versionId: json['VersionId'] as String?,
      isLatest: json['IsLatest'] as bool?,
    );
  }

  /// Converts DeleteMarkerEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'LastModified': lastModified?.toIso8601String(),
      'Owner': owner?.toJson(),
      'Key': key,
      'VersionId': versionId,
      'IsLatest': isLatest,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteMarkerEntry &&
        other.lastModified == lastModified &&
        other.owner == owner &&
        other.key == key &&
        other.versionId == versionId &&
        other.isLatest == isLatest;
  }

  @override
  /// Returns the `hashCode` value.
  int get hashCode {
    return Object.hash(lastModified, owner, key, versionId, isLatest);
  }

  @override
  String toString() {
    return 'DeleteMarkerEntry(lastModified: $lastModified, owner: $owner, key: $key, versionId: $versionId, isLatest: $isLatest)';
  }
}

/// The container that stores the versions of objects, excluding delete markers.
class ObjectVersion {
  /// The name of the object.
  String? key;

  /// Indicates whether the version is the current version. Valid values: true: The version is the current version. false: The version is a previous version.
  bool? isLatest;

  /// The storage class of the object.
  /// See StorageClassType for supported values.
  String? storageClass;

  /// The time when the Object version is transitioned to cold archive or deep cold archive storage class by the lifecycle.
  DateTime? transitionTime;

  /// The version ID of the object.
  String? versionId;

  /// The time when the object was last modified.
  DateTime? lastModified;

  /// The ETag that is generated when an object is created. ETags are used to identify the content of objects. If an object is created by calling the PutObject operation, the ETag of the object is the MD5 hash of the object content. If an object is created by using another method, the ETag is not the MD5 hash of the object content but a unique value that is calculated based on a specific rule. The ETag of an object can be used only to check whether the object content is modified. However, we recommend that you use the MD5 hash of an object rather than the ETag of the object to verify data integrity.
  String? eTag;

  /// The size of the object. Unit: bytes.
  int? size;

  /// The container that stores the information about the bucket owner.
  Owner? owner;

  /// Restore info of the object.
  String? restoreInfo;

  /// Creates a ObjectVersion instance.
  ObjectVersion({
    this.key,
    this.isLatest,
    this.storageClass,
    this.transitionTime,
    this.versionId,
    this.lastModified,
    this.eTag,
    this.size,
    this.owner,
    this.restoreInfo,
  });

  /// Creates an ObjectVersion from JSON
  factory ObjectVersion.fromJson(Map<String, dynamic> json) {
    return ObjectVersion(
      key: json['Key'] as String?,
      isLatest: json['IsLatest'] as bool?,
      storageClass: json['StorageClass'] as String?,
      transitionTime: json['TransitionTime'] != null
          ? DateTime.parse(json['TransitionTime'] as String)
          : null,
      versionId: json['VersionId'] as String?,
      lastModified: json['LastModified'] != null
          ? DateTime.parse(json['LastModified'] as String)
          : null,
      eTag: json['ETag'] as String?,
      size: json['Size'] as int?,
      owner: json['Owner'] != null
          ? Owner.fromJson(json['Owner'] as Map<String, dynamic>)
          : null,
      restoreInfo: json['RestoreInfo'] as String?,
    );
  }

  /// Converts ObjectVersion to JSON
  Map<String, dynamic> toJson() {
    return {
      'Key': key,
      'IsLatest': isLatest,
      'StorageClass': storageClass,
      'TransitionTime': transitionTime?.toIso8601String(),
      'VersionId': versionId,
      'LastModified': lastModified?.toIso8601String(),
      'ETag': eTag,
      'Size': size,
      'Owner': owner?.toJson(),
      'RestoreInfo': restoreInfo,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ObjectVersion &&
        other.key == key &&
        other.isLatest == isLatest &&
        other.storageClass == storageClass &&
        other.transitionTime == transitionTime &&
        other.versionId == versionId &&
        other.lastModified == lastModified &&
        other.eTag == eTag &&
        other.size == size &&
        other.owner == owner &&
        other.restoreInfo == restoreInfo;
  }

  @override
  /// Returns the `hashCode` value.
  int get hashCode {
    return Object.hash(
      key,
      isLatest,
      storageClass,
      transitionTime,
      versionId,
      lastModified,
      eTag,
      size,
      owner,
      restoreInfo,
    );
  }

  @override
  String toString() {
    return 'ObjectVersion(key: $key, isLatest: $isLatest, storageClass: $storageClass, transitionTime: $transitionTime, versionId: $versionId, lastModified: $lastModified, eTag: $eTag, size: $size, owner: $owner, restoreInfo: $restoreInfo)';
  }
}

/// The request for the PutBucketVersioning operation.
class PutBucketVersioningRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  final String? bucket;

  /// The container of the request body.
  final VersioningConfiguration? versioningConfiguration;

  /// Creates a PutBucketVersioningRequest instance.
  PutBucketVersioningRequest({
    this.bucket,
    this.versioningConfiguration,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutBucketVersioningRequest from JSON
  factory PutBucketVersioningRequest.fromJson(Map<String, dynamic> json) {
    return PutBucketVersioningRequest(
      bucket: json['bucket'] as String?,
      versioningConfiguration: json['versioningConfiguration'] != null
          ? VersioningConfiguration.fromJson(
              json['versioningConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts PutBucketVersioningRequest to JSON
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'versioningConfiguration': versioningConfiguration?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PutBucketVersioningRequest &&
        other.bucket == bucket &&
        other.versioningConfiguration == versioningConfiguration;
  }

  @override
  /// Returns the `hashCode` value.
  int get hashCode {
    return Object.hash(bucket, versioningConfiguration);
  }

  @override
  String toString() {
    return 'PutBucketVersioningRequest(bucket: $bucket, versioningConfiguration: $versioningConfiguration)';
  }
}

/// The result for the PutBucketVersioning operation.
class PutBucketVersioningResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a PutBucketVersioningResult instance.
  PutBucketVersioningResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutBucketVersioningResult from JSON
  factory PutBucketVersioningResult.fromJson(Map<String, dynamic> json) {
    return PutBucketVersioningResult();
  }

  /// Converts PutBucketVersioningResult to JSON
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PutBucketVersioningResult;
  }

  @override
  /// Returns the `hashCode` value.
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PutBucketVersioningResult()';
  }
}

/// The request for the GetBucketVersioning operation.
class GetBucketVersioningRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  final String? bucket;

  /// Creates a GetBucketVersioningRequest instance.
  GetBucketVersioningRequest({this.bucket, RequestModelProp? commonProp})
    : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetBucketVersioningRequest from JSON
  factory GetBucketVersioningRequest.fromJson(Map<String, dynamic> json) {
    return GetBucketVersioningRequest(bucket: json['bucket'] as String?);
  }

  /// Converts GetBucketVersioningRequest to JSON
  Map<String, dynamic> toJson() {
    return {'bucket': bucket};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetBucketVersioningRequest && other.bucket == bucket;
  }

  @override
  /// Returns the `hashCode` value.
  int get hashCode => bucket.hashCode;

  @override
  String toString() {
    return 'GetBucketVersioningRequest(bucket: $bucket)';
  }
}

/// The result for the GetBucketVersioning operation.
class GetBucketVersioningResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The container that stores the versioning state of the bucket.
  VersioningConfiguration? versioningConfiguration;

  /// Creates a GetBucketVersioningResult instance.
  GetBucketVersioningResult({
    this.versioningConfiguration,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetBucketVersioningResult from JSON
  factory GetBucketVersioningResult.fromJson(Map<String, dynamic> json) {
    return GetBucketVersioningResult(
      versioningConfiguration: json['versioningConfiguration'] != null
          ? VersioningConfiguration.fromJson(
              json['versioningConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts GetBucketVersioningResult to JSON
  Map<String, dynamic> toJson() {
    return {'versioningConfiguration': versioningConfiguration?.toJson()};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetBucketVersioningResult &&
        other.versioningConfiguration == versioningConfiguration;
  }

  @override
  /// Returns the `hashCode` value.
  int get hashCode => versioningConfiguration.hashCode;

  @override
  String toString() {
    return 'GetBucketVersioningResult(versioningConfiguration: $versioningConfiguration)';
  }
}

/// The request for the ListObjectVersions operation.
class ListObjectVersionsRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  final String? bucket;

  /// The character that is used to group objects by name. If you specify prefix and delimiter in the request, the response contains CommonPrefixes. The objects whose name contains the same string from the prefix to the next occurrence of the delimiter are grouped as a single result element in CommonPrefixes. If you specify prefix and set delimiter to a forward slash (/), only the objects in the directory are listed. The subdirectories in the directory are returned in CommonPrefixes. Objects and subdirectories in the subdirectories are not listed.By default, this parameter is left empty.
  final String? delimiter;

  /// The name of the object after which the GetBucketVersions (ListObjectVersions) operation begins. If this parameter is specified, objects whose name is alphabetically after the value of key-marker are returned. Use key-marker and version-id-marker in combination. The value of key-marker must be less than 1,024 bytes in length.By default, this parameter is left empty.  You must also specify key-marker if you specify version-id-marker.
  final String? keyMarker;

  /// The version ID of the object specified in key-marker after which the GetBucketVersions (ListObjectVersions) operation begins. The versions are returned from the latest version to the earliest version. If version-id-marker is not specified, the GetBucketVersions (ListObjectVersions) operation starts from the latest version of the object whose name is alphabetically after the value of key-marker by default.By default, this parameter is left empty.Valid values: version IDs.
  final String? versionIdMarker;

  /// The maximum number of objects to be returned. If the number of returned objects exceeds the value of max-keys, the response contains `NextKeyMarker` and `NextVersionIdMarker`. Specify the values of `NextKeyMarker` and `NextVersionIdMarker` as the markers for the next request. Valid values: 1 to 999. Default value: 100.
  final int? maxKeys;

  /// The prefix that the names of returned objects must contain.*   The value of prefix must be less than 1,024 bytes in length.*   If you specify prefix, the names of the returned objects contain the prefix.If you set prefix to a directory name, the objects whose name starts with the prefix are listed. The returned objects consist of all objects and subdirectories in the directory.By default, this parameter is left empty.
  final String? prefix;

  /// The encoding type of the content in the response. By default, this parameter is left empty. Set the value to URL.  The values of Delimiter, Marker, Prefix, NextMarker, and Key are UTF-8 encoded. If the value of Delimiter, Marker, Prefix, NextMarker, or Key contains a control character that is not supported by Extensible Markup Language (XML) 1.0, you can specify encoding-type to encode the value in the response.
  /// Sees EncodeType for supported values.
  final String? encodingType;

  /// Creates a ListObjectVersionsRequest instance.
  ListObjectVersionsRequest({
    this.bucket,
    this.delimiter,
    this.keyMarker,
    this.versionIdMarker,
    this.maxKeys,
    this.prefix,
    this.encodingType,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a ListObjectVersionsRequest from JSON
  factory ListObjectVersionsRequest.fromJson(Map<String, dynamic> json) {
    return ListObjectVersionsRequest(
      bucket: json['bucket'] as String?,
      delimiter: json['delimiter'] as String?,
      keyMarker: json['keyMarker'] as String?,
      versionIdMarker: json['versionIdMarker'] as String?,
      maxKeys: json['maxKeys'] as int?,
      prefix: json['prefix'] as String?,
      encodingType: json['encodingType'] as String?,
    );
  }

  /// Converts ListObjectVersionsRequest to JSON
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'delimiter': delimiter,
      'keyMarker': keyMarker,
      'versionIdMarker': versionIdMarker,
      'maxKeys': maxKeys,
      'prefix': prefix,
      'encodingType': encodingType,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListObjectVersionsRequest &&
        other.bucket == bucket &&
        other.delimiter == delimiter &&
        other.keyMarker == keyMarker &&
        other.versionIdMarker == versionIdMarker &&
        other.maxKeys == maxKeys &&
        other.prefix == prefix &&
        other.encodingType == encodingType;
  }

  @override
  /// Returns the `hashCode` value.
  int get hashCode {
    return Object.hash(
      bucket,
      delimiter,
      keyMarker,
      versionIdMarker,
      maxKeys,
      prefix,
      encodingType,
    );
  }

  @override
  String toString() {
    return 'ListObjectVersionsRequest(bucket: $bucket, delimiter: $delimiter, keyMarker: $keyMarker, versionIdMarker: $versionIdMarker, maxKeys: $maxKeys, prefix: $prefix, encodingType: $encodingType)';
  }
}

/// The result for the ListObjectVersions operation.
class ListObjectVersionsResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// If not all results are returned for the request, the NextKeyMarker parameter is included in the response to indicate the key-marker value of the next ListObjectVersions (GetBucketVersions) request.
  String? nextKeyMarker;

  /// If not all results are returned for the request, the NextVersionIdMarker parameter is included in the response to indicate the version-id-marker value of the next ListObjectVersions (GetBucketVersions) request.
  String? nextVersionIdMarker;

  /// The container that stores the versions of objects except for delete markers
  List<ObjectVersion>? versions;

  /// The encoding type of the content in the response. If you specify encoding-type in the request, the values of Delimiter, Marker, Prefix, NextMarker, and Key are encoded in the response.
  String? encodingType;

  /// The bucket name
  String? name;

  /// The prefix contained in the names of the returned objects.
  String? prefix;

  /// Indicates the object from which the ListObjectVersions (GetBucketVersions) operation starts.
  String? keyMarker;

  /// The version from which the ListObjectVersions (GetBucketVersions) operation starts. This parameter is used together with KeyMarker.
  String? versionIdMarker;

  /// The maximum number of objects that can be returned in the response.
  int? maxKeys;

  /// The character that is used to group objects by name. The objects whose names contain the same string from the prefix to the next occurrence of the delimiter are grouped as a single result parameter in CommonPrefixes.
  String? delimiter;

  /// Indicates whether the returned results are truncated.- true: indicates that not all results are returned for the request.- false: indicates that all results are returned for the request.
  bool? isTruncated;

  /// The container that stores delete markers
  List<DeleteMarkerEntry>? deleteMarkers;

  /// Objects whose names contain the same string that ranges from the prefix to the next occurrence of the delimiter are grouped as a single result element
  List<CommonPrefix>? commonPrefixes;

  /// Creates a ListObjectVersionsResult instance.
  ListObjectVersionsResult({
    this.nextKeyMarker,
    this.nextVersionIdMarker,
    this.versions,
    this.encodingType,
    this.name,
    this.prefix,
    this.keyMarker,
    this.versionIdMarker,
    this.maxKeys,
    this.delimiter,
    this.isTruncated,
    this.deleteMarkers,
    this.commonPrefixes,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a ListObjectVersionsResult from JSON
  factory ListObjectVersionsResult.fromJson(Map<String, dynamic> json) {
    return ListObjectVersionsResult(
      nextKeyMarker: json['nextKeyMarker'] as String?,
      nextVersionIdMarker: json['nextVersionIdMarker'] as String?,
      versions: json['versions'] != null
          ? (json['versions'] as List)
                .map((e) => ObjectVersion.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      encodingType: json['encodingType'] as String?,
      name: json['name'] as String?,
      prefix: json['prefix'] as String?,
      keyMarker: json['keyMarker'] as String?,
      versionIdMarker: json['versionIdMarker'] as String?,
      maxKeys: json['maxKeys'] as int?,
      delimiter: json['delimiter'] as String?,
      isTruncated: json['isTruncated'] as bool?,
      deleteMarkers: json['deleteMarkers'] != null
          ? (json['deleteMarkers'] as List)
                .map(
                  (e) => DeleteMarkerEntry.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      commonPrefixes: json['commonPrefixes'] != null
          ? (json['commonPrefixes'] as List)
                .map((e) => CommonPrefix.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  /// Converts ListObjectVersionsResult to JSON
  Map<String, dynamic> toJson() {
    return {
      'nextKeyMarker': nextKeyMarker,
      'nextVersionIdMarker': nextVersionIdMarker,
      'versions': versions?.map((e) => e.toJson()).toList(),
      'encodingType': encodingType,
      'name': name,
      'prefix': prefix,
      'keyMarker': keyMarker,
      'versionIdMarker': versionIdMarker,
      'maxKeys': maxKeys,
      'delimiter': delimiter,
      'isTruncated': isTruncated,
      'deleteMarkers': deleteMarkers?.map((e) => e.toJson()).toList(),
      'commonPrefixes': commonPrefixes?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListObjectVersionsResult &&
        other.nextKeyMarker == nextKeyMarker &&
        other.nextVersionIdMarker == nextVersionIdMarker &&
        _listEquals(other.versions, versions) &&
        other.encodingType == encodingType &&
        other.name == name &&
        other.prefix == prefix &&
        other.keyMarker == keyMarker &&
        other.versionIdMarker == versionIdMarker &&
        other.maxKeys == maxKeys &&
        other.delimiter == delimiter &&
        other.isTruncated == isTruncated &&
        _listEquals(other.deleteMarkers, deleteMarkers) &&
        _listEquals(other.commonPrefixes, commonPrefixes);
  }

  @override
  /// Returns the `hashCode` value.
  int get hashCode {
    return Object.hash(
      nextKeyMarker,
      nextVersionIdMarker,
      versions,
      encodingType,
      name,
      prefix,
      keyMarker,
      versionIdMarker,
      maxKeys,
      delimiter,
      isTruncated,
      deleteMarkers,
      commonPrefixes,
    );
  }

  @override
  String toString() {
    return 'ListObjectVersionsResult(nextKeyMarker: $nextKeyMarker, nextVersionIdMarker: $nextVersionIdMarker, versions: $versions, encodingType: $encodingType, name: $name, prefix: $prefix, keyMarker: $keyMarker, versionIdMarker: $versionIdMarker, maxKeys: $maxKeys, delimiter: $delimiter, isTruncated: $isTruncated, deleteMarkers: $deleteMarkers, commonPrefixes: $commonPrefixes)';
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
