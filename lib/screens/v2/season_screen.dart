import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/season.dart';
import '../../utils/theme.dart';
import '../../widgets/rich_background.dart';

class SeasonScreen extends StatefulWidget {
  const SeasonScreen({super.key});

  @override
  State<SeasonScreen> createState() => _SeasonScreenState();
}

class _SeasonScreenState extends State<SeasonScreen> {
  bool _isLoading = true;
  late SeasonInfo _currentSeason;
  late UserSeason _userSeason;
  final List<UserSeason> _hallOfFame = [];

  @override
  void initState() {
    super.initState();
    _loadSeasonData();
  }

  Future<void> _loadSeasonData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _currentSeason = _mockCurrentSeason();
      _userSeason = _mockUserSeason();
      _hallOfFame.addAll(_mockHallOfFame());
      _isLoading = false;
    });
  }

  SeasonInfo _mockCurrentSeason() => SeasonInfo(
    seasonId: 8,
    name: 'Season 8 - 夏の陣',
    startDate: DateTime(2026, 6, 1),
    endDate: DateTime(2026, 6, 30),
    isActive: true,
  );

  UserSeason _mockUserSeason() => const UserSeason(
    userId: 'user1',
    seasonId: 8,
    tier: Tier.gold,
    points: 2450,
    rank: 247,
    promoted: false,
    demoted: false,
  );

  List<UserSeason> _mockHallOfFame() => [
    const UserSeason(
      userId: 'u1',
      seasonId: 7,
      tier: Tier.diamond,
      points: 5000,
      rank: 1,
      promoted: true,
    ),
    const UserSeason(
      userId: 'u2',
      seasonId: 7,
      tier: Tier.platinum,
      points: 4200,
      rank: 2,
      promoted: true,
    ),
    const UserSeason(
      userId: 'u3',
      seasonId: 7,
      tier: Tier.platinum,
      points: 3800,
      rank: 3,
      promoted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('🏆 シーズン'),
      ),
      body: RichBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SeasonInfoCard(season: _currentSeason).animate().fadeIn(),
                  const SizedBox(height: 20),
                  _UserTierCard(season: _userSeason).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 24),
                  const Text(
                    '殿堂入り（前シーズン）',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._hallOfFame.asMap().entries.map((e) {
                    return _HallOfFameTile(season: e.value, rank: e.key + 1)
                        .animate()
                        .fadeIn(delay: (150 * (e.key + 2)).ms);
                  }),
                ],
              ),
      ),
    );
  }
}

class _SeasonInfoCard extends StatelessWidget {
  final SeasonInfo season;

  const _SeasonInfoCard({required this.season});

  @override
  Widget build(BuildContext context) {
    final daysLeft = season.endDate.difference(DateTime.now()).inDays;
    return GlowCard(
      gradient: const [Color(0xFF2A1A3E), Color(0xFF16213E)],
      glow: AppTheme.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            season.name,
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('開始', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  Text(
                    '${season.startDate.month}月${season.startDate.day}日',
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('残り日数', style: TextStyle(color: AppTheme.warning, fontSize: 11)),
                  Text(
                    '$daysLeft日',
                    style: TextStyle(
                      color: daysLeft <= 5 ? AppTheme.warning : AppTheme.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserTierCard extends StatelessWidget {
  final UserSeason season;

  const _UserTierCard({required this.season});

  @override
  Widget build(BuildContext context) {
    final progressPct = (season.points / 5000 * 100).clamp(0, 100);
    return GlowCard(
      gradient: const [Color(0xFF1E1B4B), Color(0xFF2D1B47)],
      glow: AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('あなたのランク', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(season.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        season.tierName,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${season.rank}',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ポイント', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  Text(
                    '${season.points} / 5000',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressPct / 100,
                  minHeight: 8,
                  backgroundColor: AppTheme.surface.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HallOfFameTile extends StatelessWidget {
  final UserSeason season;
  final int rank;

  const _HallOfFameTile({required this.season, required this.rank});

  @override
  Widget build(BuildContext context) {
    final medal = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '#$rank',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: rank <= 3 ? AppTheme.accent.withOpacity(0.4) : AppTheme.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(medal, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season.tierName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${season.points}pt',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            season.emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
