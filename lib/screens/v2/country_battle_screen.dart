import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/country_stats.dart';
import '../../utils/theme.dart';
import '../../widgets/rich_background.dart';

class CountryBattleScreen extends StatefulWidget {
  const CountryBattleScreen({super.key});

  @override
  State<CountryBattleScreen> createState() => _CountryBattleScreenState();
}

class _CountryBattleScreenState extends State<CountryBattleScreen> {
  bool _isLoading = true;
  List<CountryStats> _countries = [];

  @override
  void initState() {
    super.initState();
    _loadCountryStats();
  }

  Future<void> _loadCountryStats() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _countries = _mockCountryStats();
      _isLoading = false;
    });
  }

  List<CountryStats> _mockCountryStats() => [
    CountryStats(
      country: '🇯🇵',
      avgTime: 2.4,
      participants: 5200,
      rank: 1,
      computedAt: DateTime.now(),
    ),
    CountryStats(
      country: '🇰🇷',
      avgTime: 2.6,
      participants: 3800,
      rank: 2,
      computedAt: DateTime.now(),
    ),
    CountryStats(
      country: '🇨🇳',
      avgTime: 2.9,
      participants: 8100,
      rank: 3,
      computedAt: DateTime.now(),
    ),
    CountryStats(
      country: '🇺🇸',
      avgTime: 3.2,
      participants: 6500,
      rank: 4,
      computedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('🌍 国別対抗戦'),
      ),
      body: RichBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _InfoCard(),
                  const SizedBox(height: 20),
                  const Text(
                    '現在のランキング',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._countries.asMap().entries.map((e) {
                    final idx = e.key;
                    final c = e.value;
                    return _CountryTile(stats: c).animate().fadeIn(delay: (100 * idx).ms);
                  }),
                ],
              ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlowCard(
      gradient: const [Color(0xFF1B3A4B), Color(0xFF16213E)],
      glow: const Color(0xFF42A5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '世界規模でライバル国と競争',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '各国の平均クリアタイムで順位を競う。5分ごとに集計更新される',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  final CountryStats stats;

  const _CountryTile({required this.stats});

  @override
  Widget build(BuildContext context) {
    final medal = switch (stats.rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '#${stats.rank}',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stats.rank <= 3 ? AppTheme.accent.withOpacity(0.5) : AppTheme.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(medal, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.country,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '参加: ${stats.participants}人',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stats.avgTime.toStringAsFixed(2)}秒',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text('平均', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
