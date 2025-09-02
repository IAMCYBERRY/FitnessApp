/// Points calculation service for RivalX fitness app.
/// 
/// This service handles all point calculations, bonuses, rank progression,
/// and validation for the competitive fitness tracking system. It implements
/// the weighted scoring system based on activity importance and user rank.

import 'dart:math';
import '../models/user_model_clean.dart';
import '../models/workout_routine.dart';
import '../models/muscle_group.dart';

/// Enumeration for different workout types
enum WorkoutType {
  strength,
  cardio,
  bodyweight,
  duration,
  challenge,
  dailyChallenge,
}

/// Enumeration for workout intensity levels
enum WorkoutIntensity {
  low,
  moderate,
  high,
  extreme,
}

/// Data class representing a completed workout for point calculation
class CompletedWorkout {
  final String id;
  final WorkoutType type;
  final DateTime completedAt;
  final Duration duration;
  final List<CompletedExercise> exercises;
  final WorkoutIntensity intensity;
  final bool isPersonalRecord;
  final String? challengeId;
  final double? totalDistance; // in kilometers
  final double? totalWeight; // in kilograms
  final Map<String, dynamic>? additionalData;

  CompletedWorkout({
    required this.id,
    required this.type,
    required this.completedAt,
    required this.duration,
    required this.exercises,
    this.intensity = WorkoutIntensity.moderate,
    this.isPersonalRecord = false,
    this.challengeId,
    this.totalDistance,
    this.totalWeight,
    this.additionalData,
  });
}

/// Data class representing a completed exercise within a workout
class CompletedExercise {
  final String name;
  final MuscleGroup muscleGroup;
  final List<CompletedSet> sets;
  final double? distance; // in kilometers
  final Duration? duration;
  final int? reps; // for bodyweight exercises
  final bool isPersonalRecord;

  CompletedExercise({
    required this.name,
    required this.muscleGroup,
    required this.sets,
    this.distance,
    this.duration,
    this.reps,
    this.isPersonalRecord = false,
  });
}

/// Data class representing a completed set within an exercise
class CompletedSet {
  final double? weight; // in kilograms
  final int? reps;
  final int? rpe; // Rate of Perceived Exertion (1-10)
  final Duration? duration;
  final bool isPersonalRecord;

  CompletedSet({
    this.weight,
    this.reps,
    this.rpe,
    this.duration,
    this.isPersonalRecord = false,
  });
}

/// Data class representing user statistics for bonus calculations
class UserStats {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastWorkoutDate;
  final List<DateTime> workoutDates;
  final RankLevel currentRank;
  final int weeklyWorkouts;
  final double weeklyVolume;
  final bool hasActiveRival;
  final Map<String, int> personalRecords;

  UserStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastWorkoutDate,
    required this.workoutDates,
    required this.currentRank,
    required this.weeklyWorkouts,
    required this.weeklyVolume,
    required this.hasActiveRival,
    required this.personalRecords,
  });
}

/// Data class representing detailed points breakdown
class PointsBreakdown {
  final int basePoints;
  final int bonusPoints;
  final int totalPoints;
  final double streakMultiplier;
  final double rankMultiplier;
  final double prMultiplier;
  final Map<String, int> exercisePoints;
  final Map<String, int> bonusBreakdown;
  final String description;

  PointsBreakdown({
    required this.basePoints,
    required this.bonusPoints,
    required this.totalPoints,
    required this.streakMultiplier,
    required this.rankMultiplier,
    required this.prMultiplier,
    required this.exercisePoints,
    required this.bonusBreakdown,
    required this.description,
  });
}

/// Data class for points summary over a period
class PointsSummary {
  final int totalPoints;
  final int workoutCount;
  final Map<WorkoutType, int> pointsByType;
  final Map<String, int> dailyPoints;
  final int streakDays;
  final int personalRecords;
  final int challengesCompleted;
  final double averagePointsPerWorkout;

  PointsSummary({
    required this.totalPoints,
    required this.workoutCount,
    required this.pointsByType,
    required this.dailyPoints,
    required this.streakDays,
    required this.personalRecords,
    required this.challengesCompleted,
    required this.averagePointsPerWorkout,
  });
}

/// Comprehensive points calculation service for RivalX
class PointsService {
  // Base point values for different activities
  static const int _baseStrengthPointsPerSet = 10;
  static const int _baseCardioPointsPerKm = 50;
  static const int _baseBodyweightPointsPerRep = 1;
  static const int _baseDurationPointsPerMinute = 5;
  static const int _dailyChallengeBasePoints = 100;
  static const int _challengeCompletionBonus = 250;

  // Maximum points to prevent exploitation
  static const int _maxPointsPerWorkout = 2000;
  static const int _maxPointsPerExercise = 500;
  static const int _maxPointsPerDay = 5000;

