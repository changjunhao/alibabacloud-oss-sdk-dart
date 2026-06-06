import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/models/model_types.dart';
import 'package:alibabacloud_oss_sdk_dart/src/transform/serde_extensions.dart';

class SubRequest extends RequestModel {
  @override
  RequestModelProp commonProp = RequestModelProp();
  
  String? bucket;
  String? key;
  String? acl;
  Map<String, String>? metadata;
  
  SubRequest({
    this.bucket,
    this.key,
    this.acl,
    this.metadata,
  });
}

class SubResult extends ResultModel {
  @override
  ResultModelProp commonProp = ResultModelProp();
  
  String? get headerStr => commonProp.headers?.getCaseInsensitive('x-oss-header-str');
  int? get headerInt => commonProp.headers?.getCaseInsensitive('x-oss-header-int')?.toInt();
  bool? get headerBool => commonProp.headers?.getCaseInsensitive('x-oss-header-bool')?.toBool();
}

void main() {
  group('Models Tests', () {
    test('testRequestModel', () {
      var request = SubRequest();
      expect(request.bucket, isNull);
      expect(request.key, isNull);
      expect(request.acl, isNull);
      expect(request.metadata, isNull);
      expect(request.commonProp, isNotNull);
      expect(request.commonProp.headers, isNull);
      expect(request.commonProp.parameters, isNull);

      // set header
      request.addHeader('X-oss-header-str', 'true');
      request.addHeader('Content-Type', 'text/plain');

      expect(request.commonProp.headers, isNotNull);
      expect(request.commonProp.headers?['x-oss-header-str'], equals('true'));
      expect(request.commonProp.headers?['content-type'], equals('text/plain'));

      // set parameter
      request.addParameter('Parm', '1');
      request.addParameter('parm', '2');
      request.addParameter('nil-param', null);
      request.addParameter('empty-param', '');
      expect(request.commonProp.parameters, isNotNull);
      expect(request.commonProp.parameters?['Parm'], equals('1'));
      expect(request.commonProp.parameters?['parm'], equals('2'));
      expect(request.commonProp.parameters?['nil-param'], isNull);
      expect(request.commonProp.parameters?['empty-param'], equals(''));
    });

    test('testResultModel', () {
      var result = SubResult();
      expect(result.statusCode, equals(0));
      expect(result.headers, isNull);
      expect(result.requestId, equals(''));
      expect(result.headerStr, isNull);
      expect(result.headerInt, isNull);
      expect(result.headerBool, isNull);

      result.commonProp.statusCode = 200;
      result.commonProp.headers = {
        'x-oss-header-str': 'str-123',
        'x-oss-header-int': '123',
        'x-oss-header-bool': 'true',
        'x-oss-request-id': 'id-123',
      };

      expect(result.statusCode, equals(200));
      expect(result.headers, isNotNull);
      expect(result.headerStr, equals('str-123'));
      expect(result.headerInt, equals(123));
      expect(result.headerBool, equals(true));
      expect(result.requestId, equals('id-123'));
    });
  });
}