import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import '../../services/share_service.dart';
import '../../models/close_call.dart';
import '../../utils/theme.dart';
import '../home/home_screen.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  final int puzzleNumber;
  final int attempts;
  final List<Map<String, dynamic>> inputLog;

  const ResultScreen({
    super.key,
    required this.result,
    required this.puzzleNumber,
    required this.attempts,
    this.inputLog = const [],
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? _aiCommentary;
  bool _loadingAi = true;

  @override
  void initState() {
    super.initState();
    _loadAICommentary();
  }

  Future<void> _loadAICommentary() async {
    try {
      // Firebase設定後は実際のAPIを呼ぶ。今はモックレスポンス
      final isCorrect = widget.result['isCorrect'] as bool? ?? false;
      final timeSeconds = (widget.result['timeSeconds'] as num?)?.toDouble() ?? 0;
      final rank = (widget.result['globalRank'] as int?) ?? 0;

      await Future.delayed(const Duration(seconds: 1));

      final commentary = isCorrect
          ? '昨日の自分に${timeSeconds.toStringAsFixed(1)}秒差で勝利！成長してる🔥'
          : 'あと少し！明日はいける気がする💪';

      if (mounted) {
        setState(() {
          _aiCommentary = commentary;
          _loadingAi = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _aiCommentary = widget.result['isCorrect'] == true
              ? '素晴らしいプレイでした！🎉'
              : 'また明日チャレンジしよう💪';
          _loadingAi = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.result['isCorrect'] as bool? ?? false;
    final timeSeconds = (widget.result['timeSeconds'] as num?)?.toDouble() ?? 0;
    final rank = (widget.result['globalRank'] as int?) ?? 0;
    final closeCallLevel = (widget.result['closeCallLevel'] as int?) ?? 0;
    final closeCall = CloseCall(
      level: closeCallLevel,
      message: widget.result['closeCallMessage'] as String? ?? '',
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _ResultHeader(isCorrect: isCorrect, timeSeconds: timeSeconds)
                          .animate()
                          .fadeIn()
                          .scale(begin: const Offset(0.8, 0.8)),
                      const SizedBox(height: 24),
                      if (isCorrect) ...[
                        _RankCard(rank: rank, timeSeconds: timeSeconds, attempts: widget.attempts)
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.2),
                        if (widget.result['score'] != null) ...[
                          const SizedBox(height: 12),
                          _ScoreCard(
                            score: widget.result['score'] as int,
                            maxCombo: widget.result['maxCombo'] as int? ?? 0,
                            beatGhost: widget.result['beatGhost'] as bool? ?? false,
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                        ],
                      ] else if (closeCall.hasCloseCall) ...[
                        _CloseCallCard(closeCall: closeCall)
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.2),
                      ],
                      const SizedBox(height: 16),
                      _AICommentaryCard(commentary: _aiCommentary, isLoading: _loadingAi)
                          .animate()
                          .fadeIn(delay: 400.ms),
                    ],
                  ),
                ),
              ),
              _ActionButtons(
                isCorrect: isCorrect,
                rank: rank,
                timeSeconds: timeSeconds,
                puzzleNumber: widget.puzzleNumber,
                aiCommentary: _aiCommentary ?? '',
                closeCallLevel: closeCallLevel,
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final bool isCorrect;
  final double timeSeconds;

  const _ResultHeader({required this.isCorrect, required this.timeSeconds});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isCorrect ? '🎉' : '😢',
          style: const TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 12),
        Text(
          isCorrect ? '正解！' : '惜しい！',
          style: TextStyle(
            color: isCorrect ? AppTheme.success : AppTheme.warning,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isCorrect) ...[
          const SizedBox(height: 8),
          Text(
            '${timeSeconds.toStringAsFixed(1)}秒で解きました',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 18),
          ),
        ],
      ],
    );
  }
}

class _RankCard extends StatelessWidget {
  final int rank;
  final double timeSeconds;
  final int attempts;

  const _RankCard({required this.rank, required this.timeSeconds, required this.attempts});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(icon: '🏆', label: '世界順位', value: '#$rank'),
            _StatItem(icon: '⏱', label: 'タイム', value: '${timeSeconds.toStringAsFixed(1)}秒'),
            _StatItem(icon: '🔢', label: '手数', value: '$attempts回'),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  final int maxCombo;
  final bool beatGhost;

  const _ScoreCard({required this.score, required this.maxCombo, required this.beatGhost});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('SCORE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 2)),
            const SizedBox(height: 4),
            Text(
              '$score',
              style: const TextStyle(color: AppTheme.accent, fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(icon: '🔥', label: '最大コンボ', value: 'x$maxCombo'),
                _StatItem(
                  icon: beatGhost ? '🏆' : '💨',
                  label: 'ゴースト',
                  value: beatGhost ? '勝利！' : '惜敗',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseCallCard extends StatelessWidget {
  final CloseCall closeCall;

  const _CloseCallCard({required this.closeCall});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '惜しい度: ${closeCall.stars}',
              style: const TextStyle(color: AppTheme.accent, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (closeCall.message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                closeCall.message,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AICommentaryCard extends StatelessWidget {
  final String? commentary;
  final bool isLoading;

  const _AICommentaryCard({required this.commentary, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🤖', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  'AI実況',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Text(
                commentary ?? '',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isCorrect;
  final int rank;
  final double timeSeconds;
  final int puzzleNumber;
  final String aiCommentary;
  final int closeCallLevel;

  const _ActionButtons({
    required this.isCorrect,
    required this.rank,
    required this.timeSeconds,
    required this.puzzleNumber,
    required this.aiCommentary,
    required this.closeCallLevel,
  });

  @override
  Widget build(BuildContext context) {
    final shareService = ShareService();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              shareService.shareResult(
                rank: rank,
                timeSeconds: timeSeconds,
                puzzleNumber: puzzleNumber,
                isCorrect: isCorrect,
                aiCommentary: aiCommentary,
                closeCallLevel: closeCallLevel,
              );
            },
            icon: const Icon(Icons.share),
            label: Text(isCorrect ? '📤 結果を共有' : '📤 惜しさを共有'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: const BorderSide(color: AppTheme.textSecondary),
            ),
            child: const Text('🏠 ホームへ'),
          ),
        ),
      ],
    );
  }
}
