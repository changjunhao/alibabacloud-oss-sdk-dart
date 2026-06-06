import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/server_error.dart';
import 'package:alibabacloud_oss_sdk_dart/src/errors/client_errors.dart';

void main() {
  group('Errors Tests', () {
    test('testOperationError', () {
      final error = ServerError(
        statusCode: 400,
        headers: <String, String>{},
        errorFields: <String, String>{},
        requestTarget: '',
        snapshot: null,
      );
      final opErr = OperationErrors.operationError('GetObject', error);

      final err = opErr.toString();
      expect(err.contains('Operation GetObject raised a error'), isTrue);
      expect(err.contains('Error returned by Service'), isTrue);
      expect(err.contains('Error Code: BadErrorResponse'), isTrue);
      expect(err.contains('Timestamp: 202'), isTrue);
    });
  });
}
