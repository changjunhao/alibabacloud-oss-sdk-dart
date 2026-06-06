import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_object_multipart.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_object_multipart.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeObjectMultipart Tests', () {
    // ===== Serialization Tests =====

    test('testSerializeInitiateMultipartUpload', () async {
      var input = OperationInput(
        operationName: 'InitiateMultipartUpload',
        method: 'POST',
      );

      // Test with empty request
      var request = InitiateMultipartUploadRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeObjectMultipart.serializeInitiateMultipartUpload,
        ],
      );
      expect(input.headers['x-oss-forbid-overwrite'], isNull);
      expect(input.headers['x-oss-storage-class'], isNull);
      expect(input.headers['x-oss-server-side-encryption'], isNull);
      expect(input.parameters['encoding-type'], isNull);

      // Test with all fields set
      input = OperationInput(
        operationName: 'InitiateMultipartUpload',
        method: 'POST',
      );
      request = InitiateMultipartUploadRequest(
        forbidOverwrite: true,
        storageClass: 'Standard',
        tagging: 'TagA=A&TagB=B',
        serverSideEncryption: 'KMS',
        serverSideDataEncryption: 'SM4',
        serverSideEncryptionKeyId: 'key-id-123',
        cacheControl: 'no-cache',
        contentDisposition: 'attachment',
        contentEncoding: 'gzip',
        expires: 'Wed, 08 Jul 2023 16:00:00 GMT',
        encodingType: 'url',
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeObjectMultipart.serializeInitiateMultipartUpload,
        ],
      );
      expect(input.headers['x-oss-forbid-overwrite'], equals('true'));
      expect(input.headers['x-oss-storage-class'], equals('Standard'));
      expect(input.headers['x-oss-tagging'], equals('TagA=A&TagB=B'));
      expect(input.headers['x-oss-server-side-encryption'], equals('KMS'));
      expect(input.headers['x-oss-server-side-data-encryption'], equals('SM4'));
      expect(
        input.headers['x-oss-server-side-encryption-key-id'],
        equals('key-id-123'),
      );
      expect(input.headers['Cache-Control'], equals('no-cache'));
      expect(input.headers['Content-Disposition'], equals('attachment'));
      expect(input.headers['Content-Encoding'], equals('gzip'));
      expect(input.headers['Expires'], equals('Wed, 08 Jul 2023 16:00:00 GMT'));
      expect(input.parameters['encoding-type'], equals('url'));
    });

    test('testSerializeUploadPart', () async {
      var input = OperationInput(operationName: 'UploadPart', method: 'PUT');

      // Test with empty request
      var request = UploadPartRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectMultipart.serializeUploadPart],
      );
      expect(input.parameters['partNumber'], isNull);
      expect(input.parameters['uploadId'], isNull);
      expect(input.body, isNull);

      // Test with fields set
      input = OperationInput(operationName: 'UploadPart', method: 'PUT');
      final bodyData = utf8.encode('hello world');
      request = UploadPartRequest(
        partNumber: 1,
        uploadId: '0004B9894A22E5B1888A1E29F823****',
        body: ByteStream.fromData(Uint8List.fromList(bodyData)),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectMultipart.serializeUploadPart],
      );
      expect(input.parameters['partNumber'], equals('1'));
      expect(
        input.parameters['uploadId'],
        equals('0004B9894A22E5B1888A1E29F823****'),
      );
      expect(input.body, isNotNull);
      final readData = await input.body!.readData();
      expect(utf8.decode(readData!), equals('hello world'));
    });

    test('testSerializeUploadPartCopy', () async {
      var input = OperationInput(
        operationName: 'UploadPartCopy',
        method: 'PUT',
      );

      // Test with empty request
      var request = UploadPartCopyRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectMultipart.serializeUploadPartCopy],
      );
      expect(input.headers['x-oss-copy-source'], isNull);
      expect(input.headers['x-oss-copy-source-range'], isNull);
      expect(input.parameters['partNumber'], isNull);
      expect(input.parameters['uploadId'], isNull);

      // Test with all fields set
      input = OperationInput(operationName: 'UploadPartCopy', method: 'PUT');
      request = UploadPartCopyRequest(
        sourceBucket: 'source-bucket',
        sourceKey: 'source-object.txt',
        copySourceRange: 'bytes=0-9',
        copySourceIfMatch: '"etag-match"',
        copySourceIfNoneMatch: '"etag-none-match"',
        copySourceIfUnmodifiedSince: 'Fri, 13 Nov 2015 14:47:53 GMT',
        copySourceIfModifiedSince: 'Fri, 13 Nov 2015 14:47:53 GMT',
        partNumber: 1,
        uploadId: '0004B9894A22E5B1888A1E29F823****',
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectMultipart.serializeUploadPartCopy],
      );
      expect(
        input.headers['x-oss-copy-source'],
        equals('/source-bucket/source-object.txt'),
      );
      expect(input.headers['x-oss-copy-source-range'], equals('bytes=0-9'));
      expect(
        input.headers['x-oss-copy-source-if-match'],
        equals('"etag-match"'),
      );
      expect(
        input.headers['x-oss-copy-source-if-none-match'],
        equals('"etag-none-match"'),
      );
      expect(
        input.headers['x-oss-copy-source-if-unmodified-since'],
        equals('Fri, 13 Nov 2015 14:47:53 GMT'),
      );
      expect(
        input.headers['x-oss-copy-source-if-modified-since'],
        equals('Fri, 13 Nov 2015 14:47:53 GMT'),
      );
      expect(input.parameters['partNumber'], equals('1'));
      expect(
        input.parameters['uploadId'],
        equals('0004B9894A22E5B1888A1E29F823****'),
      );
    });

    test('testSerializeCompleteMultipartUpload', () async {
      var input = OperationInput(
        operationName: 'CompleteMultipartUpload',
        method: 'POST',
      );

      // Test with empty request
      var request = CompleteMultipartUploadRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeObjectMultipart.serializeCompleteMultipartUpload,
        ],
      );
      expect(input.headers['x-oss-forbid-overwrite'], isNull);
      expect(input.parameters['uploadId'], isNull);
      expect(input.body, isNull);

      // Test with parts and all fields
      input = OperationInput(
        operationName: 'CompleteMultipartUpload',
        method: 'POST',
      );
      request = CompleteMultipartUploadRequest(
        forbidOverwrite: true,
        completeAll: 'yes',
        uploadId: '0004B9894A22E5B1888A1E29F823****',
        encodingType: 'url',
        callback: 'callback-value',
        callbackVar: 'callback-var-value',
        completeMultipartUpload: CompleteMultipartUpload(
          parts: [
            UploadPart(partNumber: 1, etag: '"etag1"'),
            UploadPart(partNumber: 2, etag: '"etag2"'),
          ],
        ),
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [
          SerdeObjectMultipart.serializeCompleteMultipartUpload,
        ],
      );
      expect(input.headers['x-oss-forbid-overwrite'], equals('true'));
      expect(input.headers['x-oss-complete-all'], equals('yes'));
      expect(input.headers['x-oss-callback'], equals('callback-value'));
      expect(input.headers['x-oss-callback-var'], equals('callback-var-value'));
      expect(
        input.parameters['uploadId'],
        equals('0004B9894A22E5B1888A1E29F823****'),
      );
      expect(input.parameters['encoding-type'], equals('url'));

      // Verify the XML body
      final xmlData = await input.body!.readData();
      final xmlString = utf8.decode(xmlData!);
      expect(xmlString, contains('<CompleteMultipartUpload>'));
      expect(xmlString, contains('<Part>'));
      expect(xmlString, contains('<PartNumber>1</PartNumber>'));
      expect(xmlString, contains('<ETag>"etag1"</ETag>'));
      expect(xmlString, contains('<PartNumber>2</PartNumber>'));
      expect(xmlString, contains('<ETag>"etag2"</ETag>'));
      expect(xmlString, contains('</CompleteMultipartUpload>'));
    });

    test('testSerializeAbortMultipartUpload', () async {
      var input = OperationInput(
        operationName: 'AbortMultipartUpload',
        method: 'DELETE',
      );

      // Test with empty request
      var request = AbortMultipartUploadRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectMultipart.serializeAbortMultipartUpload],
      );
      expect(input.parameters['uploadId'], isNull);

      // Test with uploadId set
      input = OperationInput(
        operationName: 'AbortMultipartUpload',
        method: 'DELETE',
      );
      request = AbortMultipartUploadRequest(
        uploadId: '0004B9894A22E5B1888A1E29F823****',
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectMultipart.serializeAbortMultipartUpload],
      );
      expect(
        input.parameters['uploadId'],
        equals('0004B9894A22E5B1888A1E29F823****'),
      );
    });

    test('testSerializeListMultipartUploads', () async {
      var input = OperationInput(
        operationName: 'ListMultipartUploads',
        method: 'GET',
      );

      // Test with empty request
      var request = ListMultipartUploadsRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectMultipart.serializeListMultipartUploads],
      );
      expect(input.parameters['delimiter'], isNull);
      expect(input.parameters['encoding-type'], isNull);
      expect(input.parameters['key-marker'], isNull);
      expect(input.parameters['max-uploads'], isNull);
      expect(input.parameters['prefix'], isNull);
      expect(input.parameters['upload-id-marker'], isNull);

      // Test with all fields set
      input = OperationInput(
        operationName: 'ListMultipartUploads',
        method: 'GET',
      );
      request = ListMultipartUploadsRequest(
        delimiter: '/',
        encodingType: 'url',
        keyMarker: 'key-marker-value',
        maxUploads: 100,
        prefix: 'test/',
        uploadIdMarker: 'upload-id-marker-value',
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectMultipart.serializeListMultipartUploads],
      );
      expect(input.parameters['delimiter'], equals('/'));
      expect(input.parameters['encoding-type'], equals('url'));
      expect(input.parameters['key-marker'], equals('key-marker-value'));
      expect(input.parameters['max-uploads'], equals('100'));
      expect(input.parameters['prefix'], equals('test/'));
      expect(
        input.parameters['upload-id-marker'],
        equals('upload-id-marker-value'),
      );
    });

    test('testSerializeListParts', () async {
      var input = OperationInput(operationName: 'ListParts', method: 'GET');

      // Test with empty request
      var request = ListPartsRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectMultipart.serializeListParts],
      );
      expect(input.parameters['uploadId'], isNull);
      expect(input.parameters['max-parts'], isNull);
      expect(input.parameters['part-number-marker'], isNull);
      expect(input.parameters['encoding-type'], isNull);

      // Test with all fields set
      input = OperationInput(operationName: 'ListParts', method: 'GET');
      request = ListPartsRequest(
        uploadId: '0004B999EF518A1FE585B0C9360DC4****',
        maxParts: 100,
        partNumberMarker: 5,
        encodingType: 'url',
      );
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeObjectMultipart.serializeListParts],
      );
      expect(
        input.parameters['uploadId'],
        equals('0004B999EF518A1FE585B0C9360DC4****'),
      );
      expect(input.parameters['max-parts'], equals('100'));
      expect(input.parameters['part-number-marker'], equals('5'));
      expect(input.parameters['encoding-type'], equals('url'));
    });

    // ===== Deserialization Tests =====

    test('testDeserializeInitiateMultipartUpload', () async {
      // Test with null body - should throw ClientError
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = InitiateMultipartUploadResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeObjectMultipart.deserializeInitiateMultipartUpload,
          ],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      const xml = '''
<InitiateMultipartUploadResult>
  <Bucket>examplebucket</Bucket>
  <Key>multipart.data</Key>
  <UploadId>0004B9894A22E5B1888A1E29F823****</UploadId>
  <EncodingType>url</EncodingType>
</InitiateMultipartUploadResult>''';

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = InitiateMultipartUploadResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeObjectMultipart.deserializeInitiateMultipartUpload,
        ],
      );

      expect(result.bucket, equals('examplebucket'));
      expect(result.key, equals('multipart.data'));
      expect(result.uploadId, equals('0004B9894A22E5B1888A1E29F823****'));
      expect(result.encodingType, equals('url'));

      // Test without encoding type
      const xmlNoEncoding = '''
<InitiateMultipartUploadResult>
  <Bucket>examplebucket</Bucket>
  <Key>multipart.data</Key>
  <UploadId>0004B9894A22E5B1888A1E29F823****</UploadId>
</InitiateMultipartUploadResult>''';

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(
          Uint8List.fromList(utf8.encode(xmlNoEncoding)),
        ),
      );
      result = InitiateMultipartUploadResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeObjectMultipart.deserializeInitiateMultipartUpload,
        ],
      );

      expect(result.bucket, equals('examplebucket'));
      expect(result.key, equals('multipart.data'));
      expect(result.uploadId, equals('0004B9894A22E5B1888A1E29F823****'));
      expect(result.encodingType, isNull);
    });

    test('testDeserializeCompleteMultipartUpload', () async {
      // Test with null body - should throw ClientError
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = CompleteMultipartUploadResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeObjectMultipart.deserializeCompleteMultipartUpload,
          ],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      const xml = '''
<CompleteMultipartUploadResult>
  <Location>http://oss-example.oss-cn-hangzhou.aliyuncs.com/multipart.data</Location>
  <Bucket>oss-example</Bucket>
  <Key>multipart.data</Key>
  <ETag>"B864DB6A936D376F9F8D3ED3BBE540****"</ETag>
</CompleteMultipartUploadResult>''';

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = CompleteMultipartUploadResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeObjectMultipart.deserializeCompleteMultipartUpload,
        ],
      );

      expect(
        result.location,
        equals(
          'http://oss-example.oss-cn-hangzhou.aliyuncs.com/multipart.data',
        ),
      );
      expect(result.bucket, equals('oss-example'));
      expect(result.key, equals('multipart.data'));
      expect(result.etag, equals('"B864DB6A936D376F9F8D3ED3BBE540****"'));

      // Test with callback scenario (x-oss-callback header present)
      final callbackData = base64Encode(utf8.encode('{"status":"OK"}'));
      output = OperationOutput(
        statusCode: 200,
        headers: {'x-oss-callback': callbackData},
        body: ByteStream.fromData(
          Uint8List.fromList(utf8.encode('{"status":"OK"}')),
        ),
      );
      result = CompleteMultipartUploadResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeObjectMultipart.deserializeCompleteMultipartUpload,
        ],
      );

      expect(result.callbackResult, isNotNull);
      expect(result.bucket, isNull);
      expect(result.key, isNull);
    });

    test('testDeserializeUploadPartCopy', () async {
      // Test with null body - should throw ClientError
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = UploadPartCopyResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeObjectMultipart.deserializeUploadPartCopy],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      const xml = '''
<CopyPartResult>
  <ETag>"3349DC700140D7F86A0784842780****"</ETag>
  <LastModified>2012-02-23T07:01:34.000Z</LastModified>
</CopyPartResult>''';

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = UploadPartCopyResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeObjectMultipart.deserializeUploadPartCopy],
      );

      expect(result.copyPartResult, isNotNull);
      expect(
        result.copyPartResult!.etag,
        equals('"3349DC700140D7F86A0784842780****"'),
      );
      expect(result.copyPartResult!.lastModified, isNotNull);
      expect(result.copyPartResult!.lastModified!.year, equals(2012));
      expect(result.copyPartResult!.lastModified!.month, equals(2));
      expect(result.copyPartResult!.lastModified!.day, equals(23));
    });

    test('testDeserializeListMultipartUploads', () async {
      // Test with null body - should throw ClientError
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = ListMultipartUploadsResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [
            SerdeObjectMultipart.deserializeListMultipartUploads,
          ],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      const xml = '''
<ListMultipartUploadsResult>
  <Bucket>oss-example</Bucket>
  <KeyMarker></KeyMarker>
  <UploadIdMarker></UploadIdMarker>
  <NextKeyMarker>oss.avi</NextKeyMarker>
  <NextUploadIdMarker>0004B99B8E707874FC2D692FA5D7****</NextUploadIdMarker>
  <MaxUploads>1000</MaxUploads>
  <IsTruncated>false</IsTruncated>
  <Upload>
    <Key>multipart.data</Key>
    <UploadId>0004B999EF518A1FE585B0C9360DC4****</UploadId>
    <Initiated>2012-02-23T04:18:23.000Z</Initiated>
  </Upload>
  <Upload>
    <Key>oss.avi</Key>
    <UploadId>0004B99B8E707874FC2D692FA5D7****</UploadId>
    <Initiated>2012-02-23T06:14:27.000Z</Initiated>
  </Upload>
  <CommonPrefixes>
    <Prefix>src/</Prefix>
  </CommonPrefixes>
</ListMultipartUploadsResult>''';

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = ListMultipartUploadsResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [
          SerdeObjectMultipart.deserializeListMultipartUploads,
        ],
      );

      expect(result.bucket, equals('oss-example'));
      expect(result.nextKeyMarker, equals('oss.avi'));
      expect(
        result.nextUploadIdMarker,
        equals('0004B99B8E707874FC2D692FA5D7****'),
      );
      expect(result.maxUploads, equals(1000));
      expect(result.isTruncated, equals(false));
      expect(result.uploads, isNotNull);
      expect(result.uploads!.length, equals(2));
      expect(result.uploads![0].key, equals('multipart.data'));
      expect(
        result.uploads![0].uploadId,
        equals('0004B999EF518A1FE585B0C9360DC4****'),
      );
      expect(result.uploads![0].initiated, isNotNull);
      expect(result.uploads![1].key, equals('oss.avi'));
      expect(
        result.uploads![1].uploadId,
        equals('0004B99B8E707874FC2D692FA5D7****'),
      );
      expect(result.commonPrefixes, isNotNull);
      expect(result.commonPrefixes!.length, equals(1));
      expect(result.commonPrefixes![0].prefix, equals('src/'));
    });

    test('testDeserializeListParts', () async {
      // Test with null body - should throw ClientError
      var output = OperationOutput(statusCode: 200, headers: {});
      var result = ListPartsResult();

      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeObjectMultipart.deserializeListParts],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      const xml = '''
<ListPartsResult>
  <Bucket>multipart_upload</Bucket>
  <Key>multipart.data</Key>
  <UploadId>0004B999EF518A1FE585B0C9360DC4****</UploadId>
  <MaxParts>1000</MaxParts>
  <IsTruncated>false</IsTruncated>
  <Part>
    <PartNumber>1</PartNumber>
    <LastModified>2012-02-23T07:01:34.000Z</LastModified>
    <ETag>"3349DC700140D7F86A0784842780****"</ETag>
    <Size>6291456</Size>
  </Part>
  <Part>
    <PartNumber>2</PartNumber>
    <LastModified>2012-02-23T07:02:34.000Z</LastModified>
    <ETag>"5765DC700140D7F86A0784842780****"</ETag>
    <Size>6291457</Size>
  </Part>
</ListPartsResult>''';

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = ListPartsResult();

      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeObjectMultipart.deserializeListParts],
      );

      expect(result.bucket, equals('multipart_upload'));
      expect(result.key, equals('multipart.data'));
      expect(result.uploadId, equals('0004B999EF518A1FE585B0C9360DC4****'));
      expect(result.maxParts, equals(1000));
      expect(result.isTruncated, equals(false));
      expect(result.parts, isNotNull);
      expect(result.parts!.length, equals(2));
      expect(result.parts![0].partNumber, equals(1));
      expect(
        result.parts![0].etag,
        equals('"3349DC700140D7F86A0784842780****"'),
      );
      expect(result.parts![0].size, equals(6291456));
      expect(result.parts![0].lastModified, isNotNull);
      expect(result.parts![0].lastModified!.year, equals(2012));
      expect(result.parts![1].partNumber, equals(2));
      expect(
        result.parts![1].etag,
        equals('"5765DC700140D7F86A0784842780****"'),
      );
      expect(result.parts![1].size, equals(6291457));
    });
  });
}
