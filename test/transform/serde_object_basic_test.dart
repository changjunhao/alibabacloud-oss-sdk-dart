import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_object_basic.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_object_basic.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeObjectBasic Tests', () {
    // ============================================================
    // MARK: - Serialize Tests
    // ============================================================

    test('testSerializePutObject', () async {
      // Scenario 1: Empty request
      var request = PutObjectRequest();
      var input = OperationInput(operationName: 'PutObject', method: 'PUT');
      SerdeObjectBasic.serializePutObject(request, input);
      expect(input.headers['x-oss-forbid-overwrite'], isNull);
      expect(input.headers['x-oss-storage-class'], isNull);
      expect(input.headers['x-oss-object-acl'], isNull);
      expect(input.body, isNull);

      // Scenario 2: Request with all parameters
      final bodyData = Uint8List.fromList(utf8.encode('hello world'));
      request = PutObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        forbidOverwrite: true,
        storageClass: 'IA',
        objectAcl: 'private',
        serverSideEncryption: 'AES256',
        serverSideDataEncryption: 'SM4',
        serverSideEncryptionKeyId: 'key-id-123',
        tagging: 'TagA=A&TagB=B',
        cacheControl: 'no-cache',
        contentDisposition: 'attachment',
        contentEncoding: 'gzip',
        expires: 'Thu, 01 Dec 2025 16:00:00 GMT',
        contentMd5: 'md5-value',
        contentType: 'text/plain',
        callback: 'callback-value',
        callbackVar: 'callback-var-value',
        trafficLimit: 245760,
        metadata: {'author': 'test-user', 'year': '2024'},
        body: ByteStream.fromData(bodyData),
      );
      input = OperationInput(operationName: 'PutObject', method: 'PUT');
      SerdeObjectBasic.serializePutObject(request, input);

      expect(input.headers['x-oss-forbid-overwrite'], equals('true'));
      expect(input.headers['x-oss-storage-class'], equals('IA'));
      expect(input.headers['x-oss-object-acl'], equals('private'));
      expect(input.headers['x-oss-server-side-encryption'], equals('AES256'));
      expect(input.headers['x-oss-server-side-data-encryption'], equals('SM4'));
      expect(
        input.headers['x-oss-server-side-encryption-key-id'],
        equals('key-id-123'),
      );
      expect(input.headers['x-oss-tagging'], equals('TagA=A&TagB=B'));
      expect(input.headers['Cache-Control'], equals('no-cache'));
      expect(input.headers['Content-Disposition'], equals('attachment'));
      expect(input.headers['Content-Encoding'], equals('gzip'));
      expect(input.headers['Expires'], equals('Thu, 01 Dec 2025 16:00:00 GMT'));
      expect(input.headers['Content-MD5'], equals('md5-value'));
      expect(input.headers['Content-Type'], equals('text/plain'));
      expect(input.headers['x-oss-callback'], equals('callback-value'));
      expect(input.headers['x-oss-callback-var'], equals('callback-var-value'));
      expect(input.headers['x-oss-traffic-limit'], equals('245760'));
      expect(input.headers['x-oss-meta-author'], equals('test-user'));
      expect(input.headers['x-oss-meta-year'], equals('2024'));
      expect(input.body, isNotNull);
    });

    test('testSerializeCopyObject', () async {
      // Scenario 1: Empty request
      var request = CopyObjectRequest();
      var input = OperationInput(operationName: 'CopyObject', method: 'PUT');
      SerdeObjectBasic.serializeCopyObject(request, input);
      expect(input.headers['x-oss-copy-source'], isNull);

      // Scenario 2: Request with copy-source and conditional headers
      request = CopyObjectRequest(
        bucket: 'dest-bucket',
        key: 'dest-key',
        sourceBucket: 'src-bucket',
        sourceKey: 'src-key',
        forbidOverwrite: true,
        copySourceIfMatch: '"etag-value"',
        copySourceIfNoneMatch: '"etag-none"',
        copySourceIfUnmodifiedSince: 'Fri, 13 Nov 2015 14:47:53 GMT',
        copySourceIfModifiedSince: 'Thu, 12 Nov 2015 14:47:53 GMT',
        metadataDirective: 'REPLACE',
        serverSideEncryption: 'KMS',
        serverSideDataEncryption: 'SM4',
        serverSideEncryptionKeyId: 'kms-key-123',
        objectAcl: 'public-read',
        storageClass: 'Standard',
        tagging: 'key1=value1',
        taggingDirective: 'Replace',
        cacheControl: 'max-age=3600',
        contentDisposition: 'inline',
        contentEncoding: 'identity',
        expires: 'Thu, 01 Dec 2025 16:00:00 GMT',
        contentMd5: 'copy-md5',
        contentType: 'application/json',
        trafficLimit: 838860800,
        metadata: {'custom': 'value'},
      );
      input = OperationInput(operationName: 'CopyObject', method: 'PUT');
      SerdeObjectBasic.serializeCopyObject(request, input);

      expect(input.headers['x-oss-copy-source'], equals('/src-bucket/src-key'));
      expect(input.headers['x-oss-forbid-overwrite'], equals('true'));
      expect(
        input.headers['x-oss-copy-source-if-match'],
        equals('"etag-value"'),
      );
      expect(
        input.headers['x-oss-copy-source-if-none-match'],
        equals('"etag-none"'),
      );
      expect(
        input.headers['x-oss-copy-source-if-unmodified-since'],
        equals('Fri, 13 Nov 2015 14:47:53 GMT'),
      );
      expect(
        input.headers['x-oss-copy-source-if-modified-since'],
        equals('Thu, 12 Nov 2015 14:47:53 GMT'),
      );
      expect(input.headers['x-oss-metadata-directive'], equals('REPLACE'));
      expect(input.headers['x-oss-server-side-encryption'], equals('KMS'));
      expect(input.headers['x-oss-server-side-data-encryption'], equals('SM4'));
      expect(
        input.headers['x-oss-server-side-encryption-key-id'],
        equals('kms-key-123'),
      );
      expect(input.headers['x-oss-object-acl'], equals('public-read'));
      expect(input.headers['x-oss-storage-class'], equals('Standard'));
      expect(input.headers['x-oss-tagging'], equals('key1=value1'));
      expect(input.headers['x-oss-tagging-directive'], equals('Replace'));
      expect(input.headers['Cache-Control'], equals('max-age=3600'));
      expect(input.headers['Content-Disposition'], equals('inline'));
      expect(input.headers['Content-Encoding'], equals('identity'));
      expect(input.headers['Expires'], equals('Thu, 01 Dec 2025 16:00:00 GMT'));
      expect(input.headers['Content-MD5'], equals('copy-md5'));
      expect(input.headers['Content-Type'], equals('application/json'));
      expect(input.headers['x-oss-traffic-limit'], equals('838860800'));
      expect(input.headers['x-oss-meta-custom'], equals('value'));
    });

    test('testSerializeGetObject', () async {
      // Scenario 1: Empty request
      var request = GetObjectRequest();
      var input = OperationInput(operationName: 'GetObject', method: 'GET');
      SerdeObjectBasic.serializeGetObject(request, input);
      expect(input.headers['Range'], isNull);
      expect(input.parameters['versionId'], isNull);

      // Scenario 2: Request with Range, conditional headers, and response params
      request = GetObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        range: 'bytes=0-99',
        rangeBehavior: 'standard',
        ifModifiedSince: 'Fri, 13 Nov 2015 14:47:53 GMT',
        ifUnmodifiedSince: 'Fri, 13 Nov 2015 14:47:53 GMT',
        ifMatch: '"etag-123"',
        ifNoneMatch: '"etag-456"',
        acceptEncoding: 'gzip',
        responseContentType: 'application/octet-stream',
        responseContentLanguage: 'en-US',
        responseExpires: 'Thu, 01 Dec 2025 16:00:00 GMT',
        responseCacheControl: 'no-cache',
        responseContentDisposition: 'attachment; filename="test.txt"',
        responseContentEncoding: 'identity',
        versionId: 'version-abc-123',
        trafficLimit: 245760,
        process: 'image/resize,w_100',
      );
      input = OperationInput(operationName: 'GetObject', method: 'GET');
      SerdeObjectBasic.serializeGetObject(request, input);

      expect(input.headers['Range'], equals('bytes=0-99'));
      expect(input.headers['x-oss-range-behavior'], equals('standard'));
      expect(
        input.headers['If-Modified-Since'],
        equals('Fri, 13 Nov 2015 14:47:53 GMT'),
      );
      expect(
        input.headers['If-Unmodified-Since'],
        equals('Fri, 13 Nov 2015 14:47:53 GMT'),
      );
      expect(input.headers['If-Match'], equals('"etag-123"'));
      expect(input.headers['If-None-Match'], equals('"etag-456"'));
      expect(input.headers['Accept-Encoding'], equals('gzip'));
      expect(
        input.parameters['response-content-type'],
        equals('application/octet-stream'),
      );
      expect(input.parameters['response-content-language'], equals('en-US'));
      expect(
        input.parameters['response-expires'],
        equals('Thu, 01 Dec 2025 16:00:00 GMT'),
      );
      expect(input.parameters['response-cache-control'], equals('no-cache'));
      expect(
        input.parameters['response-content-disposition'],
        equals('attachment; filename="test.txt"'),
      );
      expect(input.parameters['response-content-encoding'], equals('identity'));
      expect(input.parameters['versionId'], equals('version-abc-123'));
      expect(input.headers['x-oss-traffic-limit'], equals('245760'));
      expect(input.headers['x-oss-process'], equals('image/resize,w_100'));
    });

    test('testSerializeAppendObject', () async {
      // Scenario 1: Empty request
      var request = AppendObjectRequest();
      var input = OperationInput(operationName: 'AppendObject', method: 'POST');
      SerdeObjectBasic.serializeAppendObject(request, input);
      expect(input.parameters['position'], isNull);
      expect(input.body, isNull);

      // Scenario 2: Request with position and headers
      final bodyData = Uint8List.fromList(utf8.encode('append data'));
      request = AppendObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        position: 65536,
        serverSideEncryption: 'AES256',
        objectAcl: 'private',
        storageClass: 'Standard',
        cacheControl: 'no-cache',
        contentDisposition: 'inline',
        contentEncoding: 'gzip',
        contentMd5: 'append-md5',
        contentType: 'text/plain',
        expires: 'Thu, 01 Dec 2025 16:00:00 GMT',
        trafficLimit: 500000,
        metadata: {'tag': 'test'},
        body: ByteStream.fromData(bodyData),
      );
      input = OperationInput(operationName: 'AppendObject', method: 'POST');
      SerdeObjectBasic.serializeAppendObject(request, input);

      expect(input.parameters['position'], equals('65536'));
      expect(input.headers['x-oss-server-side-encryption'], equals('AES256'));
      expect(input.headers['x-oss-object-acl'], equals('private'));
      expect(input.headers['x-oss-storage-class'], equals('Standard'));
      expect(input.headers['Cache-Control'], equals('no-cache'));
      expect(input.headers['Content-Disposition'], equals('inline'));
      expect(input.headers['Content-Encoding'], equals('gzip'));
      expect(input.headers['Content-MD5'], equals('append-md5'));
      expect(input.headers['Content-Type'], equals('text/plain'));
      expect(input.headers['Expires'], equals('Thu, 01 Dec 2025 16:00:00 GMT'));
      expect(input.headers['x-oss-traffic-limit'], equals('500000'));
      expect(input.headers['x-oss-meta-tag'], equals('test'));
      expect(input.body, isNotNull);
    });

    test('testSerializeDeleteObject', () async {
      // Scenario 1: Empty request (no versionId)
      var request = DeleteObjectRequest();
      var input = OperationInput(
        operationName: 'DeleteObject',
        method: 'DELETE',
      );
      SerdeObjectBasic.serializeDeleteObject(request, input);
      expect(input.parameters['versionId'], isNull);

      // Scenario 2: Request with versionId
      request = DeleteObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        versionId:
            'CAEQNRiBgIDyz.6C0BYiIDc4MGZjZGI2OTBjOTRmNTE5NmU5NmFhZjhjYmY0',
      );
      input = OperationInput(operationName: 'DeleteObject', method: 'DELETE');
      SerdeObjectBasic.serializeDeleteObject(request, input);
      expect(
        input.parameters['versionId'],
        equals('CAEQNRiBgIDyz.6C0BYiIDc4MGZjZGI2OTBjOTRmNTE5NmU5NmFhZjhjYmY0'),
      );
    });

    test('testSerializeHeadObject', () async {
      // Scenario 1: Empty request
      var request = HeadObjectRequest();
      var input = OperationInput(operationName: 'HeadObject', method: 'HEAD');
      SerdeObjectBasic.serializeHeadObject(request, input);
      expect(input.headers['If-Modified-Since'], isNull);
      expect(input.headers['If-Unmodified-Since'], isNull);
      expect(input.headers['If-Match'], isNull);
      expect(input.headers['If-None-Match'], isNull);
      expect(input.parameters['versionId'], isNull);

      // Scenario 2: Request with conditional headers and versionId
      request = HeadObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        ifModifiedSince: 'Fri, 13 Nov 2015 14:47:53 GMT',
        ifUnmodifiedSince: 'Sat, 14 Nov 2015 14:47:53 GMT',
        ifMatch: '"etag-match"',
        ifNoneMatch: '"etag-none-match"',
        versionId: 'version-head-123',
      );
      input = OperationInput(operationName: 'HeadObject', method: 'HEAD');
      SerdeObjectBasic.serializeHeadObject(request, input);

      expect(
        input.headers['If-Modified-Since'],
        equals('Fri, 13 Nov 2015 14:47:53 GMT'),
      );
      expect(
        input.headers['If-Unmodified-Since'],
        equals('Sat, 14 Nov 2015 14:47:53 GMT'),
      );
      expect(input.headers['If-Match'], equals('"etag-match"'));
      expect(input.headers['If-None-Match'], equals('"etag-none-match"'));
      expect(input.parameters['versionId'], equals('version-head-123'));
    });

    test('testSerializeGetObjectMeta', () async {
      // Scenario 1: Empty request
      var request = GetObjectMetaRequest();
      var input = OperationInput(
        operationName: 'GetObjectMeta',
        method: 'HEAD',
      );
      SerdeObjectBasic.serializeGetObjectMeta(request, input);
      expect(input.parameters['versionId'], isNull);

      // Scenario 2: Request with versionId
      request = GetObjectMetaRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        versionId: 'version-meta-456',
      );
      input = OperationInput(operationName: 'GetObjectMeta', method: 'HEAD');
      SerdeObjectBasic.serializeGetObjectMeta(request, input);
      expect(input.parameters['versionId'], equals('version-meta-456'));
    });

    test('testSerializeDeleteMultipleObjects', () async {
      // Scenario 1: Request with quiet and objects
      final request = DeleteMultipleObjectsRequest(
        bucket: 'test-bucket',
        quiet: true,
        encodingType: 'url',
        objects: [
          DeleteObject(key: 'key1'),
          DeleteObject(key: 'key2', versionId: 'vid-123'),
        ],
      );
      final input = OperationInput(
        operationName: 'DeleteMultipleObjects',
        method: 'POST',
      );
      SerdeObjectBasic.serializeDeleteMultipleObjects(request, input);

      expect(input.headers['Encoding-Type'], equals('url'));
      expect(input.body, isNotNull);

      // Verify the XML body content
      final data = await input.body!.readData();
      final xmlString = utf8.decode(data!);
      expect(xmlString, contains('<Delete>'));
      expect(xmlString, contains('<Quiet>true</Quiet>'));
      expect(xmlString, contains('<Object><Key>key1</Key></Object>'));
      expect(
        xmlString,
        contains(
          '<Object><Key>key2</Key><VersionId>vid-123</VersionId></Object>',
        ),
      );
      expect(xmlString, contains('</Delete>'));
    });

    test('testSerializeRestoreObject', () async {
      // Scenario 1: Request with versionId and restore parameters
      final request = RestoreObjectRequest(
        bucket: 'test-bucket',
        key: 'test-key',
        versionId: 'version-restore-789',
        restoreRequest: RestoreRequest(
          days: 2,
          jobParameters: JobParameters(tier: 'Standard'),
        ),
      );
      final input = OperationInput(
        operationName: 'RestoreObject',
        method: 'POST',
      );
      SerdeObjectBasic.serializeRestoreObject(request, input);

      expect(input.parameters['versionId'], equals('version-restore-789'));
      expect(input.body, isNotNull);

      // Verify the XML body content
      final data = await input.body!.readData();
      final xmlString = utf8.decode(data!);
      expect(xmlString, contains('<RestoreRequest>'));
      expect(xmlString, contains('<Days>2</Days>'));
      expect(
        xmlString,
        contains('<JobParameters><Tier>Standard</Tier></JobParameters>'),
      );
      expect(xmlString, contains('</RestoreRequest>'));
    });

    // ============================================================
    // MARK: - Deserialize Tests
    // ============================================================

    test('testDeserializeCopyObject', () async {
      // Scenario 1: null body throws exception
      final output1 = OperationOutput(statusCode: 200, headers: {});
      final result1 = CopyObjectResult();
      expect(
        () async =>
            await SerdeObjectBasic.deserializeCopyObject(result1, output1),
        throwsA(isA<ClientError>()),
      );

      // Scenario 2: Normal XML response
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<CopyObjectResult>
  <ETag>"5B3C1A2E053D763E1B002CC607C5A0FE1"</ETag>
  <LastModified>2024-01-01T12:00:00.000Z</LastModified>
</CopyObjectResult>''';

      final output2 = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      final result2 = CopyObjectResult();
      await SerdeObjectBasic.deserializeCopyObject(result2, output2);

      expect(result2.etag, equals('"5B3C1A2E053D763E1B002CC607C5A0FE1"'));
      expect(result2.lastModified, equals('2024-01-01T12:00:00.000Z'));
    });

    test('testDeserializeHeadObject', () async {
      // HeadObject deserialize is a no-op, but we verify the result
      // properties are populated from headers via commonProp
      final output = OperationOutput(
        statusCode: 200,
        headers: {
          'Content-Type': 'text/plain',
          'Content-Length': '1024',
          'ETag': '"etag-head-object"',
          'x-oss-object-type': 'Normal',
          'x-oss-storage-class': 'Standard',
          'x-oss-meta-author': 'test-user',
          'x-oss-meta-year': '2024',
          'Last-Modified': 'Fri, 13 Nov 2015 14:47:53 GMT',
          'x-oss-version-id': 'version-123',
          'x-oss-hash-crc64ecma': '1234567890',
        },
      );
      final result = HeadObjectResult();

      // Use Serde.deserializeOutput to populate commonProp from output
      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeObjectBasic.deserializeHeadObject],
      );

      // Verify header-based properties
      expect(result.contentType, equals('text/plain'));
      expect(result.contentLength, equals(1024));
      expect(result.etag, equals('"etag-head-object"'));
      expect(result.objectType, equals('Normal'));
      expect(result.storageClass, equals('Standard'));
      expect(result.lastModified, equals('Fri, 13 Nov 2015 14:47:53 GMT'));
      expect(result.versionId, equals('version-123'));
      expect(result.hashCrc64ecma, equals(1234567890));

      // Verify metadata
      final metadata = result.metadata;
      expect(metadata, isNotNull);
      expect(metadata!['author'], equals('test-user'));
      expect(metadata['year'], equals('2024'));
    });

    test('testDeserializeDeleteMultipleObjects', () async {
      // Scenario 1: null body throws exception
      final output1 = OperationOutput(statusCode: 200, headers: {});
      final result1 = DeleteMultipleObjectsResult();
      expect(
        () async => await SerdeObjectBasic.deserializeDeleteMultipleObjects(
          result1,
          output1,
        ),
        throwsA(isA<ClientError>()),
      );

      // Scenario 2: Normal XML response with multiple deleted objects
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<DeleteResult>
  <Deleted>
    <Key>key1</Key>
  </Deleted>
  <Deleted>
    <Key>key2</Key>
    <DeleteMarker>true</DeleteMarker>
    <DeleteMarkerVersionId>vid1</DeleteMarkerVersionId>
  </Deleted>
</DeleteResult>''';

      final output2 = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      final result2 = DeleteMultipleObjectsResult();
      await SerdeObjectBasic.deserializeDeleteMultipleObjects(result2, output2);

      expect(result2.deletedObjects, isNotNull);
      expect(result2.deletedObjects!.length, equals(2));
      expect(result2.deletedObjects![0].key, equals('key1'));
      expect(result2.deletedObjects![0].deleteMarker, isNull);
      expect(result2.deletedObjects![1].key, equals('key2'));
      expect(result2.deletedObjects![1].deleteMarker, equals(true));
      expect(result2.deletedObjects![1].deleteMarkerVersionId, equals('vid1'));
    });

    test('testDeserializeDeleteMultipleObjectsSingleObject', () async {
      // Test with single deleted object (non-list case)
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<DeleteResult>
  <Deleted>
    <Key>single-key</Key>
    <VersionId>ver-001</VersionId>
  </Deleted>
</DeleteResult>''';

      final output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      final result = DeleteMultipleObjectsResult();
      await SerdeObjectBasic.deserializeDeleteMultipleObjects(result, output);

      expect(result.deletedObjects, isNotNull);
      expect(result.deletedObjects!.length, equals(1));
      expect(result.deletedObjects![0].key, equals('single-key'));
      expect(result.deletedObjects![0].versionId, equals('ver-001'));
    });
  });
}
