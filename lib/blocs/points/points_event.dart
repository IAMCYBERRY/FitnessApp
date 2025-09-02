/// Points BLoC events for managing points and rank progression.
/// 
/// These events trigger various point-related operations including
/// workout completion, challenge victories, and bonus calculations.

import 'package:equatable/equatable.dart';
import '../../services/points_service.dart';
import '../../models/user_model_clean.dart';

/// Base class for all points-related events
abstract class PointsEvent extends Equatable {
  const PointsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize points tracking for a user
/// 
/// Fired when user logs in or app starts to load current points state
class PointsInitialize extends PointsEvent {
  /// User ID to initialize points for
  final String userId;

  const PointsInitialize({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event fired when a workout is completed
/// 
/// Calculates and awards points based on workout details and applies
/// any applicable bonuses (streak, rank multiplier, personal records)
class WorkoutCompleted extends PointsEvent {
  /// The completed workout data
  final CompletedWorkout workout;
  
  /// User statistics for bonus calculations
  final UserStats userStats;

  const WorkoutCompleted({
    required this.workout,
    required this.userStats,
  });

  @override
  List<Object?> get props => [workout, userStats];
}

/// Event fired when a challenge is completed
/// 
/// Awards base challenge completion points plus any performance bonuses
class ChallengeCompleted extends PointsEvent {
  /// Challenge ID that was completed
  final String challengeId;
  
  /// Type of challenge (public/private)
  final String challengeType;
  
  /// User's placement in the challenge
  final int placement;
  
  /// Total participants in the challenge
  final int totalParticipants;
  
  /// Base points for challenge completion
  final int basePoints;

  const ChallengeCompleted({
    required this.challengeId,
    required this.challengeType,
    required this.placement,
    required this.totalParticipants,
    this.basePoints = 250,
  });

  @override
  List<Object?> get props => [
    challengeId,
    challengeType,
    placement,
    totalParticipants,
    basePoints,
  ];
}

/// Event fired when daily challenge is completed
/// 
/// Awards standard daily challenge points (100 base)
class DailyChallengeCompleted extends PointsEvent {
  /// The daily challenge ID
  final String challengeId;
  
  /// Description of the challenge
  final String challengeDescription;
  
  /// Time taken to complete (optional)
  final Duration? completionTime;

  const DailyChallengeCompleted({
    required this.challengeId,
    required this.challengeDescription,
    this.completionTime,
  });

  @override
  List<Object?> get props => [challengeId, challengeDescription, completionTime];
}

/// Event fired when user wins rival mode competition
/// 
/// Awards 10% of rival's weekly points as bonus
class RivalModeVictory extends PointsEvent {
  /// ID of the defeated rival
  final String rivalId;
  
  /// Rival's username for display
  final String rivalUsername;
  
  /// Rival's weekly points (10% awarded as bonus)
  final int rivalWeeklyPoints;
  
  /// User's weekly points for comparison
  final int userWeeklyPoints;

  const RivalModeVictory({
    required this.rivalId,
    required this.rivalUsername,
    required this.rivalWeeklyPoints,
    required this.userWeeklyPoints,
  });

  @override
  List<Object?> get props => [
    rivalId,
    rivalUsername,
    rivalWeeklyPoints,
    userWeeklyPoints,
  ];
}

/// Event fired when streak bonus is earned
/// 
/// Triggered at specific streak milestones (3, 7, 14 days)
class StreakBonusEarned extends PointsEvent {
  /// Current streak count
  final int streakDays;
  
  /// Bonus multiplier earned
  final double bonusMultiplier;
  
  /// Points eligible for bonus
  final int basePoints;

  const StreakBonusEarned({
    required this.streakDays,
    required this.bonusMultiplier,
    required this.basePoints,
  });

  @override
  List<Object?> get props => [streakDays, bonusMultiplier, basePoints];
}

/// Event to reset weekly points
/// 
/// Fired at the start of each week (Sunday midnight)
class WeeklyPointsReset extends PointsEvent {
  /// Previous week's points for history
  final int previousWeekPoints;
  
  /// Week ending date
  final DateTime weekEndDate;

  const WeeklyPointsReset({
    required this.previousWeekPoints,
    required this.weekEndDate,
  });

  @override
  List<Object?> get props => [previousWeekPoints, weekEndDate];
}

/// Event to manually adjust points (admin/penalty)
/// 
/// Used for penalties or manual point adjustments
class PointsAdjustment extends PointsEvent {
  /// Points to add (positive) or subtract (negative)
  final int pointsChange;
  
  /// Reason for adjustment
  final String reason;
  
  /// Whether this is a penalty
  final bool isPenalty;

  const PointsAdjustment({
    required this.pointsChange,
    required this.reason,
    required this.isPenalty,
  });

  @override
  List<Object?> get props => [pointsChange, reason, isPenalty];
}

/// Event to refresh points from database
/// 
/// Used to sync local state with backend
class RefreshPoints extends PointsEvent {
  const RefreshPoints();
}

/// Event fired when rank changes
/// 
/// Internal event triggered when points cross rank thresholds
class RankChanged extends PointsEvent {
  /// Previous rank level
  final RankLevel previousRank;
  
  /// New rank level
  final RankLevel newRank;
  
  /// Total points at time of rank change
  final int totalPoints;

  const RankChanged({
    required this.previousRank,
    required this.newRank,
    required this.totalPoints,
  });

  @override
  List<Object?> get props => [previousRank, newRank, totalPoints];
}