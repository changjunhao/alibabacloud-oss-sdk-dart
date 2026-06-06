/// Options for paginating through results
class PaginatorOptions {
  /// The maximum number of items in the response.
  int? limit;

  /// Creates a new instance of PaginatorOptions
  ///
  /// Parameters:
  /// - [limit]: The maximum number of items in the response (optional)
  PaginatorOptions({this.limit});

  /// Creates a copy of this PaginatorOptions with optional parameter overrides
  PaginatorOptions copyWith({int? limit}) {
    return PaginatorOptions(limit: limit ?? this.limit);
  }

  /// Converts this PaginatorOptions to a JSON map
  Map<String, dynamic> toJson() {
    return {if (limit != null) 'limit': limit};
  }

  /// Creates a PaginatorOptions from a JSON map
  factory PaginatorOptions.fromJson(Map<String, dynamic> json) {
    return PaginatorOptions(limit: json['limit'] as int?);
  }

  @override
  String toString() {
    return 'PaginatorOptions(limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginatorOptions && other.limit == limit;
  }

  @override
  int get hashCode => limit.hashCode;
}
