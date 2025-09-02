/// Challenge model for group fitness competitions.
/// 
/// This model represents both public and private challenges where
/// multiple users compete for the highest points within a timeframe.

import 'package:flutter/material.dart';
import 'user_model_clean.dart';

/// Types of challenges available
enum ChallengeType {
  public,   // Open to all users
  private,  // Invite-only
  daily,    // 24-hour challenges
}

/// Status of a challenge
enum ChallengeStatus {
  upcoming,
  active,
  completed,
}

/// Represents a fitness challenge
class Challenge {
  final String id;
  final String name;
  final String description;
  final ChallengeType type;
  final ChallengeStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String creatorId;
  final String creatorName;
  final List<String> participantIds;
  final Map<String, int> leaderboard; // userId -> points
  final int maxParticipants;
  final String? imageUrl;
  final List<String> rules;
  final int entryFee; // Points required to join
  final int prizePool; // Total points for winners
  final Map<String, String> inviteStatus; // userId -> 'pending'/'accepted'/'declined'

  Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.creatorId,
    required this.creatorName,
    required this.participantIds,
    required this.leaderboard,
    this.maxParticipants = 100,
    this.imageUrl,
    required this.rules,
    this.entryFee = 0,
    this.prizePool = 0,
    this.inviteStatus = const {},
  });

  /// Check if challenge is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Get remaining time
  Duration get remainingTime {
    if (status == ChallengeStatus.completed) return Duration.zero;
    return endDate.difference(DateTime.now());
  }

  /// Get formatted remaining time
  String get remainingTimeFormatted {
    final duration = remainingTime;
    if (duration.isNegative) return 'Ended';
    
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  /// Get sorted leaderboard entries
  List<MapEntry<String, int>> get sortedLeaderboard {
    final entries = leaderboard.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Get user's rank in challenge
  int getUserRank(String userId) {
    final sorted = sortedLeaderboard;
    for (int i = 0; i < sorted.length; i++) {
      if (sorted[i].key == userId) {
        return i + 1;
      }
    }
    return -1; // Not participating
  }

  /// Get challenge type display name
  String get typeDisplayName {
    switch (type) {
      case ChallengeType.public:
        return 'Public Challenge';
      case ChallengeType.private:
        return 'Private Challenge';
      case ChallengeType.daily:
        return 'Daily Challenge';
    }
  }

  /// Get challenge type icon
  IconData get typeIcon {
    switch (type) {
      case ChallengeType.public:
        return Icons.public;
      case ChallengeType.private:
        return Icons.lock;
      case ChallengeType.daily:
        return Icons.today;
    }
  }

  /// Get challenge status color
  Color get statusColor {
    switch (status) {
      case ChallengeStatus.upcoming:
        return Colors.blue;
      case ChallengeStatus.active:
        return Colors.green;
      case ChallengeStatus.completed:
        return Colors.grey;
    }
  }
}

/// Represents a 1v1 rival session
class RivalSession {
  final String id;
  final String userId1;
  final String userId2;
  final String user1Name;
  final String user2Name;
  final String? user1Avatar;
  final String? user2Avatar;
  final DateTime startDate;
  final DateTime endDate;
  final int user1Points;
  final int user2Points;
  final bool isActive;
  final String? winnerId;
  final int wagerAmount; // Points wagered
  final Map<String, List<String>> activities; // userId -> activity descriptions

  RivalSession({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.user1Name,
    required this.user2Name,
    this.user1Avatar,
    this.user2Avatar,
    required this.startDate,
    required this.endDate,
    this.user1Points = 0,
    this.user2Points = 0,
    required this.isActive,
    this.winnerId,
    this.wagerAmount = 0,
    this.activities = const {},
  });

  /// Get the opponent's ID for a given user
  String getOpponentId(String userId) {
    return userId == userId1 ? userId2 : userId1;
  }

  /// Get the opponent's name for a given user
  String getOpponentName(String userId) {
    return userId == userId1 ? user2Name : user1Name;
  }

  /// Get user's points
  int getUserPoints(String userId) {
    return userId == userId1 ? user1Points : user2Points;
  }

  /// Get opponent's points
  int getOpponentPoints(String userId) {
    return userId == userId1 ? user2Points : user1Points;
  }

  /// Check if user is winning
  bool isUserWinning(String userId) {
    return getUserPoints(userId) > getOpponentPoints(userId);
  }

  /// Get point difference
  int getPointDifference(String userId) {
    return getUserPoints(userId) - getOpponentPoints(userId);
  }

  /// Get remaining time
  Duration get remainingTime {
    if (!isActive) return Duration.zero;
    return endDate.difference(DateTime.now());
  }

  /// Get formatted remaining time
  String get remainingTimeFormatted {
    final duration = remainingTime;
    if (duration.isNegative) return 'Ended';
    
    if (duration.inDays > 0) {
      return '${duration.inDays} days';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours';
    } else {
      return '${duration.inMinutes} minutes';
    }
  }
}

/// Service for managing challenges and rival sessions (mock implementation)
class ChallengeService {
  static final List<Challenge> _challenges = [];
  static final List<RivalSession> _rivalSessions = [];

  /// Get all challenges
  static List<Challenge> getAllChallenges() {
    return List.from(_challenges);
  }

  /// Get active challenges
  static List<Challenge> getActiveChallenges() {
    return _challenges.where((c) => c.status == ChallengeStatus.active).toList();
  }

  /// Get user's challenges
  static List<Challenge> getUserChallenges(String userId) {
    return _challenges.where((c) => c.participantIds.contains(userId)).toList();
  }

  /// Create a new challenge
  static void createChallenge(Challenge challenge) {
    _challenges.add(challenge);
  }

  /// Join a challenge
  static void joinChallenge(String challengeId, String userId) {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      _challenges[index].participantIds.add(userId);
      _challenges[index].leaderboard[userId] = 0;
    }
  }

  /// Get active rival session for user
  static RivalSession? getActiveRivalSession(String userId) {
    try {
      return _rivalSessions.firstWhere(
        (r) => r.isActive && (r.userId1 == userId || r.userId2 == userId),
      );
    } catch (e) {
      return null;
    }
  }

  /// Create rival session
  static void createRivalSession(RivalSession session) {
    _rivalSessions.add(session);
  }

  /// Add mock data
  static void addMockData() {
    // Add some mock challenges
    _challenges.addAll([
      Challenge(
        id: '1',
        name: 'Summer Shred Challenge',
        description: 'Get ready for summer with this intense 30-day challenge!',
        type: ChallengeType.public,
        status: ChallengeStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        creatorId: 'system',
        creatorName: 'RivalX Team',
        participantIds: ['user1', 'user2', 'user3', 'user4', 'user5'],
        leaderboard: {
          'user1': 2500,
          'user2': 2350,
          'user3': 2100,
          'user4': 1950,
          'user5': 1800,
        },
        rules: [
          'Log at least 4 workouts per week',
          'Each workout must be minimum 30 minutes',
          'All activities count towards points',
        ],
        maxParticipants: 500,
        prizePool: 10000,
      ),
      Challenge(
        id: '2',
        name: 'Daily Push-Up Challenge',
        description: 'Complete 100 push-ups today!',
        type: ChallengeType.daily,
        status: ChallengeStatus.active,
        startDate: DateTime.now().subtract(const Duration(hours: 8)),
        endDate: DateTime.now().add(const Duration(hours: 16)),
        creatorId: 'system',
        creatorName: 'RivalX Team',
        participantIds: ['user1', 'user2', 'user3'],
        leaderboard: {
          'user1': 75,
          'user2': 100,
          'user3': 50,
        },
        rules: [
          'Complete 100 push-ups in 24 hours',
          'Can be done in multiple sets',
          'Form must be proper',
        ],
      ),
    ]);

    // Add mock rival session
    _rivalSessions.add(
      RivalSession(
        id: '1',
        userId1: '123', // Current user
        userId2: 'rival123',
        user1Name: 'John Doe',
        user2Name: 'Mike Johnson',
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        user1Points: 850,
        user2Points: 720,
        isActive: true,
        wagerAmount: 100,
        activities: {
          '123': ['Chest workout - 45 min', 'Morning run - 5km'],
          'rival123': ['Leg day - 60 min', 'HIIT session - 30 min'],
        },
      ),
    );
  }
}

