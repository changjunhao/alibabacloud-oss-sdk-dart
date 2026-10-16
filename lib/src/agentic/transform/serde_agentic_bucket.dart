import 'dart:convert';
import 'dart:typed_data';
import '../../models/model_bucket_basic.dart';
import '../../models/model_shared.dart';
import '../../models/model_types.dart';
import '../../types/byte_stream.dart';
import '../../types/operation_input.dart';
import '../../types/operation_output.dart';
import '../../transform/serde_functions.dart';
import '../../transform/serde_extensions.dart';
import '../../utils/oss_utils.dart';
import '../models/model_agentic_bucket.dart';

/// Protocol serialization for Agentic management operations, reusing the core public Serde.
abstract final class SerdeAgenticBucket {
  static const _emptyMd5 = '1B2M2Y8AsgTpgAmY7PhCfg==';

  /// Sets an empty content MD5 for bodyless management requests.
  static Future<void> serializeBodyless(
    RequestModel request,
    OperationInput input,
  ) async {
    input.headers['Content-MD5'] = _emptyMd5;
  }

  /// Serializes the creation configuration; no XML is generated when configuration is absent.
  static Future<void> serializeCreateAgenticBucket(
    CreateAgenticBucketRequest request,
    OperationInput input,
  ) async {
    final config = request.createAgenticBucketConfiguration;
    if (config == null) {
      await serializeBodyless(request, input);
      return;
    }
    final xml = StringBuffer(
      '<?xml version="1.0" encoding="UTF-8"?><CreateAgenticBucketConfiguration>',
    );
    if (config.storageClass != null) {
      xml.write(
        '<StorageClass>${config.storageClass!.escape()}</StorageClass>',
      );
    }
    if (config.dataRedundancyType != null) {
      xml.write(
        '<DataRedundancyType>${config.dataRedundancyType!.escape()}</DataRedundancyType>',
      );
    }
    xml.write('</CreateAgenticBucketConfiguration>');
    input.body = ByteStream.fromData(
      Uint8List.fromList(utf8.encode(xml.toString())),
    );
  }

  /// Serializes the status XML; required-field validation is performed by the API layer.
  static Future<void> serializePutAgenticBucketStatus(
    PutAgenticBucketStatusRequest request,
    OperationInput input,
  ) async {
    if (request.status == null) {
      await serializeBodyless(request, input);
      return;
    }
    final xml =
        '<?xml version="1.0" encoding="UTF-8"?><AgenticBucketStatus><Status>${request.status!.escape()}</Status></AgenticBucketStatus>';
    input.body = ByteStream.fromData(Uint8List.fromList(utf8.encode(xml)));
  }

  /// Serializes region-level listing parameters.
  static Future<void> serializeListAgenticBuckets(
    ListAgenticBucketsRequest request,
    OperationInput input,
  ) async {
    if (request.continuationToken != null) {
      input.parameters['continuation-token'] = request.continuationToken;
    }
    if (request.maxKeys != null) {
      input.parameters['max-keys'] = request.maxKeys.toString();
    }
    await serializeBodyless(request, input);
  }

  /// Serializes BucketSpace listing parameters.
  static Future<void> serializeListBucketSpaces(
    ListBucketSpacesRequest request,
    OperationInput input,
  ) async {
    if (request.prefix != null) {
      input.parameters['prefix'] = request.prefix;
    }
    if (request.continuationToken != null) {
      input.parameters['continuation-token'] = request.continuationToken;
    }
    if (request.startAfter != null) {
      input.parameters['start-after'] = request.startAfter;
    }
    if (request.maxKeys != null) {
      input.parameters['max-keys'] = request.maxKeys.toString();
    }
    await serializeBodyless(request, input);
  }

