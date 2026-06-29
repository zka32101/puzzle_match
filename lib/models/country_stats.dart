class CountryStats {
  final String country;
  final double avgTime;
  final int participants;
  final int rank;
  final DateTime computedAt;

  const CountryStats({
    required this.country,
    required this.avgTime,
    required this.participants,
    required this.rank,
    required this.computedAt,
  });

  factory CountryStats.fromMap(Map<String, dynamic> m) => CountryStats(
    country: m['country'] as String,
    avgTime: (m['avgTime'] as num).toDouble(),
    participants: m['participants'] as int,
    rank: m['rank'] as int,
    computedAt: DateTime.parse(m['computedAt'] as String),
  );

  Map<String, dynamic> toMap() => {
    'country': country,
    'avgTime': avgTime,
    'participants': participants,
    'rank': rank,
    'computedAt': computedAt.toIso8601String(),
  };
}
