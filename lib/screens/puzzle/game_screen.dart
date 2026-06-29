import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/drag_puzzle.dart';
import '../../models/game_modifier.dart';
import '../../utils/theme.dart';
import '../../widgets/rich_background.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final DragPuzzle puzzle;
  final GameModifier? modifier;

  const GameScreen({super.key, required this.puzzle, this.modifier});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // タイマー / レース
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  double _elapsed = 0; // 秒
  double _ghostProgress = 0; // 0-1
  static const double _ghostTime = 8.0; // ゴーストのクリアタイム
  double _freezeUntil = 0; // タイムフリーズ終了秒

  // スロット / タイル
  late List<int?> _slots;
  final Set<int> _usedTiles = {};

  // コンボ / スコア
  int _combo = 0;
  int _maxCombo = 0;
  int _score = 0;
  int _misses = 0;
  bool _shieldUsed = false;
  int? _hintTileIndex;

  // 演出
  int _shakeKey = 0;
  String? _comboFlash;

  final List<Map<String, dynamic>> _inputLog = [];

  @override
  void initState() {
    super.initState();
    _slots = List<int?>.filled(widget.puzzle.slotCount, null);
    _applyModifierSetup();
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), _tick);
  }

  void _applyModifierSetup() {
    final m = widget.modifier?.type;
    if (m == ModifierType.timeFreeze) {
      _freezeUntil = 3.0;
    } else if (m == ModifierType.hintTile) {
      // 正解タイルの中で未使用の最初のものを光らせる
      for (var i = 0; i < widget.puzzle.tiles.length; i++) {
        if (widget.puzzle.solution.contains(widget.puzzle.tiles[i])) {
          _hintTileIndex = i;
          break;
        }
      }
    }
  }

  void _tick(Timer t) {
    final raw = _stopwatch.elapsedMilliseconds / 1000;
    // タイムフリーズ中は経過時間を進めない
    final effective = raw <= _freezeUntil ? 0.0 : raw - _freezeUntil;
    setState(() {
      _elapsed = effective;
      _ghostProgress = (effective / _ghostTime).clamp(0.0, 1.0);
    });
  }

  List<int> get _placedValues => _slots.whereType<int>().toList();

  double get _playerProgress =>
      _usedTiles.length / widget.puzzle.slotCount;

  void _onTileDropped(int slotIndex, int tileIndex) {
    final value = widget.puzzle.tiles[tileIndex];
    final correct = widget.puzzle.isCorrectPlacement(slotIndex, value, _slots);

    _inputLog.add({
      'relativeTimeMs': _stopwatch.elapsedMilliseconds,
      'action': correct ? 'place' : 'miss',
      'value': value.toString(),
    });

    if (correct) {
      _onCorrectPlace(slotIndex, tileIndex, value);
    } else {
      _onWrongPlace();
    }
  }

  void _onCorrectPlace(int slotIndex, int tileIndex, int value) {
    HapticFeedback.lightImpact();
    final boost = widget.modifier?.type == ModifierType.comboBoost ? 2 : 1;
    setState(() {
      _slots[slotIndex] = value;
      _usedTiles.add(tileIndex);
      if (_hintTileIndex == tileIndex) _hintTileIndex = null;
      _combo += boost;
      if (_combo > _maxCombo) _maxCombo = _combo;
      // スコア：基礎 + コンボ倍率
      final gain = 100 * _combo;
      _score += gain;
      _comboFlash = 'COMBO x$_combo  +$gain';
    });
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _comboFlash = null);
    });

    if (widget.puzzle.isSolved(_slots)) {
      _onSolved();
    }
  }

  void _onWrongPlace() {
    final hasShield =
        widget.modifier?.type == ModifierType.missShield && !_shieldUsed;
    if (hasShield) {
      HapticFeedback.selectionClick();
      setState(() {
        _shieldUsed = true;
        _comboFlash = '🛡 シールド発動！';
      });
      Timer(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _comboFlash = null);
      });
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _misses++;
      _combo = 0;
      _shakeKey++;
      _comboFlash = '✕ ミス！コンボリセット';
    });
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _comboFlash = null);
    });
  }

  void _onSolved() {
    _stopwatch.stop();
    _ticker?.cancel();

    var finalScore = _score;
    // コンボ完走ボーナス
    finalScore += _maxCombo * 50;
    // タイムボーナス（速いほど高い）
    final timeBonus = ((_ghostTime - _elapsed) * 100).clamp(0, 2000).toInt();
    finalScore += timeBonus;
    if (widget.modifier?.type == ModifierType.doubleScore) {
      finalScore *= 2;
    }

    final beatGhost = _elapsed < _ghostTime;

    final result = {
      'isCorrect': true,
      'timeSeconds': _elapsed,
      'globalRank': beatGhost ? 31 : 58,
      'closeCallLevel': 0,
      'closeCallMessage': '',
      'score': finalScore,
      'maxCombo': _maxCombo,
      'misses': _misses,
      'beatGhost': beatGhost,
    };

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            puzzleNumber: widget.puzzle.number,
            attempts: _usedTiles.length + _misses,
            inputLog: List.from(_inputLog),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('⏱ ${_elapsed.toStringAsFixed(1)}秒'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.modifier != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  widget.modifier!.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
        ],
      ),
      body: RichBackground(
        child: Column(
        children: [
          _RaceBar(
            playerProgress: _playerProgress,
            ghostProgress: _ghostProgress,
          ),
          _ComboBanner(combo: _combo, score: _score, flash: _comboFlash),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.puzzle.context != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        widget.puzzle.context!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  _EquationBoard(
                    key: ValueKey(_shakeKey),
                    equation: widget.puzzle.equation,
                    slots: _slots,
                    puzzle: widget.puzzle,
                    onAccept: _onTileDropped,
                  ).animate(key: ValueKey(_shakeKey)).shakeX(
                        hz: _shakeKey == 0 ? 0 : 4,
                        amount: _shakeKey == 0 ? 0 : 6,
                      ),
                ],
              ),
            ),
          ),
          _TileTray(
            tiles: widget.puzzle.tiles,
            usedTiles: _usedTiles,
            hintTileIndex: _hintTileIndex,
            puzzle: widget.puzzle,
          ),
          const SizedBox(height: 16),
        ],
        ),
      ),
    );
  }
}

