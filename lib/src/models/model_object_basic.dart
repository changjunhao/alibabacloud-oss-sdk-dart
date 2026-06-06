import '../types/byte_stream.dart';
import '../progress.dart';
import 'model_types.dart';
import '../transform/serde_extensions.dart';

/// The container that stores the restoration priority configuration. This configuration takes effect only when the request is sent to restore Cold Archive objects. If you do not specify the JobParameters parameter, the default restoration priority Standard is used.
class JobParameters {
  /// The restoration priority. Valid values:
  /// * Expedited: The object is restored within 1 hour.
  /// * Standard: The object is restored within 2 to 5 hours.
  /// * Bulk: The object is restored within 5 to 12 hours.
  String? tier;

  JobParameters({this.tier});

  /// Creates a JobParameters instance from a JSON map
  factory JobParameters.fromJson(Map<String, dynamic> json) {
    return JobParameters(tier: json['tier'] as String?);
  }

  /// Converts the JobParameters instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'tier': tier};
  }
}

/// The container that stores information about the RestoreObject request.
class RestoreRequest {
  /// The duration in which the object can remain in the restored state. Unit: days. Valid values: 1 to 7.
  int? days;

  /// The container that stores the restoration priority configuration. This configuration takes effect only when the request is sent to restore Cold Archive objects. If you do not specify the JobParameters parameter, the default restoration priority Standard is used.
  JobParameters? jobParameters;

  RestoreRequest({this.days, this.jobParameters});

  /// Creates a RestoreRequest instance from a JSON map
  factory RestoreRequest.fromJson(Map<String, dynamic> json) {
    return RestoreRequest(
      days: json['days'] as int?,
      jobParameters: json['jobParameters'] != null
          ? JobParameters.fromJson(
              json['jobParameters'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the RestoreRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'days': days, 'jobParameters': jobParameters?.toJson()};
  }
}

class DeleteObject {
  /// The name of the object that you want to delete.
  String? key;

  /// The version ID of the object that you want to delete.
  String? versionId;

  DeleteObject({this.key, this.versionId});

  /// Creates a DeleteObject instance from a JSON map
  factory DeleteObject.fromJson(Map<String, dynamic> json) {
    return DeleteObject(
      key: json['key'] as String?,
      versionId: json['versionId'] as String?,
    );
  }

  /// Converts the DeleteObject instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'key': key, 'versionId': versionId};
  }
}

class DeletedInfo {
  /// The name of the deleted object.
  String? key;

  /// The version ID of the object that you deleted.
  String? versionId;

  /// Indicates whether the deleted version is a delete marker.
  bool? deleteMarker;

  /// The version ID of the delete marker.
  String? deleteMarkerVersionId;

  DeletedInfo({
    this.key,
    this.versionId,
    this.deleteMarker,
    this.deleteMarkerVersionId,
  });

  /// Creates a DeletedInfo instance from a JSON map
  factory DeletedInfo.fromJson(Map<String, dynamic> json) {
    return DeletedInfo(
      key: json['key'] as String?,
      versionId: json['versionId'] as String?,
      deleteMarker: json['deleteMarker'] as bool?,
      deleteMarkerVersionId: json['deleteMarkerVersionId'] as String?,
    );
  }

  /// Converts the DeletedInfo instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'versionId': versionId,
      'deleteMarker': deleteMarker,
      'deleteMarkerVersionId': deleteMarkerVersionId,
    };
  }
}

/// The request for the PutObject operation.
class PutObjectRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// Specifies whether the object that is uploaded by calling the PutObject operation overwrites the existing object that has the same name.  When versioning is enabled or suspended for the bucket to which you want to upload the object, the **x-oss-forbid-overwrite** header does not take effect. In this case, the object that is uploaded by calling the PutObject operation overwrites the existing object that has the same name.
  ///   - If you do not specify the **x-oss-forbid-overwrite** header or set the **x-oss-forbid-overwrite** header to **false**, the object that is uploaded by calling the PutObject operation overwrites the existing object that has the same name.
  ///   - If the value of **x-oss-forbid-overwrite** is set to **true**, existing objects cannot be overwritten by objects that have the same names. If you specify the **x-oss-forbid-overwrite** request header, the queries per second (QPS) performance of OSS is degraded. If you want to use the **x-oss-forbid-overwrite** request header to perform a large number of operations (QPS greater than 1,000), contact technical support. Default value: **false**.
  bool? forbidOverwrite;

  /// The method that is used to encrypt the object on the OSS server when the object is created. Valid values: **AES256**, **KMS**, and **SM4****.If you specify the header, the header is returned in the response. OSS uses the method that is specified by this header to encrypt the uploaded object. When you download the encrypted object, the **x-oss-server-side-encryption** header is included in the response and the header value is set to the algorithm that is used to encrypt the object.
  String? serverSideEncryption;

  /// The encryption method on the server side when an object is created. Valid values: **AES256**, **KMS**, and **SM4**.
  /// If you specify the header, the header is returned in the response. OSS uses the method that is specified by this header to encrypt the uploaded object. When you download the encrypted object, the **x-oss-server-side-encryption** header is included in the response and the header value is set to the algorithm that is used to encrypt the object.
  String? serverSideDataEncryption;

  /// The ID of the customer master key (CMK) managed by Key Management Service (KMS). This header is valid only when the **x-oss-server-side-encryption** header is set to KMS.
  String? serverSideEncryptionKeyId;

  /// The access control list (ACL) of the object. Default value: default. Valid values:- default: The ACL of the object is the same as that of the bucket in which the object is stored.
  ///  - private: The ACL of the object is private. Only the owner of the object and authorized users can read and write this object.
  ///  - public-read: The ACL of the object is public-read. Only the owner of the object and authorized users can read and write this object. Other users can only read the object. Exercise caution when you set the object ACL to this value.
  ///  - public-read-write: The ACL of the object is public-read-write. All users can read and write this object. Exercise caution when you set the object ACL to this value.
  /// For more information about the ACL, see **[ACL](~~100676~~)**.
  /// Sees ObjectACLType for supported values.
  String? objectAcl;

  /// The storage class of the bucket. Default value: Standard.  Valid values:- Standard- IA- Archive- ColdArchive
  /// Sees StorageClassType for supported values.
  String? storageClass;

  /// The tag of the object. You can configure multiple tags for the object. Example: TagA=A&TagB=B.
  /// The key and value of a tag must be URL-encoded. If a tag does not contain an equal sign (=), the value of the tag is considered an empty string.
  String? tagging;

  /// The caching behavior of the web page when the object is downloaded.
  String? cacheControl;

  /// The name of the object when the object is downloaded.
  String? contentDisposition;

  /// The content encoding format of the object when the object is downloaded.
  String? contentEncoding;

  /// The expiration time of the request.
  String? expires;

  /// The MD5 hash of the object that you want to upload.
  String? contentMd5;

  /// A standard MIME type describing the format of the contents.
  String? contentType;

  /// A callback parameter is a Base64-encoded string that contains multiple fields in the JSON format.
  String? callback;

  /// Configure custom parameters by using the callback-var parameter.
  String? callbackVar;

  /// Specify the speed limit value. The speed limit value ranges from  245760 to 838860800, with a unit of bit/s.
  int? trafficLimit;

  /// Custom metadata for the object.
  Map<String, String>? metadata;

  /// The body of the request.
  ByteStream? body;

  /// Progress delegate for tracking upload progress.
  ProgressDelegate? progress;

  PutObjectRequest({
    this.bucket,
    this.key,
    this.forbidOverwrite,
    this.serverSideEncryption,
    this.serverSideDataEncryption,
    this.serverSideEncryptionKeyId,
    this.objectAcl,
    this.storageClass,
    this.tagging,
    this.cacheControl,
    this.contentDisposition,
    this.contentEncoding,
    this.expires,
    this.contentMd5,
    this.contentType,
    this.callback,
    this.callbackVar,
    this.trafficLimit,
    this.metadata,
    this.body,
    this.progress,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a PutObjectRequest instance from a JSON map
  factory PutObjectRequest.fromJson(Map<String, dynamic> json) {
    return PutObjectRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      forbidOverwrite: json['forbidOverwrite'] as bool?,
      serverSideEncryption: json['serverSideEncryption'] as String?,
      serverSideDataEncryption: json['serverSideDataEncryption'] as String?,
      serverSideEncryptionKeyId: json['serverSideEncryptionKeyId'] as String?,
      objectAcl: json['objectAcl'] as String?,
      storageClass: json['storageClass'] as String?,
      tagging: json['tagging'] as String?,
      cacheControl: json['cacheControl'] as String?,
      contentDisposition: json['contentDisposition'] as String?,
      contentEncoding: json['contentEncoding'] as String?,
      expires: json['expires'] as String?,
      contentMd5: json['contentMd5'] as String?,
      contentType: json['contentType'] as String?,
      callback: json['callback'] as String?,
      callbackVar: json['callbackVar'] as String?,
      trafficLimit: json['trafficLimit'] as int?,
      metadata: json['metadata'] != null
          ? Map<String, String>.from(json['metadata'] as Map)
          : null,
      // Note: body and progress are not serializable from JSON
    );
  }

  /// Converts the PutObjectRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'forbidOverwrite': forbidOverwrite,
      'serverSideEncryption': serverSideEncryption,
      'serverSideDataEncryption': serverSideDataEncryption,
      'serverSideEncryptionKeyId': serverSideEncryptionKeyId,
      'objectAcl': objectAcl,
      'storageClass': storageClass,
      'tagging': tagging,
      'cacheControl': cacheControl,
      'contentDisposition': contentDisposition,
      'contentEncoding': contentEncoding,
      'expires': expires,
      'contentMd5': contentMd5,
      'contentType': contentType,
      'callback': callback,
      'callbackVar': callbackVar,
      'trafficLimit': trafficLimit,
      'metadata': metadata,
      // Note: body and progress are not serializable to JSON
    };
  }
}

