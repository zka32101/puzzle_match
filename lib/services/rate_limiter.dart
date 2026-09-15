import 'package:flutter/foundation.dart';

class RateLimiter {
  final Map<String, DateTime> _lastCallTime = {};
  final Duration _minInterval;

  RateLimiter({Duration minInterval = const Duration(seconds: 1)})
      : _minInterval = minInterval;

  Future<T> rateLimit<T>(
    String key,
    Future<T> Function() fn,
  ) async {
    final lastTime = _lastCallTime[key];
    if (lastTime != null) {
      final elapsed = DateTime.now().difference(lastTime);
      if (elapsed < _minInterval) {
        await Future.delayed(_minInterval - elapsed);
      }
    }
    _lastCallTime[key] = DateTime.now();
    try {
      return await fn();
    } catch (e) {
      debugPrint('Rate limited call failed: $e');
      rethrow;
    }
  }

  void resetKey(String key) {
    _lastCallTime.remove(key);
  }

  void resetAll() {
    _lastCallTime.clear();
  }
}
