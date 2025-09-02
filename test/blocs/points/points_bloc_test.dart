/// Unit tests for the Points BLoC.
/// 
/// These tests verify the functionality of point tracking, rank progression,
/// and bonus calculations in the PointsBloc.

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:rivalx/blocs/points/points_barrel.dart';
import 'package:rivalx/blocs/auth/mock_auth_bloc.dart';
import 'package:rivalx/blocs/auth/auth_state.dart';
import 'package:rivalx/models/user_model_clean.dart';
import 'package:rivalx/services/points_service.dart';
import 'package:rivalx/services/mock_auth_service.dart';

// Generate mocks
@GenerateMocks([MockAuthBloc, MockAuthService])
import 'points_bloc_test.mocks.dart';

void main() {
  group('PointsBloc', () {
    late PointsBloc pointsBloc;
    late MockMockAuthBloc mockAuthBloc;
    late UserModel testUser;

    setUp(() {
      mockAuthBloc = MockMockAuthBloc();
      testUser = UserModel(
        userId: 'test_user_123',
        email: 'test@rivalx.com',
        userName: 'testuser',
        displayName: 'Test User',
        currentRank: RankLevel.D,
        totalPoints: 1500,
        weeklyPoints: 200,
        dateJoined: DateTime.now().subtract(const Duration(days: 30)),
        volumeLifted: 5000.0,
        distanceWalked: 100.0,
        penaltyCount: 0,
        currentStreak: 5,
        longestStreak: 10,
        lastUpdated: DateTime.now(),
      );

      // Mock auth bloc to return authenticated state
      when(mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthAuthenticated(user: testUser)),
      );
      when(mockAuthBloc.state).thenReturn(AuthAuthenticated(user: testUser));

      pointsBloc = PointsBloc(authBloc: mockAuthBloc);
    });

    tearDown(() {
      pointsBloc.close();
    });

    test('initial state is PointsInitial', () {
      expect(pointsBloc.state, equals(const PointsInitial()));
    });

    group('PointsInitialize', () {
      blocTest<PointsBloc, PointsState>(
        'emits [PointsLoading, PointsLoaded] when initialized successfully',
        build: () => pointsBloc,
        act: (bloc) => bloc.add(PointsInitialize(userId: testUser.userId)),
        expect: () => [
          const PointsLoading(message: 'Loading points...'),
          isA<PointsLoaded>()
            .having((state) => state.totalPoints, 'totalPoints', testUser.totalPoints)
            .having((state) => state.weeklyPoints, 'weeklyPoints', testUser.weeklyPoints)
            .having((state) => state.currentRank, 'currentRank', testUser.currentRank)
            .having((state) => state.currentStreak, 'currentStreak', testUser.currentStreak),
        ],
      );

      blocTest<PointsBloc, PointsState>(
        'emits [PointsLoading, PointsError] when user is null',
        build: () {
          when(mockAuthBloc.stream).thenAnswer(
            (_) => Stream.value(const AuthUnauthenticated()),
          );
          when(mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
          return PointsBloc(authBloc: mockAuthBloc);
        },
        act: (bloc) => bloc.add(PointsInitialize(userId: 'test_user')),
        expect: () => [
          const PointsLoading(message: 'Loading points...'),
          const PointsError(message: 'User not authenticated'),
        ],
      );
    });

    group('WorkoutCompleted', () {
      late CompletedWorkout testWorkout;
      late UserStats testUserStats;

      setUp(() {
        testWorkout = PointsService.generateMockStrengthWorkout(
          isPersonalRecord: false,
          intensity: WorkoutIntensity.moderate,
        );
        testUserStats = PointsService.generateMockUserStats(
          streak: testUser.currentStreak,
          rank: testUser.currentRank,
        );
      });

      blocTest<PointsBloc, PointsState>(
        'awards points for completed workout',
        build: () => pointsBloc,
        seed: () => PointsLoaded(
          totalPoints: testUser.totalPoints,
          weeklyPoints: testUser.weeklyPoints,
          currentRank: testUser.currentRank,
          pointsToNextRank: testUser.pointsToNextRank,
          rankProgress: 50.0,
          currentStreak: testUser.currentStreak,
          activeBonuses: const ActiveBonuses(
            streakBonus: 2.0,
            rankMultiplier: 1.1,
            hasActiveRival: false,
            otherBonuses: [],
          ),
          recentHistory: const [],
          lastUpdated: DateTime.now(),
        ),
        act: (bloc) => bloc.add(WorkoutCompleted(
          workout: testWorkout,
          userStats: testUserStats,
        )),
        expect: () => [
          isA<PointsAwarding>()
            .having((state) => state.pointsAwarded, 'pointsAwarded', greaterThan(0))
            .having((state) => state.activityType, 'activityType', 'workout')
            .having((state) => state.totalPoints, 'totalPoints', greaterThan(testUser.totalPoints)),
        ],
      );

      blocTest<PointsBloc, PointsState>(
        'triggers rank up when crossing threshold',
        build: () => pointsBloc,
        seed: () => PointsLoaded(
          totalPoints: 2950, // Close to C rank (3000)
          weeklyPoints: 200,
          currentRank: RankLevel.D,
          pointsToNextRank: 50,
          rankProgress: 95.0,
          currentStreak: 5,
          activeBonuses: const ActiveBonuses(
            streakBonus: 2.0,
            rankMultiplier: 1.1,
            hasActiveRival: false,
            otherBonuses: [],
          ),
          recentHistory: const [],
          lastUpdated: DateTime.now(),
        ),
        act: (bloc) => bloc.add(WorkoutCompleted(
          workout: testWorkout,
          userStats: testUserStats,
        )),
        expect: () => [
          isA<PointsAwarding>()
            .having((state) => state.isRankUp, 'isRankUp', true)
            .having((state) => state.newRank, 'newRank', RankLevel.C),
        ],
      );
    });

    group('DailyChallengeCompleted', () {
      blocTest<PointsBloc, PointsState>(
        'awards points for daily challenge completion',
        build: () => pointsBloc,
        seed: () => PointsLoaded(
          totalPoints: testUser.totalPoints,
          weeklyPoints: testUser.weeklyPoints,
          currentRank: testUser.currentRank,
          pointsToNextRank: testUser.pointsToNextRank,
          rankProgress: 50.0,
          currentStreak: testUser.currentStreak,
          activeBonuses: const ActiveBonuses(
            streakBonus: 2.0,
            rankMultiplier: 1.1,
            hasActiveRival: false,
            otherBonuses: [],
          ),
          recentHistory: const [],
          lastUpdated: DateTime.now(),
        ),
        act: (bloc) => bloc.add(const DailyChallengeCompleted(
          challengeId: 'daily_001',
          challengeDescription: '50 Push-ups Challenge',
          completionTime: Duration(minutes: 5),
        )),
        expect: () => [
          isA<PointsLoaded>()
            .having((state) => state.totalPoints, 'totalPoints', 
              testUser.totalPoints + (100 * 1.1).round()) // Base 100 + rank multiplier
            .having((state) => state.recentHistory.length, 'historyLength', 1),
        ],
      );
    });

    group('RivalModeVictory', () {
      blocTest<PointsBloc, PointsState>(
        'awards 10% bonus for rival victory',
        build: () => pointsBloc,
        seed: () => PointsLoaded(
          totalPoints: testUser.totalPoints,
          weeklyPoints: testUser.weeklyPoints,
          currentRank: testUser.currentRank,
          pointsToNextRank: testUser.pointsToNextRank,
          rankProgress: 50.0,
          currentStreak: testUser.currentStreak,
          activeBonuses: const ActiveBonuses(
            streakBonus: 2.0,
            rankMultiplier: 1.1,
            hasActiveRival: true,
            otherBonuses: [],
          ),
          recentHistory: const [],
          lastUpdated: DateTime.now(),
        ),
        act: (bloc) => bloc.add(const RivalModeVictory(
          rivalId: 'rival_123',
          rivalUsername: 'TestRival',
          rivalWeeklyPoints: 1000,
          userWeeklyPoints: 1200,
        )),
        expect: () => [
          isA<PointsLoaded>()
            .having((state) => state.totalPoints, 'totalPoints', 
              testUser.totalPoints + 100) // 10% of 1000
            .having((state) => state.recentHistory.first.activity, 'activityType', 'Rival Victory'),
        ],
      );
    });

    group('StreakBonusEarned', () {
      blocTest<PointsBloc, PointsState>(
        'awards streak bonus points',
        build: () => pointsBloc,
        seed: () => PointsLoaded(
          totalPoints: testUser.totalPoints,
          weeklyPoints: testUser.weeklyPoints,
          currentRank: testUser.currentRank,
          pointsToNextRank: testUser.pointsToNextRank,
          rankProgress: 50.0,
          currentStreak: 6, // Will become 7
          activeBonuses: const ActiveBonuses(
            streakBonus: 2.0,
            rankMultiplier: 1.1,
            hasActiveRival: false,
            otherBonuses: [],
          ),
          recentHistory: const [],
          lastUpdated: DateTime.now(),
        ),
        act: (bloc) => bloc.add(const StreakBonusEarned(
          streakDays: 7,
          bonusMultiplier: 0.05, // 5% bonus
          basePoints: 200,
        )),
        expect: () => [
          isA<PointsLoaded>()
            .having((state) => state.currentStreak, 'currentStreak', 7)
            .having((state) => state.totalPoints, 'totalPoints', 
              testUser.totalPoints + 10) // 5% of 200
            .having((state) => state.recentHistory.first.activity, 'activityType', 'Streak Bonus'),
        ],
      );
    });

    group('PointsAdjustment', () {
      blocTest<PointsBloc, PointsState>(
        'applies point penalty correctly',
        build: () => pointsBloc,
        seed: () => PointsLoaded(
          totalPoints: testUser.totalPoints,
          weeklyPoints: testUser.weeklyPoints,
          currentRank: testUser.currentRank,
          pointsToNextRank: testUser.pointsToNextRank,
          rankProgress: 50.0,
          currentStreak: testUser.currentStreak,
          activeBonuses: const ActiveBonuses(
            streakBonus: 2.0,
            rankMultiplier: 1.1,
            hasActiveRival: false,
            otherBonuses: [],
          ),
          recentHistory: const [],
          lastUpdated: DateTime.now(),
        ),
        act: (bloc) => bloc.add(const PointsAdjustment(
          pointsChange: -100,
          reason: 'Missed workout penalty',
          isPenalty: true,
        )),
        expect: () => [
          isA<PointsLoaded>()
            .having((state) => state.totalPoints, 'totalPoints', testUser.totalPoints - 100)
            .having((state) => state.recentHistory.first.activity, 'activityType', 'Penalty'),
        ],
      );
    });

    group('WeeklyPointsReset', () {
      blocTest<PointsBloc, PointsState>(
        'resets weekly points to zero',
        build: () => pointsBloc,
        seed: () => PointsLoaded(
          totalPoints: testUser.totalPoints,
          weeklyPoints: 500,
          currentRank: testUser.currentRank,
          pointsToNextRank: testUser.pointsToNextRank,
          rankProgress: 50.0,
          currentStreak: testUser.currentStreak,
          activeBonuses: const ActiveBonuses(
            streakBonus: 2.0,
            rankMultiplier: 1.1,
            hasActiveRival: false,
            otherBonuses: [],
          ),
          recentHistory: const [],
          lastUpdated: DateTime.now(),
        ),
        act: (bloc) => bloc.add(WeeklyPointsReset(
          previousWeekPoints: 500,
          weekEndDate: DateTime.now(),
        )),
        expect: () => [
          isA<PointsLoaded>()
            .having((state) => state.weeklyPoints, 'weeklyPoints', 0)
            .having((state) => state.totalPoints, 'totalPoints', testUser.totalPoints)
            .having((state) => state.recentHistory.first.activity, 'activityType', 'Weekly Reset'),
        ],
      );
    });

    group('Edge Cases', () {
      test('validates point claims correctly', () {
        final validWorkout = PointsService.generateMockStrengthWorkout();
        final invalidWorkout = CompletedWorkout(
          id: 'invalid',
          type: WorkoutType.strength,
          completedAt: DateTime.now(),
          duration: const Duration(minutes: 2), // Too short
          exercises: [],
        );

        expect(PointsService.validatePointClaim(100, validWorkout), true);
        expect(PointsService.validatePointClaim(100, invalidWorkout), false);
        expect(PointsService.validatePointClaim(-50, validWorkout), false);
        expect(PointsService.validatePointClaim(5000, validWorkout), false);
      });

      test('calculates rank progression correctly', () {
        expect(UserModel.getRankFromPoints(0), RankLevel.E);
        expect(UserModel.getRankFromPoints(1000), RankLevel.D);
        expect(UserModel.getRankFromPoints(3000), RankLevel.C);
        expect(UserModel.getRankFromPoints(7000), RankLevel.B);
        expect(UserModel.getRankFromPoints(15000), RankLevel.A);
        expect(UserModel.getRankFromPoints(30000), RankLevel.S);
        expect(UserModel.getRankFromPoints(60000), RankLevel.SS);
      });

      test('calculates streak bonuses correctly', () {
        expect(PointsService.calculateStreakBonus(1), 0.0);
        expect(PointsService.calculateStreakBonus(3), 0.02);
        expect(PointsService.calculateStreakBonus(7), 0.05);
        expect(PointsService.calculateStreakBonus(14), 0.10);
        expect(PointsService.calculateStreakBonus(30), 0.10);
      });
    });
  });
}