/// The result for the PutObject operation.
class PutObjectResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The 64-bit CRC value of the object. This value is calculated based on the ECMA-182 standard.
  int? get hashCrc64ecma {
    final value = commonProp.headers?.getCaseInsensitive(
      'x-oss-hash-crc64ecma',
    );
    return value?.toUInt64();
  }

  /// Version of the object.
  String? get versionId => commonProp.headers?['x-oss-version-id'];

  /// Entity tag for the uploaded object.
  String? get etag => commonProp.headers?['etag'];

  /// Content-Md5 for the uploaded object.
  String? get contentMd5 => commonProp.headers?['content-md5'];

  /// Callback result in json format.
  /// It is valid only when the callback is set.
  String? callbackResult;

  PutObjectResult({this.callbackResult, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a PutObjectResult instance from a JSON map
  factory PutObjectResult.fromJson(Map<String, dynamic> json) {
    return PutObjectResult(callbackResult: json['callbackResult'] as String?);
  }

  /// Converts the PutObjectResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'callbackResult': callbackResult};
  }
}

/// The request for the GetObject operation.
class GetObjectRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The range of data of the object to be returned.
  /// - If the value of Range is valid, OSS returns the response that includes the total size of the object and the range of data returned. For example, Content-Range: bytes 0~9/44 indicates that the total size of the object is 44 bytes, and the range of data returned is the first 10 bytes.
  /// - However, if the value of Range is invalid, the entire object is returned, and the response returned by OSS excludes Content-Range. Default value: null
  String? range;

  /// Specify standard behaviors to download data by range.
  /// If the value is "standard", the download behavior is modified when the specified range is not within the valid range.
  /// For an object whose size is 1,000 bytes:
  /// 1) If you set Range: bytes to 500-2000, the value at the end of the range is invalid. In this case, OSS returns HTTP status code 206 and the data that is within the range of byte 500 to byte 999.
  /// 2) If you set Range: bytes to 1000-2000, the value at the start of the range is invalid. In this case, OSS returns HTTP status code 416 and the InvalidRange error code.
  String? rangeBehavior;

  /// If the time specified in this header is earlier than the object modified time or is invalid, OSS returns the object and 200 OK. If the time specified in this header is later than or the same as the object modified time, OSS returns 304 Not Modified. The time must be in GMT. Example: `Fri, 13 Nov 2015 14:47:53 GMT`.Default value: null
  String? ifModifiedSince;

  /// If the time specified in this header is the same as or later than the object modified time, OSS returns the object and 200 OK. If the time specified in this header is earlier than the object modified time, OSS returns 412 Precondition Failed.                               The time must be in GMT. Example: `Fri, 13 Nov 2015 14:47:53 GMT`.You can specify both the **If-Modified-Since** and **If-Unmodified-Since** headers in a request. Default value: null
  String? ifUnmodifiedSince;

  /// If the ETag specified in the request matches the ETag value of the object, OSS transmits the object and returns 200 OK. If the ETag specified in the request does not match the ETag value of the object, OSS returns 412 Precondition Failed. The ETag value of an object is used to check whether the content of the object has changed. You can check data integrity by using the ETag value. Default value: null
  String? ifMatch;

  /// If the ETag specified in the request does not match the ETag value of the object, OSS transmits the object and returns 200 OK. If the ETag specified in the request matches the ETag value of the object, OSS returns 304 Not Modified. You can specify both the **If-Match** and **If-None-Match** headers in a request. Default value: null
  String? ifNoneMatch;

  /// The encoding type at the client side. If you want an object to be returned in the GZIP format, you must include the Accept-Encoding:gzip header in your request. OSS determines whether to return the object compressed in the GZip format based on the Content-Type header and whether the size of the object is larger than or equal to 1 KB.                                   If an object is compressed in the GZip format, the response OSS returns does not include the ETag value of the object.    - OSS supports the following Content-Type values to compress the object in the GZip format: text/cache-manifest, text/xml, text/plain, text/css, application/javascript, application/x-javascript, application/rss+xml, application/json, and text/json. Default value: null
  String? acceptEncoding;

  /// The content-type header in the response that OSS returns.
  String? responseContentType;

  /// The content-language header in the response that OSS returns.
  String? responseContentLanguage;

  /// The expires header in the response that OSS returns.
  String? responseExpires;

  /// The cache-control header in the response that OSS returns.
  String? responseCacheControl;

  /// The content-disposition header in the response that OSS returns.
  String? responseContentDisposition;

  /// The content-encoding header in the response that OSS returns.
  String? responseContentEncoding;

  /// The version ID of the object that you want to query.
  String? versionId;

  /// Specify the speed limit value. The speed limit value ranges from  245760 to 838860800, with a unit of bit/s.
  int? trafficLimit;

  /// Image processing parameters.
  String? process;

  /// Progress delegate for tracking download progress.
  ProgressDelegate? progress;

  GetObjectRequest({
    this.bucket,
    this.key,
    this.range,
    this.rangeBehavior,
    this.ifModifiedSince,
    this.ifUnmodifiedSince,
    this.ifMatch,
    this.ifNoneMatch,
    this.acceptEncoding,
    this.responseContentType,
    this.responseContentLanguage,
    this.responseExpires,
    this.responseCacheControl,
    this.responseContentDisposition,
    this.responseContentEncoding,
    this.versionId,
    this.trafficLimit,
    this.process,
    this.progress,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetObjectRequest instance from a JSON map
  factory GetObjectRequest.fromJson(Map<String, dynamic> json) {
    return GetObjectRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      range: json['range'] as String?,
      rangeBehavior: json['rangeBehavior'] as String?,
      ifModifiedSince: json['ifModifiedSince'] as String?,
      ifUnmodifiedSince: json['ifUnmodifiedSince'] as String?,
      ifMatch: json['ifMatch'] as String?,
      ifNoneMatch: json['ifNoneMatch'] as String?,
      acceptEncoding: json['acceptEncoding'] as String?,
      responseContentType: json['responseContentType'] as String?,
      responseContentLanguage: json['responseContentLanguage'] as String?,
      responseExpires: json['responseExpires'] as String?,
      responseCacheControl: json['responseCacheControl'] as String?,
      responseContentDisposition: json['responseContentDisposition'] as String?,
      responseContentEncoding: json['responseContentEncoding'] as String?,
      versionId: json['versionId'] as String?,
      trafficLimit: json['trafficLimit'] as int?,
      process: json['process'] as String?,
      // Note: progress is not serializable from JSON
    );
  }

  /// Converts the GetObjectRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'range': range,
      'rangeBehavior': rangeBehavior,
      'ifModifiedSince': ifModifiedSince,
      'ifUnmodifiedSince': ifUnmodifiedSince,
      'ifMatch': ifMatch,
      'ifNoneMatch': ifNoneMatch,
      'acceptEncoding': acceptEncoding,
      'responseContentType': responseContentType,
      'responseContentLanguage': responseContentLanguage,
      'responseExpires': responseExpires,
      'responseCacheControl': responseCacheControl,
      'responseContentDisposition': responseContentDisposition,
      'responseContentEncoding': responseContentEncoding,
      'versionId': versionId,
      'trafficLimit': trafficLimit,
      'process': process,
      // Note: progress is not serializable to JSON
    };
  }
}

