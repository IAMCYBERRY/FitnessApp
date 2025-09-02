/// Comprehensive unit tests for PointsService.
/// 
/// This test suite covers all point calculation logic, bonuses, validation,
/// rank progression, and edge cases for the RivalX fitness application.
/// It ensures the integrity of the competitive point system.

import 'package:flutter_test/flutter_test.dart';
import 'package:rivalx/services/points_service.dart';
import 'package:rivalx/models/user_model.dart';
import 'package:rivalx/models/muscle_group.dart';

void main() {
  group('PointsService', () {
    late CompletedWorkout mockStrengthWorkout;
    late CompletedWorkout mockCardioWorkout;
    late CompletedWorkout mockBodyweightWorkout;
    late UserStats mockUserStats;

    setUp(() {
      // Create mock strength workout
      mockStrengthWorkout = CompletedWorkout(
        id: 'workout_1',
        type: WorkoutType.strength,
        completedAt: DateTime.now(),
        duration: const Duration(minutes: 60),
        intensity: WorkoutIntensity.moderate,
        exercises: [
          CompletedExercise(
            name: 'Bench Press',
            muscleGroup: MuscleGroup.chest,
            sets: [
              CompletedSet(weight: 80, reps: 8, rpe: 7),
              CompletedSet(weight: 85, reps: 6, rpe: 8),
              CompletedSet(weight: 90, reps: 4, rpe: 9),
            ],
          ),
          CompletedExercise(
            name: 'Squats',
            muscleGroup: MuscleGroup.quads,
            sets: [
              CompletedSet(weight: 100, reps: 10, rpe: 6),
              CompletedSet(weight: 110, reps: 8, rpe: 7),
            ],
          ),
        ],
      );

      // Create mock cardio workout
      mockCardioWorkout = CompletedWorkout(
        id: 'workout_2',
        type: WorkoutType.cardio,
        completedAt: DateTime.now(),
        duration: const Duration(minutes: 45),
        totalDistance: 5.0, // 5 km
        exercises: [],
      );

      // Create mock bodyweight workout
      mockBodyweightWorkout = CompletedWorkout(
        id: 'workout_3',
        type: WorkoutType.bodyweight,
        completedAt: DateTime.now(),
        duration: const Duration(minutes: 30),
        exercises: [
          CompletedExercise(
            name: 'Push-ups',
            muscleGroup: MuscleGroup.chest,
            reps: 50,
            sets: [],
          ),
          CompletedExercise(
            name: 'Squats',
            muscleGroup: MuscleGroup.quads,
            reps: 100,
            sets: [],
          ),
        ],
      );

      // Create mock user stats
      mockUserStats = UserStats(
        currentStreak: 5,
        longestStreak: 10,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 1)),
        workoutDates: List.generate(
          5,
          (index) => DateTime.now().subtract(Duration(days: index + 1)),
        ),
        currentRank: RankLevel.B,
        weeklyWorkouts: 4,
        weeklyVolume: 5000,
        hasActiveRival: true,
        personalRecords: {
          'Bench Press': 100,
          'Squats': 140,
        },
      );
    });

    group('Basic Point Calculations', () {
      test('should calculate base strength points correctly', () {
        final points = PointsService.calculateWorkoutPoints(
          mockStrengthWorkout,
          mockUserStats,
        );

        expect(points, greaterThan(0));
        expect(points, lessThanOrEqualTo(2000)); // Max points per workout
      });

      test('should calculate cardio points correctly', () {
        final points = PointsService.calculateWorkoutPoints(
          mockCardioWorkout,
          mockUserStats,
        );

        // Base cardio points: 5km * 50 points/km = 250 points
        // Plus intensity, rank multipliers, and potential bonuses
        expect(points, greaterThan(200));
        expect(points, lessThanOrEqualTo(2000));
      });

      test('should calculate bodyweight points correctly', () {
        final points = PointsService.calculateWorkoutPoints(
          mockBodyweightWorkout,
          mockUserStats,
        );

        // Base: (50 push-ups + 100 squats) * 1 point/rep = 150 points
        // Plus muscle group multipliers, rank multipliers, and bonuses
        expect(points, greaterThan(100));
        expect(points, lessThanOrEqualTo(2000));
      });

      test('should calculate duration workout points correctly', () {
        final durationWorkout = CompletedWorkout(
          id: 'duration_1',
          type: WorkoutType.duration,
          completedAt: DateTime.now(),
          duration: const Duration(minutes: 60),
          exercises: [],
        );

        final points = PointsService.calculateWorkoutPoints(
          durationWorkout,
          mockUserStats,
        );

        // Base: 60 minutes * 5 points/minute = 300 points
        expect(points, greaterThan(250));
      });

      test('should calculate daily challenge points correctly', () {
        final dailyChallenge = CompletedWorkout(
          id: 'daily_1',
          type: WorkoutType.dailyChallenge,
          completedAt: DateTime.now(),
          duration: const Duration(minutes: 20),
          exercises: [],
        );

        final points = PointsService.calculateWorkoutPoints(
          dailyChallenge,
          mockUserStats,
        );

        // Base daily challenge points: 100
        expect(points, greaterThanOrEqualTo(100));
      });

      test('should calculate challenge completion points correctly', () {
        final challenge = CompletedWorkout(
          id: 'challenge_1',
          type: WorkoutType.challenge,
          completedAt: DateTime.now(),
          duration: const Duration(minutes: 30),
          exercises: [],
        );

        final points = PointsService.calculateWorkoutPoints(
          challenge,
          mockUserStats,
        );

        // Base challenge completion bonus: 250
        expect(points, greaterThanOrEqualTo(250));
      });
    });

    group('Intensity Multipliers', () {
      test('should apply low intensity multiplier correctly', () {
        final lowIntensityWorkout = mockStrengthWorkout.copyWith(
          intensity: WorkoutIntensity.low,
        );

        final points = PointsService.calculateWorkoutPoints(
          lowIntensityWorkout,
          mockUserStats,
        );

        final normalPoints = PointsService.calculateWorkoutPoints(
          mockStrengthWorkout,
          mockUserStats,
        );

        expect(points, lessThan(normalPoints));
      });

      test('should apply high intensity multiplier correctly', () {
        final highIntensityWorkout = mockStrengthWorkout.copyWith(
          intensity: WorkoutIntensity.high,
        );

        final points = PointsService.calculateWorkoutPoints(
          highIntensityWorkout,
          mockUserStats,
        );

        final normalPoints = PointsService.calculateWorkoutPoints(
          mockStrengthWorkout,
          mockUserStats,
        );

        expect(points, greaterThan(normalPoints));
      });

      test('should apply extreme intensity multiplier correctly', () {
        final extremeWorkout = mockStrengthWorkout.copyWith(
          intensity: WorkoutIntensity.extreme,
        );

        final points = PointsService.calculateWorkoutPoints(
          extremeWorkout,
          mockUserStats,
        );

        final normalPoints = PointsService.calculateWorkoutPoints(
          mockStrengthWorkout,
          mockUserStats,
        );

        expect(points, greaterThan(normalPoints));
      });
    });

    group('Streak Bonuses', () {
      test('should calculate 3-day streak bonus correctly', () {
        final streakBonus = PointsService.calculateStreakBonus(3);
        expect(streakBonus, equals(0.02)); // 2% bonus
      });

      test('should calculate 7-day streak bonus correctly', () {
        final streakBonus = PointsService.calculateStreakBonus(7);
        expect(streakBonus, equals(0.05)); // 5% bonus
      });

      test('should calculate 14-day streak bonus correctly', () {
        final streakBonus = PointsService.calculateStreakBonus(14);
        expect(streakBonus, equals(0.10)); // 10% bonus
      });

      test('should not give bonus for streaks less than 3 days', () {
        final streakBonus1 = PointsService.calculateStreakBonus(1);
        final streakBonus2 = PointsService.calculateStreakBonus(2);
        
        expect(streakBonus1, equals(0.0));
        expect(streakBonus2, equals(0.0));
      });

      test('should cap streak bonus at 10% for very long streaks', () {
        final streakBonus = PointsService.calculateStreakBonus(30);
        expect(streakBonus, equals(0.10)); // Still 10% max
      });

      test('should apply streak bonus to workout points', () {
        final streakUserStats = mockUserStats.copyWith(currentStreak: 7);
        
        final pointsWithStreak = PointsService.calculateWorkoutPoints(
          mockStrengthWorkout,
          streakUserStats,
        );

        final pointsNoStreak = PointsService.calculateWorkoutPoints(
          mockStrengthWorkout,
          mockUserStats.copyWith(currentStreak: 0),
        );

        expect(pointsWithStreak, greaterThan(pointsNoStreak));
      });
    });

    group('Rank Multipliers', () {
      test('should apply rank multipliers correctly', () {
        final rankEStats = mockUserStats.copyWith(currentRank: RankLevel.E);
        final rankSStats = mockUserStats.copyWith(currentRank: RankLevel.S);

        final pointsE = PointsService.calculateWorkoutPoints(
          mockStrengthWorkout,
          rankEStats,
        );

        final pointsS = PointsService.calculateWorkoutPoints(
          mockStrengthWorkout,
          rankSStats,
        );

        expect(pointsS, greaterThan(pointsE));
      });

      test('should handle all rank levels', () {
        for (final rank in RankLevel.values) {
          final stats = mockUserStats.copyWith(currentRank: rank);
          final points = PointsService.calculateWorkoutPoints(
            mockStrengthWorkout,
            stats,
          );

          expect(points, greaterThan(0));
        }
      });
    });

    group('Personal Record Bonuses', () {
      test('should apply PR bonus when workout is personal record', () {
        final prWorkout = mockStrengthWorkout.copyWith(isPersonalRecord: true);
        
        final pointsWithPR = PointsService.calculateWorkoutPoints(
          prWorkout,
          mockUserStats,
        );

        final pointsNoPR = PointsService.calculateWorkoutPoints(
          mockStrengthWorkout,
          mockUserStats,
        );

        expect(pointsWithPR, greaterThan(pointsNoPR));
      });

      test('should not apply PR bonus when workout is not personal record', () {
        final breakdown = PointsService.calculatePointsWithBreakdown(
          mockStrengthWorkout,
          mockUserStats,
        );

        expect(breakdown.prMultiplier, equals(1.0));
      });
    });

    group('Detailed Points Breakdown', () {
      test('should return detailed breakdown with all components', () {
        final breakdown = PointsService.calculatePointsWithBreakdown(
          mockStrengthWorkout,
          mockUserStats,
        );

        expect(breakdown.basePoints, greaterThan(0));
        expect(breakdown.totalPoints, greaterThanOrEqualTo(breakdown.basePoints));
        expect(breakdown.streakMultiplier, greaterThanOrEqualTo(1.0));
        expect(breakdown.rankMultiplier, greaterThanOrEqualTo(1.0));
        expect(breakdown.exercisePoints, isNotEmpty);
        expect(breakdown.description, isNotEmpty);
      });

      test('should include streak bonus in breakdown when streak exists', () {
        final streakStats = mockUserStats.copyWith(currentStreak: 7);
        final breakdown = PointsService.calculatePointsWithBreakdown(
          mockStrengthWorkout,
          streakStats,
        );

        expect(breakdown.bonusBreakdown.keys, contains(contains('Streak Bonus')));
      });

      test('should include PR bonus in breakdown for personal records', () {
        final prWorkout = mockStrengthWorkout.copyWith(isPersonalRecord: true);
        final breakdown = PointsService.calculatePointsWithBreakdown(
          prWorkout,
          mockUserStats,
        );

        expect(breakdown.bonusBreakdown.keys, contains('Personal Record Bonus'));
      });
    });

    group('Point Validation', () {
      test('should validate reasonable point claims', () {
        final validPoints = 500;
        final isValid = PointsService.validatePointClaim(
          validPoints,
          mockStrengthWorkout,
        );

        expect(isValid, isTrue);
      });

      test('should reject excessive point claims', () {
        final excessivePoints = 5000; // Above max per workout
        final isValid = PointsService.validatePointClaim(
          excessivePoints,
          mockStrengthWorkout,
        );

        expect(isValid, isFalse);
      });

      test('should reject negative point claims', () {
        final negativePoints = -100;
        final isValid = PointsService.validatePointClaim(
          negativePoints,
          mockStrengthWorkout,
        );

        expect(isValid, isFalse);
      });

      test('should reject workouts shorter than minimum duration', () {
        final shortWorkout = mockStrengthWorkout.copyWith(
          duration: const Duration(minutes: 2),
        );
        final isValid = PointsService.validatePointClaim(
          500,
          shortWorkout,
        );

        expect(isValid, isFalse);
      });

      test('should reject strength workouts with no exercises', () {
        final emptyWorkout = mockStrengthWorkout.copyWith(exercises: []);
        final isValid = PointsService.validatePointClaim(
          500,
          emptyWorkout,
        );

        expect(isValid, isFalse);
      });

      test('should reject strength workouts with excessive weight', () {
        final heavyWorkout = CompletedWorkout(
          id: 'heavy',
          type: WorkoutType.strength,
          completedAt: DateTime.now(),
          duration: const Duration(minutes: 60),
          exercises: [
            CompletedExercise(
              name: 'Bench Press',
              muscleGroup: MuscleGroup.chest,
              sets: [
                CompletedSet(weight: 1000, reps: 1), // Unrealistic weight
              ],
            ),
          ],
        );

        final isValid = PointsService.validatePointClaim(500, heavyWorkout);
        expect(isValid, isFalse);
      });

      test('should reject cardio workouts with excessive distance', () {
        final longCardio = mockCardioWorkout.copyWith(totalDistance: 200.0);
        final isValid = PointsService.validatePointClaim(500, longCardio);
        expect(isValid, isFalse);
      });

      test('should reject bodyweight workouts with excessive reps', () {
        final excessiveBodyweight = CompletedWorkout(
          id: 'excessive',
          type: WorkoutType.bodyweight,
          completedAt: DateTime.now(),
          duration: const Duration(minutes: 30),
          exercises: [
            CompletedExercise(
              name: 'Push-ups',
              muscleGroup: MuscleGroup.chest,
              reps: 5000, // Unrealistic reps
              sets: [],
            ),
          ],
        );

        final isValid = PointsService.validatePointClaim(500, excessiveBodyweight);
        expect(isValid, isFalse);
      });

      test('should reject duration workouts exceeding maximum time', () {
        final longWorkout = CompletedWorkout(
          id: 'long',
          type: WorkoutType.duration,
          completedAt: DateTime.now(),
          duration: const Duration(hours: 8), // Exceeds 6-hour limit
          exercises: [],
        );

        final isValid = PointsService.validatePointClaim(500, longWorkout);
        expect(isValid, isFalse);
      });
    });

    group('Rank Progression', () {
      test('should update user rank based on total points', () {
        final rank1000 = PointsService.updateUserRank(1000);
        final rank5000 = PointsService.updateUserRank(5000);
        final rank15000 = PointsService.updateUserRank(15000);
        final rank50000 = PointsService.updateUserRank(50000);

        expect(rank1000, equals(RankLevel.E));
        expect(rank5000, equals(RankLevel.D));
        expect(rank15000, equals(RankLevel.C));
        expect(rank50000, equals(RankLevel.A));
      });
    });

    group('Rival Mode', () {
      test('should calculate rival victory bonus correctly', () {
        final opponentPoints = 1000;
        final bonus = PointsService.calculateRivalVictoryBonus(opponentPoints);
        
        expect(bonus, equals(100)); // 10% of 1000
      });

      test('should handle zero opponent points', () {
        final bonus = PointsService.calculateRivalVictoryBonus(0);
        expect(bonus, equals(0));
      });
    });

    group('Points Summary', () {
      test('should generate comprehensive points summary', () {
        final workouts = [
          mockStrengthWorkout,
          mockCardioWorkout,
          mockBodyweightWorkout,
        ];

        final summary = PointsService.getPointsBreakdown(workouts, mockUserStats);

        expect(summary.totalPoints, greaterThan(0));
        expect(summary.workoutCount, equals(3));
        expect(summary.pointsByType, isNotEmpty);
        expect(summary.dailyPoints, isNotEmpty);
        expect(summary.averagePointsPerWorkout, greaterThan(0));
      });

      test('should handle empty workout list', () {
        final summary = PointsService.getPointsBreakdown([], mockUserStats);

        expect(summary.totalPoints, equals(0));
        expect(summary.workoutCount, equals(0));
        expect(summary.averagePointsPerWorkout, equals(0));
      });
    });

    group('Muscle Group Multipliers', () {
      test('should apply correct multipliers for major muscle groups', () {
        final chestExercise = CompletedExercise(
          name: 'Bench Press',
          muscleGroup: MuscleGroup.chest,
          sets: [CompletedSet(weight: 100, reps: 10)],
        );

        final forearmsExercise = CompletedExercise(
          name: 'Wrist Curls',
          muscleGroup: MuscleGroup.forearms,
          sets: [CompletedSet(weight: 20, reps: 15)],
        );

        final chestWorkout = mockStrengthWorkout.copyWith(
          exercises: [chestExercise],
        );

        final forearmsWorkout = mockStrengthWorkout.copyWith(
          exercises: [forearmsExercise],
        );

        final chestPoints = PointsService.calculateWorkoutPoints(
          chestWorkout,
          mockUserStats,
        );

        final forearmsPoints = PointsService.calculateWorkoutPoints(
          forearmsWorkout,
          mockUserStats,
        );

        // Chest has higher multiplier (1.2) than forearms (0.8)
        expect(chestPoints, greaterThan(forearmsPoints));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle null optional fields gracefully', () {
        final basicWorkout = CompletedWorkout(
          id: 'basic',
          type: WorkoutType.strength,
          completedAt: DateTime.now(),
          duration: const Duration(minutes: 30),
          exercises: [
            CompletedExercise(
              name: 'Basic Exercise',
              muscleGroup: MuscleGroup.chest,
              sets: [CompletedSet(weight: 50, reps: 10)],
            ),
          ],
        );

        final points = PointsService.calculateWorkoutPoints(
          basicWorkout,
          mockUserStats,
        );

        expect(points, greaterThan(0));
      });

      test('should cap total points at daily maximum', () {
        // Create a workout that would exceed daily max
        final massiveWorkout = CompletedWorkout(
          id: 'massive',
          type: WorkoutType.strength,
          completedAt: DateTime.now(),
          duration: const Duration(hours: 3),
          intensity: WorkoutIntensity.extreme,
          isPersonalRecord: true,
          exercises: List.generate(20, (index) => 
            CompletedExercise(
              name: 'Exercise $index',
              muscleGroup: MuscleGroup.chest,
              sets: List.generate(10, (setIndex) => 
                CompletedSet(weight: 200, reps: 20, rpe: 10)
              ),
            ),
          ),
        );

        final highStreakStats = mockUserStats.copyWith(
          currentStreak: 30,
          currentRank: RankLevel.SS,
        );

        final points = PointsService.calculateWorkoutPoints(
          massiveWorkout,
          highStreakStats,
        );

        expect(points, lessThanOrEqualTo(5000)); // Daily max
      });

      test('should handle workout with mixed exercise types', () {
        final mixedWorkout = CompletedWorkout(
          id: 'mixed',
          type: WorkoutType.strength,
          completedAt: DateTime.now(),
          duration: const Duration(minutes: 60),
          exercises: [
            CompletedExercise(
              name: 'Bench Press',
              muscleGroup: MuscleGroup.chest,
              sets: [CompletedSet(weight: 80, reps: 8)],
            ),
            CompletedExercise(
              name: 'Push-ups',
              muscleGroup: MuscleGroup.chest,
              reps: 20,
              sets: [],
            ),
          ],
        );

        final points = PointsService.calculateWorkoutPoints(
          mixedWorkout,
          mockUserStats,
        );

        expect(points, greaterThan(0));
      });
    });

    group('Mock Data Generators', () {
      test('should generate valid mock strength workout', () {
        final mockWorkout = PointsService.generateMockStrengthWorkout();

        expect(mockWorkout.type, equals(WorkoutType.strength));
        expect(mockWorkout.exercises, isNotEmpty);
        expect(mockWorkout.duration.inMinutes, equals(60));
      });

      test('should generate mock workout with personal record flag', () {
        final prWorkout = PointsService.generateMockStrengthWorkout(
          isPersonalRecord: true,
        );

        expect(prWorkout.isPersonalRecord, isTrue);
      });

      test('should generate valid mock user stats', () {
        final mockStats = PointsService.generateMockUserStats();

        expect(mockStats.currentStreak, greaterThanOrEqualTo(0));
        expect(mockStats.currentRank, isNotNull);
        expect(mockStats.personalRecords, isNotEmpty);
      });

      test('should generate mock user stats with custom values', () {
        final customStats = PointsService.generateMockUserStats(
          streak: 10,
          rank: RankLevel.A,
        );

        expect(customStats.currentStreak, equals(10));
        expect(customStats.currentRank, equals(RankLevel.A));
      });
    });
  });
}

