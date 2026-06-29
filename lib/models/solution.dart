class Solution {
  final String id;
  final String userId;
  final String puzzleId;
  final DateTime serverStartTime;
  final DateTime serverSubmitTime;
  final double timeSeconds;
  final int attempts;
  final bool isCorrect;
  final int closeCallLevel;
  final int globalRank;

  const Solution({
    required this.id,
    required this.userId,
    required this.puzzleId,
    required this.serverStartTime,
    required this.serverSubmitTime,
    required this.timeSeconds,
    required this.attempts,
    required this.isCorrect,
    required this.closeCallLevel,
    required this.globalRank,
  });

  factory Solution.fromMap(Map<String, dynamic> map, String id) {
    return Solution(
      id: id,
      userId: map['userId'] as String,
      puzzleId: map['puzzleId'] as String,
      serverStartTime: DateTime.parse(map['serverStartTime'] as String),
      serverSubmitTime: DateTime.parse(map['serverSubmitTime'] as String),
      timeSeconds: (map['timeSeconds'] as num).toDouble(),
      attempts: map['attempts'] as int,
      isCorrect: map['isCorrect'] as bool,
      closeCallLevel: (map['closeCallLevel'] as int?) ?? 0,
      globalRank: (map['globalRank'] as int?) ?? 0,
    );
  }
}
