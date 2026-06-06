import 'model_types.dart';
import 'model_bucket_basic.dart';
import '../transform/serde_extensions.dart';
import '../types/byte_stream.dart';
import '../progress.dart';

/// The container that stores the information about multipart upload tasks.
class Upload {
  /// The time when the multipart upload task was initiated.
  DateTime? initiated;

  /// The name of the object for which a multipart upload task was initiated.  The results returned by OSS are listed in ascending alphabetical order of object names. Multiple multipart upload tasks that are initiated to upload the same object are listed in ascending order of upload IDs.
  String? key;

  /// The ID of the multipart upload task.
  String? uploadId;

  /// Creates a Upload instance.
  Upload({this.initiated, this.key, this.uploadId});

  /// Creates an Upload instance from a JSON map
  factory Upload.fromJson(Map<String, dynamic> json) {
    return Upload(
      initiated: json['initiated'] != null
          ? DateTime.parse(json['initiated'] as String)
          : null,
      key: json['key'] as String?,
      uploadId: json['uploadId'] as String?,
    );
  }

  /// Converts the Upload instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'initiated': initiated?.toIso8601String(),
      'key': key,
      'uploadId': uploadId,
    };
  }
}

/// The container that stores the uploaded parts.
class UploadPart {
  /// The ETag that is generated when the object is created. ETags are used to identify the content of objects.If an object is created by calling the CompleteMultipartUpload operation, the ETag is not the MD5 hash of the object content but a unique value calculated based on a specific rule.  The ETag of an object can be used to check whether the object content changes. We recommend that you use the MD5 hash of an object rather than the ETag of the object to verify data integrity.
  String? etag;

  /// The number of parts.
  int? partNumber;

  /// Creates a UploadPart instance.
  UploadPart({this.etag, this.partNumber});

  /// Creates an UploadPart instance from a JSON map
  factory UploadPart.fromJson(Map<String, dynamic> json) {
    return UploadPart(
      etag: json['etag'] as String?,
      partNumber: json['partNumber'] as int?,
    );
  }

  /// Converts the UploadPart instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'etag': etag, 'partNumber': partNumber};
  }
}

/// The `Part` part.
class Part {
  /// The ETag value of the content of the uploaded part.
  String? etag;

  /// The number that identifies a part.
  int? partNumber;

  /// The time when the part was uploaded.
  DateTime? lastModified;

  /// The size of the uploaded parts.
  int? size;

  /// The 64-bit CRC value of the object.
  /// This value is calculated based on the ECMA-182 standar
  String? hashCrc64;

  /// Creates a Part instance.
  Part({
    this.etag,
    this.partNumber,
    this.lastModified,
    this.size,
    this.hashCrc64,
  });

  /// Creates a Part instance from a JSON map
  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      etag: json['etag'] as String?,
      partNumber: json['partNumber'] as int?,
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'] as String)
          : null,
      size: json['size'] as int?,
      hashCrc64: json['hashCrc64'] as String?,
    );
  }

  /// Converts the Part instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'etag': etag,
      'partNumber': partNumber,
      'lastModified': lastModified?.toIso8601String(),
      'size': size,
      'hashCrc64': hashCrc64,
    };
  }
}

/// The container that stores the content of the CompleteMultipartUpload request.
class CompleteMultipartUpload {
  /// The container that stores the uploaded parts.
  List<UploadPart>? parts;

  /// Creates a CompleteMultipartUpload instance.
  CompleteMultipartUpload({this.parts});