/// Extension methods for testing
extension CompletedWorkoutTestExtensions on CompletedWorkout {
  CompletedWorkout copyWith({
    String? id,
    WorkoutType? type,
    DateTime? completedAt,
    Duration? duration,
    List<CompletedExercise>? exercises,
    WorkoutIntensity? intensity,
    bool? isPersonalRecord,
    String? challengeId,
    double? totalDistance,
    double? totalWeight,
    Map<String, dynamic>? additionalData,
  }) {
    return CompletedWorkout(
      id: id ?? this.id,
      type: type ?? this.type,
      completedAt: completedAt ?? this.completedAt,
      duration: duration ?? this.duration,
      exercises: exercises ?? this.exercises,
      intensity: intensity ?? this.intensity,
      isPersonalRecord: isPersonalRecord ?? this.isPersonalRecord,
      challengeId: challengeId ?? this.challengeId,
      totalDistance: totalDistance ?? this.totalDistance,
      totalWeight: totalWeight ?? this.totalWeight,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

extension UserStatsTestExtensions on UserStats {
  UserStats copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastWorkoutDate,
    List<DateTime>? workoutDates,
    RankLevel? currentRank,
    int? weeklyWorkouts,
    double? weeklyVolume,
    bool? hasActiveRival,
    Map<String, int>? personalRecords,
  }) {
    return UserStats(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      workoutDates: workoutDates ?? this.workoutDates,
      currentRank: currentRank ?? this.currentRank,
      weeklyWorkouts: weeklyWorkouts ?? this.weeklyWorkouts,
      weeklyVolume: weeklyVolume ?? this.weeklyVolume,
      hasActiveRival: hasActiveRival ?? this.hasActiveRival,
      personalRecords: personalRecords ?? this.personalRecords,
    );
  }
}