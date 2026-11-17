import 'package:flutter/foundation.dart' show visibleForTesting;

/// `[crypt]…[/crypt]` 的加解密，对齐网页版 `js_bbscode_core.js` 的
/// `ubbcode.crypt` / `ubbcode.decrypt`。
///
/// 网页版加密：明文按 UTF-16 码元做 RC4（密钥为密码的码元），结果用 JS
/// `escape()` 转义，再把 `%uXXXX` 的四位十六进制换成 `~!#|^()=\`];,?:{}`
/// 中的字符。解密是逆过程。密码错误时不会报错，只会得到乱码。
abstract final class NgaCrypt {
  /// 密文允许出现的字符（网页版 `crypt.e` 的校验）。
  static final _cipherRegex = RegExp(
    r'^[*@\-_+./~!#^()=`\];,?:{}|A-Za-z0-9%]*$',
  );

  /// 连续 4 个替换字符还原成 `%uXXXX`。
  static final _wideCharRegex = RegExp(r'[~!#^()=`\];,?:{}|]{4}');

  static const _hexToSymbol = {
    '0': '~', '1': '!', '2': '#', '3': '|', '4': '^', '5': '(', //
    '6': ')', '7': '=', '8': '`', '9': ']', 'A': ';', 'B': ',', //
    'C': '?', 'D': ':', 'E': '{', 'F': '}',
  };
  static final _symbolToHex = {
    for (final entry in _hexToSymbol.entries) entry.value: entry.key,
  };

  /// 密文格式是否合法；不合法的密文无法解密。
  static bool isValidCipher(String cipher) =>
      cipher.isNotEmpty && _cipherRegex.hasMatch(cipher);

  /// 密文（均为 ASCII 字符）转十六进制，放进 HTML 属性时不受其他 Parser 干扰。
  static String toHex(String cipher) => cipher.codeUnits
      .map((unit) => unit.toRadixString(16).padLeft(2, '0'))
      .join();

  /// [toHex] 的逆过程，格式不对时返回 null。
  static String? fromHex(String hex) {
    if (hex.isEmpty || hex.length.isOdd || !_isHex(hex)) return null;
    return String.fromCharCodes([
      for (var i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ]);
  }

  /// 用 [password] 解密 [cipher]，密文格式不合法或密码为空时返回 null。
  static String? decrypt(String password, String cipher) {
    if (password.isEmpty || !isValidCipher(cipher)) return null;
    final escaped = cipher.replaceAllMapped(
      _wideCharRegex,
      (m) => '%u${m[0]!.split('').map((c) => _symbolToHex[c]).join()}',
    );
    return _rc4(password, _unescape(escaped));
  }

  /// 加密，供测试构造密文。
  @visibleForTesting
  static String encrypt(String password, String plain) =>
      _escape(_rc4(password, plain)).replaceAllMapped(_escapedWideRegex, (m) {
        return m[1]!.toUpperCase().split('').map((c) => _hexToSymbol[c]).join();
      });

  static final _escapedWideRegex = RegExp(r'%u([0-9A-Fa-f]{4})');

  static String _rc4(String key, String text) {
    final keyUnits = key.codeUnits;
    final s = List<int>.generate(256, (i) => i);
    var j = 0;
    for (var i = 0; i < 256; i++) {
      j = (j + s[i] + keyUnits[i % keyUnits.length]) % 256;
      final x = s[i];
      s[i] = s[j];
      s[j] = x;
    }
    final units = text.codeUnits;
    final out = List<int>.filled(units.length, 0);
    var i = 0;
    j = 0;
    for (var y = 0; y < units.length; y++) {
      i = (i + 1) % 256;
      j = (j + s[i]) % 256;
      final x = s[i];
      s[i] = s[j];
      s[j] = x;
      out[y] = units[y] ^ s[(s[i] + s[j]) % 256];
    }
    return String.fromCharCodes(out);
  }

  /// JS `escape()`：字母数字与 `@*_+-./` 原样保留，其余码元转成
  /// `%XX` / `%uXXXX`（大写十六进制）。
  static String _escape(String text) {
    final buffer = StringBuffer();
    for (final unit in text.codeUnits) {
      if (_isEscapeSafe(unit)) {
        buffer.writeCharCode(unit);
      } else if (unit < 256) {
        buffer.write(
          '%${unit.toRadixString(16).toUpperCase().padLeft(2, '0')}',
        );
      } else {
        buffer.write(
          '%u${unit.toRadixString(16).toUpperCase().padLeft(4, '0')}',
        );
      }
    }
    return buffer.toString();
  }

  static bool _isEscapeSafe(int unit) =>
      (unit >= 0x30 && unit <= 0x39) ||
      (unit >= 0x41 && unit <= 0x5A) ||
      (unit >= 0x61 && unit <= 0x7A) ||
      '@*_+-./'.codeUnits.contains(unit);

  /// JS `unescape()`：`%uXXXX`、`%XX` 还原为码元，其余字符原样保留。
  static String _unescape(String text) {
    final units = <int>[];
    var i = 0;
    while (i < text.length) {
      final unit = text.codeUnitAt(i);
      if (unit == 0x25) {
        if (i + 6 <= text.length &&
            text[i + 1] == 'u' &&
            _isHex(text.substring(i + 2, i + 6))) {
          units.add(int.parse(text.substring(i + 2, i + 6), radix: 16));
          i += 6;
          continue;
        }
        if (i + 3 <= text.length && _isHex(text.substring(i + 1, i + 3))) {
          units.add(int.parse(text.substring(i + 1, i + 3), radix: 16));
          i += 3;
          continue;
        }
      }
      units.add(unit);
      i++;
    }
    return String.fromCharCodes(units);
  }

  static final _hexRegex = RegExp(r'^[0-9A-Fa-f]+$');

  static bool _isHex(String value) => _hexRegex.hasMatch(value);
}