  static ServerSideEncryptionRule _parseSse(Map<String, dynamic> node) {
    final nested = node['ApplyServerSideEncryptionByDefault'];
    final base = nested is Map<String, dynamic> ? nested : node;
    return ServerSideEncryptionRule(
      kmsDataEncryption: base['KMSDataEncryption'] as String?,
      sseAlgorithm: base['SSEAlgorithm'] as String?,
      kmsMasterKeyId: base['KMSMasterKeyID'] as String?,
    );
  }

  /// Parses AgenticBucket information, including both SSE XML shapes.
  static Future<void> deserializeGetAgenticBucket(
    GetAgenticBucketResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'AgenticBucketInfo',
    );
    final sse = body['ServerSideEncryptionRule'];
    result.agenticBucketInfo = AgenticBucketInfo(
      name: body['Name'] as String?,
      owner: body['Owner'] as String?,
      region: body['Region'] as String?,
      storageClass: body['StorageClass'] as String?,
      dataRedundancyType: body['DataRedundancyType'] as String?,
      status: body['Status'] as String?,
      bucketResourceType: body['BucketResourceType'] as String?,
      createTime: body['CreateTime'] as String?,
      acl: body['ACL'] as String?,
      publicAccessBlock: body['PublicAccessBlock'] as String?,
      serverSideEncryptionRule: sse is Map<String, dynamic>
          ? _parseSse(sse)
          : null,
      versioning: body['Versioning'] as String?,
      bucketPolicy: body['BucketPolicy'] as String?,
    );
  }

  static List<Map<String, dynamic>>? _items(Object? wrapper, String tag) {
    if (wrapper is! Map<String, dynamic>) return null;
    final items = wrapper[tag];
    if (items is Map<String, dynamic>) return [items];
    if (items is List) return items.cast<Map<String, dynamic>>();
    return null;
  }

  /// Parses the AgenticBucket listing, preserving server-side raw timestamps and owner strings.
  static Future<void> deserializeListAgenticBuckets(
    ListAgenticBucketsResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'ListAgenticBucketsResult',
    );
    result.region = body['Region'] as String?;
    result.owner = body['Owner'] as String?;
    result.continuationToken = body['ContinuationToken'] as String?;
    result.nextContinuationToken = body['NextContinuationToken'] as String?;
    result.isTruncated = (body['IsTruncated'] as String?)?.toBool();
    result.agenticBuckets = _items(body['AgenticBuckets'], 'AgenticBucket')
        ?.map(
          (item) => AgenticBucketSummary(
            name: item['Name'] as String?,
            storageClass: item['StorageClass'] as String?,
            dataRedundancyType: item['DataRedundancyType'] as String?,
            createTime: item['CreateTime'] as String?,
          ),
        )
        .toList();
  }

  /// Parses the BucketSpace listing and nested Owner.
  static Future<void> deserializeListBucketSpaces(
    ListBucketSpacesResult result,
    OperationOutput output,
  ) async {
    final body = await Serde.deserializeXmlWithRoot<Map<String, dynamic>>(
      output.body,
      'ListBucketSpacesResult',
    );
    final owner = body['Owner'];
    if (owner is Map<String, dynamic>) {
      result.owner = Owner(
        id: owner['ID'] as String?,
        displayName: owner['DisplayName'] as String?,
      );
    }
    result.prefix = body['Prefix'] as String?;
    result.maxKeys = (body['MaxKeys'] as String?)?.toInt();
    result.continuationToken = body['ContinuationToken'] as String?;
    result.nextContinuationToken = body['NextContinuationToken'] as String?;
    result.startAfter = body['StartAfter'] as String?;
    result.isTruncated = (body['IsTruncated'] as String?)?.toBool();
    result.bucketSpaces = _items(body['BucketSpaces'], 'BucketSpace')
        ?.map(
          (item) => BucketSpaceSummary(
            name: item['Name'] as String?,
            location: item['Location'] as String?,
            creationDate: item['CreationDate'] as String?,
            storageClass: item['StorageClass'] as String?,
          ),
        )
        .toList();
  }
}
