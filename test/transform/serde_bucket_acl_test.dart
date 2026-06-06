import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_bucket_acl.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_input.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/operation_output.dart';
import 'package:alibabacloud_oss_sdk_dart/src/types/byte_stream.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_bucket_acl.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_functions.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('SerdeBucketAcl Tests', () {
    test('testSerializePutBucketAcl', () async {
      var input = OperationInput(
        operationName: 'PutBucketAcl',
        method: 'PUT',
      );
      const acl = 'private';

      // Test with empty request (no ACL)
      var request = PutBucketAclRequest();
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketAcl.serializePutBucketAcl],
      );
      expect(input.headers['x-oss-acl'], isNull);

      // Test with ACL set
      request = PutBucketAclRequest(acl: acl);
      await Serde.serializeInput(
        request,
        input,
        customSerializers: [SerdeBucketAcl.serializePutBucketAcl],
      );
      expect(input.headers['x-oss-acl'], equals(acl));
    });

    test('testDeserializeGetBucketAcl', () async {
      // Test with null body
      var output = OperationOutput(
        statusCode: 200,
        headers: {},
      );
      var result = GetBucketAclResponse();
      
      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketAcl.deserializeGetBucketAcl],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with unexpected body
      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode('<a></a>'))),
      );
      result = GetBucketAclResponse();
      
      expect(
        () async => await Serde.deserializeOutput(
          result,
          output,
          customDeserializers: [SerdeBucketAcl.deserializeGetBucketAcl],
        ),
        throwsA(isA<ClientError>()),
      );

      // Test with normal XML response
      const acl = 'private';
      const ownerId = '0022012****';
      const displayName = 'user_example';
      final xml = '''
<AccessControlPolicy>
    <Owner>
        <ID>$ownerId</ID>
        <DisplayName>$displayName</DisplayName>
    </Owner>
    <AccessControlList>
        <Grant>$acl</Grant>
    </AccessControlList>
</AccessControlPolicy>
'''.trim();

      output = OperationOutput(
        statusCode: 200,
        headers: {},
        body: ByteStream.fromData(Uint8List.fromList(utf8.encode(xml))),
      );
      result = GetBucketAclResponse();
      
      await Serde.deserializeOutput(
        result,
        output,
        customDeserializers: [SerdeBucketAcl.deserializeGetBucketAcl],
      );
      
      expect(result.accessControlPolicy?.accessControlList?.grant, equals(acl));
      expect(result.accessControlPolicy?.owner?.displayName, equals(displayName));
      expect(result.accessControlPolicy?.owner?.id, equals(ownerId));
    });
  });
}