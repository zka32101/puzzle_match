import 'dart:math';
import '../models/drag_puzzle.dart';

/// パズルを数学的に検証しながら自動生成するエンジン
class PuzzleGenerator {
  static final _rng = Random(42); // 再現可能なシード

  /// 全パズルを生成して返す（計算・数列・ことば・絵文字）
  static List<DragPuzzle> generate() {
    final easy   = _buildEasy(1);
    final normal = _buildNormal(easy.length + 1);
    final hard   = _buildHard(easy.length + normal.length + 1);
    final seq    = _buildSequence(easy.length + normal.length + hard.length + 1);
    final word   = _buildWord(easy.length + normal.length + hard.length + seq.length + 1);
    final emoji  = _buildEmoji(easy.length + normal.length + hard.length + seq.length + word.length + 1);
    return [...easy, ...normal, ...hard, ...seq, ...word, ...emoji];
  }

  // ── Easy テンプレート ──────────────────────────────────

  static List<DragPuzzle> _buildEasy(int startNum) {
    final list = <DragPuzzle>[];
    int n = startNum;

    // A + B = C （可換）
    for (final pair in [
      [3, 7], [4, 6], [2, 8], [5, 5], [1, 9],
      [6, 7], [3, 8], [4, 9], [2, 7], [5, 8],
    ]) {
      final a = pair[0], b = pair[1];
      list.add(_make(n++, '足し算', 1,
        equation: '◯ + ◯ = ${a + b}',
        solution: [a, b],
        orderSensitive: false,
        excludeFromDistractors: [a + b],
      ));
    }

    // A × B = C （可換）
    for (final pair in [
      [2, 3], [3, 4], [2, 6], [4, 5], [3, 7],
      [2, 9], [4, 6], [3, 8], [5, 6], [4, 7],
    ]) {
      final a = pair[0], b = pair[1];
      list.add(_make(n++, '掛け算', 1,
        equation: '◯ × ◯ = ${a * b}',
        solution: [a, b],
        orderSensitive: false,
        excludeFromDistractors: [a * b],
      ));
    }

    // A - B = C （順序重要: 左側が大きい）
    for (final pair in [
      [7, 3], [9, 4], [8, 5], [6, 2], [10, 3],
    ]) {
      final a = pair[0], b = pair[1];
      list.add(_make(n++, '引き算', 1,
        equation: '◯ - ◯ = ${a - b}',
        solution: [a, b],
        orderSensitive: true,
        excludeFromDistractors: [a - b],
      ));
    }

    // A + B + C = D
    for (final triple in [
      [2, 3, 5], [1, 4, 6], [3, 3, 4], [2, 4, 5], [1, 3, 7],
    ]) {
      final a = triple[0], b = triple[1], c = triple[2];
      list.add(_make(n++, '3つ足し算', 1,
        equation: '◯ + ◯ + ◯ = ${a + b + c}',
        solution: [a, b, c],
        orderSensitive: false,
        excludeFromDistractors: [a + b + c],
      ));
    }

    return list;
  }

  // ── Normal テンプレート ────────────────────────────────

