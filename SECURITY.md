# Security Architecture - puzzle_match

This document outlines the security measures, best practices, and architecture for the puzzle_match application.

## Table of Contents

1. [Overview](#overview)
2. [Authentication & Authorization](#authentication--authorization)
3. [Data Protection](#data-protection)
4. [API Security](#api-security)
5. [Input Validation](#input-validation)
6. [Error Handling](#error-handling)
7. [Logging & Monitoring](#logging--monitoring)
8. [Dependency Management](#dependency-management)
9. [Security Testing](#security-testing)
10. [Incident Response](#incident-response)

---

## Overview

puzzle_match implements a multi-layered security approach:

- **Client-side validation** prevents malformed data from reaching the server
- **Authentication** via Firebase Auth ensures user identity
- **Rate limiting** prevents API abuse
- **Secure storage** protects sensitive tokens
- **Firestore security rules** enforce database access control
- **HTTPS/TLS** encrypts all network communication
- **Security logging** tracks suspicious activity

---

## Authentication & Authorization

### Firebase Authentication

The app uses Firebase Authentication with two methods:

#### 1. Anonymous Sign-In
- **Use**: Initial access without account creation
- **Security**: Anonymous auth tokens are temporary and short-lived
- **Upgrade Path**: Users can link Google account later

#### 2. Google Sign-In
- **Use**: Persistent user authentication
- **Security**: Handled by official Google Sign-In package
- **Token Flow**: 
  1. User authenticates via Google
  2. ID token provided by Firebase
  3. Token stored securely via `flutter_secure_storage`
  4. Token passed in API request headers as Bearer token

### Authorization

All Firestore operations respect Firebase security rules:

```dart
// User data: Only owner can access
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// Solutions: All authenticated users can access
match /solutions/{document=**} {
  allow read, write: if request.auth != null;
}

// Stats: Only owner can access
match /close_call_stats/{userId}/{document=**} {
  allow read, write: if request.auth.uid == userId;
}
```

---

## Data Protection

### Secure Storage

**Sensitive Data (Use `flutter_secure_storage`):**
- Authentication tokens
- API keys (if any)
- User credentials

```dart
// Example: Secure token storage
final secureStorage = FlutterSecureStorage();
await secureStorage.write(key: 'auth_token', value: token);
```

**Non-Sensitive Data (Use `shared_preferences`):**
- User preferences
- UI state
- Public user information

### Encryption

- **At Rest**: Firestore encrypts data by default
- **In Transit**: All API calls use HTTPS (TLS 1.2+)
- **No Hardcoded Secrets**: API URLs are public; sensitive tokens are injected at runtime

---

## API Security

### Authentication

All API calls include Bearer token authentication:

```dart
headers: {
  'Authorization': 'Bearer $authToken',
  'Content-Type': 'application/json',
}
```

### Rate Limiting

Client-side rate limiting prevents accidental/malicious API abuse:

```dart
final rateLimiter = RateLimiter(minInterval: Duration(seconds: 1));

// Limit getPuzzle calls to 1 per second
await rateLimiter.rateLimit('getPuzzle', () => 
  apiService.getPuzzleOfDay()
);
```

### Request Timeouts

All HTTP requests have timeouts (10-15 seconds):

```dart
final response = await http.get(
  uri,
  headers: headers,
).timeout(Duration(seconds: 15));
```

### Error Handling

- Generic error messages returned to UI
- Server response bodies not exposed
- Prevents information leakage via error messages

---

## Input Validation

All user inputs are validated before API submission using `InputValidators`:

### Built-in Validators

```dart
// Validate user IDs
InputValidators.isValidUserId(userId)

// Validate puzzle IDs  
InputValidators.isValidPuzzleId(puzzleId)

// Validate answers
InputValidators.isValidAnswer(answer)

// Validate emails
InputValidators.isValidEmail(email)

// Validate tokens
InputValidators.isValidToken(token)
```

### Validation Examples

```dart
// Validate and submit answer
final error = InputValidators.validateAnswerInput(userAnswer);
if (error != null) {
  showErrorMessage(error); // User-friendly message
  return;
}

// Proceed with validated input
await apiService.submitSolution(
  puzzleId: puzzleId,
  answer: userAnswer,
);
```

### Length Limits

- **userId**: Max 128 characters
- **puzzleId**: Max 50 characters
- **answer**: Max 1000 characters
- **token**: Min 10 characters

---

## Error Handling

### General Principles

1. **User-Friendly Messages**: Never expose internal error details
2. **Logging**: Log technical details for debugging
3. **Graceful Degradation**: Provide fallback behavior

### JSON Parsing Safety

```dart
// Safe JSON decoding with error handling
try {
  final data = JsonUtils.safeJsonDecode(responseBody);
  // Process data
} catch (e) {
  SecurityLogger().logJsonParseError(e.toString());
  showUserError('Invalid server response');
}
```

### Error Messages

✅ **Good** (user-friendly):
- "パズルの取得に失敗しました" (Failed to get puzzle)
- "Invalid answer format"

❌ **Bad** (information leakage):
- "Firestore query failed: Permission denied"
- "JWT token expired: xyz..."

---

## Logging & Monitoring

### Security Event Logging

Track security-related events using `SecurityLogger`:

```dart
final logger = SecurityLogger();

// Log authentication
logger.logAuthenticationSuccess(userId);
logger.logAuthenticationFailed('Invalid credentials');

// Log validation failures
logger.logInvalidInput('puzzleId', 'Contains invalid characters');

// Log suspicious activity
logger.logSuspiciousActivity(
  'Multiple failed attempts',
  userId: userId,
  metadata: {'attemptCount': 5},
);
```

### Event Types

- `authenticationFailed` - Auth attempt failed
- `authenticationSuccess` - User authenticated
- `invalidInput` - Validation failed
- `invalidToken` - Token validation failed
- `rateLimitExceeded` - Rate limit hit
- `jsonParseError` - JSON parsing failed
- `unauthorizedAccess` - Access denied
- `suspiciousActivity` - Anomalous behavior

### Retrieving Logs

```dart
// Get recent events
final events = SecurityLogger().getRecentEvents(limit: 20);

// Get events by type
final authFailures = SecurityLogger()
  .getEventsByType(SecurityEventType.authenticationFailed);

// Access log entries
for (final event in events) {
  print(event.toString());
  if (event.metadata != null) {
    print('Metadata: ${event.metadata}');
  }
}
```

---

## Dependency Management

### Regular Updates

Check for dependency vulnerabilities regularly:

```bash
# Check for outdated dependencies
dart pub outdated

# Upgrade all dependencies
flutter pub upgrade
```

### CI/CD Security Checks

The deployment workflow includes:

```yaml
# Check for dependency vulnerabilities
dart pub outdated

# Run code analysis
flutter analyze

# Build with security checks
flutter build apk --release
```

### Secure Packages

Current security-relevant packages:

- `firebase_core` (^3.6.0) - Firebase SDK
- `firebase_auth` (^5.3.1) - Authentication
- `cloud_firestore` (^5.4.4) - Database
- `google_sign_in` (^6.2.1) - OAuth integration
- `flutter_secure_storage` (^9.2.2) - Secure token storage
- `http` (^1.2.2) - HTTP client

---

## Security Testing

### Test Coverage

Comprehensive security tests are in `test/security_test.dart`:

- Input validation tests (boundary cases, injection attempts)
- Rate limiting tests (enforcement, reset)
- JSON parsing tests (malformed data, exceptions)

### Running Tests

```bash
# Run all security tests
flutter test test/security_test.dart

# Run specific test group
flutter test test/security_test.dart -k "InputValidators"

# Run with verbose output
flutter test test/security_test.dart --verbose
```

### Example Test Cases

```dart
// Validate injection attempt
test('rejects puzzle IDs with special characters', () {
  expect(
    InputValidators.isValidPuzzleId('puzzle; DROP TABLE'),
    isFalse,
  );
});

// Test rate limiting enforcement
test('enforces minimum interval between calls', () async {
  final limiter = RateLimiter(minInterval: Duration(milliseconds: 100));
  // Test implementation
});
```

---

## Incident Response

### Security Incidents

If a security issue is discovered:

1. **Identify** the vulnerability type and scope
2. **Contain** to prevent further exposure
3. **Investigate** root cause and impact
4. **Fix** with minimal, focused changes
5. **Verify** the fix works without regressions
6. **Communicate** with affected users if needed
7. **Document** the incident and lessons learned

### Reporting Security Issues

If you discover a security vulnerability:

- Do NOT post it in public issues
- Email security concerns to project maintainers
- Include reproduction steps and impact assessment
- Allow reasonable time for fix and disclosure

---

## Best Practices

### For Developers

✅ **DO:**
- Validate all user inputs
- Use secure storage for sensitive data
- Log security events
- Keep dependencies updated
- Review error messages for leakage
- Test edge cases and boundary conditions

❌ **DON'T:**
- Hardcode secrets or API keys
- Log sensitive user data
- Ignore validation errors
- Trust client-side validation alone
- Expose detailed error messages to users
- Disable security features "temporarily"

### Code Review Checklist

Before submitting PRs:

- [ ] All user inputs validated
- [ ] No hardcoded secrets
- [ ] Error messages generic
- [ ] Security logging in place
- [ ] Tests cover edge cases
- [ ] Dependencies checked for vulnerabilities

---

## References

- [Firebase Security Rules Guide](https://firebase.google.com/docs/firestore/security/start)
- [Flutter Security Best Practices](https://flutter.dev/docs/development/security)
- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Dart Security Guidelines](https://dart.dev/guides/security)

---

**Last Updated:** 2026-09-16  
**Status:** Active  
**Maintainers:** puzzle_match team
