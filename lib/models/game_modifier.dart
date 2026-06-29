import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// ローグライク要素：日替わりで選べるパワーアップ
enum ModifierType {
  comboBoost,
  timeFreeze,
  hintTile,
  missShield,
  doubleScore,
}

class GameModifier {
  final ModifierType type;
  final String emoji;
  final String name;
  final String description;
  final Color color;

  const GameModifier({
    required this.type,
    required this.emoji,
    required this.name,
    required this.description,
    required this.color,
  });

  static const List<GameModifier> all = [
    GameModifier(
      type: ModifierType.comboBoost,
      emoji: '⚡',
      name: 'コンボブースト',
      description: 'コンボ倍率が2倍速で上昇',
      color: AppTheme.accent,
    ),
    GameModifier(
      type: ModifierType.timeFreeze,
      emoji: '⏱',
      name: 'タイムフリーズ',
      description: '最初の3秒はタイマー停止',
      color: Color(0xFF42A5F5),
    ),
    GameModifier(
      type: ModifierType.hintTile,
      emoji: '🎯',
      name: 'ヒントタイル',
      description: '正解タイル1つが光る',
      color: AppTheme.success,
    ),
    GameModifier(
      type: ModifierType.missShield,
      emoji: '🛡',
      name: 'ミスシールド',
      description: '1回のミスはノーペナルティ',
      color: AppTheme.secondary,
    ),
    GameModifier(
      type: ModifierType.doubleScore,
      emoji: '💎',
      name: 'スコア2倍',
      description: '最終スコアが2倍',
      color: AppTheme.primary,
    ),
  ];

  /// 日替わりシードで3枚を提示（同じ日は同じ顔ぶれ）
  static List<GameModifier> dailyOffer(int daySeed) {
    final pool = List<GameModifier>.from(all);
    final picks = <GameModifier>[];
    var seed = daySeed;
    while (picks.length < 3 && pool.isNotEmpty) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final idx = seed % pool.length;
      picks.add(pool.removeAt(idx));
    }
    return picks;
  }
}
