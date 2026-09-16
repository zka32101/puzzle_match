import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_match/utils/validators.dart';
import 'package:puzzle_match/utils/json_utils.dart';
import 'package:puzzle_match/services/rate_limiter.dart';

void main() {
  group('InputValidators', () {
    group('isValidUserId', () {
      test('accepts valid user IDs', () {
        expect(InputValidators.isValidUserId('user123'), isTrue);
        expect(InputValidators.isValidUserId('a'), isTrue);
      });

      test('rejects empty user IDs', () {
        expect(InputValidators.isValidUserId(''), isFalse);
      });

      test('rejects overly long user IDs', () {
        final longId = 'a' * 129;
        expect(InputValidators.isValidUserId(longId), isFalse);
      });

      test('accepts maximum length user ID', () {
        final maxId = 'a' * 128;
        expect(InputValidators.isValidUserId(maxId), isTrue);
      });
    });

    group('isValidPuzzleId', () {
      test('accepts valid puzzle IDs', () {
        expect(InputValidators.isValidPuzzleId('puzzle-123'), isTrue);
        expect(InputValidators.isValidPuzzleId('p'), isTrue);
      });

      test('rejects empty puzzle IDs', () {
        expect(InputValidators.isValidPuzzleId(''), isFalse);
      });

      test('rejects overly long puzzle IDs', () {
        final longId = 'p' * 51;
        expect(InputValidators.isValidPuzzleId(longId), isFalse);
      });

      test('accepts maximum length puzzle ID', () {
        final maxId = 'p' * 50;
        expect(InputValidators.isValidPuzzleId(maxId), isTrue);
      });
    });

    group('isValidAnswer', () {
      test('accepts valid answers', () {
        expect(InputValidators.isValidAnswer('answer'), isTrue);
        expect(InputValidators.isValidAnswer('A'), isTrue);
      });

      test('rejects empty answers', () {
        expect(InputValidators.isValidAnswer(''), isFalse);
      });

      test('rejects overly long answers', () {
        final longAnswer = 'a' * 1001;
        expect(InputValidators.isValidAnswer(longAnswer), isFalse);
      });

      test('accepts maximum length answer', () {
        final maxAnswer = 'a' * 1000;
        expect(InputValidators.isValidAnswer(maxAnswer), isTrue);
      });
    });

    group('isValidEmail', () {
      test('accepts valid emails', () {
        expect(InputValidators.isValidEmail('user@example.com'), isTrue);
        expect(InputValidators.isValidEmail('test.user+tag@domain.co.uk'), isTrue);
      });

      test('rejects invalid emails', () {
        expect(InputValidators.isValidEmail('notanemail'), isFalse);
        expect(InputValidators.isValidEmail('user@'), isFalse);
        expect(InputValidators.isValidEmail('@example.com'), isFalse);
      });
    });

    group('isValidToken', () {
      test('accepts valid tokens', () {
        expect(InputValidators.isValidToken('validtoken123456'), isTrue);
      });

      test('rejects short tokens', () {
        expect(InputValidators.isValidToken('short'), isFalse);
      });

      test('rejects empty tokens', () {
        expect(InputValidators.isValidToken(''), isFalse);
      });
    });

    group('validatePuzzleInput', () {
      test('returns null for valid input', () {
        expect(InputValidators.validatePuzzleInput('valid-id'), isNull);
      });

      test('returns error for empty input', () {
        expect(InputValidators.validatePuzzleInput(''), isNotNull);
      });

      test('returns error for oversized input', () {
        final long = 'a' * 51;
        expect(InputValidators.validatePuzzleInput(long), isNotNull);
      });
    });

    group('validateAnswerInput', () {
      test('returns null for valid input', () {
        expect(InputValidators.validateAnswerInput('valid'), isNull);
      });

      test('returns error for empty input', () {
        expect(InputValidators.validateAnswerInput(''), isNotNull);
      });

      test('returns error for oversized input', () {
        final long = 'a' * 1001;
        expect(InputValidators.validateAnswerInput(long), isNotNull);
      });
    });
  });

  group('JsonUtils', () {
    group('safeJsonDecode', () {
      test('decodes valid JSON', () {
        final result = JsonUtils.safeJsonDecode('{"key": "value"}');
        expect(result, {'key': 'value'});
      });

      test('throws on invalid JSON', () {
        expect(
          () => JsonUtils.safeJsonDecode('not valid json'),
          throwsException,
        );
      });

      test('throws on non-map JSON', () {
        expect(
          () => JsonUtils.safeJsonDecode('["array", "data"]'),
          throwsException,
        );
      });

      test('throws on malformed JSON', () {
        expect(
          () => JsonUtils.safeJsonDecode('{"incomplete": '),
          throwsException,
        );
      });
    });

    group('safeJsonDecodeAs', () {
      test('decodes and transforms valid JSON', () {
        final result = JsonUtils.safeJsonDecodeAs(
          '{"name": "test"}',
          (json) => json['name'] as String,
        );
        expect(result, 'test');
      });

      test('returns null on invalid JSON', () {
        final result = JsonUtils.safeJsonDecodeAs(
          'invalid',
          (json) => json['name'] as String,
        );
        expect(result, isNull);
      });
    });

    group('safeJsonDecodeList', () {
      test('decodes and transforms valid JSON array', () {
        final result = JsonUtils.safeJsonDecodeList(
          '[{"id": 1}, {"id": 2}]',
          (json) => json['id'] as int,
        );
        expect(result, [1, 2]);
      });

      test('returns null on invalid JSON', () {
        final result = JsonUtils.safeJsonDecodeList(
          'invalid',
          (json) => json['id'] as int,
        );
        expect(result, isNull);
      });

      test('returns null on non-array JSON', () {
        final result = JsonUtils.safeJsonDecodeList(
          '{"key": "value"}',
          (json) => json['id'] as int,
        );
        expect(result, isNull);
      });
    });
  });

  group('RateLimiter', () {
    test('allows first call immediately', () async {
      final limiter = RateLimiter(minInterval: Duration(seconds: 1));
      final stopwatch = Stopwatch()..start();
      await limiter.rateLimit('test', () async => 'result');
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('enforces minimum interval between calls', () async {
      final limiter = RateLimiter(minInterval: Duration(milliseconds: 100));

      await limiter.rateLimit('test', () async => 'first');

      final stopwatch = Stopwatch()..start();
      await limiter.rateLimit('test', () async => 'second');
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
    });

    test('allows different keys to bypass rate limit', () async {
      final limiter = RateLimiter(minInterval: Duration(seconds: 10));

      await limiter.rateLimit('key1', () async => 'result1');

      final stopwatch = Stopwatch()..start();
      await limiter.rateLimit('key2', () async => 'result2');
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('resets individual key', () async {
      final limiter = RateLimiter(minInterval: Duration(seconds: 10));

      await limiter.rateLimit('test', () async => 'first');
      limiter.resetKey('test');

      final stopwatch = Stopwatch()..start();
      await limiter.rateLimit('test', () async => 'second');
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('resets all keys', () async {
      final limiter = RateLimiter(minInterval: Duration(seconds: 10));

      await limiter.rateLimit('key1', () async => 'result1');
      await limiter.rateLimit('key2', () async => 'result2');
      limiter.resetAll();

      final stopwatch = Stopwatch()..start();
      await limiter.rateLimit('key1', () async => 'result3');
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('propagates exceptions from function', () async {
      final limiter = RateLimiter();

      expect(
        () => limiter.rateLimit('test', () async => throw Exception('test error')),
        throwsException,
      );
    });
  });
}