  static List<DragPuzzle> _buildNormal(int startNum) {
    final list = <DragPuzzle>[];
    int n = startNum;

    // A × B + C = D （左から計算）
    for (final t in [
      [2, 3, 4], [3, 4, 1], [2, 5, 3], [4, 3, 5], [5, 2, 6],
      [3, 3, 7], [2, 7, 1], [4, 4, 4], [3, 5, 5], [6, 2, 3],
    ]) {
      final a = t[0], b = t[1], c = t[2];
      final result = a * b + c;
      list.add(_make(n++, '掛け算+足し算', 2,
        equation: '◯ × ◯ + ◯ = $result',
        solution: [a, b, c],
        orderSensitive: true,
        excludeFromDistractors: [result],
      ));
    }

    // A ÷ B = C（順序重要）
    for (final t in [
      [6, 2], [8, 4], [9, 3], [12, 4], [10, 5],
      [15, 3], [16, 4], [14, 7], [18, 6], [20, 5],
    ]) {
      final a = t[0], b = t[1];
      list.add(_make(n++, '割り算', 2,
        equation: '◯ ÷ ◯ = ${a ~/ b}',
        solution: [a, b],
        orderSensitive: true,
        excludeFromDistractors: [a ~/ b],
      ));
    }

    // (A + B) × C = D
    for (final t in [
      [2, 3, 4], [1, 4, 3], [2, 5, 2], [3, 4, 3], [1, 6, 2],
    ]) {
      final a = t[0], b = t[1], c = t[2];
      final result = (a + b) * c;
      list.add(_make(n++, '括弧計算', 2,
        equation: '(◯ + ◯) × ◯ = $result',
        solution: [a, b, c],
        orderSensitive: true,
        excludeFromDistractors: [result],
      ));
    }

    // A² + B = C
    for (final t in [
      [2, 1], [3, 1], [2, 5], [3, 7], [4, 2],
    ]) {
      final a = t[0], b = t[1];
      list.add(_make(n++, '二乗', 2,
        equation: '◯² + ◯ = ${a * a + b}',
        solution: [a, b],
        orderSensitive: true,
        excludeFromDistractors: [a * a + b],
      ));
    }

    // A + B = C × D
    for (final t in [
      [3, 7, 2, 5], [4, 8, 3, 4], [6, 9, 3, 5],
    ]) {
      final a = t[0], b = t[1], c = t[2], d = t[3];
      if (a + b == c * d) {
        list.add(_make(n++, '等式パズル', 2,
          equation: '◯ + ◯ = ◯ × ◯',
          solution: [a, b, c, d],
          orderSensitive: false,
          excludeFromDistractors: [],
        ));
      }
    }

    return list;
  }

  // ── Hard テンプレート ──────────────────────────────────

  static List<DragPuzzle> _buildHard(int startNum) {
    final list = <DragPuzzle>[];
    int n = startNum;

    // A × B - C = D（順序重要）
    for (final t in [
      [4, 5, 3], [3, 7, 2], [5, 6, 5], [4, 8, 7], [6, 5, 4],
      [7, 4, 3], [3, 9, 4], [5, 7, 6], [8, 4, 7], [6, 6, 1],
    ]) {
      final a = t[0], b = t[1], c = t[2];
      final result = a * b - c;
      if (result > 0) {
        list.add(_make(n++, '掛け算-引き算', 3,
          equation: '◯ × ◯ - ◯ = $result',
          solution: [a, b, c],
          orderSensitive: true,
          excludeFromDistractors: [result],
        ));
      }
    }

    // A² - B = C
    for (final t in [
      [4, 3], [5, 4], [4, 7], [5, 9], [6, 8],
      [3, 5], [4, 12], [5, 16], [6, 12], [3, 8],
    ]) {
      final a = t[0], b = t[1];
      final result = a * a - b;
      if (result > 0) {
        list.add(_make(n++, '二乗-引き算', 3,
          equation: '◯² - ◯ = $result',
          solution: [a, b],
          orderSensitive: true,
          excludeFromDistractors: [result],
        ));
      }
    }

    // A × B + C × D = E
    for (final t in [
      [2, 3, 4, 5], [3, 4, 2, 6], [5, 3, 4, 2],
      [2, 7, 3, 3], [4, 4, 3, 5],
    ]) {
      final a = t[0], b = t[1], c = t[2], d = t[3];
      final result = a * b + c * d;
      list.add(_make(n++, '複合計算', 3,
        equation: '◯ × ◯ + ◯ × ◯ = $result',
        solution: [a, b, c, d],
        orderSensitive: false,
        excludeFromDistractors: [result],
      ));
    }

    // (A - B) × C = D
    for (final t in [
      [7, 3, 4], [9, 5, 3], [8, 2, 5], [6, 4, 7], [10, 4, 3],
    ]) {
      final a = t[0], b = t[1], c = t[2];
      final result = (a - b) * c;
      list.add(_make(n++, '括弧引き算', 3,
        equation: '(◯ - ◯) × ◯ = $result',
        solution: [a, b, c],
        orderSensitive: true,
        excludeFromDistractors: [result],
      ));
    }

    return list;
  }

  // ── ヘルパー ──────────────────────────────────────────

  static DragPuzzle _makeMath(
    int number, String category, int difficulty, {
    required String equation,
    required List<int> solution,
    required bool orderSensitive,
    required List<int> excludeFromDistractors,
  }) => _make(number, category, difficulty,
    equation: equation, solution: solution,
    orderSensitive: orderSensitive,
    excludeFromDistractors: excludeFromDistractors,
  );

