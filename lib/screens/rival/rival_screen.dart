import 'package:flutter/material.dart';
import '../../models/rival.dart';
import '../../models/ghost_replay.dart';
import '../../utils/theme.dart';
import '../replay/ghost_replay_screen.dart';

class RivalScreen extends StatefulWidget {
  const RivalScreen({super.key});

  @override
  State<RivalScreen> createState() => _RivalScreenState();
}

class _RivalScreenState extends State<RivalScreen> {
  bool _isLoading = true;
  List<Rival> _rivals = [];

  @override
  void initState() {
    super.initState();
    _loadRivals();
  }

  Future<void> _loadRivals() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _rivals = _mockRivals();
      _isLoading = false;
    });
  }

  List<Rival> _mockRivals() {
    return [
      const Rival(userId: '0', userName: 'GhostKing', rank: 45, todayTime: 1.8, country: '🇯🇵'),
      const Rival(userId: '1', userName: 'SpeedSolver', rank: 46, todayTime: 2.1, country: '🇺🇸'),
      const Rival(
          userId: 'me', userName: 'あなた', rank: 47, todayTime: 3.4, country: '🇯🇵', isSelf: true),
      const Rival(userId: '2', userName: 'MathMaster', rank: 48, todayTime: 4.7, country: '🇰🇷'),
      const Rival(userId: '3', userName: 'QuickMind', rank: 49, todayTime: 6.2, country: '🇨🇳'),
    ];
  }

  GhostReplay _mockGhostReplay(Rival rival) {
    return GhostReplay(
      userId: rival.userId,
      userName: rival.userName,
      rank: rival.rank,
      timeSeconds: rival.todayTime ?? 5.0,
      inputLog: [
        const InputLogEntry(relativeTimeMs: 400, action: 'type', value: '3'),
        const InputLogEntry(relativeTimeMs: 900, action: 'submit', value: '3'),
      ],
    );
  }

  void _watchReplay(Rival rival) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GhostReplayScreen(
          replay: _mockGhostReplay(rival),
          puzzleQuestion: '□ + □ = 10\n□ × □ = 21',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('⚔️ ライバルマッチング'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              backgroundColor: AppTheme.surface,
              label: const Text(
                'DAU < 1,000 (近隣ランク表示)',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                _InfoBanner(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rivals.length,
                    itemBuilder: (context, index) {
                      final rival = _rivals[index];
                      return _RivalTile(
                        rival: rival,
                        onWatchReplay: rival.isSelf || rival.todayTime == null
                            ? null
                            : () => _watchReplay(rival),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.primary, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'あなたの前後のランク帯を表示中。👻アイコンでリプレイ観戦できます！',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _RivalTile extends StatelessWidget {
  final Rival rival;
  final VoidCallback? onWatchReplay;

  const _RivalTile({required this.rival, this.onWatchReplay});

  @override
  Widget build(BuildContext context) {
    final isSelf = rival.isSelf;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isSelf
            ? Border.all(color: AppTheme.accent, width: 2)
            : Border.all(color: AppTheme.surface),
        color: isSelf ? AppTheme.accent.withOpacity(0.05) : AppTheme.cardBg,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: _RankBadge(rank: rival.rank),
        title: Row(
          children: [
            Text(
              rival.userName,
              style: TextStyle(
                color: isSelf ? AppTheme.accent : AppTheme.textPrimary,
                fontWeight: isSelf ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (rival.country != null) ...[
              const SizedBox(width: 6),
              Text(rival.country!, style: const TextStyle(fontSize: 14)),
            ],
            if (isSelf) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        subtitle: rival.todayTime != null
            ? Text(
                '今日のタイム: ${rival.todayTime!.toStringAsFixed(1)}秒',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              )
            : const Text('未プレイ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: onWatchReplay != null
            ? IconButton(
                onPressed: onWatchReplay,
                icon: const Text('👻', style: TextStyle(fontSize: 22)),
                tooltip: 'リプレイ観戦',
              )
            : null,
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final color = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => AppTheme.textSecondary,
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