/// Represents a friend/user for rival challenges
class Friend {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final RankLevel currentRank;
  final int totalPoints;
  final int weeklyPoints;
  final FitnessLevel? fitnessLevel;
  final bool isOnline;
  final DateTime lastActive;
  final int wins;
  final int losses;
  final int currentStreak;

  Friend({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.currentRank,
    required this.totalPoints,
    required this.weeklyPoints,
    this.fitnessLevel,
    required this.isOnline,
    required this.lastActive,
    this.wins = 0,
    this.losses = 0,
    this.currentStreak = 0,
  });

  /// Get user's initials for avatar display
  String get initials {
    final names = displayName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
  }

  /// Get skill level based on total points
  String get skillLevel {
    if (totalPoints >= 30000) return 'Expert';
    if (totalPoints >= 15000) return 'Advanced';
    if (totalPoints >= 7000) return 'Intermediate';
    if (totalPoints >= 1000) return 'Beginner';
    return 'Newcomer';
  }

  /// Get win rate percentage
  double get winRate {
    final totalGames = wins + losses;
    if (totalGames == 0) return 0.0;
    return (wins / totalGames) * 100;
  }

  /// Get last active time formatted
  String get lastActiveFormatted {
    final now = DateTime.now();
    final difference = now.difference(lastActive);
    
    if (difference.inMinutes < 5) return 'Active now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }
}

/// Status of a challenge invitation
enum InvitationStatus {
  pending,
  accepted,
  declined,
  expired,
}

/// Types of rival challenges
enum RivalChallengeType {
  general,      // Overall fitness points
  strength,     // Weight lifting focused
  cardio,       // Cardio/endurance focused
  custom,       // User-defined activities
}

/// Represents a challenge invitation between rivals
class ChallengeInvitation {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final RivalChallengeType challengeType;
  final int duration; // Duration in days
  final int wagerAmount; // Points wagered
  final String? personalMessage;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? expiresAt;