  /// パズルを1つ作成。タイルはsolution + ランダムなdistractor
  static DragPuzzle _make(
    int number,
    String category,
    int difficulty, {
    required String equation,
    required List<int> solution,
    required bool orderSensitive,
    required List<int> excludeFromDistractors,
  }) {
    // タイルを生成: solutionを含む9～10枚
    final tileSet = <int>{...solution};
    final excluded = {...solution, ...excludeFromDistractors};
    // ディストラクター候補（1～20の中からランダム）
    final candidates = List.generate(20, (i) => i + 1)
        .where((v) => !excluded.contains(v))
        .toList()
      ..shuffle(_rng);
    final need = max(0, 9 - tileSet.length);
    tileSet.addAll(candidates.take(need));
    final tiles = tileSet.toList()..shuffle(_rng);

    return DragPuzzle(
      number: number,
      category: category,
      difficulty: difficulty,
      equation: equation,
      slotCount: solution.length,
      tiles: tiles,
      solution: solution,
      orderSensitive: orderSensitive,
    );
  }

  // ── 数列パズル ────────────────────────────────────────

  static List<DragPuzzle> _buildSequence(int startNum) {
    final list = <DragPuzzle>[];
    int n = startNum;

    // 等差数列
    for (final t in [
      [2, 4, 6,  0, 10, 12],  // 0=8
      [3, 6, 9,  0, 15, 18],  // 0=12
      [5, 10,0, 20, 25, 30],  // 0=15
      [1, 4, 7,  0, 13, 16],  // 0=10
      [10,8, 6,  0,  2,  0],  // 0=4（降順）
    ]) {
      final seq = List<int>.from(t);
      final blanks = <int>[];
      for (var i = 0; i < seq.length; i++) {
        if (seq[i] == 0) blanks.add(i);
      }
      if (blanks.isEmpty) continue;
      // 数列の差を計算
      final diff = seq.firstWhere((v) => v != 0, orElse: () => 1);
      // 欠けている値を復元
      final full = List<int>.generate(seq.length, (i) {
        if (seq[i] != 0) return seq[i];
        // 前後の有効値から補間
        int? prev, next;
        for (var j = i - 1; j >= 0; j--) { if (seq[j] != 0) { prev = seq[j]; break; } }
        for (var j = i + 1; j < seq.length; j++) { if (seq[j] != 0) { next = seq[j]; break; } }
        if (prev != null && next != null) return (prev + next) ~/ 2;
        if (prev != null) return prev + diff;
        if (next != null) return next - diff;
        return 0;
      });

      final solution = [for (var i in blanks) full[i]];
      final display = [
        for (var i = 0; i < seq.length; i++)
          blanks.contains(i) ? '◯' : '${full[i]}'
      ].join(', ');

      list.add(_makeMath(n++, '数列', 1,
        equation: '$display',
        solution: solution,
        orderSensitive: true,
        excludeFromDistractors: full,
      ));
    }

    // フィボナッチ数列
    final fib = [1, 1, 2, 3, 5, 8, 13, 21];
    for (var blank = 3; blank <= 6; blank++) {
      final display = [
        for (var i = 0; i < 6; i++) i == blank ? '◯' : '${fib[i]}'
      ].join(', ');
      list.add(_makeMath(n++, 'フィボナッチ', 2,
        equation: display,
        solution: [fib[blank]],
        orderSensitive: true,
        excludeFromDistractors: fib,
      ));
    }

    // 等比数列（×2, ×3）
    for (final t in [
      [1, 2, 4, 0, 16],   // ×2: 0=8
      [2, 6, 0, 54],      // ×3: 0=18
      [1, 3, 9, 0, 81],   // ×3: 0=27
      [5, 10, 20, 0, 80], // ×2: 0=40
    ]) {
      final seq = List<int>.from(t);
      final blankIdx = seq.indexOf(0);
      if (blankIdx < 1) continue;
      final ratio = seq[blankIdx - 1] > 0 ? (seq.length > blankIdx + 1 && seq[blankIdx + 1] > 0
          ? seq[blankIdx + 1] ~/ (seq[blankIdx - 1])
          : 2) : 2;
      final ans = seq[blankIdx - 1] * ratio;
      seq[blankIdx] = ans;
      final display = [for (var i = 0; i < seq.length; i++) i == blankIdx ? '◯' : '${seq[i]}'].join(', ');
      list.add(_makeMath(n++, '等比数列', 2,
        equation: display,
        solution: [ans],
        orderSensitive: true,
        excludeFromDistractors: seq,
      ));
    }

    return list;
  }

