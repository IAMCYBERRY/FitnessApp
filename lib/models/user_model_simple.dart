/// Simple user model for testing without Firebase dependencies.
/// 
/// This is a simplified version of the user model that doesn't use
/// Firestore Timestamp or other Firebase-specific types.

/// User rank levels from E (beginner) to SS (expert)
enum RankLevel { E, D, C, B, A, S, SS }

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String displayName;
  final DateTime dateJoined;
  final double weightLifted;
  final double distanceWalked;
  final String rank;
  final int totalPoints;
  final int weeklyPoints;
  final int workoutStreak;
  final bool isRivalModeActive;
  final String? currentRivalId;
  final String fitnessLevel;
  final List<String> fitnessGoals;

  const UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayName,
    required this.dateJoined,
    required this.weightLifted,
    required this.distanceWalked,
    required this.rank,
    required this.totalPoints,
    required this.weeklyPoints,
    required this.workoutStreak,
    required this.isRivalModeActive,
    this.currentRivalId,
    required this.fitnessLevel,
    required this.fitnessGoals,
  });

  /// Calculate rank level based on total points
  /// 
  /// @param points Total points accumulated by the user
  /// @return Appropriate RankLevel
  static RankLevel getRankFromPoints(int points) {
    if (points >= 60000) return RankLevel.SS;
    if (points >= 30000) return RankLevel.S;
    if (points >= 15000) return RankLevel.A;
    if (points >= 7000) return RankLevel.B;
    if (points >= 3000) return RankLevel.C;
    if (points >= 1000) return RankLevel.D;
    return RankLevel.E;
  }
}