import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/leaderboard_entry.dart';
import '../../utils/theme.dart';
import '../../widgets/rich_background.dart';
import '../../data/puzzle_data.dart';
import '../puzzle/modifier_select_screen.dart';
import '../puzzle/difficulty_select_screen.dart';
import '../../models/drag_puzzle.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../leaderboard/friend_duel_screen.dart';
import '../rival/rival_screen.dart';
import '../v2/country_battle_screen.dart';
import '../v2/season_screen.dart';
import '../v2/streak_insurance_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: RichBackground(
        child: _selectedIndex == 0 ? const _HomeTab() : const LeaderboardScreen(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.85),
          border: Border(top: BorderSide(color: AppTheme.primary.withOpacity(0.2))),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          indicatorColor: AppTheme.primary.withOpacity(0.25),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: 'ホーム'),
            NavigationDestination(icon: Icon(Icons.leaderboard_rounded), label: 'ランキング'),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [AppTheme.primary, AppTheme.secondary],
          ).createShader(b),
          child: const Text(
            'パズルマッチ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        children: [
          _StreakCard(streak: 0).animate().fadeIn().slideY(begin: 0.15),
          const SizedBox(height: 16),
          _TodayPuzzleCard().animate().fadeIn(delay: 100.ms).slideY(begin: 0.15),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DifficultySelectScreen()),
            ),
            label: const Text('難易度別パズル選択 →'),
          ),
          const SizedBox(height: 16),
          _FriendDuelCard(onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FriendDuelScreen()),
            );
          }).animate().fadeIn(delay: 200.ms).slideX(begin: 0.15),
          const SizedBox(height: 16),
          _RivalCard(onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RivalScreen()),
            );
          }).animate().fadeIn(delay: 300.ms).slideX(begin: 0.15),
          const SizedBox(height: 24),
          const _SectionTitle(title: '🌍 v2.0 スケール機能'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SmallCard(
                  emoji: '🌍',
                  title: '国別対抗',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CountryBattleScreen()),
                  ),
                ).animate().fadeIn(delay: 350.ms),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallCard(
                  emoji: '🏆',
                  title: 'シーズン',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SeasonScreen()),
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallCard(
                  emoji: '🛡',
                  title: '保険',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StreakInsuranceScreen()),
                  ),
                ).animate().fadeIn(delay: 450.ms),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: '🏆 世界ランキング'),
          const SizedBox(height: 8),
          _LeaderboardPreview(entries: _mockEntries())
              .animate()
              .fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  List<LeaderboardEntry> _mockEntries() {
    return [
      const LeaderboardEntry(userId: '1', userName: 'User123', timeSeconds: 2.1, rank: 1, country: '🇯🇵'),
      const LeaderboardEntry(userId: '2', userName: 'PuzzlePro', timeSeconds: 3.4, rank: 2, country: '🇺🇸'),
      const LeaderboardEntry(userId: '3', userName: 'MathWiz', timeSeconds: 5.7, rank: 3, country: '🇰🇷'),
      const LeaderboardEntry(userId: '4', userName: 'QuickThinker', timeSeconds: 8.2, rank: 4, country: '🇨🇳'),
      const LeaderboardEntry(userId: '5', userName: 'BrainMaster', timeSeconds: 12.9, rank: 5, country: '🇬🇧'),
    ];
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      gradient: const [Color(0xFF2A1A3E), Color(0xFF16213E)],
      glow: AppTheme.warning,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
              ),
              boxShadow: [
                BoxShadow(color: AppTheme.warning.withOpacity(0.5), blurRadius: 14),
              ],
            ),
            child: const Center(child: Text('🔥', style: TextStyle(fontSize: 28))),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 900.ms, begin: const Offset(1, 1), end: const Offset(1.08, 1.08)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '連続 $streak日',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                '今日もプレイしよう！',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayPuzzleCard extends StatelessWidget {
  const _TodayPuzzleCard();

  @override
  Widget build(BuildContext context) {
    final puzzle = PuzzleData.getDailyPuzzle();
    return _PuzzleCard(
      puzzleNumber: puzzle.number,
      category: puzzle.category,
      difficulty: puzzle.difficulty,
      puzzle: puzzle,
    );
  }
}