  ChallengeInvitation({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.challengeType,
    required this.duration,
    this.wagerAmount = 0,
    this.personalMessage,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.expiresAt,
  });

  /// Check if invitation has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get time remaining for invitation
  Duration get timeRemaining {
    if (expiresAt == null) return Duration.zero;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get formatted time remaining
  String get timeRemainingFormatted {
    final duration = timeRemaining;
    if (duration.isNegative || duration == Duration.zero) return 'Expired';
    
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  /// Get challenge type display name
  String get challengeTypeDisplayName {
    switch (challengeType) {
      case RivalChallengeType.general:
        return 'General Fitness';
      case RivalChallengeType.strength:
        return 'Strength Training';
      case RivalChallengeType.cardio:
        return 'Cardio & Endurance';
      case RivalChallengeType.custom:
        return 'Custom Challenge';
    }
  }

  /// Get challenge type icon
  IconData get challengeTypeIcon {
    switch (challengeType) {
      case RivalChallengeType.general:
        return Icons.fitness_center;
      case RivalChallengeType.strength:
        return Icons.sports_gymnastics;
      case RivalChallengeType.cardio:
        return Icons.directions_run;
      case RivalChallengeType.custom:
        return Icons.star;
    }
  }

  /// Get duration formatted string
  String get durationFormatted {
    if (duration == 1) return '1 day';
    if (duration < 7) return '$duration days';
    if (duration == 7) return '1 week';
    if (duration == 14) return '2 weeks';
    return '$duration days';
  }
}

/// Represents a daily challenge
class DailyChallenge {
  final String id;
  final String name;
  final String description;
  final String instruction;
  final ChallengeType type;
  final DateTime date;
  final int targetValue; // e.g., 50 squats, 300 seconds plank
  final String unit; // e.g., "reps", "seconds", "minutes"
  final String icon;
  final int basePoints;
  final bool isCompleted;
  final int? completedValue;
  final DateTime? completedAt;

  DailyChallenge({
    required this.id,
    required this.name,
    required this.description,
    required this.instruction,
    this.type = ChallengeType.daily,
    required this.date,
    required this.targetValue,
    required this.unit,
    required this.icon,
    this.basePoints = 100,
    this.isCompleted = false,
    this.completedValue,
    this.completedAt,
  });

  /// Get remaining time for today's challenge
  Duration get remainingTime {
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return endOfDay.difference(DateTime.now());
  }

  /// Get formatted remaining time
  String get remainingTimeFormatted {
    final duration = remainingTime;
    if (duration.isNegative) return 'Expired';
    
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m left today';
    } else {
      return '${duration.inMinutes}m left today';
    }
  }

  /// Check if challenge is still active today
  bool get isActive {
    final now = DateTime.now();
    final challengeDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    return challengeDate.isAtSameMomentAs(today) && !isCompleted;
  }

  /// Get completion percentage
  double get completionPercentage {
    if (!isCompleted || completedValue == null) return 0.0;
    return (completedValue! / targetValue * 100).clamp(0.0, 100.0);
  }

  /// Copy with new values
  DailyChallenge copyWith({
    String? id,
    String? name,
    String? description,
    String? instruction,
    ChallengeType? type,
    DateTime? date,
    int? targetValue,
    String? unit,
    String? icon,
    int? basePoints,
    bool? isCompleted,
    int? completedValue,
    DateTime? completedAt,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      instruction: instruction ?? this.instruction,
      type: type ?? this.type,
      date: date ?? this.date,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      icon: icon ?? this.icon,
      basePoints: basePoints ?? this.basePoints,
      isCompleted: isCompleted ?? this.isCompleted,
      completedValue: completedValue ?? this.completedValue,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Service for managing daily challenges
class DailyChallengeService {
  static final List<DailyChallenge> _challenges = [];
  static final List<DailyChallenge> _completedChallenges = [];

  /// Get today's daily challenge
  static DailyChallenge? getTodaysChallenge() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    try {
      return _challenges.firstWhere(
        (challenge) {
          final challengeDate = DateTime(
            challenge.date.year,
            challenge.date.month,
            challenge.date.day,
          );
          return challengeDate.isAtSameMomentAs(todayDate);
        },
      );
    } catch (e) {
      // Generate today's challenge if not found
      return _generateTodaysChallenge();
    }
  }

  /// Complete today's challenge
  static DailyChallenge? completeChallenge(String challengeId, int completedValue) {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      final challenge = _challenges[index];
      final completedChallenge = challenge.copyWith(
        isCompleted: true,
        completedValue: completedValue,
        completedAt: DateTime.now(),
      );
      
      _challenges[index] = completedChallenge;
      _completedChallenges.add(completedChallenge);
      
      return completedChallenge;
    }
    return null;
  }

  /// Get challenge history for the last 7 days
  static List<DailyChallenge> getChallengeHistory() {
    return _completedChallenges
        .where((c) => c.completedAt != null && 
               c.completedAt!.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
  }

  /// Get current streak count
  static int getCurrentStreak() {
    final completed = _completedChallenges
        .where((c) => c.completedAt != null)
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    if (completed.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();
    
    for (final challenge in completed) {
      final daysDifference = now.difference(challenge.completedAt!).inDays;
      
      if (daysDifference == streak) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  /// Generate today's challenge based on day of week and algorithms
  static DailyChallenge _generateTodaysChallenge() {
    final today = DateTime.now();
    final dayOfWeek = today.weekday;
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    
    // Predefined challenges that rotate
    final challenges = [
      {
        'name': 'Push-Up Power',
        'description': 'Complete push-ups to build upper body strength',
        'instruction': 'Do as many push-ups as you can with proper form. You can break into multiple sets.',
        'target': 50,
        'unit': 'reps',
        'icon': '💪',
      },
      {
        'name': 'Plank Hold Challenge',
        'description': 'Hold a plank position to strengthen your core',
        'instruction': 'Hold a plank position for the target time. You can break into multiple holds.',
        'target': 300, // 5 minutes
        'unit': 'seconds',
        'icon': '🏋️',
      },
      {
        'name': 'Squat Challenge',
        'description': 'Perform squats to strengthen your legs and glutes',
        'instruction': 'Complete squats with proper form. Go down until thighs are parallel to floor.',
        'target': 75,
        'unit': 'reps',
        'icon': '🦵',
      },
      {
        'name': 'Jumping Jacks',
        'description': 'Get your heart rate up with jumping jacks',
        'instruction': 'Perform jumping jacks at a steady pace. Focus on landing softly.',
        'target': 100,
        'unit': 'reps',
        'icon': '🏃',
      },
      {
        'name': 'Burpee Blast',
        'description': 'Full-body exercise combining squat, plank, and jump',
        'instruction': 'Complete burpees with proper form: squat, plank, push-up, jump up.',
        'target': 20,
        'unit': 'reps',
        'icon': '🔥',
      },
      {
        'name': 'Wall Sit Challenge',
        'description': 'Build leg endurance with wall sits',
        'instruction': 'Sit against the wall with thighs parallel to floor. Hold the position.',
        'target': 180, // 3 minutes
        'unit': 'seconds',
        'icon': '🧱',
      },
      {
        'name': 'Mountain Climbers',
        'description': 'Cardio and core exercise in plank position',
        'instruction': 'Start in plank position and alternate bringing knees to chest quickly.',
        'target': 60,
        'unit': 'reps',
        'icon': '⛰️',
      },
    ];

    // Select challenge based on day of year to ensure variety
    final challengeData = challenges[dayOfYear % challenges.length];
    
    final challenge = DailyChallenge(
      id: 'daily_${today.year}_${today.month}_${today.day}',
      name: challengeData['name'] as String,
      description: challengeData['description'] as String,
      instruction: challengeData['instruction'] as String,
      date: today,
      targetValue: challengeData['target'] as int,
      unit: challengeData['unit'] as String,
      icon: challengeData['icon'] as String,
    );

    _challenges.add(challenge);
    return challenge;
  }

  /// Clear all data (for testing)
  static void clearData() {
    _challenges.clear();
    _completedChallenges.clear();
  }
}

/// Service for managing friends and challenge invitations (mock implementation)
class FriendService {
  static final List<Friend> _friends = [];
  static final List<ChallengeInvitation> _invitations = [];

  /// Get all friends for a user
  static List<Friend> getAllFriends(String userId) {
    return List.from(_friends);
  }

  /// Search friends by username or email
  static List<Friend> searchFriends(String query) {
    if (query.isEmpty) return getAllFriends('current_user');
    
    return _friends.where((friend) =>
      friend.username.toLowerCase().contains(query.toLowerCase()) ||
      friend.displayName.toLowerCase().contains(query.toLowerCase()) ||
      friend.email.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Get friend suggestions based on skill level and activity
  static List<Friend> getSuggestedFriends(String userId) {
    // Mock logic: return friends with similar skill levels
    return _friends.where((friend) => 
      friend.totalPoints >= 1000 && friend.totalPoints <= 10000
    ).take(5).toList();
  }

  /// Get recent rivals (friends you've competed with)
  static List<Friend> getRecentRivals(String userId) {
    // Mock logic: return friends with recent activity
    return _friends.where((friend) => 
      friend.lastActive.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).take(3).toList();
  }

  /// Send challenge invitation
  static void sendChallengeInvitation(ChallengeInvitation invitation) {
    _invitations.add(invitation);
  }

  /// Get pending invitations sent by user
  static List<ChallengeInvitation> getSentInvitations(String userId) {
    return _invitations.where((inv) => 
      inv.senderId == userId && inv.status == InvitationStatus.pending
    ).toList();
  }

  /// Get pending invitations received by user
  static List<ChallengeInvitation> getReceivedInvitations(String userId) {
    return _invitations.where((inv) => 
      inv.receiverId == userId && inv.status == InvitationStatus.pending
    ).toList();
  }

  /// Accept challenge invitation
  static void acceptInvitation(String invitationId) {
    final index = _invitations.indexWhere((inv) => inv.id == invitationId);
    if (index != -1) {
      final invitation = _invitations[index];
      _invitations[index] = ChallengeInvitation(
        id: invitation.id,
        senderId: invitation.senderId,
        senderName: invitation.senderName,
        receiverId: invitation.receiverId,
        receiverName: invitation.receiverName,
        challengeType: invitation.challengeType,
        duration: invitation.duration,
        wagerAmount: invitation.wagerAmount,
        personalMessage: invitation.personalMessage,
        status: InvitationStatus.accepted,
        createdAt: invitation.createdAt,
        respondedAt: DateTime.now(),
        expiresAt: invitation.expiresAt,
      );

      // Create rival session
      final rivalSession = RivalSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId1: invitation.senderId,
        userId2: invitation.receiverId,
        user1Name: invitation.senderName,
        user2Name: invitation.receiverName,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: invitation.duration)),
        isActive: true,
        wagerAmount: invitation.wagerAmount,
      );
      
      ChallengeService.createRivalSession(rivalSession);
    }
  }

  /// Decline challenge invitation
  static void declineInvitation(String invitationId) {
    final index = _invitations.indexWhere((inv) => inv.id == invitationId);
    if (index != -1) {
      final invitation = _invitations[index];
      _invitations[index] = ChallengeInvitation(
        id: invitation.id,
        senderId: invitation.senderId,
        senderName: invitation.senderName,
        receiverId: invitation.receiverId,
        receiverName: invitation.receiverName,
        challengeType: invitation.challengeType,
        duration: invitation.duration,
        wagerAmount: invitation.wagerAmount,
        personalMessage: invitation.personalMessage,
        status: InvitationStatus.declined,
        createdAt: invitation.createdAt,
        respondedAt: DateTime.now(),
        expiresAt: invitation.expiresAt,
      );
    }
  }

  /// Add mock data
  static void addMockData() {
    if (_friends.isEmpty) {
      _friends.addAll([
        Friend(
          id: 'friend1',
          username: 'fitnessguru22',
          displayName: 'Sarah Johnson',
          email: 'sarah@example.com',
          currentRank: RankLevel.B,
          totalPoints: 12500,
          weeklyPoints: 450,
          fitnessLevel: FitnessLevel.advanced,
          isOnline: true,
          lastActive: DateTime.now().subtract(const Duration(minutes: 15)),
          wins: 8,
          losses: 3,
          currentStreak: 2,
        ),
        Friend(
          id: 'friend2',
          username: 'cardioking',
          displayName: 'Mike Chen',
          email: 'mike@example.com',
          currentRank: RankLevel.A,
          totalPoints: 18200,
          weeklyPoints: 380,
          fitnessLevel: FitnessLevel.advanced,
          isOnline: false,
          lastActive: DateTime.now().subtract(const Duration(hours: 2)),
          wins: 12,
          losses: 5,
          currentStreak: 4,
        ),
        Friend(
          id: 'friend3',
          username: 'strengthstar',
          displayName: 'Alex Rodriguez',
          email: 'alex@example.com',
          currentRank: RankLevel.C,
          totalPoints: 5800,
          weeklyPoints: 290,
          fitnessLevel: FitnessLevel.intermediate,
          isOnline: true,
          lastActive: DateTime.now().subtract(const Duration(minutes: 45)),
          wins: 4,
          losses: 6,
          currentStreak: 1,
        ),
        Friend(
          id: 'friend4',
          username: 'yogamaster',
          displayName: 'Emma Wilson',
          email: 'emma@example.com',
          currentRank: RankLevel.D,
          totalPoints: 2100,
          weeklyPoints: 180,
          fitnessLevel: FitnessLevel.beginner,
          isOnline: false,
          lastActive: DateTime.now().subtract(const Duration(days: 1)),
          wins: 2,
          losses: 3,
          currentStreak: 0,
        ),
        Friend(
          id: 'friend5',
          username: 'ironlifter',
          displayName: 'David Park',
          email: 'david@example.com',
          currentRank: RankLevel.S,
          totalPoints: 45000,
          weeklyPoints: 620,
          fitnessLevel: FitnessLevel.advanced,
          isOnline: true,
          lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
          wins: 23,
          losses: 7,
          currentStreak: 8,
        ),
        Friend(
          id: 'friend6',
          username: 'runnerchic',
          displayName: 'Lisa Thompson',
          email: 'lisa@example.com',
          currentRank: RankLevel.C,
          totalPoints: 6200,
          weeklyPoints: 340,
          fitnessLevel: FitnessLevel.intermediate,
          isOnline: false,
          lastActive: DateTime.now().subtract(const Duration(hours: 5)),
          wins: 6,
          losses: 4,
          currentStreak: 2,
        ),
      ]);
    }

    // Add mock invitations
    if (_invitations.isEmpty) {
      _invitations.addAll([
        ChallengeInvitation(
          id: 'inv1',
          senderId: '123', // Current user
          senderName: 'John Doe',
          receiverId: 'friend1',
          receiverName: 'Sarah Johnson',
          challengeType: RivalChallengeType.general,
          duration: 7,
          wagerAmount: 200,
          personalMessage: 'Ready for a week-long battle? Let\'s see who can rack up more points!',
          status: InvitationStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          expiresAt: DateTime.now().add(const Duration(days: 1)),
        ),
        ChallengeInvitation(
          id: 'inv2',
          senderId: 'friend2',
          senderName: 'Mike Chen',
          receiverId: '123', // Current user
          receiverName: 'John Doe',
          challengeType: RivalChallengeType.cardio,
          duration: 3,
          wagerAmount: 150,
          personalMessage: 'I challenge you to a cardio showdown! 3 days of pure endurance - are you up for it?',
          status: InvitationStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          expiresAt: DateTime.now().add(const Duration(hours: 18)),
        ),
      ]);
    }
  }
}