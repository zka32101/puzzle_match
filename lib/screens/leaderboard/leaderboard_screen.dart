import 'package:flutter/material.dart';
import '../../models/leaderboard_entry.dart';
import '../../utils/theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  List<LeaderboardEntry> get _mockEntries => [
    const LeaderboardEntry(userId: '1', userName: 'User123', timeSeconds: 2.1, rank: 1, country: '🇯🇵'),
    const LeaderboardEntry(userId: '2', userName: 'PuzzlePro', timeSeconds: 3.4, rank: 2, country: '🇺🇸'),
    const LeaderboardEntry(userId: '3', userName: 'MathWiz', timeSeconds: 5.7, rank: 3, country: '🇰🇷'),
    const LeaderboardEntry(userId: '4', userName: 'QuickThinker', timeSeconds: 8.2, rank: 4, country: '🇨🇳'),
    const LeaderboardEntry(userId: '5', userName: 'BrainMaster', timeSeconds: 12.9, rank: 5, country: '🇬🇧'),
    const LeaderboardEntry(userId: '6', userName: 'SpeedSolver', timeSeconds: 15.3, rank: 6, country: '🇩🇪'),
    const LeaderboardEntry(userId: '7', userName: 'NightOwl', timeSeconds: 18.7, rank: 7, country: '🇫🇷'),
    const LeaderboardEntry(userId: '8', userName: 'You', timeSeconds: 23.0, rank: 47, country: '🇯🇵'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('🏆 世界ランキング')),
      body: _LeaderboardList(entries: _mockEntries),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const _LeaderboardList({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'まだ誰もプレイしていません\n最初にプレイしよう！',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, i) => _RankingItem(entry: entries[i]),
    );
  }
}

class _RankingItem extends StatelessWidget {
  final LeaderboardEntry entry;

  const _RankingItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;
    final rankEmoji = switch (entry.rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '#${entry.rank}',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          child: Text(
            rankEmoji,
            style: TextStyle(
              color: isTop3 ? AppTheme.accent : AppTheme.textSecondary,
              fontSize: isTop3 ? 24 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          entry.userName,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: entry.country != null
            ? Text(entry.country!, style: const TextStyle(color: AppTheme.textSecondary))
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${entry.timeSeconds.toStringAsFixed(1)}秒',
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