class _PuzzleCard extends StatelessWidget {
  final int puzzleNumber;
  final String category;
  final int difficulty;
  final DragPuzzle? puzzle;

  const _PuzzleCard({
    required this.puzzleNumber,
    required this.category,
    required this.difficulty,
    this.puzzle,
  });

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      gradient: const [Color(0xFF1E1B4B), Color(0xFF2D1B47)],
      glow: AppTheme.primary,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '📅 本日のパズル',
                  style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(
                '#$puzzleNumber',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            category,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('⭐' * difficulty, style: const TextStyle(fontSize: 16)),
              Text('☆' * (5 - difficulty),
                  style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                ),
                boxShadow: [
                  BoxShadow(color: AppTheme.secondary.withOpacity(0.45), blurRadius: 18, offset: const Offset(0, 6)),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ModifierSelectScreen(
                        puzzle: puzzle ?? PuzzleData.getDailyPuzzle(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 26),
                label: const Text('プレイ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 1800.ms, color: Colors.white24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _FriendDuelCard extends StatelessWidget {
  final VoidCallback onTap;

  const _FriendDuelCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _ActionTile(
      emoji: '👥',
      title: 'フレンド予想バトル',
      subtitle: '友達と一緒にパズル対戦',
      gradient: const [Color(0xFF1B3A4B), Color(0xFF16213E)],
      glow: const Color(0xFF42A5F5),
      onTap: onTap,
    );
  }
}

/// 横長アクションタイル（グロー付き）
class _SmallCard extends StatelessWidget {
  final String emoji;
  final String title;
  final VoidCallback onTap;

  const _SmallCard({
    required this.emoji,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: AppTheme.primary.withOpacity(0.15), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Color glow;
  final VoidCallback onTap;

  const _ActionTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.glow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      gradient: gradient,
      glow: glow,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: glow.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(color: glow.withOpacity(0.4)),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: glow),
        ],
      ),
    );
  }
}

class _RivalCard extends StatelessWidget {
  final VoidCallback onTap;

  const _RivalCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _ActionTile(
      emoji: '⚔️',
      title: 'ライバルマッチング',
      subtitle: '近くのランク帯と対決・リプレイ観戦',
      gradient: const [Color(0xFF3A1B2E), Color(0xFF16213E)],
      glow: AppTheme.secondary,
      onTap: onTap,
    );
  }
}

class _LeaderboardPreview extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const _LeaderboardPreview({required this.entries});

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      gradient: const [Color(0xFF1A1A2E), Color(0xFF16213E)],
      glow: AppTheme.accent,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          ...entries.map((entry) {
            final isTop3 = entry.rank <= 3;
            final rankEmoji = switch (entry.rank) {
              1 => '🥇',
              2 => '🥈',
              3 => '🥉',
              _ => '#${entry.rank}',
            };
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isTop3 ? AppTheme.accent.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                dense: true,
                leading: Container(
                  width: 38,
                  alignment: Alignment.center,
                  child: Text(
                    rankEmoji,
                    style: TextStyle(
                      color: isTop3 ? AppTheme.accent : AppTheme.textSecondary,
                      fontSize: isTop3 ? 24 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(entry.userName,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                    if (entry.country != null) ...[
                      const SizedBox(width: 6),
                      Text(entry.country!, style: const TextStyle(fontSize: 13)),
                    ],
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${entry.timeSeconds.toStringAsFixed(1)}秒',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }),
          TextButton(
            onPressed: () {},
            child: const Text('全ランキング表示 →'),
          ),
        ],
      ),
    );
  }
}