/// The request for the CopyObject operation.
class CopyObjectRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The name of the source bucket.
  String? sourceBucket;

  /// The name of the source object.
  String? sourceKey;

  /// Specifies whether the CopyObject operation overwrites objects with the same name. The **x-oss-forbid-overwrite** request header does not take effect when versioning is enabled or suspended for the destination bucket. In this case, the CopyObject operation overwrites the existing object that has the same name as the destination object.*   If you do not specify the **x-oss-forbid-overwrite** header or set the header to **false**, an existing object that has the same name as the object that you want to copy is overwritten.*****   If you set the **x-oss-forbid-overwrite** header to **true**, an existing object that has the same name as the object that you want to copy is not overwritten.If you specify the **x-oss-forbid-overwrite** header, the queries per second (QPS) performance of OSS may be degraded. If you want to specify the **x-oss-forbid-overwrite** header in a large number of requests (QPS greater than 1,000), contact technical support. Default value: false.
  bool? forbidOverwrite;

  /// The object copy condition. If the ETag value of the source object is the same as the ETag value that you specify in the request, OSS copies the object and returns 200 OK. By default, this header is left empty.
  String? copySourceIfMatch;

  /// The object copy condition. If the ETag value of the source object is different from the ETag value that you specify in the request, OSS copies the object and returns 200 OK. By default, this header is left empty.
  String? copySourceIfNoneMatch;

  /// The object copy condition. If the time that you specify in the request is the same as or later than the modification time of the object, OSS copies the object and returns 200 OK. By default, this header is left empty.
  String? copySourceIfUnmodifiedSince;

  /// If the source object is modified after the time that you specify in the request, OSS copies the object. By default, this header is left empty.
  String? copySourceIfModifiedSince;

  /// The method that is used to configure the metadata of the destination object. Default value: COPY.*   **COPY**: The metadata of the source object is copied to the destination object. The **x-oss-server-side-encryption** attribute of the source object is not copied to the destination object. The **x-oss-server-side-encryption** header in the CopyObject request specifies the method that is used to encrypt the destination object.*   **REPLACE**: The metadata that you specify in the request is used as the metadata of the destination object.  If the path of the source object is the same as the path of the destination object and versioning is disabled for the bucket in which the source and destination objects are stored, the metadata that you specify in the CopyObject request is used as the metadata of the destination object regardless of the value of the x-oss-metadata-directive header.
  String? metadataDirective;

  /// The entropy coding-based encryption algorithm that OSS uses to encrypt an object when you create the object. The valid values of the header are **AES256** and **KMS**. You must activate Key Management Service (KMS) in the OSS console before you can use the KMS encryption algorithm. Otherwise, the KmsServiceNotEnabled error is returned.*   If you do not specify the **x-oss-server-side-encryption** header in the CopyObject request, the destination object is not encrypted on the server regardless of whether the source object is encrypted on the server.*   If you specify the **x-oss-server-side-encryption** header in the CopyObject request, the destination object is encrypted on the server after the CopyObject operation is performed regardless of whether the source object is encrypted on the server. In addition, the response to a CopyObject request contains the **x-oss-server-side-encryption** header whose value is the encryption algorithm of the destination object. When the destination object is downloaded, the **x-oss-server-side-encryption** header is included in the response. The value of this header is the encryption algorithm of the destination object.
  String? serverSideEncryption;

  /// The server side data encryption algorithm. Invalid value: SM4
  String? serverSideDataEncryption;

  /// The ID of the customer master key (CMK) that is managed by KMS. This parameter is available only if you set **x-oss-server-side-encryption** to KMS.
  String? serverSideEncryptionKeyId;

  /// The access control list (ACL) of the destination object when the object is created. Default value: default.Valid values:*   default: The ACL of the object is the same as the ACL of the bucket in which the object is stored.*   private: The ACL of the object is private. Only the owner of the object and authorized users have read and write permissions on the object. Other users do not have permissions on the object.*   public-read: The ACL of the object is public-read. Only the owner of the object and authorized users have read and write permissions on the object. Other users have only read permissions on the object. Exercise caution when you set the ACL of the bucket to this value.*   public-read-write: The ACL of the object is public-read-write. All users have read and write permissions on the object. Exercise caution when you set the ACL of the bucket to this value.For more information about ACLs, see [Object ACL](~~100676~~).
  /// Sees ObjectACLType for supported values.
  String? objectAcl;

  /// The storage class of the object that you want to upload. Default value: Standard. If you specify a storage class when you upload the object, the storage class applies regardless of the storage class of the bucket to which you upload the object. For example, if you set **x-oss-storage-class** to Standard when you upload an object to an IA bucket, the storage class of the uploaded object is Standard.Valid values:*   Standard*   IA*   Archive*   ColdArchiveFor more information about storage classes, see [Overview](~~51374~~).
  /// Sees StorageClassType for supported values.
  String? storageClass;

  /// The tag of the destination object. You can add multiple tags to the destination object. Example: TagA=A\&TagB=B.  The tag key and tag value must be URL-encoded. If a key-value pair does not contain an equal sign (=), the tag value is considered an empty string.
  String? tagging;

  /// The method that is used to add tags to the destination object. Default value: Copy.
  /// Valid values:
  ///    **Copy**: The tags of the source object are copied to the destination object.
  ///    **Replace**: The tags that you specify in the request are added to the destination object.
  String? taggingDirective;

  /// The caching behavior of the web page when the object is downloaded.
  String? cacheControl;

  /// The name of the object when the object is downloaded.
  String? contentDisposition;

  /// The content encoding format of the object when the object is downloaded.
  String? contentEncoding;

  /// The expiration time of the request.
  String? expires;

  /// The MD5 hash of the object that you want to upload.
  String? contentMd5;

  /// A standard MIME type describing the format of the contents.
  String? contentType;

  /// Specify the speed limit value. The speed limit value ranges from  245760 to 838860800, with a unit of bit/s.
  int? trafficLimit;

  /// Custom metadata for the object.
  Map<String, String>? metadata;

  CopyObjectRequest({
    this.bucket,
    this.key,
    this.sourceBucket,
    this.sourceKey,
    this.forbidOverwrite,
    this.copySourceIfMatch,
    this.copySourceIfNoneMatch,
    this.copySourceIfUnmodifiedSince,
    this.copySourceIfModifiedSince,
    this.metadataDirective,
    this.serverSideEncryption,
    this.serverSideDataEncryption,
    this.serverSideEncryptionKeyId,
    this.objectAcl,
    this.storageClass,
    this.tagging,
    this.taggingDirective,
    this.cacheControl,
    this.contentDisposition,
    this.contentEncoding,
    this.expires,
    this.contentMd5,
    this.contentType,
    this.trafficLimit,
    this.metadata,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a CopyObjectRequest instance from a JSON map
  factory CopyObjectRequest.fromJson(Map<String, dynamic> json) {
    return CopyObjectRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      sourceBucket: json['sourceBucket'] as String?,
      sourceKey: json['sourceKey'] as String?,
      forbidOverwrite: json['forbidOverwrite'] as bool?,
      copySourceIfMatch: json['copySourceIfMatch'] as String?,
      copySourceIfNoneMatch: json['copySourceIfNoneMatch'] as String?,
      copySourceIfUnmodifiedSince:
          json['copySourceIfUnmodifiedSince'] as String?,
      copySourceIfModifiedSince: json['copySourceIfModifiedSince'] as String?,
      metadataDirective: json['metadataDirective'] as String?,
      serverSideEncryption: json['serverSideEncryption'] as String?,
      serverSideDataEncryption: json['serverSideDataEncryption'] as String?,
      serverSideEncryptionKeyId: json['serverSideEncryptionKeyId'] as String?,
      objectAcl: json['objectAcl'] as String?,
      storageClass: json['storageClass'] as String?,
      tagging: json['tagging'] as String?,
      taggingDirective: json['taggingDirective'] as String?,
      cacheControl: json['cacheControl'] as String?,
      contentDisposition: json['contentDisposition'] as String?,
      contentEncoding: json['contentEncoding'] as String?,
      expires: json['expires'] as String?,
      contentMd5: json['contentMd5'] as String?,
      contentType: json['contentType'] as String?,
      trafficLimit: json['trafficLimit'] as int?,
      metadata: json['metadata'] != null
          ? Map<String, String>.from(json['metadata'] as Map)
          : null,
    );
  }

  /// Converts the CopyObjectRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'sourceBucket': sourceBucket,
      'sourceKey': sourceKey,
      'forbidOverwrite': forbidOverwrite,
      'copySourceIfMatch': copySourceIfMatch,
      'copySourceIfNoneMatch': copySourceIfNoneMatch,
      'copySourceIfUnmodifiedSince': copySourceIfUnmodifiedSince,
      'copySourceIfModifiedSince': copySourceIfModifiedSince,
      'metadataDirective': metadataDirective,
      'serverSideEncryption': serverSideEncryption,
      'serverSideDataEncryption': serverSideDataEncryption,
      'serverSideEncryptionKeyId': serverSideEncryptionKeyId,
      'objectAcl': objectAcl,
      'storageClass': storageClass,
      'tagging': tagging,
      'taggingDirective': taggingDirective,
      'cacheControl': cacheControl,
      'contentDisposition': contentDisposition,
      'contentEncoding': contentEncoding,
      'expires': expires,
      'contentMd5': contentMd5,
      'contentType': contentType,
      'trafficLimit': trafficLimit,
      'metadata': metadata,
    };
  }
}

