/// SDK information class that provides version and name details.
/// Uses compile-time constants to ensure accurate release metadata.
class SdkInfo {
  /// Creates a SdkInfo instance.
  SdkInfo();

  // Compile-time constants for version metadata.
  // These values should be updated by the build script before release.
  static const String _major = '1';
  static const String _minor = '0';
  static const String _patch = '2';
  static const String _tag = '';

  // Compile-time constants for SDK metadata.
  static const String _sdkName = 'alibabacloud-oss-sdk-dart';
  static const String _description = 'Alibaba Cloud OSS SDK for Dart';

  // Build timestamp, optional and mainly useful for debugging.
  static const String _buildTime = '2026-06-06T06:00:00.000000Z';

  /// Returns the full version string.
  /// Format: `major.minor.patch<tag>`
  static String get version => '$_major.$_minor.$_patch$_tag';

  /// Returns the SDK name.
  static String get name => _sdkName;

  /// Returns the SDK description.
  static String get description => _description;

  /// Returns the major version.
  static String get majorVersion => _major;

  /// Returns the minor version.
  static String get minorVersion => _minor;

  /// Returns the patch version.
  static String get patchVersion => _patch;

  /// Returns the version tag, such as `-beta` or `-alpha`.
  static String get versionTag => _tag;

  /// Returns the build timestamp.
  static String get buildTime => _buildTime;

  /// Returns a detailed map of version metadata.
  static Map<String, String> get versionInfo => {
    'name': name,
    'version': version,
    'description': description,
    'major': majorVersion,
    'minor': minorVersion,
    'patch': patchVersion,
    'tag': versionTag,
    'buildTime': buildTime,
  };

  /// Returns whether this build is a pre-release version.
  static bool get isPreRelease => _tag.isNotEmpty;

  /// Returns the user agent string.
  static String get userAgent => '$_sdkName/$version';

  /// Compares the current version with another version string.
  /// Returns `-1` if lower, `0` if equal, and `1` if higher.
  static int compareVersion(String otherVersion) {
    final current = version.split('.');
    final other = otherVersion.split('.');

    for (int i = 0; i < 3; i++) {
      final currentPart =
          int.tryParse(current.length > i ? current[i] : '0') ?? 0;
      final otherPart = int.tryParse(other.length > i ? other[i] : '0') ?? 0;

      if (currentPart < otherPart) return -1;
      if (currentPart > otherPart) return 1;
    }

    return 0;
  }

  /// Formats the version information for display.
  static String toDisplayString() {
    return '$name v$version';
  }
}
