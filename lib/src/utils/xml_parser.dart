import 'dart:typed_data';
import 'package:xml/xml.dart';

/// Parser interface.
abstract class Parser {
  Map<String, dynamic> parse(Uint8List data);
}

/// XML parser that converts XML data into a `Map` structure.
class XmlParser implements Parser {
  Map<String, dynamic> _response = {};
  final _Stack<_ElementNode> _elementStack = _Stack<_ElementNode>();
  _ElementNode? _rootNode;

  /// The last error that occurred.
  Exception? lastError;

  /// Parses XML data.
  @override
  Map<String, dynamic> parse(Uint8List data) {
    try {
      final xmlString = String.fromCharCodes(data);
      final document = XmlDocument.parse(xmlString);

      _response = {};
      _elementStack.clear();
      _rootNode = null;
      lastError = null;

      _parseElement(document.rootElement);

      if (_rootNode != null) {
        final result = _rootNode!.asDictionary();
        if (result != null) {
          _response = result;
        } else {
          // Empty root element (e.g. self-closing <Tag xmlns="..."/>)
          _response = {_rootNode!.key: <String, dynamic>{}};
        }
      }

      return _response;
    } catch (e) {
      lastError = Exception('XML parsing failed: $e');
      return _response;
    }
  }

  /// Recursively parses an XML element.
  void _parseElement(XmlElement element) {
    final elementNode = _ElementNode(key: element.name.local);

    if (_elementStack.isNotEmpty) {
      _elementStack.top()?.nodes.add(elementNode);
    } else {
      _rootNode = elementNode;
    }

    _elementStack.push(elementNode);

    // Handle text content.
    final textContent = element.innerText.trim();
    if (textContent.isNotEmpty &&
        element.children.every((child) => child is XmlText)) {
      elementNode.value = textContent;
    }

    // Recursively process child elements.
    for (final child in element.children) {
      if (child is XmlElement) {
        _parseElement(child);
      }
    }

    _elementStack.pop();
  }
}

/// Stack data structure.
class _Stack<T> {
  final List<T> _items = [];

  /// Pushes an item onto the stack.
  void push(T item) {
    _items.add(item);
  }

  /// Pops the top item from the stack.
  T? pop() {
    if (_items.isEmpty) return null;
    return _items.removeLast();
  }

  /// Returns the top item on the stack.
  T? top() {
    if (_items.isEmpty) return null;
    return _items.last;
  }

  /// Returns whether the stack is empty.
  bool get isEmpty => _items.isEmpty;

  /// Returns whether the stack is not empty.
  bool get isNotEmpty => _items.isNotEmpty;

  /// Clears the stack.
  void clear() {
    _items.clear();
  }
}

/// XML element node.
class _ElementNode {
  final String key;
  String? value;
  final List<_ElementNode> nodes = [];

  _ElementNode({required this.key});

  /// Converts the node to a dictionary representation.
  Map<String, dynamic>? asDictionary() {
    final entry = _getEntry();
    if (entry != null) {
      return {entry.key: entry.value};
    }
    return null;
  }

  /// Returns the key-value entry for this node.
  MapEntry<String, dynamic>? _getEntry() {
    if (value != null) {
      return MapEntry(key, value!);
    }

    if (nodes.isEmpty) {
      return null;
    }

    final Map<String, dynamic> result = {};

    for (final node in nodes) {
      final entry = node._getEntry();
      if (entry != null) {
        final existingValue = result[entry.key];
        if (existingValue != null) {
          // Convert duplicate keys into a list.
          if (existingValue is List) {
            existingValue.add(entry.value);
          } else {
            result[entry.key] = [existingValue, entry.value];
          }
        } else {
          result[entry.key] = entry.value;
        }
      }
    }

    return MapEntry(key, result);
  }
}

/// Extension helpers for creating a map from XML data.
extension DictionaryXMLExtensions on Map<String, dynamic> {
  /// Creates a dictionary from XML data.
  static Map<String, dynamic> withXMLData(Uint8List data) {
    final parser = XmlParser();
    final result = parser.parse(data);
    if (parser.lastError != null) {
      throw parser.lastError!;
    }
    return result;
  }

  /// Creates a dictionary from XML data and returns both the result and error.
  static (Map<String, dynamic>, Exception?) withXMLDataError(Uint8List data) {
    final parser = XmlParser();
    final result = parser.parse(data);
    return (result, parser.lastError);
  }
}