/// The result for the GetObject operation.
class GetObjectResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The Md5 hash for the uploaded object.
  String? get contentMd5 =>
      commonProp.headers?.getCaseInsensitive('Content-MD5');

  /// A map of metadata to store with the object.
  /// It is a lowcased key dictionary
  Map<String, String>? get metadata => commonProp.headers?.toUserMetadata();

  /// The type of the object.
  String? get objectType =>
      commonProp.headers?.getCaseInsensitive('x-oss-object-type');

  /// The 64-bit CRC value of the object.
  /// This value is calculated based on the ECMA-182 standard.
  int? get hashCrc64ecma {
    final value = commonProp.headers?.getCaseInsensitive(
      'x-oss-hash-crc64ecma',
    );
    return value?.toUInt64();
  }

  /// The lifecycle information about the object.
  /// If lifecycle rules are configured for the object, this header is included in the response.
  /// This header contains the following parameters: expiry-date that indicates the expiration time of the object, and rule-id that indicates the ID of the matched lifecycle rule.
  String? get expiration =>
      commonProp.headers?.getCaseInsensitive('x-oss-expiration');

  /// Request charged information.
  String? get requestCharged =>
      commonProp.headers?.getCaseInsensitive('x-oss-request-charged');

  /// A standard MIME type describing the format of the object data.
  String? get contentType =>
      commonProp.headers?.getCaseInsensitive('Content-Type');

  /// The ID of the customer master key (CMK) that is managed by Key Management Service (KMS).
  String? get serverSideEncryptionKeyId => commonProp.headers
      ?.getCaseInsensitive('x-oss-server-side-encryption-key-id');

  /// The position for the next append operation.
  /// If the type of the object is Appendable, this header is included in the response.
  int? get nextAppendPosition {
    final value = commonProp.headers?.getCaseInsensitive(
      'x-oss-next-append-position',
    );
    return value?.toInt();
  }

  /// The status of the object when you restore an object.
  /// If the storage class of the bucket is Archive and a RestoreObject request is submitted.
  String? get restore =>
      commonProp.headers?.getCaseInsensitive('x-oss-restore');

  /// Size of the body in bytes.
  int? get contentLength {
    final value = commonProp.headers?.getCaseInsensitive('Content-Length');
    return value?.toInt();
  }

  /// The portion of the object returned in the response.
  int? get contentRange {
    final value = commonProp.headers?.getCaseInsensitive('Content-Range');
    return value?.toInt();
  }

  /// The entity tag (ETag).
  /// An ETag is created when an object is created to identify the content of the object.
  String? get etag => commonProp.headers?.getCaseInsensitive('ETag');

  /// The server side data encryption algorithm.
  String? get serverSideEncryption =>
      commonProp.headers?.getCaseInsensitive('x-oss-server-side-encryption');

  /// The storage class of the object.
  String? get storageClass =>
      commonProp.headers?.getCaseInsensitive('x-oss-storage-class');

  /// The result of an event notification that is triggered for the object.
  String? get processStatus =>
      commonProp.headers?.getCaseInsensitive('x-oss-process-status');

  /// The time when the returned objects were last modified.
  String? get lastModified =>
      commonProp.headers?.getCaseInsensitive('Last-Modified');

  /// The number of tags added to the object.
  /// This header is included in the response only when you have read permissions on tags.
  int? get taggingCount {
    final value = commonProp.headers?.getCaseInsensitive('x-oss-tagging-count');
    return value?.toInt();
  }

  /// Specifies whether the object retrieved was (true) or was not (false) a Delete Marker.
  bool? get deleteMarker {
    final value = commonProp.headers?.getCaseInsensitive('x-oss-delete-marker');
    return value?.toBool();
  }

  /// The body of the response.
  ByteStream? body;

  GetObjectResult({this.body, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetObjectResult instance from a JSON map
  factory GetObjectResult.fromJson(Map<String, dynamic> json) {
    return GetObjectResult(
      // Note: body is not serializable from JSON
    );
  }

  /// Converts the GetObjectResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      // Note: body is not serializable to JSON
    };
  }
}