  // ── ことばパズル（ひらがな） ─────────────────────────

  static List<DragPuzzle> _buildWord(int startNum) {
    final list = <DragPuzzle>[];
    int n = startNum;

    // 規則: labels の先頭に答え文字を並べ、solution=[0], [0,1] などとする
    // solution[i] = そのスロットが受け入れるタイルの値（= labels のインデックス）
    // 例: solution=[0] → スロット0 は labels[0] のタイルのみ正解
    final defs = [
      // ── Easy（1スロット・3文字以内） ──
      // りんご: ◯ ん ご → り
      _WordDef('◯ ん ご',     [0], ['り', 'ば', 'め', 'す', 'ぬ', 'も', 'つ', 'か', 'な'], '果物（くだもの）', 1),
      // うさぎ: う さ ◯ → ぎ
      _WordDef('う さ ◯',    [0], ['ぎ', 'ね', 'め', 'か', 'む', 'て', 'わ', 'こ', 'く'], '動物（どうぶつ）', 1),
      // さくら: さ ◯ ら → く
      _WordDef('さ ◯ ら',    [0], ['く', 'せ', 'お', 'ん', 'づ', 'み', 'し', 'ゆ', 'ち'], '花（はな）', 1),
      // きいろ: き い ◯ → ろ
      _WordDef('き い ◯',    [0], ['ろ', 'め', 'す', 'か', 'ふ', 'て', 'を', 'の', 'は'], '色（いろ）', 1),
      // かみ: ◯ み → か
      _WordDef('◯ み',       [0], ['か', 'ね', 'も', 'わ', 'い', 'は', 'ふ', 'く', 'ち'], '道具（どうぐ）', 1),
      // ── Normal（1スロット・4文字） ──
      // えんぴつ: ◯ ん ぴ つ → え
      _WordDef('◯ ん ぴ つ', [0], ['え', 'お', 'あ', 'い', 'う', 'き', 'け', 'く', 'こ'], '文房具（ぶんぼうぐ）', 2),
      // たいよう: た い よ ◯ → う
      _WordDef('た い よ ◯', [0], ['う', 'め', 'ん', 'か', 'な', 'し', 'ら', 'て', 'は'], '天体（てんたい）', 2),
      // ひこうき: ひ ◯ う き → こ
      _WordDef('ひ ◯ う き',  [0], ['こ', 'の', 'ふ', 'ね', 'む', 'ら', 'え', 'あ', 'そ'], '乗り物（のりもの）', 2),
      // おにぎり: ◯ に ぎ り → お
      _WordDef('◯ に ぎ り', [0], ['お', 'あ', 'い', 'う', 'え', 'か', 'き', 'く', 'こ'], '食べ物（たべもの）', 2),
      // ── Hard（2スロット穴あき） ──
      // たなばた: た ◯ ば ◯ → な(0), た(1)
      _WordDef('た ◯ ば ◯',     [0,1], ['な', 'た', 'さ', 'か', 'に', 'め', 'は', 'ら', 'く'], '行事（ぎょうじ）', 3),
      // こいのぼり: ◯ い の ◯ り → こ(0), ぼ(1)
      _WordDef('◯ い の ◯ り',  [0,1], ['こ', 'ぼ', 'と', 'さ', 'め', 'か', 'ね', 'ら', 'む'], '行事（ぎょうじ）', 3),
    ];

    for (final d in defs) {
      list.add(DragPuzzle(
        number: n++,
        category: 'ことば',
        difficulty: d.difficulty,
        type: PuzzleType.word,
        equation: d.equation,
        context: d.context,
        slotCount: d.solution.length,
        tiles: List.generate(d.labels.length, (i) => i),
        solution: d.solution,
        tileLabels: d.labels,
        orderSensitive: true,
      ));
    }

    return list;
  }

  // ── 絵文字パズル ──────────────────────────────────────

