/// Attribute key for type-safe attribute storage
class AttributeKey<T> {
  final String name;

  const AttributeKey({required this.name});

  @override
  String toString() {
    return 'AttributeKey: $name';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttributeKey<T> && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

/// A type-safe attribute storage container
class Attributes {
  final Map<String, List<dynamic>> _attributes = {};

  /// Returns the number of attributes stored
  int get size => _attributes.length;

  /// Gets the first value for the given key
  T? get<T>(AttributeKey<T> key) {
    final vals = values(key);
    return vals?.isNotEmpty == true ? vals!.first : null;
  }

  /// Gets all values for the given key
  List<T>? values<T>(AttributeKey<T> key) {
    final result = _attributes[key.name];
    if (result == null) return null;
    return result.cast<T>();
  }

  /// Checks if the key exists in attributes
  bool contains<T>(AttributeKey<T> key) {
    return get(key) != null;
  }

  /// Sets a single value for the given key
  void set<T>(AttributeKey<T> key, T value) {
    _attributes[key.name] = [value];
  }

  /// Sets multiple values for the given key
  void setValues<T>(AttributeKey<T> key, List<T> values) {
    _attributes[key.name] = List<dynamic>.from(values);
  }

  /// Appends a value to the existing values for the given key
  void append<T>(AttributeKey<T> key, T value) {
    final vals = values(key);
    if (vals != null) {
      final newVals = List<T>.from(vals);
      newVals.add(value);
      _attributes[key.name] = List<dynamic>.from(newVals);
    } else {
      _attributes[key.name] = [value];
    }
  }

  /// Removes all values for the given key
  void remove<T>(AttributeKey<T> key) {
    _attributes.remove(key.name);
  }

  /// Clears all attributes
  void clear() {
    _attributes.clear();
  }
}

/// Predefined attribute keys
class AttributeKeys {
  static const subResource = AttributeKey<String>(name: 'sub-resource');
  static const expirationTime = AttributeKey<DateTime>(name: 'expiration-time');
  static const responseHandlers = AttributeKey<dynamic>(
    name: 'responseHandlers',
  );
}