/// The result for the CopyObject operation.
class CopyObjectResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The version ID of the source object.
  String? get copySourceVersionId =>
      commonProp.headers?.getCaseInsensitive('x-oss-copy-source-version-id');

  /// Version of the object.
  String? get versionId =>
      commonProp.headers?.getCaseInsensitive('x-oss-version-id');

  /// The 64-bit CRC value of the object. This value is calculated based on the ECMA-182 standard.
  int? get hashCrc64 {
    final value = commonProp.headers?.getCaseInsensitive(
      'x-oss-hash-crc64ecma',
    );
    return value?.toUInt64();
  }

  /// The encryption method on the server side when an object is created. Valid values: AES256 and KMS
  String? get serverSideEncryption =>
      commonProp.headers?.getCaseInsensitive('x-oss-server-side-encryption');

  /// The encryption algorithm of the object. AES256 or SM4.
  String? get serverSideDataEncryption => commonProp.headers
      ?.getCaseInsensitive('x-oss-server-side-data-encryption');

  /// The ID of the customer master key (CMK) that is managed by Key Management Service (KMS).
  String? get serverSideEncryptionKeyId => commonProp.headers
      ?.getCaseInsensitive('x-oss-server-side-encryption-key-id');

  /// The ETag value of the destination object.
  String? etag;

  /// The time when the destination object was last modified.
  String? lastModified;

  CopyObjectResult({this.etag, this.lastModified, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a CopyObjectResult instance from a JSON map
  factory CopyObjectResult.fromJson(Map<String, dynamic> json) {
    return CopyObjectResult(
      etag: json['etag'] as String?,
      lastModified: json['lastModified'] as String?,
    );
  }

  /// Converts the CopyObjectResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'etag': etag, 'lastModified': lastModified};
  }
}

