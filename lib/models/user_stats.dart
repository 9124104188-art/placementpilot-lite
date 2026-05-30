class UserStats {
  final int xp;
  final int streak;
  final double progress;

  UserStats({required this.xp, required this.streak, required this.progress});

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      xp: map['xp'] ?? 0,
      streak: map['streak'] ?? 0,
      progress: (map['progress'] ?? 0).toDouble(),
    );
  }
}