  // Intensity multipliers
  static const Map<WorkoutIntensity, double> _intensityMultipliers = {
    WorkoutIntensity.low: 0.8,
    WorkoutIntensity.moderate: 1.0,
    WorkoutIntensity.high: 1.3,
    WorkoutIntensity.extreme: 1.6,
  };

  // Muscle group importance multipliers
  static const Map<MuscleGroup, double> _muscleGroupMultipliers = {
    MuscleGroup.chest: 1.2,
    MuscleGroup.shoulders: 1.1,
    MuscleGroup.quads: 1.2,
    MuscleGroup.hamstrings: 1.1,
    MuscleGroup.glutes: 1.1,
    MuscleGroup.biceps: 1.0,
    MuscleGroup.triceps: 1.0,
    MuscleGroup.abs: 1.1,
    MuscleGroup.calves: 0.9,
    MuscleGroup.forearms: 0.8,
    MuscleGroup.traps: 1.0,
  };

  // Rank multipliers for weighted scoring
  static const Map<RankLevel, double> _rankMultipliers = {
    RankLevel.E: 1.0,
    RankLevel.D: 1.1,
    RankLevel.C: 1.2,
    RankLevel.B: 1.3,
    RankLevel.A: 1.4,
    RankLevel.S: 1.5,
    RankLevel.SS: 1.6,
  };

  /// Calculates total points for a completed workout
  /// 
  /// @param workout CompletedWorkout instance
  /// @param userStats UserStats for bonus calculations
  /// @return Total points earned including bonuses
  static int calculateWorkoutPoints(
    CompletedWorkout workout,
    UserStats userStats,
  ) {
    final breakdown = calculatePointsWithBreakdown(workout, userStats);
    return breakdown.totalPoints;
  }

  /// Calculates points with detailed breakdown
  /// 
  /// @param workout CompletedWorkout instance
  /// @param userStats UserStats for bonus calculations
  /// @return PointsBreakdown with detailed information
  static PointsBreakdown calculatePointsWithBreakdown(
    CompletedWorkout workout,
    UserStats userStats,
  ) {
    int basePoints = 0;
    final Map<String, int> exercisePoints = {};
    final Map<String, int> bonusBreakdown = {};

    // Calculate base points based on workout type
    switch (workout.type) {
      case WorkoutType.strength:
        basePoints = _calculateStrengthPoints(workout, exercisePoints);
        break;
      case WorkoutType.cardio:
        basePoints = _calculateCardioPoints(workout, exercisePoints);
        break;
      case WorkoutType.bodyweight:
        basePoints = _calculateBodyweightPoints(workout, exercisePoints);
        break;
      case WorkoutType.duration:
        basePoints = _calculateDurationPoints(workout, exercisePoints);
        break;
      case WorkoutType.dailyChallenge:
        basePoints = _dailyChallengeBasePoints;
        exercisePoints['Daily Challenge'] = basePoints;
        break;
      case WorkoutType.challenge:
        basePoints = _challengeCompletionBonus;
        exercisePoints['Challenge Completion'] = basePoints;
        break;
    }

    // Apply intensity multiplier
    final intensityMultiplier = _intensityMultipliers[workout.intensity] ?? 1.0;
    basePoints = (basePoints * intensityMultiplier).round();

    // Apply rank multiplier for weighted scoring
    final rankMultiplier = _rankMultipliers[userStats.currentRank] ?? 1.0;
    basePoints = (basePoints * rankMultiplier).round();

    // Calculate bonuses
    final streakBonus = _calculateStreakBonus(userStats.currentStreak);
    final streakBonusPoints = (basePoints * streakBonus).round();
    if (streakBonusPoints > 0) {
      bonusBreakdown['Streak Bonus (${userStats.currentStreak} days)'] = streakBonusPoints;
    }

    final prBonus = workout.isPersonalRecord ? 0.2 : 0.0;
    final prBonusPoints = (basePoints * prBonus).round();
    if (prBonusPoints > 0) {
      bonusBreakdown['Personal Record Bonus'] = prBonusPoints;
    }

    // Apply workout validation and caps
    basePoints = min(basePoints, _maxPointsPerWorkout);
    final totalBonusPoints = streakBonusPoints + prBonusPoints;
    final totalPoints = basePoints + totalBonusPoints;

    return PointsBreakdown(
      basePoints: basePoints,
      bonusPoints: totalBonusPoints,
      totalPoints: min(totalPoints, _maxPointsPerDay),
      streakMultiplier: 1.0 + streakBonus,
      rankMultiplier: rankMultiplier,
      prMultiplier: 1.0 + prBonus,
      exercisePoints: exercisePoints,
      bonusBreakdown: bonusBreakdown,
      description: _generatePointsDescription(workout, userStats),
    );
  }

