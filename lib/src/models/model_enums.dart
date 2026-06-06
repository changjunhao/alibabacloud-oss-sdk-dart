/// Canned access control list values.
enum CannedAccessControlList {
  /// Uses the bucket default ACL.
  defaultAcl('default'),

  /// Private access.
  private('private'),

  /// Public read access.
  publicRead('public-read'),

  /// Public read-write access.
  publicReadWrite('public-read-write');

  const CannedAccessControlList(this.value);

  /// The serialized string value of this enum item.
  final String value;

  @override
  String toString() => value;
}

/// Storage class values.
enum StorageClass {
  /// Standard storage.
  standard('Standard'),

  /// Infrequent access storage.
  ia('IA'),

  /// Archive storage.
  archive('Archive'),

  /// Cold archive storage.
  coldArchive('ColdArchive');

  const StorageClass(this.value);

  /// The serialized string value of this enum item.
  final String value;

  @override
  String toString() => value;
}

/// Metadata directive values.
enum MetadataDirective {
  /// Copy metadata.
  copy('COPY'),

  /// Replace metadata.
  replace('REPLACE');

  const MetadataDirective(this.value);

  /// The serialized string value of this enum item.
  final String value;

  @override
  String toString() => value;
}

/// Tagging directive values.
enum TaggingDirective {
  /// Copy tags.
  copy('COPY'),

  /// Replace tags.
  replace('REPLACE');

  const TaggingDirective(this.value);

  /// The serialized string value of this enum item.
  final String value;

  @override
  String toString() => value;
}

/// Restore tier values.
enum Tier {
  /// Restores the object within about one hour.
  expedited('Expedited'),

  /// Restores the object within about two to five hours.
  standard('Standard'),

  /// Restores the object within about five to twelve hours.
  /// This tier does not apply to Deep Cold Archive.
  bulk('Bulk');

  const Tier(this.value);

  /// The serialized string value of this enum item.
  final String value;

  @override
  String toString() => value;
}

/// Data redundancy type values.
enum DataRedundancyType {
  /// Locally redundant storage (LRS) stores each object on multiple devices
  /// within the same zone to preserve reliability and availability.
  lrs('LRS'),

  /// Zone-redundant storage (ZRS) distributes user data across multiple zones
  /// within the same region so data remains accessible if one zone is unavailable.
  zrs('ZRS');

  const DataRedundancyType(this.value);

  /// The serialized string value of this enum item.
  final String value;

  @override
  String toString() => value;
}

/// Encoding type values.
enum EncodingType {
  /// URL encoding.
  url('url');

  const EncodingType(this.value);

  /// The serialized string value of this enum item.
  final String value;

  @override
  String toString() => value;
}

/// Access monitor status
enum AccessMonitorStatus {
  /// Access tracking is enabled
  enabled('Enabled'),

  /// Access tracking is disabled
  disabled('Disabled');

  const AccessMonitorStatus(this.value);

  /// The serialized string value of this enum item.
  final String value;

  @override
  String toString() => value;

  /// Creates an AccessMonitorStatus value from its string representation.
  static AccessMonitorStatus? fromString(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.value == value) return e;
    }
    return null;
  }
}

/// WORM retention policy state
enum WormState {
  /// The retention policy is in the InProgress state
  inProgress('InProgress'),

  /// The retention policy is in the Locked state
  locked('Locked');

  const WormState(this.value);

  /// The serialized string value of this enum item.
  final String value;

  @override
  String toString() => value;

  /// Creates an WormState value from its string representation.
  static WormState? fromString(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.value == value) return e;
    }
    return null;
  }
}
