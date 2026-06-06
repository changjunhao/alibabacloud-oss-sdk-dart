import 'package:test/test.dart';
import 'package:alibabacloud_oss_sdk_dart/alibabacloud_oss_sdk_dart.dart';

void main() {
  group('Progress Tests', () {
    test('testProgressWithRetry', () {
      int lastTotalBytesTransferred = 0;

      final progress = ProgressClosure((
        bytesIncrement,
        totalBytesTransferred,
        totalBytesExpected,
      ) {
        expect(
          lastTotalBytesTransferred,
          lessThanOrEqualTo(totalBytesTransferred),
        );
        lastTotalBytesTransferred = totalBytesTransferred;
      });

      final prog = ProgressWithRetry(progress);

      // First loop: from 0 to 50 by 5
      for (int bytesCount = 0; bytesCount <= 50; bytesCount += 5) {
        prog.onProgress(5, bytesCount, 100);
      }

      // Second loop: from 0 to 100 by 5
      for (int bytesCount = 0; bytesCount <= 100; bytesCount += 5) {
        prog.onProgress(5, bytesCount, 100);
      }
    });
  });
}