  /// Calculates streak bonus multiplier
  /// 
  /// @param consecutiveDays Number of consecutive workout days
  /// @return Bonus multiplier (0.0 to 0.10)
  static double calculateStreakBonus(int consecutiveDays) {
    if (consecutiveDays >= 14) return 0.10; // 14-day streak: +10%
    if (consecutiveDays >= 7) return 0.05;  // 7-day streak: +5%
    if (consecutiveDays >= 3) return 0.02;  // 3-day streak: +2%
    return 0.0;
  }

  /// Validates if point claim is reasonable
  /// 
  /// @param points Claimed points
  /// @param workout CompletedWorkout being validated
  /// @return true if points are valid, false otherwise
  static bool validatePointClaim(int points, CompletedWorkout workout) {
    // Check maximum limits
    if (points > _maxPointsPerWorkout) return false;
    if (points < 0) return false;

    // Check minimum workout duration
    if (workout.duration.inMinutes < 5) return false;

    // Validate workout type specific constraints
    switch (workout.type) {
      case WorkoutType.strength:
        if (workout.exercises.isEmpty) return false;
        // Check for reasonable set counts
        for (final exercise in workout.exercises) {
          if (exercise.sets.length > 20) return false; // Max 20 sets per exercise
          for (final set in exercise.sets) {
            if (set.weight != null && set.weight! > 500) return false; // Max 500kg
            if (set.reps != null && set.reps! > 100) return false; // Max 100 reps
          }
        }
        break;
      case WorkoutType.cardio:
        if (workout.totalDistance != null && workout.totalDistance! > 100) {
          return false; // Max 100km per workout
        }
        break;
      case WorkoutType.bodyweight:
        // Check for reasonable rep counts
        final totalReps = workout.exercises.fold(0, (sum, exercise) => 
            sum + (exercise.reps ?? 0));
        if (totalReps > 2000) return false; // Max 2000 total reps
        break;
      case WorkoutType.duration:
        if (workout.duration.inHours > 6) return false; // Max 6 hours
        break;
      default:
        break;
    }

    return true;
  }

  /// Updates user rank based on total points
  /// 
  /// @param totalPoints User's total accumulated points
  /// @return New RankLevel based on points
  static RankLevel updateUserRank(int totalPoints) {
    return UserModel.getRankFromPoints(totalPoints);
  }

  /// Calculates rival mode victory bonus
  /// 
  /// @param opponentWeeklyPoints Opponent's weekly points
  /// @return Bonus points (10% of opponent's points)
  static int calculateRivalVictoryBonus(int opponentWeeklyPoints) {
    return (opponentWeeklyPoints * 0.1).round();
  }

  /// Generates points summary for a given period
  /// 
  /// @param workouts List of completed workouts in period
  /// @param userStats User statistics
  /// @return PointsSummary with aggregate data
  static PointsSummary getPointsBreakdown(
    List<CompletedWorkout> workouts,
    UserStats userStats,
  ) {
    int totalPoints = 0;
    final Map<WorkoutType, int> pointsByType = {};
    final Map<String, int> dailyPoints = {};
    int personalRecords = 0;
    int challengesCompleted = 0;

    for (final workout in workouts) {
      final points = calculateWorkoutPoints(workout, userStats);
      totalPoints += points;

      // Track by type
      pointsByType[workout.type] = 
          (pointsByType[workout.type] ?? 0) + points;

      // Track daily
      final dateKey = workout.completedAt.toString().substring(0, 10);
      dailyPoints[dateKey] = (dailyPoints[dateKey] ?? 0) + points;

      // Count PRs and challenges
      if (workout.isPersonalRecord) personalRecords++;
      if (workout.type == WorkoutType.challenge || 
          workout.type == WorkoutType.dailyChallenge) {
        challengesCompleted++;
      }
    }

    return PointsSummary(
      totalPoints: totalPoints,
      workoutCount: workouts.length,
      pointsByType: pointsByType,
      dailyPoints: dailyPoints,
      streakDays: userStats.currentStreak,
      personalRecords: personalRecords,
      challengesCompleted: challengesCompleted,
      averagePointsPerWorkout: workouts.isEmpty ? 0 : totalPoints / workouts.length,
    );
  }

  // Private helper methods

