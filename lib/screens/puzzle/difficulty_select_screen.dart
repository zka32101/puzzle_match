import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/puzzle_data.dart';
import '../../models/drag_puzzle.dart';
import '../../utils/theme.dart';
import '../../widgets/rich_background.dart';
import 'modifier_select_screen.dart';

class DifficultySelectScreen extends StatelessWidget {
  const DifficultySelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('難易度選択'),
      ),
      body: RichBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                '難易度を選んで\nパズルに挑戦',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 32),
              _DifficultyButton(
                difficulty: 1,
                emoji: '⭐',
                label: 'Easy',
                description: '基礎的な計算パズル',
                color: const Color(0xFF4CAF50),
                onTap: () => _selectDifficulty(context, 1),
              ).animate().fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 12),
              _DifficultyButton(
                difficulty: 2,
                emoji: '⭐⭐',
                label: 'Normal',
                description: '混合計算とパズル',
                color: AppTheme.accent,
                onTap: () => _selectDifficulty(context, 2),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              const SizedBox(height: 12),
              _DifficultyButton(
                difficulty: 3,
                emoji: '⭐⭐⭐',
                label: 'Hard',
                description: '複雑な計算と論理',
                color: AppTheme.secondary,
                onTap: () => _selectDifficulty(context, 3),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDifficulty(BuildContext context, int difficulty) {
    final puzzles = PuzzleData.getByDifficulty(difficulty);
    if (puzzles.isEmpty) return;
    // 日付ベースで選択してバリエーションを出す
    final idx = DateTime.now().day % puzzles.length;
    final puzzle = puzzles[idx];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ModifierSelectScreen(puzzle: puzzle),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final int difficulty;
  final String emoji;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.difficulty,
    required this.emoji,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final puzzles = PuzzleData.getByDifficulty(difficulty);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${puzzles.length}問',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