  /// Creates a CompleteMultipartUpload instance from a JSON map
  factory CompleteMultipartUpload.fromJson(Map<String, dynamic> json) {
    return CompleteMultipartUpload(
      parts: json['parts'] != null
          ? (json['parts'] as List)
                .map((e) => UploadPart.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  /// Converts the CompleteMultipartUpload instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'parts': parts?.map((e) => e.toJson()).toList()};
  }
}

/// The container that stores the copy result.
class CopyPartResult {
  /// The last modified time of copy source.
  DateTime? lastModified;

  /// The ETag of the copied part.
  String? etag;

  /// Creates a CopyPartResult instance.
  CopyPartResult({this.lastModified, this.etag});
}

/// The request for the InitiateMultipartUpload operation.
class InitiateMultipartUploadRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket to which the object is uploaded by the multipart upload task.
  String? bucket;

  /// The name of the object that is uploaded by the multipart upload task.
  String? key;

  /// Specifies whether the InitiateMultipartUpload operation overwrites the existing object that has the same name as the object that you want to upload. When versioning is enabled or suspended for the bucket to which you want to upload the object, the **x-oss-forbid-overwrite** header does not take effect. In this case, the InitiateMultipartUpload operation overwrites the existing object that has the same name as the object that you want to upload.
  /// - If you do not specify the **x-oss-forbid-overwrite** header or set the **x-oss-forbid-overwrite** header to **false**, the object that is uploaded by calling the PutObject operation overwrites the existing object that has the same name.
  /// - If the value of **x-oss-forbid-overwrite** is set to **true**, existing objects cannot be overwritten by objects that have the same names. If you specify the **x-oss-forbid-overwrite** request header, the queries per second (QPS) performance of OSS is degraded. If you want to use the **x-oss-forbid-overwrite** request header to perform a large number of operations (QPS greater than 1,000), contact technical support
  bool? forbidOverwrite;

  /// The storage class of the bucket. Default value: Standard.
  /// Valid values: Standard, IA, Archive, ColdArchive
  String? storageClass;

  /// The tag of the object. You can configure multiple tags for the object. Example: TagA=A&TagB=B. The key and value of a tag must be URL-encoded. If a tag does not contain an equal sign (=), the value of the tag is considered an empty string.
  String? tagging;

  /// The server-side encryption method that is used to encrypt each part of the object that you want to upload. Valid values: **AES256**, **KMS**, and **SM4**. You must activate Key Management Service (KMS) before you set this header to KMS. If you specify this header in the request, this header is included in the response. OSS uses the method specified by this header to encrypt each uploaded part. When you download the object, the x-oss-server-side-encryption header is included in the response and the header value is set to the algorithm that is used to encrypt the object.
  String? serverSideEncryption;

  /// The algorithm that is used to encrypt the object that you want to upload. If this header is not specified, the object is encrypted by using AES-256. This header is valid only when **x-oss-server-side-encryption** is set to KMS. Valid value: SM4.
  String? serverSideDataEncryption;

  /// The ID of the CMK that is managed by KMS. This header is valid only when **x-oss-server-side-encryption** is set to KMS.
  String? serverSideEncryptionKeyId;

  /// The caching behavior of the web page when the object is downloaded. For more information, see **[RFC 2616](https://www.ietf.org/rfc/rfc2616.txt)**. Default value: null.
  String? cacheControl;

  /// The name of the object when the object is downloaded. For more information, see **[RFC 2616](https://www.ietf.org/rfc/rfc2616.txt)**. Default value: null.
  String? contentDisposition;

  /// The content encoding format of the object when the object is downloaded. For more information, see **[RFC 2616](https://www.ietf.org/rfc/rfc2616.txt)**. Default value: null.
  String? contentEncoding;

  /// A standard MIME type describing the format of the contents.
  String? contentType;

  /// The expiration time of the request. Unit: milliseconds. For more information, see **[RFC 2616](https://www.ietf.org/rfc/rfc2616.txt)**. Default value: null.
  String? expires;

  /// The method used to encode the object name in the response. Only URL encoding is supported. The object name can contain characters encoded in UTF-8. However, the XML 1.0 standard cannot be used to parse specific control characters, such as characters whose ASCII values range from 0 to 10. You can configure the encoding-type parameter to encode object names that include characters that cannot be parsed by XML 1.0 in the response. Default value: null
  String? encodingType;

  /// Creates a InitiateMultipartUploadRequest instance.
  InitiateMultipartUploadRequest({
    this.bucket,
    this.key,
    this.forbidOverwrite,
    this.storageClass,
    this.tagging,
    this.serverSideEncryption,
    this.serverSideDataEncryption,
    this.serverSideEncryptionKeyId,
    this.cacheControl,
    this.contentDisposition,
    this.contentEncoding,
    this.contentType,
    this.expires,
    this.encodingType,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates an InitiateMultipartUploadRequest instance from a JSON map
  factory InitiateMultipartUploadRequest.fromJson(Map<String, dynamic> json) {
    return InitiateMultipartUploadRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      forbidOverwrite: json['forbidOverwrite'] as bool?,
      storageClass: json['storageClass'] as String?,
      tagging: json['tagging'] as String?,
      serverSideEncryption: json['serverSideEncryption'] as String?,
      serverSideDataEncryption: json['serverSideDataEncryption'] as String?,
      serverSideEncryptionKeyId: json['serverSideEncryptionKeyId'] as String?,
      cacheControl: json['cacheControl'] as String?,
      contentDisposition: json['contentDisposition'] as String?,
      contentEncoding: json['contentEncoding'] as String?,
      contentType: json['contentType'] as String?,
      expires: json['expires'] as String?,
      encodingType: json['encodingType'] as String?,
    );
  }

  /// Converts the InitiateMultipartUploadRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'forbidOverwrite': forbidOverwrite,
      'storageClass': storageClass,
      'tagging': tagging,
      'serverSideEncryption': serverSideEncryption,
      'serverSideDataEncryption': serverSideDataEncryption,
      'serverSideEncryptionKeyId': serverSideEncryptionKeyId,
      'cacheControl': cacheControl,
      'contentDisposition': contentDisposition,
      'contentEncoding': contentEncoding,
      'contentType': contentType,
      'expires': expires,
      'encodingType': encodingType,
    };
  }
}

