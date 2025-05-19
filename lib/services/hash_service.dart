import 'dart:convert';
import 'package:crypto/crypto.dart';

/// دالة لإنشاء SHA-256 hash من نص معين
String generateHash(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

/// دالة لمقارنة الهاش القديم والجديد وترجع النتيجة مع الهاش الجديد
Map<String, dynamic> generateAndCompareHash(String storedHash, String input) {
  final newHash = generateHash(input);
  final isMatch = storedHash == newHash;

  return {
    "newHash": newHash,
    "isMatch": isMatch,
  };
}