  static List<DragPuzzle> _buildEmoji(int startNum) {
    final list = <DragPuzzle>[];
    int n = startNum;

    // 仲間外れ
    final outsiders = [
      _EmojiDef(
        context: '果物（くだもの）の仲間外れは？',
        equation: '答え: ◯',
        labels: ['🍎', '🍊', '🍋', '🚗', '🍇'],
        solution: [3], // 🚗
      ),
      _EmojiDef(
        context: '動物（どうぶつ）の仲間外れは？',
        equation: '答え: ◯',
        labels: ['🐶', '🐱', '✈️', '🐸', '🐰'],
        solution: [2], // ✈️
      ),
      _EmojiDef(
        context: '乗り物（のりもの）の仲間外れは？',
        equation: '答え: ◯',
        labels: ['🚗', '🚌', '🍕', '✈️', '🚢'],
        solution: [2], // 🍕
      ),
      _EmojiDef(
        context: '天気（てんき）の仲間外れは？',
        equation: '答え: ◯',
        labels: ['☀️', '🌧️', '❄️', '🍔', '🌈'],
        solution: [3], // 🍔
      ),
    ];

    for (final d in outsiders) {
      list.add(DragPuzzle(
        number: n++,
        category: '仲間外れ',
        difficulty: 1,
        type: PuzzleType.emoji,
        context: d.context,
        equation: d.equation,
        slotCount: 1,
        tiles: List.generate(d.labels.length, (i) => i),
        solution: d.solution,
        tileLabels: d.labels,
        orderSensitive: true,
      ));
    }

    // 順番並べ（大きさ順・順序）
    final orders = [
      _EmojiDef(
        context: '大きい順に並べよう（大→中→小）',
        equation: '◯ > ◯ > ◯',
        labels: ['🐭', '🐘', '🐱'],
        solution: [1, 2, 0], // 🐘 > 🐱 > 🐭
      ),
      _EmojiDef(
        context: '速い順に並べよう（速→遅）',
        equation: '◯ > ◯ > ◯',
        labels: ['🚶', '✈️', '🚗'],
        solution: [1, 2, 0], // ✈️ > 🚗 > 🚶
      ),
      _EmojiDef(
        context: '時刻の順に並べよう（朝→昼→夜）',
        equation: '◯ → ◯ → ◯',
        labels: ['🌙', '🌅', '☀️'],
        solution: [1, 2, 0], // 🌅 → ☀️ → 🌙
      ),
    ];

    for (final d in orders) {
      list.add(DragPuzzle(
        number: n++,
        category: '順番パズル',
        difficulty: 2,
        type: PuzzleType.emoji,
        context: d.context,
        equation: d.equation,
        slotCount: d.solution.length,
        tiles: List.generate(d.labels.length, (i) => i),
        solution: d.solution,
        tileLabels: d.labels,
        orderSensitive: true,
      ));
    }

    // 連想パズル（季節・ペア）
    final associations = [
      _EmojiDef(
        context: '春:🌸 夏:🌻 秋:🍁 冬:◯',
        equation: '冬といえば？',
        labels: ['⛄', '🌊', '🌺', '🍄', '🌿'],
        solution: [0], // ⛄
      ),
      _EmojiDef(
        context: '🌞 と 反対（はんたい）は？',
        equation: '答え: ◯',
        labels: ['🌙', '⭐', '☁️', '❄️', '🌊'],
        solution: [0], // 🌙
      ),
      _EmojiDef(
        context: '🍚 を食べるときに使う道具は？',
        equation: '答え: ◯',
        labels: ['🍴', '🥢', '🔧', '✏️', '🎸'],
        solution: [1], // 🥢
      ),
    ];

    for (final d in associations) {
      list.add(DragPuzzle(
        number: n++,
        category: '連想パズル',
        difficulty: 2,
        type: PuzzleType.emoji,
        context: d.context,
        equation: d.equation,
        slotCount: 1,
        tiles: List.generate(d.labels.length, (i) => i),
        solution: d.solution,
        tileLabels: d.labels,
        orderSensitive: true,
      ));
    }

    return list;
  }

  // 未使用の旧ヘルパー（後方互換のため残す）
  static List<DragPuzzle> _addSub(int n, {required int limit}) => [];
  static List<DragPuzzle> _mul(int n) => [];
}

class _WordDef {
  final String equation;
  final List<int> solution;
  final List<String> labels;
  final String context;
  final int difficulty;
  _WordDef(this.equation, this.solution, this.labels, this.context, this.difficulty);
}

class _EmojiDef {
  final String context;
  final String equation;
  final List<String> labels;
  final List<int> solution;
  _EmojiDef({required this.context, required this.equation, required this.labels, required this.solution});
}