/// The result for the InitiateMultipartUpload operation.
class InitiateMultipartUploadResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The encoding type of the object name in the response. If the encoding-type parameter is specified in the request, the object name in the response is encoded.
  String? encodingType;

  /// The name of the bucket to which the object is uploaded by the multipart upload task.
  String? bucket;

  /// The name of the object that is uploaded by the multipart upload task.
  String? key;

  /// The upload ID that uniquely identifies the multipart upload task. The upload ID is used to call UploadPart and CompleteMultipartUpload later.
  String? uploadId;

  /// Creates a InitiateMultipartUploadResult instance.
  InitiateMultipartUploadResult({
    this.encodingType,
    this.bucket,
    this.key,
    this.uploadId,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates an InitiateMultipartUploadResult instance from a JSON map
  factory InitiateMultipartUploadResult.fromJson(Map<String, dynamic> json) {
    return InitiateMultipartUploadResult(
      encodingType: json['encodingType'] as String?,
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      uploadId: json['uploadId'] as String?,
    );
  }

  /// Converts the InitiateMultipartUploadResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'encodingType': encodingType,
      'bucket': bucket,
      'key': key,
      'uploadId': uploadId,
    };
  }
}

/// The request for the UploadPart operation.
class UploadPartRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The number that identifies a part. Valid values: 1 to 10000.
  /// The size of a part ranges from 100 KB to 5 GB. In multipart upload, each part except the last part must be larger than or equal to 100 KB in size.
  /// When you call the UploadPart operation, the size of each part is not verified because not all parts have been uploaded and OSS does not know which part is the last part.
  /// The size of each part is verified only when you call CompleteMultipartUpload.
  int? partNumber;

  /// The ID that identifies the object to which the part that you want to upload belongs.
  String? uploadId;

  /// The request body.
  ByteStream? body;

  /// Progress delegate for tracking upload progress.
  ProgressDelegate? progress;

  /// Creates a UploadPartRequest instance.
  UploadPartRequest({
    this.bucket,
    this.key,
    this.partNumber,
    this.uploadId,
    this.body,
    this.progress,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates an UploadPartRequest instance from a JSON map
  factory UploadPartRequest.fromJson(Map<String, dynamic> json) {
    return UploadPartRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      partNumber: json['partNumber'] as int?,
      uploadId: json['uploadId'] as String?,
    );
  }

  /// Converts the UploadPartRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'partNumber': partNumber,
      'uploadId': uploadId,
    };
  }
}

/// The result for the UploadPart operation.
class UploadPartResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The ETag that is generated when the object is created.
  String? get etag => commonProp.headers?.getCaseInsensitive('ETag');

  /// Creates a UploadPartResult instance.
  UploadPartResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates an UploadPartResult instance from a JSON map
  factory UploadPartResult.fromJson(Map<String, dynamic> json) {
    return UploadPartResult();
  }

  /// Converts the UploadPartResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the CompleteMultipartUpload operation.
class CompleteMultipartUploadRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// Specifies whether the object with the same object name is overwritten when you call the CompleteMultipartUpload operation.
  /// - If the value of x-oss-forbid-overwrite is not specified or set to false, the existing object can be overwritten by the object that has the same name.
  /// - If the value of x-oss-forbid-overwrite is set to true, the existing object cannot be overwritten by the object that has the same name.
  /// - The x-oss-forbid-overwrite request header is invalid if versioning is enabled or suspended for the bucket. In this case, the existing object can be overwritten by the object that has the same name when you call the CompleteMultipartUpload operation.
  /// - If you specify the x-oss-forbid-overwrite request header, the queries per second (QPS) performance of OSS may be degraded. If you want to configure the x-oss-forbid-overwrite header in a large number of requests (QPS greater than 1,000), submit a ticket.
  bool? forbidOverwrite;

  /// Specifies whether to list all parts that are uploaded by using the current upload ID. Valid value: yes.
  /// - If x-oss-complete-all is set to yes in the request, OSS lists all parts that are uploaded by using the current upload ID, sorts the parts by part number, and then performs the CompleteMultipartUpload operation. When OSS performs the CompleteMultipartUpload operation, OSS cannot detect the parts that are not uploaded or currently being uploaded. Before you call the CompleteMultipartUpload operation, make sure that all parts are uploaded.
  /// - If x-oss-complete-all is specified in the request, the request body cannot be specified. Otherwise, an error occurs.
  /// - If x-oss-complete-all is specified in the request, the format of the response remains unchanged.
  String? completeAll;

  /// The identifier of the multipart upload task.
  String? uploadId;

  /// The encoding type of the object name in the response. Only URL encoding is supported. The object name can contain characters that are encoded in UTF-8. However, the XML 1.0 standard cannot be used to parse control characters, such as characters with an ASCII value from 0 to 10. You can configure this parameter to encode the object name in the response.
  String? encodingType;

  /// A callback parameter is a Base64-encoded string that contains multiple
  /// fields in the JSON format.
  String? callback;

  /// Configure custom parameters by using the callback-var parameter.
  String? callbackVar;

  /// The request body schema.
  CompleteMultipartUpload? completeMultipartUpload;

  /// Creates a CompleteMultipartUploadRequest instance.
  CompleteMultipartUploadRequest({
    this.bucket,
    this.key,
    this.forbidOverwrite,
    this.completeAll,
    this.uploadId,
    this.encodingType,
    this.callback,
    this.callbackVar,
    this.completeMultipartUpload,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a CompleteMultipartUploadRequest instance from a JSON map
  factory CompleteMultipartUploadRequest.fromJson(Map<String, dynamic> json) {
    return CompleteMultipartUploadRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      forbidOverwrite: json['forbidOverwrite'] as bool?,
      completeAll: json['completeAll'] as String?,
      uploadId: json['uploadId'] as String?,
      encodingType: json['encodingType'] as String?,
      callback: json['callback'] as String?,
      callbackVar: json['callbackVar'] as String?,
    );
  }

  /// Converts the CompleteMultipartUploadRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'forbidOverwrite': forbidOverwrite,
      'completeAll': completeAll,
      'uploadId': uploadId,
      'encodingType': encodingType,
      'callback': callback,
      'callbackVar': callbackVar,
    };
  }
}

/// The result for the CompleteMultipartUpload operation.
class CompleteMultipartUploadResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The version ID of the object.
  String? get versionId =>
      commonProp.headers?.getCaseInsensitive('x-oss-version-id');

  /// The name of the uploaded object.
  String? key;

  /// The ETag that is generated when an object is created. ETags are used to identify the content of objects.
  /// If an object is created by calling the CompleteMultipartUpload operation, the ETag value is not the MD5 hash of the object content but a unique value calculated based on a specific rule.
  /// The ETag of an object can be used to check whether the object content is modified. However, we recommend that you use the MD5 hash of an object rather than the ETag value of the object to verify data integrity.
  String? etag;

  /// The encoding type of the object name in the response. If this parameter is specified in the request, the object name is encoded in the response.
  String? encodingType;

  /// The URL that is used to access the uploaded object.
  String? location;

  /// The name of the bucket that contains the object you want to restore.
  String? bucket;

  /// The callback result data.
  List<int>? callbackResult;

  /// Creates a CompleteMultipartUploadResult instance.
  CompleteMultipartUploadResult({
    this.key,
    this.etag,
    this.encodingType,
    this.location,
    this.bucket,
    this.callbackResult,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a CompleteMultipartUploadResult instance from a JSON map
  factory CompleteMultipartUploadResult.fromJson(Map<String, dynamic> json) {
    return CompleteMultipartUploadResult(
      key: json['key'] as String?,
      etag: json['etag'] as String?,
      encodingType: json['encodingType'] as String?,
      location: json['location'] as String?,
      bucket: json['bucket'] as String?,
    );
  }

  /// Converts the CompleteMultipartUploadResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'etag': etag,
      'encodingType': encodingType,
      'location': location,
      'bucket': bucket,
    };
  }
}

