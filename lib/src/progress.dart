import 'types/attributes.dart';

/// Progress delegate interface for tracking upload/download progress
abstract class ProgressDelegate {
  /// Called when progress is made
  void onProgress(
    int bytesIncrement,
    int totalBytesTransferred,
    int totalBytesExpected,
  );
}

/// Progress delegate implementation using a closure/callback function
class ProgressClosure implements ProgressDelegate {
  final void Function(
    int bytesIncrement,
    int totalBytesTransferred,
    int totalBytesExpected,
  )
  _closure;

  /// Creates a progress delegate with the given closure
  const ProgressClosure(this._closure);

  @override
  void onProgress(
    int bytesIncrement,
    int totalBytesTransferred,
    int totalBytesExpected,
  ) {
    _closure(bytesIncrement, totalBytesTransferred, totalBytesExpected);
  }
}

/// Progress delegate with retry logic to prevent duplicate progress reports
class ProgressWithRetry implements ProgressDelegate {
  final ProgressDelegate _delegate;
  int _lastTotalBytesTransferred = 0;

  /// Creates a progress delegate with retry logic
  ProgressWithRetry(this._delegate);

  @override
  void onProgress(
    int bytesIncrement,
    int totalBytesTransferred,
    int totalBytesExpected,
  ) {
    if (totalBytesTransferred > _lastTotalBytesTransferred) {
      _delegate.onProgress(
        bytesIncrement,
        totalBytesTransferred,
        totalBytesExpected,
      );
      _lastTotalBytesTransferred = totalBytesTransferred;
    }
  }
}

/// Progress delegate descriptor containing delegate and upload flag
class ProgressDelegateDesc {
  final ProgressDelegate delegate;
  final bool upload;

  /// Creates a progress delegate descriptor
  const ProgressDelegateDesc({required this.delegate, required this.upload});
}

/// Extension to AttributeKeys for progress delegate
extension ProgressAttributeKeys on AttributeKeys {
  /// Attribute key for progress delegate
  static const progressDelegate = AttributeKey<ProgressDelegateDesc>(
    name: 'progress-delegate',
  );
}
