import '../models/drag_puzzle.dart';
import 'puzzle_generator.dart';

class PuzzleData {
  static final List<DragPuzzle> all = PuzzleGenerator.generate();

  static DragPuzzle getDailyPuzzle() {
    final day = DateTime.now().day;
    final idx = (day - 1) % all.length;
    return all[idx];
  }

  static List<DragPuzzle> getByDifficulty(int difficulty) {
    return all.where((p) => p.difficulty == difficulty).toList();
  }

  static int get easyCount => getByDifficulty(1).length;
  static int get normalCount => getByDifficulty(2).length;
  static int get hardCount => getByDifficulty(3).length;
}
