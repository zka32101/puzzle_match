enum PuzzleType { math, sequence, word, emoji }

/// ドラッグ操作パズルのデータ構造
class DragPuzzle {
  final int number;
  final String category;
  final int difficulty;
  final PuzzleType type;

  /// 式・問題文（◯がスロット位置）
  final String equation;

  /// 補足ヒント（問題の上に表示）
  final String? context;

  /// スロット数
  final int slotCount;

  /// タイル値リスト（int インデックス）
  final List<int> tiles;

  /// 正解（スロット順）
  final List<int> solution;

  /// null → 数値をそのまま表示
  /// non-null → labels[value] を表示（ことば・絵文字パズル用）
  final List<String>? tileLabels;

  /// true: スロット順序が重要（引き算・割り算など）
  final bool orderSensitive;

  const DragPuzzle({
    required this.number,
    required this.category,
    required this.difficulty,
    required this.equation,
    required this.slotCount,
    required this.tiles,
    required this.solution,
    this.type = PuzzleType.math,
    this.context,
    this.tileLabels,
    this.orderSensitive = false,
  });

  /// タイル値 → 表示テキスト
  String labelOf(int value) =>
      (tileLabels != null && value >= 0 && value < tileLabels!.length)
          ? tileLabels![value]
          : '$value';

  /// スロットへの配置が正しいか判定
  /// [slotIndex] : ドロップ先のスロット番号
  /// [value]     : 配置しようとしている値
  /// [currentSlots] : 現在のスロット状態（nullは空き）
  bool isCorrectPlacement(int slotIndex, int value, List<int?> currentSlots) {
    if (orderSensitive) {
      // 順序重要：そのスロットの正解と一致するか
      if (slotIndex >= solution.length) return false;
      return solution[slotIndex] == value;
    } else {
      // 順序不問：まだ配置されていない正解値かどうか
      final placed = currentSlots.whereType<int>().toList();
      final needed = List<int>.from(solution);
      for (final p in placed) {
        needed.remove(p);
      }
      return needed.contains(value);
    }
  }

  bool isSolved(List<int?> slots) {
    final placed = slots.whereType<int>().toList();
    if (placed.length != solution.length) return false;
    if (orderSensitive) {
      for (var i = 0; i < solution.length; i++) {
        if (slots[i] != solution[i]) return false;
      }
      return true;
    } else {
      final a = List<int>.from(placed)..sort();
      final b = List<int>.from(solution)..sort();
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }
  }
}
