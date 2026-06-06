import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/utils/xml_parser.dart';

void main() {
  group('XmlParser Tests', () {
    test('testXmlParser', () {
      const bucket = 'oss-example';
      const keyMarker = 'keyMarker';
      const uploadIdMarker = 'uploadIdMarker';
      const nextKeyMarker = 'oss.avi';
      const nextUploadIdMarker = '0004B99B8E707874FC2D692FA5D77D3F';
      const delimiter = 'delimiter';
      const prefix = 'prefix';
      const maxUploads = 1000;
      const isTruncated = false;

      final uploads = [
        {
          'Key': 'multipart.data',
          'UploadId': 'B999EF518A1FE585B0C9360DC4C8****',
          'Initiated': '2012-02-23T04:18:23.000Z',
        },
        {
          'Key': 'oss.avi',
          'UploadId': '0004B99B8E707874FC2D692FA5D7****',
          'Initiated': '2012-02-23T06:14:27.000Z',
        },
        {
          'Key': 'multipart.data',
          'UploadId': '0004B999EF5A239BB9138C6227D6****',
          'Initiated': '2012-02-23T04:18:23.000Z',
        },
      ];

      var bodyString = '<?xml version="1.0" encoding="UTF-8"?>';
      bodyString +=
          '<ListMultipartUploadsResultOld xmlns="http://doc.oss-cn-hangzhou.aliyuncs.com">';
      bodyString += '<Bucket>$bucket</Bucket>';
      bodyString += '<KeyMarker>$keyMarker</KeyMarker>';
      bodyString += '<UploadIdMarker>$uploadIdMarker</UploadIdMarker>';
      bodyString += '<NextKeyMarker>$nextKeyMarker</NextKeyMarker>';
      bodyString +=
          '<NextUploadIdMarker>$nextUploadIdMarker</NextUploadIdMarker>';
      bodyString += '<Delimiter>$delimiter</Delimiter>';
      bodyString += '<Prefix>$prefix</Prefix>';
      bodyString += '<MaxUploads>$maxUploads</MaxUploads>';
      bodyString += '<IsTruncated>$isTruncated</IsTruncated>';

      for (final upload in uploads) {
        bodyString += '<Upload><Key>${upload['Key']}</Key>';
        bodyString += '<UploadId>${upload['UploadId']}</UploadId>';
        bodyString += '<Initiated>${upload['Initiated']}</Initiated></Upload>';
      }
      bodyString += '</ListMultipartUploadsResultOld>';

      final body = Uint8List.fromList(bodyString.codeUnits);
      final parser = XmlParser();
      final result =
          parser.parse(body)['ListMultipartUploadsResultOld']
              as Map<String, dynamic>;

      expect(result['Bucket'] as String, equals(bucket));
      expect(result['KeyMarker'] as String, equals(keyMarker));
      expect(result['UploadIdMarker'] as String, equals(uploadIdMarker));
      expect(result['NextKeyMarker'] as String, equals(nextKeyMarker));
      expect(
        result['NextUploadIdMarker'] as String,
        equals(nextUploadIdMarker),
      );
      expect(result['Delimiter'] as String, equals(delimiter));
      expect(result['Prefix'] as String, equals(prefix));
      expect(int.parse(result['MaxUploads'] as String), equals(maxUploads));
      expect(result['IsTruncated'] as String, equals(isTruncated.toString()));

      for (final upload in uploads) {
        final resultUploads = result['Upload'] as List<dynamic>;
        for (final resultUpload in resultUploads) {
          final uploadMap = resultUpload as Map<String, dynamic>;
          if (uploadMap['UploadId'] == upload['UploadId']) {
            expect(upload['Key'], equals(uploadMap['Key']));
            expect(upload['Initiated'], equals(uploadMap['Initiated']));
          }
        }
      }
    });
  });
}
