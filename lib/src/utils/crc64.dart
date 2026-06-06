import 'dart:typed_data';

/// CRC64 implementation for data integrity verification
class CRC64 {
  /// The shared default CRC64 calculator instance.
  static final CRC64 defaultInstance = CRC64._();

  static const int _poly = 0xC96C5795D7870F42;
  late final List<List<int>> _table;
  late final bool _isLittleEndian;
  bool _initialized = false;

  /// Creates a CRC64 instance.
  CRC64._();

  /// Initialize CRC64 with precomputed tables
  void _initialize() {
    if (_initialized) return;
    // Check endianness
    final byteData = ByteData(8);
    byteData.setInt64(0, 1, Endian.host);
    _isLittleEndian = byteData.getInt8(0) == 1;

    // Initialize lookup tables
    _table = List.generate(8, (_) => List.filled(256, 0));

    // Generate base table
    for (int n = 0; n < 256; n++) {
      int crc = n;
      for (int i = 0; i < 8; i++) {
        crc = (crc & 1) != 0 ? _poly ^ (crc >>> 1) : crc >>> 1;
      }
      _table[0][n] = crc;
    }

    // Generate extended tables
    for (int n = 0; n < 256; n++) {
      int crc = _table[0][n];
      for (int k = 1; k < 8; k++) {
        crc = _table[0][crc & 0xFF] ^ (crc >>> 8);
        _table[k][n] = crc;
      }
    }

    // Adjust for big endian if needed
    if (!_isLittleEndian) {
      for (int k = 0; k < 8; k++) {
        for (int n = 0; n < 256; n++) {
          _table[k][n] = _rev8(_table[k][n]);
        }
      }
    }
    _initialized = true;
  }

  /// Reverse 8 bytes
  int _rev8(int a) {
    int m = 0xFF00FF00FF00FF;
    a = ((a >>> 8) & m) | ((a & m) << 8);
    m = 0xFFFF0000FFFF;
    a = ((a >>> 16) & m) | ((a & m) << 16);
    return (a >>> 32) | (a << 32);
  }

  /// Calculate CRC64 for given data
  int crc64(int crc, Uint8List data, [int? length]) {
    if (!_initialized) {
      _initialize();
    }

    final len = length ?? data.length;
    if (_isLittleEndian) {
      return _crc64Little(crc, data, len);
    } else {
      return _crc64Big(crc, data, len);
    }
  }

  /// CRC64 calculation for little endian
  int _crc64Little(int crc, Uint8List data, int len) {
    int offset = 0;
    crc = ~crc;

    // Process single bytes until aligned
    while (len > 0 && (offset & 7) != 0) {
      crc = _table[0][(crc ^ data[offset]) & 0xFF] ^ (crc >>> 8);
      offset++;
      len--;
    }

    // Process 8-byte chunks
    while (len >= 8) {
      final chunk = _getUint64(data, offset);
      crc ^= chunk;
      crc =
          _table[7][crc & 0xFF] ^
          _table[6][(crc >>> 8) & 0xFF] ^
          _table[5][(crc >>> 16) & 0xFF] ^
          _table[4][(crc >>> 24) & 0xFF] ^
          _table[3][(crc >>> 32) & 0xFF] ^
          _table[2][(crc >>> 40) & 0xFF] ^
          _table[1][(crc >>> 48) & 0xFF] ^
          _table[0][crc >>> 56];
      offset += 8;
      len -= 8;
    }

    // Process remaining bytes
    while (len > 0) {
      crc = _table[0][(crc ^ data[offset]) & 0xFF] ^ (crc >>> 8);
      offset++;
      len--;
    }

    return ~crc;
  }

  /// CRC64 calculation for big endian
  int _crc64Big(int crc, Uint8List data, int len) {
    int offset = 0;
    crc = ~_rev8(crc);

    // Process single bytes until aligned
    while (len > 0 && (offset & 7) != 0) {
      crc = _table[0][(crc >>> 56) ^ data[offset]] ^ (crc << 8);
      offset++;
      len--;
    }

    // Process 8-byte chunks
    while (len >= 8) {
      final chunk = _getUint64(data, offset);
      crc ^= chunk;
      crc =
          _table[0][crc & 0xFF] ^
          _table[1][(crc >>> 8) & 0xFF] ^
          _table[2][(crc >>> 16) & 0xFF] ^
          _table[3][(crc >>> 24) & 0xFF] ^
          _table[4][(crc >>> 32) & 0xFF] ^
          _table[5][(crc >>> 40) & 0xFF] ^
          _table[6][(crc >>> 48) & 0xFF] ^
          _table[7][crc >>> 56];
      offset += 8;
      len -= 8;
    }

    // Process remaining bytes
    while (len > 0) {
      crc = _table[0][(crc >>> 56) ^ data[offset]] ^ (crc << 8);
      offset++;
      len--;
    }

    return ~_rev8(crc);
  }

  /// Get 64-bit integer from byte array at offset
  int _getUint64(Uint8List data, int offset) {
    final byteData = ByteData.sublistView(data, offset, offset + 8);
    return byteData.getUint64(0, Endian.host);
  }

  /// Matrix multiplication in GF(2)
  int _gf2MatrixTimes(List<int> mat, int vec) {
    int sum = 0;
    int matIndex = 0;

    while (vec != 0) {
      if ((vec & 1) != 0) {
        sum ^= mat[matIndex];
      }
      vec >>>= 1;
      matIndex++;
    }
    return sum;
  }

  /// Square matrix in GF(2)
  void _gf2MatrixSquare(List<int> square, List<int> mat) {
    for (int n = 0; n < 64; n++) {
      square[n] = _gf2MatrixTimes(mat, mat[n]);
    }
  }

  /// Combine two CRC64 values
  int crc64Combine(int crc1, int crc2, int len2) {
    if (len2 == 0) {
      return crc1;
    }

    int row = 1;
    final even = List.filled(64, 0); // even-power-of-two zeros operator
    final odd = List.filled(64, 0); // odd-power-of-two zeros operator

    // Put operator for one zero bit in odd
    odd[0] = 0xC96C5795D7870F42; // CRC-64 polynomial
    for (int n = 1; n < 64; n++) {
      odd[n] = row;
      row <<= 1;
    }

    // Put operator for two zero bits in even
    _gf2MatrixSquare(even, odd);

    // Put operator for four zero bits in odd
    _gf2MatrixSquare(odd, even);

    // Apply len2 zeros to crc1
    while (true) {
      // Apply zeros operator for this bit of len2
      _gf2MatrixSquare(even, odd);
      if ((len2 & 1) != 0) {
        crc1 = _gf2MatrixTimes(even, crc1);
      }
      len2 >>>= 1;

      // If no more bits set, then done
      if (len2 == 0) {
        break;
      }

      // Another iteration with odd and even swapped
      _gf2MatrixSquare(odd, even);
      if ((len2 & 1) != 0) {
        crc1 = _gf2MatrixTimes(odd, crc1);
      }
      len2 >>>= 1;

      // If no more bits set, then done
      if (len2 == 0) {
        break;
      }
    }

    // Return combined crc
    return crc1 ^ crc2;
  }

  /// Convenience method to calculate CRC64 for string data
  int crc64String(String data, [int initialCrc = 0]) {
    final bytes = Uint8List.fromList(data.codeUnits);
    return crc64(initialCrc, bytes);
  }

  /// Convenience method to calculate CRC64 for byte list
  int crc64Bytes(List<int> data, [int initialCrc = 0]) {
    final bytes = Uint8List.fromList(data);
    return crc64(initialCrc, bytes);
  }
}
