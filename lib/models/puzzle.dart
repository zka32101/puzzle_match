class Puzzle {
  final String id;
  final int number;
  final DateTime publishedDate;
  final String category;
  final int difficulty;
  final String question;
  final String expectedFormat;
  final String solutionHash;
  final int totalAttempts;
  final double avgSolveTime;

  const Puzzle({
    required this.id,
    required this.number,
    required this.publishedDate,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.expectedFormat,
    required this.solutionHash,
    this.totalAttempts = 0,
    this.avgSolveTime = 0,
  });

  factory Puzzle.fromMap(Map<String, dynamic> map, String id) {
    return Puzzle(
      id: id,
      number: map['number'] as int,
      publishedDate: DateTime.parse(map['publishedDate'] as String),
      category: map['category'] as String,
      difficulty: map['difficulty'] as int,
      question: map['content']['question'] as String,
      expectedFormat: map['content']['expectedFormat'] as String,
      solutionHash: map['solutionHash'] as String,
      totalAttempts: (map['stats']?['totalAttempts'] as int?) ?? 0,
      avgSolveTime: (map['stats']?['avgSolveTime'] as num?)?.toDouble() ?? 0,
    );
  }
}