/// The request for the UploadPartCopy operation.
class UploadPartCopyRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object.
  String? key;

  /// The name of the source bucket.
  String? sourceBucket;

  /// The name of the source object.
  String? sourceKey;

  /// The range of bytes to copy data from the source object. For example, if you specify bytes to 0 to 9, the system transfers byte 0 to byte 9, a total of 10 bytes.
  /// Default value: null
  /// - If the x-oss-copy-source-range request header is not specified, the entire source object is copied.
  /// - If the x-oss-copy-source-range request header is specified, the response contains the length of the entire object and the range of bytes to be copied for this operation. For example, Content-Range: bytes 0~9/44 indicates that the length of the entire object is 44 bytes. The range of bytes to be copied is byte 0 to byte 9.
  /// - If the specified range does not conform to the range conventions, OSS copies the entire object and does not include Content-Range in the response.
  String? copySourceRange;

  /// The copy operation condition. If the ETag value of the source object is the same as the ETag value provided by the user, OSS copies data. Otherwise, OSS returns 412 Precondition Failed.
  /// Default value: null
  String? copySourceIfMatch;

  /// The object transfer condition. If the input ETag value does not match the ETag value of the object, the system transfers the object normally and returns 200 OK. Otherwise, OSS returns 304 Not Modified.
  /// Default value: null
  String? copySourceIfNoneMatch;

  /// The object transfer condition. If the specified time is the same as or later than the actual modified time of the object, OSS transfers the object normally and returns 200 OK. Otherwise, OSS returns 412 Precondition Failed.
  /// Default value: null
  String? copySourceIfUnmodifiedSince;

  /// The object transfer condition. If the specified time is earlier than the actual modified time of the object, the system transfers the object normally and returns 200 OK. Otherwise, OSS returns 304 Not Modified.
  /// Default value: null
  /// Time format: ddd, dd MMM yyyy HH:mm:ss GMT. Example: Fri, 13 Nov 2015 14:47:53 GMT.
  String? copySourceIfModifiedSince;

  /// The number of parts.
  int? partNumber;

  /// The ID that identifies the object to which the parts to upload belong.
  String? uploadId;

  /// Creates a UploadPartCopyRequest instance.
  UploadPartCopyRequest({
    this.bucket,
    this.key,
    this.sourceBucket,
    this.sourceKey,
    this.copySourceRange,
    this.copySourceIfMatch,
    this.copySourceIfNoneMatch,
    this.copySourceIfUnmodifiedSince,
    this.copySourceIfModifiedSince,
    this.partNumber,
    this.uploadId,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates an UploadPartCopyRequest instance from a JSON map
  factory UploadPartCopyRequest.fromJson(Map<String, dynamic> json) {
    return UploadPartCopyRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      sourceBucket: json['sourceBucket'] as String?,
      sourceKey: json['sourceKey'] as String?,
      copySourceRange: json['copySourceRange'] as String?,
      copySourceIfMatch: json['copySourceIfMatch'] as String?,
      copySourceIfNoneMatch: json['copySourceIfNoneMatch'] as String?,
      copySourceIfUnmodifiedSince:
          json['copySourceIfUnmodifiedSince'] as String?,
      copySourceIfModifiedSince: json['copySourceIfModifiedSince'] as String?,
      partNumber: json['partNumber'] as int?,
      uploadId: json['uploadId'] as String?,
    );
  }

  /// Converts the UploadPartCopyRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'sourceBucket': sourceBucket,
      'sourceKey': sourceKey,
      'copySourceRange': copySourceRange,
      'copySourceIfMatch': copySourceIfMatch,
      'copySourceIfNoneMatch': copySourceIfNoneMatch,
      'copySourceIfUnmodifiedSince': copySourceIfUnmodifiedSince,
      'copySourceIfModifiedSince': copySourceIfModifiedSince,
      'partNumber': partNumber,
      'uploadId': uploadId,
    };
  }
}

