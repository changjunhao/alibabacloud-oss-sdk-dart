/// The class of the container that stores the ACL information.
class AccessControlList {
  /// The ACL of the bucket.
  /// Sees BucketACLType for supported values.
  String? grant;

  /// Creates an access control list container.
  AccessControlList({this.grant});

  /// Converts the access control list instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'grant': grant};
  }

  /// Creates an access control list instance from a JSON map.
  factory AccessControlList.fromJson(Map<String, dynamic> json) {
    return AccessControlList(grant: json['grant'] as String?);
  }
}

/// The container that stores the information about the bucket owner.
class Owner {
  /// The ID of the bucket owner.
  String? id;

  /// The name of the bucket owner. The name of the bucket owner is the same as the ID of the bucket owner.
  String? displayName;

  /// Creates a Owner instance.
  Owner({this.id, this.displayName});

  /// Converts the Owner instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'ID': id, 'DisplayName': displayName};
  }

  /// Creates a Owner instance from a JSON map.
  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['ID'] as String?,
      displayName: json['DisplayName'] as String?,
    );
  }
}

/// The container that stores the ACL information.
class AccessControlPolicy {
  /// The class of the container that stores the ACL information.
  AccessControlList? accessControlList;

  /// The container that stores the information about the bucket owner.
  Owner? owner;

  /// Creates an access control policy container.
  AccessControlPolicy({this.accessControlList, this.owner});

  /// Converts the access control policy instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'accessControlList': accessControlList?.toJson(),
      'owner': owner?.toJson(),
    };
  }

  /// Creates an access control policy instance from a JSON map.
  factory AccessControlPolicy.fromJson(Map<String, dynamic> json) {
    return AccessControlPolicy(
      accessControlList: json['accessControlList'] != null
          ? AccessControlList.fromJson(
              json['accessControlList'] as Map<String, dynamic>,
            )
          : null,
      owner: json['owner'] != null
          ? Owner.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// The `Range` range.
class Range {
  /// The `start` value.
  final int? start;

  /// The `end` value.
  final int? end;

  /// Creates a Range instance.
  const Range({this.start, this.end});

  /// Creates a Range instance from `fromString`.
  factory Range.fromString(String rangeString) {
    final string = rangeString.replaceAll('bytes=', '');
    final startAndEnd = string.split('-');
    if (startAndEnd.length != 2) {
      throw ArgumentError('Invalid range string format');
    }

    final start = startAndEnd.first.isNotEmpty
        ? int.tryParse(startAndEnd.first)
        : null;
    final end = startAndEnd.last.isNotEmpty
        ? int.tryParse(startAndEnd.last)
        : null;

    return Range(start: start, end: end);
  }

  /// Creates a Range value using `from` parameters.
  static Range from(int start) {
    return Range(start: start, end: null);
  }

  /// Creates a Range value using `to` parameters.
  static Range to(int end) {
    return Range(start: null, end: end);
  }

  /// Returns the `asString` result.
  String? asString() {
    if (start == null && end == null) {
      return null;
    }
    var range = 'bytes=${start ?? 0}-';
    if (end != null) {
      range += end.toString();
    }
    return range;
  }
}

/// Supported content types for callback request bodies.
enum CallbackBodyType {
  urlEncoded('application/x-www-form-urlencoded'),
  json('application/json');

  const CallbackBodyType(this.value);

  /// The serialized string value of this enum item.
  final String value;
}

/// Callback configuration for OSS upload notifications.
class Callback {
  /// the callback url
  ///
  /// The URL of the server to which OSS sends a callback request.
  /// After an object is uploaded, OSS uses the POST method to send a callback request to the URL.
  /// The body of the request is the content that is specified in callbackBody.
  /// In most cases, the server with the URL returns the HTTP/1.1 200 OK response.
  /// The response body must be in the JSON format, and the value of the Content-Length response header must be valid and smaller than 3 MB in size.
  final String callbackUrl;

  /// The value of the Host header in the callback request.
  /// The value must comply with the naming conventions for domain names and IP addresses.
  /// This field takes effect only when you configure the callbackUrl field.
  /// If you do not configure the callbackHost field, the host value is resolved from the URL that is specified by the callbackUrl field and populated in this field.
  String? callbackHost;

  /// The value of the Content-Type header in the callback request.
  CallbackBodyType? callbackBodyType;

  /// The value of the callback request body.
  /// OSS system variables, custom variables, and constants are supported.
  /// The supported system variables: https://www.alibabacloud.com/help/en/object-storage-service/latest/callback
  final String callbackBody;

  /// The custom parameters
  Map<String, String>? callbackVar;

  /// Creates a Callback instance.
  Callback({
    required this.callbackUrl,
    required this.callbackBody,
    this.callbackHost,
    this.callbackBodyType,
    this.callbackVar,
  });

  /// Returns the `toDictionary` result.
  Map<String, dynamic> toDictionary() {
    /// The `callback` value.
    final Map<String, dynamic> callback = {
      'callbackUrl': callbackUrl,
      'callbackBody': callbackBody,
    };

    if (callbackHost != null) {
      callback['callbackHost'] = callbackHost;
    }

    if (callbackBodyType != null) {
      callback['callbackBodyType'] = callbackBodyType!.value;
    }

    return callback;
  }
}
