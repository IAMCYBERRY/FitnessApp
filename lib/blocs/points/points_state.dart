/// Points BLoC states for managing user points and rank progression.
/// 
/// These states represent different stages of points tracking including
/// loading, success, error states, and detailed point information.

import 'package:equatable/equatable.dart';
import '../../models/user_model_clean.dart';
import '../../services/points_service.dart';

/// Base class for all points-related states
abstract class PointsState extends Equatable {
  const PointsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before points are loaded
class PointsInitial extends PointsState {
  const PointsInitial();
}

/// State while points are being loaded or calculated
class PointsLoading extends PointsState {
  /// Optional message to show during loading
  final String? message;

  const PointsLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Main state containing current points information
class PointsLoaded extends PointsState {
  /// Current total points
  final int totalPoints;
  
  /// Points earned this week
  final int weeklyPoints;
  
  /// Current rank based on total points
  final RankLevel currentRank;
  
  /// Points needed to reach next rank
  final int pointsToNextRank;
  
  /// Percentage progress to next rank (0-100)
  final double rankProgress;
  
  /// Current workout streak
  final int currentStreak;
  
  /// Active bonuses and multipliers
  final ActiveBonuses activeBonuses;
  
  /// Recent point history (last 10 entries)
  final List<PointHistoryEntry> recentHistory;
  
  /// Last update timestamp
  final DateTime lastUpdated;

  const PointsLoaded({
    required this.totalPoints,
    required this.weeklyPoints,
    required this.currentRank,
    required this.pointsToNextRank,
    required this.rankProgress,
    required this.currentStreak,
    required this.activeBonuses,
    required this.recentHistory,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    totalPoints,
    weeklyPoints,
    currentRank,
    pointsToNextRank,
    rankProgress,
    currentStreak,
    activeBonuses,
    recentHistory,
    lastUpdated,
  ];

  /// Creates a copy with updated values
  PointsLoaded copyWith({
    int? totalPoints,
    int? weeklyPoints,
    RankLevel? currentRank,
    int? pointsToNextRank,
    double? rankProgress,
    int? currentStreak,
    ActiveBonuses? activeBonuses,
    List<PointHistoryEntry>? recentHistory,
    DateTime? lastUpdated,
  }) {
    return PointsLoaded(
      totalPoints: totalPoints ?? this.totalPoints,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
      currentRank: currentRank ?? this.currentRank,
      pointsToNextRank: pointsToNextRank ?? this.pointsToNextRank,
      rankProgress: rankProgress ?? this.rankProgress,
      currentStreak: currentStreak ?? this.currentStreak,
      activeBonuses: activeBonuses ?? this.activeBonuses,
      recentHistory: recentHistory ?? this.recentHistory,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// State when points are being awarded with animation data
class PointsAwarding extends PointsLoaded {
  /// Points being awarded in this transaction
  final int pointsAwarded;
  
  /// Breakdown of points for display
  final PointsBreakdown breakdown;
  
  /// Type of activity that earned points
  final String activityType;
  
  /// Whether this triggers a rank up
  final bool isRankUp;
  
  /// New rank if rank up occurred
  final RankLevel? newRank;

  const PointsAwarding({
    required this.pointsAwarded,
    required this.breakdown,
    required this.activityType,
    required this.isRankUp,
    this.newRank,
    required super.totalPoints,
    required super.weeklyPoints,
    required super.currentRank,
    required super.pointsToNextRank,
    required super.rankProgress,
    required super.currentStreak,
    required super.activeBonuses,
    required super.recentHistory,
    required super.lastUpdated,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    pointsAwarded,
    breakdown,
    activityType,
    isRankUp,
    newRank,
  ];
}

/// Error state for points operations
class PointsError extends PointsState {
  /// Error message
  final String message;
  
  /// Previous state before error (for recovery)
  final PointsState? previousState;
  
  /// Whether error is recoverable
  final bool isRecoverable;

  const PointsError({
    required this.message,
    this.previousState,
    this.isRecoverable = true,
  });

  @override
  List<Object?> get props => [message, previousState, isRecoverable];
}

/// State for rank change celebration
class RankUpAchieved extends PointsLoaded {
  /// Previous rank before promotion
  final RankLevel previousRank;
  
  /// Bonus points for rank up (if any)
  final int rankUpBonus;

  const RankUpAchieved({
    required this.previousRank,
    required this.rankUpBonus,
    required super.totalPoints,
    required super.weeklyPoints,
    required super.currentRank,
    required super.pointsToNextRank,
    required super.rankProgress,
    required super.currentStreak,
    required super.activeBonuses,
    required super.recentHistory,
    required super.lastUpdated,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    previousRank,
    rankUpBonus,
  ];
}

/// Active bonuses and multipliers
class ActiveBonuses extends Equatable {
  /// Current streak bonus percentage (0-10)
  final double streakBonus;
  
  /// Rank multiplier based on current rank
  final double rankMultiplier;
  
  /// Whether user has active rival for bonus
  final bool hasActiveRival;
  
  /// List of other active bonuses
  final List<BonusInfo> otherBonuses;

  const ActiveBonuses({
    required this.streakBonus,
    required this.rankMultiplier,
    required this.hasActiveRival,
    required this.otherBonuses,
  });

  @override
  List<Object?> get props => [
    streakBonus,
    rankMultiplier,
    hasActiveRival,
    otherBonuses,
  ];

  /// Total multiplier from all bonuses
  double get totalMultiplier {
    double total = 1.0 + (streakBonus / 100);
    total *= rankMultiplier;
    for (final bonus in otherBonuses) {
      total *= bonus.multiplier;
    }
    return total;
  }
}

/// Information about a specific bonus
class BonusInfo extends Equatable {
  /// Bonus name
  final String name;
  
  /// Bonus description
  final String description;
  
  /// Multiplier value
  final double multiplier;
  
  /// Expiration date (if applicable)
  final DateTime? expiresAt;

  const BonusInfo({
    required this.name,
    required this.description,
    required this.multiplier,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [name, description, multiplier, expiresAt];
}

/// Entry in point history
class PointHistoryEntry extends Equatable {
  /// Unique ID for the entry
  final String id;
  
  /// Points earned/lost
  final int points;
  
  /// Activity that generated points
  final String activity;
  
  /// Detailed description
  final String description;
  
  /// When points were earned
  final DateTime timestamp;
  
  /// Icon or emoji for display
  final String icon;
  
  /// Whether this was a bonus
  final bool isBonus;

  const PointHistoryEntry({
    required this.id,
    required this.points,
    required this.activity,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.isBonus,
  });

  @override
  List<Object?> get props => [
    id,
    points,
    activity,
    description,
    timestamp,
    icon,
    isBonus,
  ];
}