/// あなた vs 👻 のリアルタイムレース
class _RaceBar extends StatelessWidget {
  final double playerProgress;
  final double ghostProgress;

  const _RaceBar({required this.playerProgress, required this.ghostProgress});

  @override
  Widget build(BuildContext context) {
    final leading = playerProgress >= ghostProgress;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: AppTheme.primary.withOpacity(0.2))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🏃', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    'あなた',
                    style: TextStyle(
                      color: leading ? AppTheme.success : AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                leading ? 'リード中！🔥' : 'ゴーストが先行👻',
                style: TextStyle(
                  color: leading ? AppTheme.success : AppTheme.warning,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Row(
                children: [
                  Text('ゴースト',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  SizedBox(width: 4),
                  Text('👻', style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _track(playerProgress, AppTheme.primary, '🏃'),
          const SizedBox(height: 6),
          _track(ghostProgress, AppTheme.textSecondary, '👻'),
        ],
      ),
    );
  }

  Widget _track(double progress, Color color, String emoji) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return SizedBox(
          height: 18,
          child: Stack(
            children: [
              Container(
                height: 6,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                height: 6,
                width: (w * progress).clamp(0, w),
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 120),
                left: (w * progress - 9).clamp(0, w - 18),
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ComboBanner extends StatelessWidget {
  final int combo;
  final int score;
  final String? flash;

  const _ComboBanner({required this.combo, required this.score, this.flash});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'x$combo',
                style: TextStyle(
                  color: combo >= 3 ? AppTheme.accent : AppTheme.textSecondary,
                  fontSize: combo >= 3 ? 28 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Text('COMBO',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
          if (flash != null)
            Flexible(
              child: Text(
                flash!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ).animate().fadeIn(duration: 150.ms).then().fadeOut(delay: 500.ms),
            ),
          Text(
            '$score pt',
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EquationBoard extends StatelessWidget {
  final String equation;
  final List<int?> slots;
  final DragPuzzle puzzle;
  final void Function(int slotIndex, int tileIndex) onAccept;

  const _EquationBoard({
    super.key,
    required this.equation,
    required this.slots,
    required this.puzzle,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final parts = equation.split('◯');
    final widgets = <Widget>[];
    var slotIdx = 0;
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        widgets.add(Text(
          parts[i],
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
      if (i < parts.length - 1) {
        final idx = slotIdx;
        widgets.add(_Slot(
          value: slots[idx],
          label: slots[idx] != null ? puzzle.labelOf(slots[idx]!) : null,
          onAccept: (tileIndex) => onAccept(idx, tileIndex),
        ));
        slotIdx++;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 12,
          children: widgets,
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  final int? value;
  final String? label;
  final void Function(int tileIndex) onAccept;

  const _Slot({required this.value, required this.onAccept, this.label});

  @override
  Widget build(BuildContext context) {
    final displayText = label ?? (value != null ? '$value' : '');
    return DragTarget<int>(
      onWillAccept: (_) => value == null,
      onAccept: onAccept,
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        return Container(
          width: 56,
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: value != null
                ? AppTheme.success.withOpacity(0.2)
                : hovering
                    ? AppTheme.primary.withOpacity(0.3)
                    : AppTheme.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value != null
                  ? AppTheme.success
                  : hovering
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              displayText,
              style: TextStyle(
                color: value != null ? AppTheme.success : AppTheme.textSecondary,
                fontSize: displayText.length > 2 ? 20 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TileTray extends StatelessWidget {
  final List<int> tiles;
  final Set<int> usedTiles;
  final int? hintTileIndex;
  final DragPuzzle puzzle;

  const _TileTray({
    required this.tiles,
    required this.usedTiles,
    required this.puzzle,
    this.hintTileIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.primary.withOpacity(0.25))),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'タイルをドラッグして当てはめよう',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < tiles.length; i++)
                if (!usedTiles.contains(i))
                  _DraggableTile(
                    index: i,
                    value: tiles[i],
                    label: puzzle.labelOf(tiles[i]),
                    isHint: hintTileIndex == i,
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DraggableTile extends StatelessWidget {
  final int index;
  final int value;
  final String label;
  final bool isHint;

  const _DraggableTile({
    required this.index,
    required this.value,
    required this.label,
    required this.isHint,
  });

  Widget _tile({bool dragging = false}) {
    final isEmoji = label.runes.length == 1 &&
        label.runes.first > 0x1F000; // 絵文字判定
    final fontSize = isEmoji ? 28.0 : (label.length > 2 ? 18.0 : 26.0);
    final w = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHint
              ? [AppTheme.accent, const Color(0xFFFFA000)]
              : [AppTheme.primary, AppTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isHint ? AppTheme.accent : AppTheme.primary)
                .withOpacity(dragging ? 0.6 : 0.35),
            blurRadius: dragging ? 16 : 8,
            spreadRadius: dragging ? 2 : 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    if (isHint && !dragging) {
      return w.animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            duration: 600.ms,
            begin: const Offset(1, 1),
            end: const Offset(1.12, 1.12),
          );
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<int>(
      data: index,
      onDragStarted: () => HapticFeedback.selectionClick(),
      feedback: _tile(dragging: true),
      childWhenDragging: Opacity(opacity: 0.25, child: _tile()),
      child: _tile(),
    );
  }
}
