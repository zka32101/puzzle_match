import 'dart:convert';
import 'package:flutter/foundation.dart';

class JsonUtils {
  static Map<String, dynamic> safeJsonDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw FormatException('Invalid JSON structure: expected Map');
    } catch (e) {
      debugPrint('JSON decode error: $e');
      throw Exception('Invalid server response format');
    }
  }

  static T? safeJsonDecodeAs<T>(String body, T Function(Map<String, dynamic>) fromJson) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return fromJson(decoded);
      }
      throw FormatException('Invalid JSON structure: expected Map');
    } catch (e) {
      debugPrint('JSON decode error: $e');
      return null;
    }
  }

  static List<T>? safeJsonDecodeList<T>(
    String body,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(fromJson)
            .toList();
      }
      throw FormatException('Invalid JSON structure: expected List');
    } catch (e) {
      debugPrint('JSON list decode error: $e');
      return null;
    }
  }
}