/// The request for the AppendObject operation.
class AppendObjectRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The method used to encrypt objects on the specified OSS server. Valid values:- AES256: Keys managed by OSS are used for encryption and decryption (SSE-OSS). - KMS: Keys managed by Key Management Service (KMS) are used for encryption and decryption. - SM4: The SM4 block cipher algorithm is used for encryption and decryption.
  String? serverSideEncryption;

  /// The access control list (ACL) of the object. Default value: default.  Valid values:- default: The ACL of the object is the same as that of the bucket in which the object is stored. - private: The ACL of the object is private. Only the owner of the object and authorized users can read and write this object. - public-read: The ACL of the object is public-read. Only the owner of the object and authorized users can read and write this object. Other users can only read the object. Exercise caution when you set the object ACL to this value. - public-read-write: The ACL of the object is public-read-write. All users can read and write this object. Exercise caution when you set the object ACL to this value. For more information about the ACL, see [ACL](~~100676~~).
  /// Sees ObjectACLType for supported values.
  String? objectAcl;

  /// The storage class of the object that you want to upload. Valid values:- Standard- IA- ArchiveIf you specify the object storage class when you upload an object, the storage class of the uploaded object is the specified value regardless of the storage class of the bucket to which the object is uploaded. If you set x-oss-storage-class to Standard when you upload an object to an IA bucket, the object is stored as a Standard object. For more information about storage classes, see the "Overview" topic in Developer Guide. notice The value that you specify takes effect only when you call the AppendObject operation on an object for the first time.
  /// Sees StorageClassType for supported values.
  String? storageClass;

  /// Custom metadata for the object.
  Map<String, String>? metadata;

  /// The web page caching behavior for the object. For more information, see **[RFC 2616](https://www.ietf.org/rfc/rfc2616.txt)**. Default value: null.
  String? cacheControl;

  /// The name of the object when the object is downloaded. For more information, see **[RFC 2616](https://www.ietf.org/rfc/rfc2616.txt)**. Default value: null.
  String? contentDisposition;

  /// The encoding format of the object content. For more information, see **[RFC 2616](https://www.ietf.org/rfc/rfc2616.txt)**. Default value: null.
  String? contentEncoding;

  /// The Content-MD5 header value is a string calculated by using the MD5 algorithm. The header is used to check whether the content of the received message is the same as that of the sent message. To obtain the value of the Content-MD5 header, calculate a 128-bit number based on the message content except for the header, and then encode the number in Base64. Default value: null.Limits: none.
  String? contentMd5;

  /// A standard MIME type describing the format of the contents.
  String? contentType;

  /// The expiration time. For more information, see **[RFC 2616](https://www.ietf.org/rfc/rfc2616.txt)**. Default value: null.
  String? expires;

  /// Specify the initial value of CRC64. If not set, the crc check is ignored.
  int? initHashCrc64;

  /// The position from which the AppendObject operation starts.  Each time an AppendObject operation succeeds, the x-oss-next-append-position header is included in the response to specify the position from which the next AppendObject operation starts. The value of position in the first AppendObject operation performed on an object must be 0. The value of position in subsequent AppendObject operations performed on the object is the current length of the object. For example, if the value of position specified in the first AppendObject request is 0 and the value of content-length is 65536, the value of position in the second AppendObject request must be 65536. - If the value of position in the AppendObject request is 0 and the name of the object that you want to append is unique, you can set headers such as x-oss-server-side-encryption in an AppendObject request in the same way as you set in a PutObject request. If you add the x-oss-server-side-encryption header to an AppendObject request, the x-oss-server-side-encryption header is included in the response to the request. If you want to modify metadata, you can call the CopyObject operation. - If you call an AppendObject operation to append a 0 KB object whose position value is valid to an Appendable object, the status of the Appendable object is not changed.
  int? position;

  /// Specify the speed limit value. The speed limit value ranges from  245760 to 838860800, with a unit of bit/s.
  int? trafficLimit;

  /// The request body.
  ByteStream? body;

  /// Progress delegate for tracking upload progress.
  ProgressDelegate? progress;

  AppendObjectRequest({
    this.bucket,
    this.key,
    this.position,
    this.body,
    this.initHashCrc64,
    this.serverSideEncryption,
    this.objectAcl,
    this.storageClass,
    this.metadata,
    this.cacheControl,
    this.contentDisposition,
    this.contentEncoding,
    this.contentMd5,
    this.contentType,
    this.expires,
    this.trafficLimit,
    this.progress,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates an AppendObjectRequest instance from a JSON map
  factory AppendObjectRequest.fromJson(Map<String, dynamic> json) {
    return AppendObjectRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      position: json['position'] as int?,
      initHashCrc64: json['initHashCrc64'] as int?,
      serverSideEncryption: json['serverSideEncryption'] as String?,
      objectAcl: json['objectAcl'] as String?,
      storageClass: json['storageClass'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, String>.from(json['metadata'] as Map)
          : null,
      cacheControl: json['cacheControl'] as String?,
      contentDisposition: json['contentDisposition'] as String?,
      contentEncoding: json['contentEncoding'] as String?,
      contentMd5: json['contentMd5'] as String?,
      contentType: json['contentType'] as String?,
      expires: json['expires'] as String?,
      trafficLimit: json['trafficLimit'] as int?,
      // Note: body and progress are not serializable from JSON
    );
  }

  /// Converts the AppendObjectRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'position': position,
      'initHashCrc64': initHashCrc64,
      'serverSideEncryption': serverSideEncryption,
      'objectAcl': objectAcl,
      'storageClass': storageClass,
      'metadata': metadata,
      'cacheControl': cacheControl,
      'contentDisposition': contentDisposition,
      'contentEncoding': contentEncoding,
      'contentMd5': contentMd5,
      'contentType': contentType,
      'expires': expires,
      'trafficLimit': trafficLimit,
      // Note: body and progress are not serializable to JSON
    };
  }
}

/// The result for the AppendObject operation.
class AppendObjectResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The position that must be provided in the next request, which is the current length of the object.
  int? get nextAppendPosition {
    final value = commonProp.headers?.getCaseInsensitive(
      'x-oss-next-append-position',
    );
    return value?.toInt();
  }

  /// Version of the object.
  String? get versionId =>
      commonProp.headers?.getCaseInsensitive('x-oss-version-id');

  /// The 64-bit CRC value of the object. This value is calculated based on the ECMA-182 standard.
  int? get hashCrc64ecma {
    final value = commonProp.headers?.getCaseInsensitive(
      'x-oss-hash-crc64ecma',
    );
    return value?.toUInt64();
  }

  /// The encryption method on the server side when an object is created. Valid values: AES256 and KMS
  String? get serverSideEncryption =>
      commonProp.headers?.getCaseInsensitive('x-oss-server-side-encryption');

  /// The encryption algorithm of the object. AES256 or SM4.
  String? get serverSideDataEncryption => commonProp.headers
      ?.getCaseInsensitive('x-oss-server-side-data-encryption');

  /// The ID of the customer master key (CMK) that is managed by Key Management Service (KMS).
  String? get serverSideEncryptionKeyId => commonProp.headers
      ?.getCaseInsensitive('x-oss-server-side-encryption-key-id');

  /// The ETag value of the destination object.
  String? etag;

  AppendObjectResult({this.etag, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates an AppendObjectResult instance from a JSON map
  factory AppendObjectResult.fromJson(Map<String, dynamic> json) {
    return AppendObjectResult(etag: json['etag'] as String?);
  }

  /// Converts the AppendObjectResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'etag': etag};
  }
}

/// The request for the DeleteObject operation.
class DeleteObjectRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The version ID of the object.
  String? versionId;

  DeleteObjectRequest({
    this.bucket,
    this.key,
    this.versionId,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a DeleteObjectRequest instance from a JSON map
  factory DeleteObjectRequest.fromJson(Map<String, dynamic> json) {
    return DeleteObjectRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      versionId: json['versionId'] as String?,
    );
  }

  /// Converts the DeleteObjectRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'key': key, 'versionId': versionId};
  }
}

