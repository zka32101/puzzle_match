import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/leaderboard_entry.dart';
import 'puzzle_provider.dart';

final leaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((ref, date) async {
  final api = ref.watch(apiServiceProvider);
  return api.getLeaderboard(date: date, limit: 100);
});
