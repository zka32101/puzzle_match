class InputLogEntry {
  final int relativeTimeMs;
  final String action;
  final String value;

  const InputLogEntry({
    required this.relativeTimeMs,
    required this.action,
    required this.value,
  });

  Map<String, dynamic> toMap() => {
        'relativeTimeMs': relativeTimeMs,
        'action': action,
        'value': value,
      };

  factory InputLogEntry.fromMap(Map<String, dynamic> m) => InputLogEntry(
        relativeTimeMs: m['relativeTimeMs'] as int,
        action: m['action'] as String,
        value: m['value'] as String,
      );
}

class GhostReplay {
  final String userId;
  final String userName;
  final int rank;
  final double timeSeconds;
  final List<InputLogEntry> inputLog;

  const GhostReplay({
    required this.userId,
    required this.userName,
    required this.rank,
    required this.timeSeconds,
    required this.inputLog,
  });

  factory GhostReplay.fromMap(Map<String, dynamic> m) => GhostReplay(
        userId: m['userId'] as String,
        userName: m['userName'] as String? ?? 'Unknown',
        rank: m['rank'] as int,
        timeSeconds: (m['timeSeconds'] as num).toDouble(),
        inputLog: (m['inputLog'] as List<dynamic>? ?? [])
            .map((e) => InputLogEntry.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
}
