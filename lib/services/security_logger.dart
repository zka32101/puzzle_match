import 'package:flutter/foundation.dart';

enum SecurityEventType {
  authenticationFailed,
  authenticationSuccess,
  invalidInput,
  invalidToken,
  rateLimitExceeded,
  jsonParseError,
  unauthorizedAccess,
  suspiciousActivity,
}

class SecurityEvent {
  final SecurityEventType type;
  final String message;
  final String? userId;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final StackTrace? stackTrace;

  SecurityEvent({
    required this.type,
    required this.message,
    this.userId,
    this.metadata,
    StackTrace? stackTrace,
  })  : timestamp = DateTime.now(),
        stackTrace = stackTrace;

  @override
  String toString() =>
      '[${timestamp.toIso8601String()}] ${type.name.toUpperCase()}: $message${userId != null ? ' (userId: $userId)' : ''}';
}

class SecurityLogger {
  static final SecurityLogger _instance = SecurityLogger._internal();
  final List<SecurityEvent> _eventLog = [];
  final int _maxLogSize = 100;

  SecurityLogger._internal();

  factory SecurityLogger() {
    return _instance;
  }

  void logEvent(SecurityEvent event) {
    _eventLog.add(event);

    if (kDebugMode) {
      debugPrint('🔒 ${event.toString()}');
      if (event.metadata != null) {
        debugPrint('   Metadata: ${event.metadata}');
      }
    }

    if (_eventLog.length > _maxLogSize) {
      _eventLog.removeAt(0);
    }
  }

  void logAuthenticationFailed(String reason, {String? userId}) {
    logEvent(
      SecurityEvent(
        type: SecurityEventType.authenticationFailed,
        message: 'Authentication failed: $reason',
        userId: userId,
      ),
    );
  }

  void logAuthenticationSuccess(String userId) {
    logEvent(
      SecurityEvent(
        type: SecurityEventType.authenticationSuccess,
        message: 'User authenticated successfully',
        userId: userId,
      ),
    );
  }

  void logInvalidInput(String fieldName, String reason, {String? userId}) {
    logEvent(
      SecurityEvent(
        type: SecurityEventType.invalidInput,
        message: 'Invalid input for field: $fieldName',
        userId: userId,
        metadata: {'field': fieldName, 'reason': reason},
      ),
    );
  }

  void logInvalidToken(String reason, {String? userId}) {
    logEvent(
      SecurityEvent(
        type: SecurityEventType.invalidToken,
        message: 'Invalid token: $reason',
        userId: userId,
      ),
    );
  }

  void logRateLimitExceeded(String endpoint, {String? userId}) {
    logEvent(
      SecurityEvent(
        type: SecurityEventType.rateLimitExceeded,
        message: 'Rate limit exceeded for endpoint: $endpoint',
        userId: userId,
        metadata: {'endpoint': endpoint},
      ),
    );
  }

  void logJsonParseError(String error, {String? userId}) {
    logEvent(
      SecurityEvent(
        type: SecurityEventType.jsonParseError,
        message: 'JSON parsing failed: $error',
        userId: userId,
      ),
    );
  }

  void logUnauthorizedAccess(String resource, {String? userId}) {
    logEvent(
      SecurityEvent(
        type: SecurityEventType.unauthorizedAccess,
        message: 'Unauthorized access attempt to: $resource',
        userId: userId,
        metadata: {'resource': resource},
      ),
    );
  }

  void logSuspiciousActivity(String description, {String? userId, Map<String, dynamic>? metadata}) {
    logEvent(
      SecurityEvent(
        type: SecurityEventType.suspiciousActivity,
        message: 'Suspicious activity detected: $description',
        userId: userId,
        metadata: metadata,
      ),
    );
  }

  List<SecurityEvent> getRecentEvents({int limit = 20}) {
    return _eventLog.skip((_eventLog.length - limit).clamp(0, _eventLog.length)).toList();
  }

  List<SecurityEvent> getEventsByType(SecurityEventType type) {
    return _eventLog.where((event) => event.type == type).toList();
  }

  void clearLog() {
    _eventLog.clear();
  }

  int get eventCount => _eventLog.length;
}
