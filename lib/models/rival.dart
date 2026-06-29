class Rival {
  final String userId;
  final String userName;
  final int rank;
  final double? todayTime;
  final String? country;
  final bool isSelf;

  const Rival({
    required this.userId,
    required this.userName,
    required this.rank,
    this.todayTime,
    this.country,
    this.isSelf = false,
  });

  factory Rival.fromMap(Map<String, dynamic> m) => Rival(
        userId: m['userId'] as String,
        userName: m['userName'] as String,
        rank: m['rank'] as int,
        todayTime: (m['todayTime'] as num?)?.toDouble(),
        country: m['country'] as String?,
        isSelf: m['isSelf'] as bool? ?? false,
      );
}
