import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/utils/mime_utils.dart';

void main() {
  group('MimeUtils Tests', () {
    test('testGetMimeType', () {
      // Test file paths
      const filePath1 = '/dir/dir/file.png';
      const filePath2 = '/dir/file';
      const filePath3 = '/dir/dir/';

      var mimeType = MimeUtils.getMimeTypeFromUri(
        Uri.parse('file://$filePath1'),
      );
      expect(mimeType, equals('image/png'));

      mimeType = MimeUtils.getMimeTypeFromUri(Uri.parse('file://$filePath2'));
      expect(mimeType, isNull);

      mimeType = MimeUtils.getMimeTypeFromUri(Uri.parse('file://$filePath3'));
      expect(mimeType, isNull);

      // Test file names
      const fileName1 = 'file.png';
      const fileName2 = 'file';
      const fileName3 = 'file.';
      const fileName4 = 'file/';
      const fileName5 = 'file\\';
      const fileName6 = 'file:';

      mimeType = MimeUtils.getMimeType(fileName1);
      expect(mimeType, equals('image/png'));

      mimeType = MimeUtils.getMimeType(fileName2);
      expect(mimeType, isNull);

      mimeType = MimeUtils.getMimeType(fileName3);
      expect(mimeType, isNull);

      mimeType = MimeUtils.getMimeType(fileName4);
      expect(mimeType, isNull);

      mimeType = MimeUtils.getMimeType(fileName5);
      expect(mimeType, isNull);

      mimeType = MimeUtils.getMimeType(fileName6);
      expect(mimeType, isNull);
    });
  });
}