/// The result for the UploadPartCopy operation.
class UploadPartCopyResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The version ID of the source object.
  String? get copySourceVersionId =>
      commonProp.headers?.getCaseInsensitive('x-oss-copy-source-version-id');

  /// The container that stores the copy result.
  CopyPartResult? copyPartResult;

  /// Creates a UploadPartCopyResult instance.
  UploadPartCopyResult({this.copyPartResult, ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates an UploadPartCopyResult instance from a JSON map
  factory UploadPartCopyResult.fromJson(Map<String, dynamic> json) {
    return UploadPartCopyResult(
      copyPartResult: json['copyPartResult'] != null
          ? CopyPartResult(
              lastModified: json['copyPartResult']['lastModified'] != null
                  ? DateTime.parse(
                      json['copyPartResult']['lastModified'] as String,
                    )
                  : null,
              etag: json['copyPartResult']['etag'] as String?,
            )
          : null,
    );
  }

  /// Converts the UploadPartCopyResult instance to a JSON map
  Map<String, dynamic> toJson() {
    final copyPartResultJson = copyPartResult != null
        ? {
            'lastModified': copyPartResult!.lastModified?.toIso8601String(),
            'etag': copyPartResult!.etag,
          }
        : null;

    return {'copyPartResult': copyPartResultJson};
  }
}

/// The request for the AbortMultipartUpload operation.
class AbortMultipartUploadRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The full path of the object that you want to upload.
  String? key;

  /// The ID of the multipart upload task.
  String? uploadId;

  /// Creates a request to cancel an in-progress multipart upload task.
  AbortMultipartUploadRequest({
    this.bucket,
    this.key,
    this.uploadId,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates an AbortMultipartUploadRequest instance from a JSON map
  factory AbortMultipartUploadRequest.fromJson(Map<String, dynamic> json) {
    return AbortMultipartUploadRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      uploadId: json['uploadId'] as String?,
    );
  }

  /// Converts the AbortMultipartUploadRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'key': key, 'uploadId': uploadId};
  }
}

/// The result for the AbortMultipartUpload operation.
class AbortMultipartUploadResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// Creates a result for a completed AbortMultipartUpload operation.
  AbortMultipartUploadResult({ResultModelProp? commonProp})
    : commonProp = commonProp ?? ResultModelProp();

  /// Creates an AbortMultipartUploadResult instance from a JSON map
  factory AbortMultipartUploadResult.fromJson(Map<String, dynamic> json) {
    return AbortMultipartUploadResult();
  }

  /// Converts the AbortMultipartUploadResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {};
  }
}

/// The request for the ListMultipartUploads operation.
class ListMultipartUploadsRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The character used to group objects by name. Objects whose names contain the same string that ranges from the specified prefix to the delimiter that appears for the first time are grouped as a CommonPrefixes element.
  String? delimiter;

  /// The maximum number of multipart upload tasks that can be returned for the current request. Default value: 1000. Maximum value: 1000.
  int? maxUploads;

  /// This parameter is used together with the upload-id-marker parameter to specify the position from which the next list begins.
  /// - If the upload-id-marker parameter is not set, Object Storage Service (OSS) returns all multipart upload tasks in which object names are alphabetically after the key-marker value.
  /// - If the upload-id-marker parameter is set, the response includes the following tasks:
  /// - Multipart upload tasks in which object names are alphabetically after the key-marker value in alphabetical order
  /// - Multipart upload tasks in which object names are the same as the key-marker parameter value but whose upload IDs are greater than the upload-id-marker parameter value
  String? keyMarker;

  /// The prefix that the returned object names must contain. If you specify a prefix in the request, the specified prefix is included in the response.You can use prefixes to group and manage objects in buckets in the same way you manage a folder in a file system.
  String? prefix;

  /// The upload ID of the multipart upload task after which the list begins. This parameter is used together with the key-marker parameter.
  /// - If the key-marker parameter is not set, OSS ignores the upload-id-marker parameter.
  /// - If the key-marker parameter is configured, the query result includes:
  /// - Multipart upload tasks in which object names are alphabetically after the key-marker value in alphabetical order
  /// - Multipart upload tasks in which object names are the same as the key-marker parameter value but whose upload IDs are greater than the upload-id-marker parameter value
  String? uploadIdMarker;

  /// The encoding type of the object name in the response. Values of Delimiter, KeyMarker, Prefix, NextKeyMarker, and Key can be encoded in UTF-8. However, the XML 1.0 standard cannot be used to parse control characters such as characters with an American Standard Code for Information Interchange (ASCII) value from 0 to 10. You can set the encoding-type parameter to encode values of Delimiter, KeyMarker, Prefix, NextKeyMarker, and Key in the response.Default value: null
  /// Sees EncodingType for supported values.
  String? encodingType;

  /// Creates a ListMultipartUploadsRequest instance.
  ListMultipartUploadsRequest({
    this.bucket,
    this.delimiter,
    this.maxUploads,
    this.keyMarker,
    this.prefix,
    this.uploadIdMarker,
    this.encodingType,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a ListMultipartUploadsRequest instance from a JSON map
  factory ListMultipartUploadsRequest.fromJson(Map<String, dynamic> json) {
    return ListMultipartUploadsRequest(
      bucket: json['bucket'] as String?,
      delimiter: json['delimiter'] as String?,
      maxUploads: json['maxUploads'] as int?,
      keyMarker: json['keyMarker'] as String?,
      prefix: json['prefix'] as String?,
      uploadIdMarker: json['uploadIdMarker'] as String?,
      encodingType: json['encodingType'] as String?,
    );
  }

  /// Converts the ListMultipartUploadsRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'delimiter': delimiter,
      'maxUploads': maxUploads,
      'keyMarker': keyMarker,
      'prefix': prefix,
      'uploadIdMarker': uploadIdMarker,
      'encodingType': encodingType,
    };
  }
}