/// The result for the DeleteObject operation.
class DeleteObjectResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// Indicates whether the deleted version is a delete marker.
  bool? get deleteMarker {
    final value = commonProp.headers?.getCaseInsensitive('x-oss-delete-marker');
    return value?.toBool();
  }

  /// The version ID of the object.
  String? get versionId =>
      commonProp.headers?.getCaseInsensitive('x-oss-version-id');

  DeleteObjectResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a DeleteObjectResult instance from a JSON map
  factory DeleteObjectResult.fromJson(Map<String, dynamic> json) {
    return DeleteObjectResult();
  }

  /// Converts the DeleteObjectResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the HeadObject operation.
class HeadObjectRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// If the time that is specified in the request is earlier than the time when the object is modified, OSS returns 200 OK and the metadata of the object. Otherwise, OSS returns 304 not modified. Default value: null.
  String? ifModifiedSince;

  /// If the time that is specified in the request is later than or the same as the time when the object is modified, OSS returns 200 OK and the metadata of the object. Otherwise, OSS returns 412 precondition failed. Default value: null.
  String? ifUnmodifiedSince;

  /// If the ETag value that is specified in the request matches the ETag value of the object, OSS returns 200 OK and the metadata of the object. Otherwise, OSS returns 412 precondition failed. Default value: null.
  String? ifMatch;

  /// If the ETag value that is specified in the request does not match the ETag value of the object, OSS returns 200 OK and the metadata of the object. Otherwise, OSS returns 304 Not Modified. Default value: null.
  String? ifNoneMatch;

  /// The version ID of the object for which you want to query metadata.
  String? versionId;

  HeadObjectRequest({
    this.bucket,
    this.key,
    this.ifModifiedSince,
    this.ifUnmodifiedSince,
    this.ifMatch,
    this.ifNoneMatch,
    this.versionId,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a HeadObjectRequest instance from a JSON map
  factory HeadObjectRequest.fromJson(Map<String, dynamic> json) {
    return HeadObjectRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      ifModifiedSince: json['ifModifiedSince'] as String?,
      ifUnmodifiedSince: json['ifUnmodifiedSince'] as String?,
      ifMatch: json['ifMatch'] as String?,
      ifNoneMatch: json['ifNoneMatch'] as String?,
      versionId: json['versionId'] as String?,
    );
  }

  /// Converts the HeadObjectRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'ifModifiedSince': ifModifiedSince,
      'ifUnmodifiedSince': ifUnmodifiedSince,
      'ifMatch': ifMatch,
      'ifNoneMatch': ifNoneMatch,
      'versionId': versionId,
    };
  }
}

/// The result for the HeadObject operation.
class HeadObjectResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The lifecycle information about the object.
  /// If lifecycle rules are configured for the object, this header is included in the response.
  /// This header contains the following parameters: expiry-date that indicates the expiration time of the object, and rule-id that indicates the ID of the matched lifecycle rule.
  String? get expiration =>
      commonProp.headers?.getCaseInsensitive('x-oss-expiration');

  /// The status of the object when you restore an object.
  /// If the storage class of the bucket is Archive and a RestoreObject request is submitted.
  String? get restore =>
      commonProp.headers?.getCaseInsensitive('x-oss-restore');

  /// The Md5 hash for the uploaded object.
  String? get contentMd5 =>
      commonProp.headers?.getCaseInsensitive('Content-MD5');

  /// The entity tag (ETag).
  /// An ETag is created when an object is created to identify the content of the object.
  String? get etag => commonProp.headers?.getCaseInsensitive('ETag');

  /// The type of the object.
  String? get objectType =>
      commonProp.headers?.getCaseInsensitive('x-oss-object-type');

  /// The result of an event notification that is triggered for the object.
  String? get processStatus =>
      commonProp.headers?.getCaseInsensitive('x-oss-process-status');

  /// The requester. This header is included in the response if the pay-by-requester mode is enabled for the bucket and the requester is not the bucket owner. The value of this header is requester.
  String? get requestCharged =>
      commonProp.headers?.getCaseInsensitive('x-oss-request-charged');

  /// The time when the returned objects were last modified.
  String? get lastModified =>
      commonProp.headers?.getCaseInsensitive('Last-Modified');

  /// A map of metadata to store with the object.
  /// It is a lowcased key dictionary
  Map<String, String>? get metadata => commonProp.headers?.toUserMetadata();

  /// The number of tags added to the object.
  /// This header is included in the response only when you have read permissions on tags.
  int? get taggingCount {
    final value = commonProp.headers?.getCaseInsensitive('x-oss-tagging-count');
    return value?.toInt();
  }

  /// If the requested object is encrypted by
  /// using a server-side encryption algorithm based on entropy encoding, OSS automatically decrypts
  /// the object and returns the decrypted object after OSS receives the GetObject request.
  /// The x-oss-server-side-encryption header is included in the response to indicate the encryption algorithm used to encrypt the object on the server.
  String? get serverSideEncryption =>
      commonProp.headers?.getCaseInsensitive('x-oss-server-side-encryption');

  /// The server side data encryption algorithm.
  String? get serverSideDataEncryption => commonProp.headers
      ?.getCaseInsensitive('x-oss-server-side-data-encryption');

  /// The ID of the customer master key (CMK) that is managed by Key Management Service (KMS).
  String? get serverSideEncryptionKeyId => commonProp.headers
      ?.getCaseInsensitive('x-oss-server-side-encryption-key-id');

  /// The position for the next append operation.
  /// If the type of the object is Appendable, this header is included in the response.
  int? get nextAppendPosition {
    final value = commonProp.headers?.getCaseInsensitive(
      'x-oss-next-append-position',
    );
    return value?.toInt();
  }

  /// The 64-bit CRC value of the object.
  /// This value is calculated based on the ECMA-182 standard.
  int? get hashCrc64ecma {
    final value = commonProp.headers?.getCaseInsensitive(
      'x-oss-hash-crc64ecma',
    );
    return value?.toUInt64();
  }

  /// The time when the storage class of the returned objects is changed to Cold Archive or Deep Cold Archive based on lifecycle rules.
  String? get transitionTime =>
      commonProp.headers?.getCaseInsensitive('x-oss-transition-time');

  /// The storage class of the object.
  String? get storageClass =>
      commonProp.headers?.getCaseInsensitive('x-oss-storage-class');

  /// Size of the body in bytes.
  int? get contentLength {
    final value = commonProp.headers?.getCaseInsensitive('Content-Length');
    return value?.toInt();
  }

  /// A standard MIME type describing the format of the object data.
  String? get contentType =>
      commonProp.headers?.getCaseInsensitive('Content-Type');

  /// The caching behavior of the web page when the object is downloaded.
  String? get cacheControl =>
      commonProp.headers?.getCaseInsensitive('Cache-Control');

  /// The method that is used to access the object.
  String? get contentDisposition =>
      commonProp.headers?.getCaseInsensitive('Content-Disposition');

  /// The method that is used to encode the object.
  String? get contentEncoding =>
      commonProp.headers?.getCaseInsensitive('Content-Encoding');

  /// The expiration time of the cache in UTC.
  String? get expires => commonProp.headers?.getCaseInsensitive('Expires');

  /// Version of the object.
  String? get versionId =>
      commonProp.headers?.getCaseInsensitive('x-oss-version-id');

  HeadObjectResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a HeadObjectResult instance from a JSON map
  factory HeadObjectResult.fromJson(Map<String, dynamic> json) {
    return HeadObjectResult();
  }

  /// Converts the HeadObjectResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the GetObjectMeta operation.
class GetObjectMetaRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The versionID of the object.
  String? versionId;

  GetObjectMetaRequest({
    this.bucket,
    this.key,
    this.versionId,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a GetObjectMetaRequest instance from a JSON map
  factory GetObjectMetaRequest.fromJson(Map<String, dynamic> json) {
    return GetObjectMetaRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      versionId: json['versionId'] as String?,
    );
  }

  /// Converts the GetObjectMetaRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'key': key, 'versionId': versionId};
  }
}

/// The result for the GetObjectMeta operation.
class GetObjectMetaResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// Version of the object.
  String? get versionId =>
      commonProp.headers?.getCaseInsensitive('x-oss-version-id');

  /// Entity tag for the object.
  String? get etag => commonProp.headers?.getCaseInsensitive('ETag');

  /// Size of the body in bytes.
  int? get contentLength {
    final value = commonProp.headers?.getCaseInsensitive('Content-Length');
    return value?.toInt();
  }

  /// The time when the object was last accessed.
  String? get lastAccessTime =>
      commonProp.headers?.getCaseInsensitive('x-oss-last-access-time');

  /// The time when the returned objects were last modified.
  String? get lastModified =>
      commonProp.headers?.getCaseInsensitive('Last-Modified');

  /// The time when the storage class of the returned objects is changed to Cold Archive or Deep Cold Archive based on lifecycle rules.
  String? get transitionTime =>
      commonProp.headers?.getCaseInsensitive('x-oss-transition-time');

  GetObjectMetaResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a GetObjectMetaResult instance from a JSON map
  factory GetObjectMetaResult.fromJson(Map<String, dynamic> json) {
    return GetObjectMetaResult();
  }

  /// Converts the GetObjectMetaResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the RestoreObject operation.
class RestoreObjectRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The version number of the object that you want to restore.
  String? versionId;

  /// The request body schema.
  RestoreRequest? restoreRequest;

  RestoreObjectRequest({
    this.bucket,
    this.key,
    this.versionId,
    this.restoreRequest,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a RestoreObjectRequest instance from a JSON map
  factory RestoreObjectRequest.fromJson(Map<String, dynamic> json) {
    return RestoreObjectRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      versionId: json['versionId'] as String?,
      restoreRequest: json['restoreRequest'] != null
          ? RestoreRequest.fromJson(
              json['restoreRequest'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts the RestoreObjectRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'versionId': versionId,
      'restoreRequest': restoreRequest?.toJson(),
    };
  }
}

/// The result for the RestoreObject operation.
class RestoreObjectResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// Version of the object.
  String? get versionId =>
      commonProp.headers?.getCaseInsensitive('x-oss-version-id');

  /// The restore priority of the object.
  String? get objectRestorePriority =>
      commonProp.headers?.getCaseInsensitive('x-oss-object-restore-priority');

  RestoreObjectResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a RestoreObjectResult instance from a JSON map
  factory RestoreObjectResult.fromJson(Map<String, dynamic> json) {
    return RestoreObjectResult();
  }

  /// Converts the RestoreObjectResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the DeleteMultipleObjects operation.
class DeleteMultipleObjectsRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket
  String? bucket;

  /// The encoding type of the object names in the response. Valid value: url
  /// Sees EncodingType for supported values.
  String? encodingType;

  /// Specifies whether to enable the Quiet return mode.
  /// The DeleteMultipleObjects operation provides the following return modes: Valid value: true,false
  bool? quiet;

  /// The container that stores information about you want to delete objects.
  List<DeleteObject>? objects;

  DeleteMultipleObjectsRequest({
    this.bucket,
    this.objects,
    this.quiet,
    this.encodingType,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a DeleteMultipleObjectsRequest instance from a JSON map
  factory DeleteMultipleObjectsRequest.fromJson(Map<String, dynamic> json) {
    return DeleteMultipleObjectsRequest(
      bucket: json['bucket'] as String?,
      encodingType: json['encodingType'] as String?,
      quiet: json['quiet'] as bool?,
      objects: json['objects'] != null
          ? (json['objects'] as List)
                .map((e) => DeleteObject.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  /// Converts the DeleteMultipleObjectsRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'encodingType': encodingType,
      'quiet': quiet,
      'objects': objects?.map((e) => e.toJson()).toList(),
    };
  }
}

/// The result for the DeleteMultipleObjects operation.
class DeleteMultipleObjectsResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  /// The container that stores information about you want to delete objects.
  List<DeletedInfo>? deletedObjects;

  /// The encoding type of the object names in the response. Valid value: url
  /// Sees EncodingType for supported values.
  String? encodingType;

  DeleteMultipleObjectsResult({
    this.deletedObjects,
    this.encodingType,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a DeleteMultipleObjectsResult instance from a JSON map
  factory DeleteMultipleObjectsResult.fromJson(Map<String, dynamic> json) {
    return DeleteMultipleObjectsResult(
      deletedObjects: json['deletedObjects'] != null
          ? (json['deletedObjects'] as List)
                .map((e) => DeletedInfo.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      encodingType: json['encodingType'] as String?,
    );
  }

  /// Converts the DeleteMultipleObjectsResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'deletedObjects': deletedObjects?.map((e) => e.toJson()).toList(),
      'encodingType': encodingType,
    };
  }
}

/// The request for the CleanRestoredObject operation.
class CleanRestoredObjectRequest extends RequestModel {
  @override
  RequestModelProp commonProp;

  /// The name of the bucket
  String? bucket;

  /// The name of the object.
  String? key;

  CleanRestoredObjectRequest({
    this.bucket,
    this.key,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a CleanRestoredObjectRequest instance from a JSON map
  factory CleanRestoredObjectRequest.fromJson(Map<String, dynamic> json) {
    return CleanRestoredObjectRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
    );
  }

  /// Converts the CleanRestoredObjectRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'key': key};
  }
}

/// The result for the CleanRestoredObject operation.
class CleanRestoredObjectResult extends ResultModel {
  @override
  ResultModelProp commonProp;

  CleanRestoredObjectResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates a CleanRestoredObjectResult instance from a JSON map
  factory CleanRestoredObjectResult.fromJson(Map<String, dynamic> json) {
    return CleanRestoredObjectResult();
  }

  /// Converts the CleanRestoredObjectResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}