  static int _calculateStrengthPoints(
    CompletedWorkout workout,
    Map<String, int> exercisePoints,
  ) {
    int totalPoints = 0;

    for (final exercise in workout.exercises) {
      int exerciseTotal = 0;
      
      for (final set in exercise.sets) {
        if (set.weight != null && set.reps != null) {
          int setPoints = (_baseStrengthPointsPerSet * 
              (set.weight! / 50) * // Weight factor (normalized to 50kg)
              (set.reps! / 10)).round(); // Rep factor (normalized to 10 reps)
          
          // Apply RPE bonus if available
          if (set.rpe != null && set.rpe! >= 8) {
            setPoints = (setPoints * 1.1).round(); // +10% for high RPE
          }
          
          exerciseTotal += setPoints;
        }
      }

      // Apply muscle group multiplier
      final multiplier = _muscleGroupMultipliers[exercise.muscleGroup] ?? 1.0;
      exerciseTotal = (exerciseTotal * multiplier).round();
      
      // Cap exercise points
      exerciseTotal = min(exerciseTotal, _maxPointsPerExercise);
      
      exercisePoints[exercise.name] = exerciseTotal;
      totalPoints += exerciseTotal;
    }

    return totalPoints;
  }

  static int _calculateCardioPoints(
    CompletedWorkout workout,
    Map<String, int> exercisePoints,
  ) {
    if (workout.totalDistance == null) return 0;

    int points = (workout.totalDistance! * _baseCardioPointsPerKm).round();
    
    // Time bonus for sustained cardio
    if (workout.duration.inMinutes > 30) {
      points = (points * 1.2).round(); // +20% for 30+ minutes
    }
    
    exercisePoints['Cardio Distance'] = points;
    return points;
  }

  static int _calculateBodyweightPoints(
    CompletedWorkout workout,
    Map<String, int> exercisePoints,
  ) {
    int totalPoints = 0;

    for (final exercise in workout.exercises) {
      int exerciseTotal = 0;
      
      if (exercise.reps != null) {
        exerciseTotal = exercise.reps! * _baseBodyweightPointsPerRep;
        
        // Apply muscle group multiplier
        final multiplier = _muscleGroupMultipliers[exercise.muscleGroup] ?? 1.0;
        exerciseTotal = (exerciseTotal * multiplier).round();
        
        exercisePoints[exercise.name] = exerciseTotal;
        totalPoints += exerciseTotal;
      }
    }

    return totalPoints;
  }

  static int _calculateDurationPoints(
    CompletedWorkout workout,
    Map<String, int> exercisePoints,
  ) {
    int points = workout.duration.inMinutes * _baseDurationPointsPerMinute;
    exercisePoints['Duration Activity'] = points;
    return points;
  }

  static double _calculateStreakBonus(int consecutiveDays) {
    return calculateStreakBonus(consecutiveDays);
  }

  static String _generatePointsDescription(
    CompletedWorkout workout,
    UserStats userStats,
  ) {
    final buffer = StringBuffer();
    buffer.write('${workout.type.name.toUpperCase()} workout completed');
    
    if (workout.isPersonalRecord) {
      buffer.write(' with PR!');
    }
    
    if (userStats.currentStreak > 0) {
      buffer.write(' (${userStats.currentStreak}-day streak)');
    }
    
    return buffer.toString();
  }

  /// Mock data generators for testing and development

  /// Generates mock completed workout for testing
  static CompletedWorkout generateMockStrengthWorkout({
    bool isPersonalRecord = false,
    WorkoutIntensity intensity = WorkoutIntensity.moderate,
  }) {
    return CompletedWorkout(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      type: WorkoutType.strength,
      completedAt: DateTime.now(),
      duration: const Duration(minutes: 60),
      intensity: intensity,
      isPersonalRecord: isPersonalRecord,
      exercises: [
        CompletedExercise(
          name: 'Bench Press',
          muscleGroup: MuscleGroup.chest,
          sets: [
            CompletedSet(weight: 80, reps: 8, rpe: 7),
            CompletedSet(weight: 85, reps: 6, rpe: 8),
            CompletedSet(weight: 90, reps: 4, rpe: 9),
          ],
          isPersonalRecord: isPersonalRecord,
        ),
        CompletedExercise(
          name: 'Squats',
          muscleGroup: MuscleGroup.quads,
          sets: [
            CompletedSet(weight: 100, reps: 10, rpe: 6),
            CompletedSet(weight: 110, reps: 8, rpe: 7),
            CompletedSet(weight: 120, reps: 6, rpe: 8),
          ],
        ),
      ],
    );
  }

  /// Generates mock user stats for testing
  static UserStats generateMockUserStats({
    int streak = 5,
    RankLevel rank = RankLevel.B,
  }) {
    final now = DateTime.now();
    return UserStats(
      currentStreak: streak,
      longestStreak: max(streak, 10),
      lastWorkoutDate: now.subtract(const Duration(days: 1)),
      workoutDates: List.generate(
        streak,
        (index) => now.subtract(Duration(days: index + 1)),
      ),
      currentRank: rank,
      weeklyWorkouts: 4,
      weeklyVolume: 5000,
      hasActiveRival: true,
      personalRecords: {
        'Bench Press': 100,
        'Squats': 140,
        'Deadlift': 160,
      },
    );
  }
}