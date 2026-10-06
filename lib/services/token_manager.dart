import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  final FlutterSecureStorage _secureStorage;

  String? _currentToken;
  DateTime? _tokenExpiresAt;
  static const String _tokenKey = 'auth_token';
  static const String _expiryKey = 'auth_token_expiry';
  static const int _tokenRefreshThresholdSeconds = 300; // Refresh 5 min before expiry

  TokenManager._internal({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  factory TokenManager({FlutterSecureStorage? secureStorage}) {
    return _instance;
  }

  /// Store authentication token securely
  Future<void> setToken(String token, {DateTime? expiresAt}) async {
    _currentToken = token;
    _tokenExpiresAt = expiresAt;

    await _secureStorage.write(key: _tokenKey, value: token);
    if (expiresAt != null) {
      await _secureStorage.write(
        key: _expiryKey,
        value: expiresAt.toIso8601String(),
      );
    }
  }

  /// Retrieve current token, refreshing if necessary
  Future<String?> getToken({
    required Future<String?> Function() refreshFn,
  }) async {
    await _loadTokenFromStorage();

    if (_currentToken == null) {
      return null;
    }

    // Check if token needs refresh
    if (_shouldRefreshToken()) {
      return await _refreshToken(refreshFn);
    }

    return _currentToken;
  }

  /// Check if token is expired
  bool isTokenExpired() {
    if (_tokenExpiresAt == null) return false;
    return DateTime.now().isAfter(_tokenExpiresAt!);
  }

  /// Check if token should be proactively refreshed
  bool _shouldRefreshToken() {
    if (_tokenExpiresAt == null) return false;

    final now = DateTime.now();
    final timeUntilExpiry = _tokenExpiresAt!.difference(now).inSeconds;

    return timeUntilExpiry < _tokenRefreshThresholdSeconds;
  }

  /// Refresh authentication token
  Future<String?> _refreshToken(Future<String?> Function() refreshFn) async {
    try {
      final newToken = await refreshFn();
      if (newToken != null) {
        // Calculate default expiry (24 hours from now)
        final expiresAt = DateTime.now().add(Duration(hours: 24));
        await setToken(newToken, expiresAt: expiresAt);
        return newToken;
      }
      return null;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return null;
    }
  }

  /// Clear stored token
  Future<void> clearToken() async {
    _currentToken = null;
    _tokenExpiresAt = null;
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _expiryKey);
  }

  /// Load token from secure storage
  Future<void> _loadTokenFromStorage() async {
    if (_currentToken != null) return;

    final token = await _secureStorage.read(key: _tokenKey);
    final expiryStr = await _secureStorage.read(key: _expiryKey);

    if (token != null) {
      _currentToken = token;
      if (expiryStr != null) {
        _tokenExpiresAt = DateTime.parse(expiryStr);
      }
    }
  }

  /// Get token status for debugging
  Future<Map<String, dynamic>> getTokenStatus() async {
    await _loadTokenFromStorage();

    return {
      'hasToken': _currentToken != null,
      'isExpired': isTokenExpired(),
      'shouldRefresh': _shouldRefreshToken(),
      'expiresAt': _tokenExpiresAt?.toIso8601String(),
    };
  }
}
