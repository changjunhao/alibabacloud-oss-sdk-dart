import 'dart:io';
import 'package:alibabacloud_oss_sdk_dart/src/sdk_info.dart';

/// Returns the platform name.
String _getSystemName() {
  if (Platform.isLinux) {
    return 'linux';
  } else if (Platform.isMacOS) {
    return 'macOS';
  } else if (Platform.isIOS) {
    return 'iOS';
  } else if (Platform.isWindows) {
    return 'windows';
  } else if (Platform.isAndroid) {
    return 'android';
  } else if (Platform.isFuchsia) {
    return 'fuchsia';
  } else {
    return 'unknown';
  }
}

/// Returns the operating system version string.
String _getSystemVersion() {
  try {
    return Platform.operatingSystemVersion;
  } catch (e) {
    return 'unknown';
  }
}

/// Returns the locale identifier.
String _getLocaleIdentifier() {
  try {
    return Platform.localeName;
  } catch (e) {
    return 'en_US';
  }
}

/// Utility methods for building user agent strings.
class UserAgent {
  /// Returns the default user agent string.
  /// Format: `sdkName/sdkVersion (systemName/systemVersion/localeIdentifier)`
  static String getDefault() {
    final sdkName = SdkInfo.name;
    final sdkVersion = SdkInfo.version;

    final systemName = _getSystemName();
    final systemVersion = _getSystemVersion();
    final localeIdentifier = _getLocaleIdentifier();

    final info = '$systemName/$systemVersion/$localeIdentifier';

    return '$sdkName/$sdkVersion ($info)';
  }

  /// Returns a simplified user agent string that only includes SDK metadata.
  static String getSimple() {
    return SdkInfo.userAgent;
  }

  /// Returns a custom user agent string.
  /// [customInfo] is appended to the default user agent string.
  static String getCustom(String customInfo) {
    final defaultUserAgent = getDefault();
    return '$defaultUserAgent $customInfo';
  }
}
