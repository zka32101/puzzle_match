import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/game_modifier.dart';
import '../../models/drag_puzzle.dart';
import '../../utils/theme.dart';
import '../../widgets/rich_background.dart';
import 'game_screen.dart';

/// ローグライク要素：プレイ前にパワーアップを1枚選ぶ
class ModifierSelectScreen extends StatelessWidget {
  final DragPuzzle puzzle;

  const ModifierSelectScreen({super.key, required this.puzzle});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daySeed = now.year * 10000 + now.month * 100 + now.day;
    final offer = GameModifier.dailyOffer(daySeed);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('パワーアップ選択'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RichBackground(
        child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              '🎲 本日の特典',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn().slideY(begin: -0.3),
            const SizedBox(height: 8),
            const Text(
              '1つ選んで勝負に挑もう（毎日変わる）',
              style: TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: offer.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  final m = offer[i];
                  return _ModifierCard(
                    modifier: m,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(puzzle: puzzle, modifier: m),
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: (150 * i).ms).slideX(begin: 0.2);
                },
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(puzzle: puzzle, modifier: null),
                  ),
                );
              },
              child: const Text('特典なしで挑戦する →'),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _ModifierCard extends StatelessWidget {
  final GameModifier modifier;
  final VoidCallback onTap;

  const _ModifierCard({required this.modifier, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: modifier.color, width: 2),
          boxShadow: [
            BoxShadow(
              color: modifier.color.withOpacity(0.25),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: modifier.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(modifier.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modifier.name,
                    style: TextStyle(
                      color: modifier.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    modifier.description,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