/// The result for the ListMultipartUploads operation.
class ListMultipartUploadsResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The method used to encode the object name in the response. If encoding-type is specified in the request, values of those elements including Delimiter, KeyMarker, Prefix, NextKeyMarker, and Key are encoded in the returned result.
  String? encodingType;

  /// The name of the object that corresponds to the multipart upload task after which the list begins.
  String? keyMarker;

  /// The upload ID of the multipart upload task after which the list begins.
  String? uploadIdMarker;

  /// Indicates whether the list of multipart upload tasks returned in the response is truncated. Default value: false. Valid values:
  /// - true: Only part of the results are returned this time.
  /// - false: All results are returned.
  bool? isTruncated;

  /// The character used to group objects by name. If you specify the Delimiter parameter in the request, the response contains the CommonPrefixes element. Objects whose names contain the same string from the prefix to the next occurrence of the delimiter are grouped as a single result element in
  String? delimiter;

  /// The ID list of the multipart upload tasks.
  List<Upload>? uploads;

  /// The name of the bucket.
  String? bucket;

  /// The object name marker in the response for the next request to return the remaining results.
  String? nextKeyMarker;

  /// The NextUploadMarker value that is used for the UploadMarker value in the next request if the response does not contain all required results.
  String? nextUploadIdMarker;

  /// The maximum number of multipart upload tasks returned by OSS.
  int? maxUploads;

  /// The prefix that the returned object names must contain. If you specify a prefix in the request, the specified prefix is included in the response.
  String? prefix;

  /// If the delimiter parameter is specified in the request, the response contains the CommonPrefixes parameter. The objects whose names contain the same string from the prefix to the next occurrence of the delimiter are grouped as a single result element in the CommonPrefixes parameter.
  List<CommonPrefix>? commonPrefixes;

  /// Creates a ListMultipartUploadsResult instance.
  ListMultipartUploadsResult({
    this.encodingType,
    this.keyMarker,
    this.uploadIdMarker,
    this.isTruncated,
    this.delimiter,
    this.uploads,
    this.bucket,
    this.nextKeyMarker,
    this.nextUploadIdMarker,
    this.maxUploads,
    this.prefix,
    this.commonPrefixes,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a ListMultipartUploadsResult instance from a JSON map
  factory ListMultipartUploadsResult.fromJson(Map<String, dynamic> json) {
    return ListMultipartUploadsResult(
      encodingType: json['encodingType'] as String?,
      keyMarker: json['keyMarker'] as String?,
      uploadIdMarker: json['uploadIdMarker'] as String?,
      isTruncated: json['isTruncated'] as bool?,
      delimiter: json['delimiter'] as String?,
      uploads: json['uploads'] != null
          ? (json['uploads'] as List)
                .map((e) => Upload.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      bucket: json['bucket'] as String?,
      nextKeyMarker: json['nextKeyMarker'] as String?,
      nextUploadIdMarker: json['nextUploadIdMarker'] as String?,
      maxUploads: json['maxUploads'] as int?,
      prefix: json['prefix'] as String?,
      commonPrefixes: json['commonPrefixes'] != null
          ? (json['commonPrefixes'] as List)
                .map((e) => CommonPrefix.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  /// Converts the ListMultipartUploadsResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'encodingType': encodingType,
      'keyMarker': keyMarker,
      'uploadIdMarker': uploadIdMarker,
      'isTruncated': isTruncated,
      'delimiter': delimiter,
      'uploads': uploads?.map((e) => e.toJson()).toList(),
      'bucket': bucket,
      'nextKeyMarker': nextKeyMarker,
      'nextUploadIdMarker': nextUploadIdMarker,
      'maxUploads': maxUploads,
      'prefix': prefix,
      'commonPrefixes': commonPrefixes?.map((e) => e.toJson()).toList(),
    };
  }
}

/// The request for the ListParts operation.
class ListPartsRequest extends RequestModel {
  @override
  /// Shared request properties such as headers and query parameters.
  RequestModelProp commonProp;

  /// The name of the bucket.
  String? bucket;

  /// The name of the object.
  String? key;

  /// The ID of the multipart upload task.By default, this parameter is left empty.
  String? uploadId;

  /// The maximum number of parts that can be returned by OSS.Default value: 1000.Maximum value: 1000.
  int? maxParts;

  /// The position from which the list starts. All parts whose part numbers are greater than the value of this parameter are listed.By default, this parameter is left empty.
  int? partNumberMarker;

  /// The maximum number of parts that can be returned by OSS. Default value: 1000.Maximum value: 1000.
  /// Sees EncodingType for supported values.
  String? encodingType;

  /// Creates a ListPartsRequest instance.
  ListPartsRequest({
    this.bucket,
    this.key,
    this.uploadId,
    this.maxParts,
    this.partNumberMarker,
    this.encodingType,
    RequestModelProp? commonProp,
  }) : commonProp = commonProp ?? RequestModelProp();

  /// Creates a ListPartsRequest instance from a JSON map
  factory ListPartsRequest.fromJson(Map<String, dynamic> json) {
    return ListPartsRequest(
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      uploadId: json['uploadId'] as String?,
      maxParts: json['maxParts'] as int?,
      partNumberMarker: json['partNumberMarker'] as int?,
      encodingType: json['encodingType'] as String?,
    );
  }

  /// Converts the ListPartsRequest instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'key': key,
      'uploadId': uploadId,
      'maxParts': maxParts,
      'partNumberMarker': partNumberMarker,
      'encodingType': encodingType,
    };
  }
}

/// The result for the ListParts operation.
class ListPartsResult extends ResultModel {
  @override
  /// Shared result properties such as response headers and status metadata.
  ResultModelProp commonProp;

  /// The maximum number of parts in the response.
  int? maxParts;

  /// Indicates whether the list of parts returned in the response has been truncated. A value of true indicates that the response does not contain all required results. A value of false indicates that the response contains all required results.Valid values: true and false.
  bool? isTruncated;

  /// The list of all parts.
  List<Part>? parts;

  /// The name of the bucket.
  String? bucket;

  /// The name of the object.
  String? key;

  /// The ID of the upload task.
  String? uploadId;

  /// The position from which the list starts. All parts whose part numbers are greater than the value of this parameter are listed.
  int? partNumberMarker;

  /// The NextPartNumberMarker value that is used for the PartNumberMarker value in a subsequent request when the response does not contain all required results.
  int? nextPartNumberMarker;

  /// The encoding type of the object name in the response.
  String? encodingType;

  /// Creates a ListPartsResult instance.
  ListPartsResult({
    this.maxParts,
    this.isTruncated,
    this.parts,
    this.bucket,
    this.key,
    this.uploadId,
    this.partNumberMarker,
    this.nextPartNumberMarker,
    this.encodingType,
    ResultModelProp? commonProp,
  }) : commonProp = commonProp ?? ResultModelProp();

  /// Creates a ListPartsResult instance from a JSON map
  factory ListPartsResult.fromJson(Map<String, dynamic> json) {
    return ListPartsResult(
      maxParts: json['maxParts'] as int?,
      isTruncated: json['isTruncated'] as bool?,
      parts: json['parts'] != null
          ? (json['parts'] as List)
                .map((e) => Part.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      bucket: json['bucket'] as String?,
      key: json['key'] as String?,
      uploadId: json['uploadId'] as String?,
      partNumberMarker: json['partNumberMarker'] as int?,
      nextPartNumberMarker: json['nextPartNumberMarker'] as int?,
      encodingType: json['encodingType'] as String?,
    );
  }

  /// Converts the ListPartsResult instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'maxParts': maxParts,
      'isTruncated': isTruncated,
      'parts': parts?.map((e) => e.toJson()).toList(),
      'bucket': bucket,
      'key': key,
      'uploadId': uploadId,
      'partNumberMarker': partNumberMarker,
      'nextPartNumberMarker': nextPartNumberMarker,
      'encodingType': encodingType,
    };
  }
}
