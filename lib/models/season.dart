enum Tier { bronze, silver, gold, platinum, diamond }

class SeasonInfo {
  final int seasonId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const SeasonInfo({
    required this.seasonId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory SeasonInfo.fromMap(Map<String, dynamic> m) => SeasonInfo(
    seasonId: m['seasonId'] as int,
    name: m['name'] as String,
    startDate: DateTime.parse(m['startDate'] as String),
    endDate: DateTime.parse(m['endDate'] as String),
    isActive: m['isActive'] as bool,
  );
}

class UserSeason {
  final String userId;
  final int seasonId;
  final Tier tier;
  final int points;
  final int rank;
  final bool promoted;
  final bool demoted;

  const UserSeason({
    required this.userId,
    required this.seasonId,
    required this.tier,
    required this.points,
    required this.rank,
    this.promoted = false,
    this.demoted = false,
  });

  factory UserSeason.fromMap(Map<String, dynamic> m) => UserSeason(
    userId: m['userId'] as String,
    seasonId: m['seasonId'] as int,
    tier: Tier.values[m['tier'] as int? ?? 0],
    points: m['points'] as int,
    rank: m['rank'] as int,
    promoted: m['promoted'] as bool? ?? false,
    demoted: m['demoted'] as bool? ?? false,
  );

  String get emoji => switch (tier) {
    Tier.bronze => '🥉',
    Tier.silver => '⚪',
    Tier.gold => '🟡',
    Tier.platinum => '💎',
    Tier.diamond => '👑',
  };

  String get tierName => switch (tier) {
    Tier.bronze => 'Bronze',
    Tier.silver => 'Silver',
    Tier.gold => 'Gold',
    Tier.platinum => 'Platinum',
    Tier.diamond => 'Diamond',
  };
}
