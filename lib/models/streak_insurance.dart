class StreakInsurance {
  final String userId;
  final bool isActive;
  final DateTime? expiresAt;
  final int usesRemaining;
  final int totalUses;
  static const int maxUses = 1;
  static const double monthlyPrice = 120.0;

  const StreakInsurance({
    required this.userId,
    required this.isActive,
    this.expiresAt,
    this.usesRemaining = 1,
    this.totalUses = 1,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get canUse => isActive && !isExpired && usesRemaining > 0;

  factory StreakInsurance.fromMap(Map<String, dynamic> m) => StreakInsurance(
    userId: m['userId'] as String,
    isActive: m['isActive'] as bool? ?? false,
    expiresAt: m['expiresAt'] != null ? DateTime.parse(m['expiresAt'] as String) : null,
    usesRemaining: m['usesRemaining'] as int? ?? 0,
    totalUses: m['totalUses'] as int? ?? 1,
  );

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'isActive': isActive,
    'expiresAt': expiresAt?.toIso8601String(),
    'usesRemaining': usesRemaining,
    'totalUses': totalUses,
  };
}
