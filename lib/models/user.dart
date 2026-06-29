class AppUser {
  final String id;
  final String displayName;
  final String email;
  final String? profileImage;
  final String authProvider;
  final String country;
  final DateTime createdAt;
  final DateTime lastPlayedAt;
  final int currentStreak;
  final int longestStreak;
  final bool notificationsEnabled;
  final bool darkMode;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    this.profileImage,
    required this.authProvider,
    required this.country,
    required this.createdAt,
    required this.lastPlayedAt,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.notificationsEnabled = true,
    this.darkMode = true,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      displayName: map['displayName'] as String,
      email: (map['email'] as String?) ?? '',
      profileImage: map['profileImage'] as String?,
      authProvider: map['authProvider'] as String,
      country: (map['country'] as String?) ?? 'JP',
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastPlayedAt: DateTime.parse(map['lastPlayedAt'] as String),
      currentStreak: (map['currentStreak'] as int?) ?? 0,
      longestStreak: (map['longestStreak'] as int?) ?? 0,
      notificationsEnabled: (map['preferences']?['notifications'] as bool?) ?? true,
      darkMode: (map['preferences']?['darkMode'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'profileImage': profileImage,
      'authProvider': authProvider,
      'country': country,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'preferences': {
        'notifications': notificationsEnabled,
        'darkMode': darkMode,
      },
    };
  }

  AppUser copyWith({
    String? displayName,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastPlayedAt,
  }) {
    return AppUser(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email,
      profileImage: profileImage,
      authProvider: authProvider,
      country: country,
      createdAt: createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      notificationsEnabled: notificationsEnabled,
      darkMode: darkMode,
    );
  }
}
