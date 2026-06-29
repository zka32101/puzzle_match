class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? profileImage;
  final double timeSeconds;
  final int rank;
  final String? country;

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.profileImage,
    required this.timeSeconds,
    required this.rank,
    this.country,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      profileImage: map['profileImage'] as String?,
      timeSeconds: (map['timeSeconds'] as num).toDouble(),
      rank: map['rank'] as int,
      country: map['country'] as String?,
    );
  }
}
