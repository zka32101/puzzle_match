import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/puzzle.dart';
import '../models/leaderboard_entry.dart';

class ApiService {
  final String? _authToken;

  ApiService({String? authToken}) : _authToken = authToken;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<Map<String, dynamic>> getPuzzleOfDay() async {
    final response = await http
        .post(
          Uri.parse('$API_BASE_URL/getPuzzleOfDay'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('パズルの取得に失敗しました');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> submitSolution({
    required String puzzleId,
    required String answer,
    required int attempts,
  }) async {
    final response = await http
        .post(
          Uri.parse('$API_BASE_URL/submitSolution'),
          headers: _headers,
          body: jsonEncode({
            'puzzleId': puzzleId,
            'answer': answer,
            'attempts': attempts,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('解答の送信に失敗しました');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<LeaderboardEntry>> getLeaderboard({
    required String date,
    int limit = 100,
  }) async {
    final response = await http
        .get(
          Uri.parse('$API_BASE_URL/getLeaderboard?date=$date&limit=$limit'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('ランキングの取得に失敗しました');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final entries = data['entries'] as List<dynamic>;
    return entries
        .map((e) => LeaderboardEntry.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> generateAICommentary({
    required double timeSeconds,
    required double? prevTime,
    required int rank,
    required int streak,
    required bool isCorrect,
  }) async {
    final response = await http
        .post(
          Uri.parse('$API_BASE_URL/generateAICommentary'),
          headers: _headers,
          body: jsonEncode({
            'timeSeconds': timeSeconds,
            'prevTime': prevTime,
            'rank': rank,
            'streak': streak,
            'isCorrect': isCorrect,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      return isCorrect ? '素晴らしいプレイでした！🎉' : 'また明日チャレンジしよう💪';
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['commentary'] as String;
  }
}
