/// Points BLoC for managing user points, ranks, and progression.
/// 
/// This BLoC coordinates between the PointsService and the UI to track
/// points earned from workouts, challenges, and other activities. It manages
/// rank progression, streak bonuses, and maintains point history.

import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rivalx/blocs/points/points_event.dart';
import 'package:rivalx/blocs/points/points_state.dart';
import 'package:rivalx/models/user_model_clean.dart';
import 'package:rivalx/services/points_service.dart';
import 'package:rivalx/blocs/auth/local_auth_bloc.dart';
import 'package:rivalx/blocs/auth/auth_state.dart';

/// BLoC for managing points and rank progression
class PointsBloc extends Bloc<PointsEvent, PointsState> {
  /// Reference to auth bloc for user updates
  final LocalAuthBloc _authBloc;
  
  /// Points calculation service
  final PointsService _pointsService = PointsService();
  
  /// Current user model
  UserModel? _currentUser;
  
  /// Auth state subscription
  StreamSubscription<AuthState>? _authSubscription;
  
  /// Timer for weekly reset
  Timer? _weeklyResetTimer;
  
  /// In-memory point history (last 10 entries)
  final List<PointHistoryEntry> _pointHistory = [];

  /// Creates a PointsBloc instance
  /// 
  /// @param authBloc Authentication bloc for user management
  PointsBloc({required LocalAuthBloc authBloc})
      : _authBloc = authBloc,
        super(const PointsInitial()) {
    
    // Register event handlers
    on<PointsInitialize>(_onInitialize);
    on<WorkoutCompleted>(_onWorkoutCompleted);
    on<ChallengeCompleted>(_onChallengeCompleted);
    on<DailyChallengeCompleted>(_onDailyChallengeCompleted);
    on<RivalModeVictory>(_onRivalModeVictory);
    on<StreakBonusEarned>(_onStreakBonusEarned);
    on<WeeklyPointsReset>(_onWeeklyPointsReset);
    on<PointsAdjustment>(_onPointsAdjustment);
    on<RefreshPoints>(_onRefreshPoints);
    on<RankChanged>(_onRankChanged);

    // Listen to auth state changes
    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        _currentUser = authState.user;
        add(PointsInitialize(userId: authState.user.userId));
      } else if (authState is AuthUnauthenticated) {
        _currentUser = null;
        _pointHistory.clear();
      }
    });

    // Set up weekly reset timer
    _setupWeeklyReset();
  }

  /// Initialize points for a user
  Future<void> _onInitialize(
    PointsInitialize event,
    Emitter<PointsState> emit,
  ) async {
    emit(const PointsLoading(message: 'Loading points...'));

    try {
      if (_currentUser == null) {
        emit(const PointsError(message: 'User not authenticated'));
        return;
      }

      // Load point history from storage/backend
      // For now, generate some mock history
      if (_pointHistory.isEmpty) {
        _generateMockHistory();
      }

      // Calculate active bonuses
      final activeBonuses = _calculateActiveBonuses(_currentUser!);

      // Emit loaded state
      emit(PointsLoaded(
        totalPoints: _currentUser!.totalPoints,
        weeklyPoints: _currentUser!.weeklyPoints,
        currentRank: _currentUser!.currentRank,
        pointsToNextRank: _currentUser!.pointsToNextRank,
        rankProgress: _calculateRankProgress(_currentUser!),
        currentStreak: _currentUser!.currentStreak,
        activeBonuses: activeBonuses,
        recentHistory: List.from(_pointHistory),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(PointsError(
        message: 'Failed to initialize points: ${e.toString()}',
        previousState: state,
      ));
    }
  }

  /// Handle workout completed event
  Future<void> _onWorkoutCompleted(
    WorkoutCompleted event,
    Emitter<PointsState> emit,
  ) async {
    if (_currentUser == null || state is! PointsLoaded) return;

    final currentState = state as PointsLoaded;
    
    try {
      // Calculate points with breakdown
      final breakdown = PointsService.calculatePointsWithBreakdown(
        event.workout,
        event.userStats,
      );

      // Validate points
      if (!PointsService.validatePointClaim(breakdown.totalPoints, event.workout)) {
        emit(PointsError(
          message: 'Invalid workout data detected',
          previousState: state,
        ));
        return;
      }

      // Update user points
      final newTotalPoints = _currentUser!.totalPoints + breakdown.totalPoints;
      final newWeeklyPoints = _currentUser!.weeklyPoints + breakdown.totalPoints;
      
      // Check for rank change
      final newRank = PointsService.updateUserRank(newTotalPoints);
      final isRankUp = newRank != _currentUser!.currentRank;

      // Update user model
      _currentUser = _currentUser!.copyWith(
        totalPoints: newTotalPoints,
        weeklyPoints: newWeeklyPoints,
        currentRank: newRank,
        lastUpdated: DateTime.now(),
      );

      // Update auth bloc with new user data
      _updateUserInAuthBloc();

      // Add to history
      _addToHistory(PointHistoryEntry(
        id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
        points: breakdown.totalPoints,
        activity: 'Workout Completed',
        description: breakdown.description,
        timestamp: DateTime.now(),
        icon: '💪',
        isBonus: false,
      ));

      // Calculate new state values
      final activeBonuses = _calculateActiveBonuses(_currentUser!);

      // Emit awarding state for animation
      emit(PointsAwarding(
        pointsAwarded: breakdown.totalPoints,
        breakdown: breakdown,
        activityType: 'workout',
        isRankUp: isRankUp,
        newRank: isRankUp ? newRank : null,
        totalPoints: newTotalPoints,
        weeklyPoints: newWeeklyPoints,
        currentRank: newRank,
        pointsToNextRank: _currentUser!.pointsToNextRank,
        rankProgress: _calculateRankProgress(_currentUser!),
        currentStreak: _currentUser!.currentStreak,
        activeBonuses: activeBonuses,
        recentHistory: List.from(_pointHistory),
        lastUpdated: DateTime.now(),
      ));

      // After animation delay, show rank up if applicable
      if (isRankUp) {
        await Future.delayed(const Duration(seconds: 2));
        add(RankChanged(
          previousRank: currentState.currentRank,
          newRank: newRank,
          totalPoints: newTotalPoints,
        ));
      }
    } catch (e) {
      emit(PointsError(
        message: 'Failed to award workout points: ${e.toString()}',
        previousState: state,
      ));
    }
  }

  /// Handle challenge completed event
  Future<void> _onChallengeCompleted(
    ChallengeCompleted event,
    Emitter<PointsState> emit,
  ) async {
    if (_currentUser == null || state is! PointsLoaded) return;

    try {
      // Calculate challenge points with placement bonus
      int points = event.basePoints;
      
      // Add placement bonus
      if (event.placement == 1) {
        points = (points * 1.5).round(); // 50% bonus for 1st place
      } else if (event.placement == 2) {
        points = (points * 1.3).round(); // 30% bonus for 2nd place
      } else if (event.placement == 3) {
        points = (points * 1.15).round(); // 15% bonus for 3rd place
      }

      // Apply rank multiplier
      final rankMultiplier = _getRankMultiplier(_currentUser!.currentRank);
      points = (points * rankMultiplier).round();

      // Update user points
      final newTotalPoints = _currentUser!.totalPoints + points;
      final newWeeklyPoints = _currentUser!.weeklyPoints + points;
      
      // Check for rank change
      final newRank = PointsService.updateUserRank(newTotalPoints);
      final isRankUp = newRank != _currentUser!.currentRank;

      // Update user model
      _currentUser = _currentUser!.copyWith(
        totalPoints: newTotalPoints,
        weeklyPoints: newWeeklyPoints,
        currentRank: newRank,
        lastUpdated: DateTime.now(),
      );

      // Update auth bloc
      _updateUserInAuthBloc();

      // Add to history
      _addToHistory(PointHistoryEntry(
        id: 'challenge_${event.challengeId}',
        points: points,
        activity: 'Challenge Completed',
        description: '${event.challengeType} challenge - Placed #${event.placement}',
        timestamp: DateTime.now(),
        icon: '🏆',
        isBonus: event.placement <= 3,
      ));

      // Emit new state
      emit(PointsLoaded(
        totalPoints: newTotalPoints,
        weeklyPoints: newWeeklyPoints,
        currentRank: newRank,
        pointsToNextRank: _currentUser!.pointsToNextRank,
        rankProgress: _calculateRankProgress(_currentUser!),
        currentStreak: _currentUser!.currentStreak,
        activeBonuses: _calculateActiveBonuses(_currentUser!),
        recentHistory: List.from(_pointHistory),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(PointsError(
        message: 'Failed to award challenge points: ${e.toString()}',
        previousState: state,
      ));
    }
  }

  /// Handle daily challenge completed event
  Future<void> _onDailyChallengeCompleted(
    DailyChallengeCompleted event,
    Emitter<PointsState> emit,
  ) async {
    if (_currentUser == null || state is! PointsLoaded) return;

    try {
      // Base daily challenge points
      int points = 100;

      // Apply rank multiplier
      final rankMultiplier = _getRankMultiplier(_currentUser!.currentRank);
      points = (points * rankMultiplier).round();

      // Update user points
      final newTotalPoints = _currentUser!.totalPoints + points;
      final newWeeklyPoints = _currentUser!.weeklyPoints + points;
      
      // Update user model
      _currentUser = _currentUser!.copyWith(
        totalPoints: newTotalPoints,
        weeklyPoints: newWeeklyPoints,
        lastUpdated: DateTime.now(),
      );

      // Update auth bloc
      _updateUserInAuthBloc();

      // Add to history
      _addToHistory(PointHistoryEntry(
        id: 'daily_${event.challengeId}',
        points: points,
        activity: 'Daily Challenge',
        description: event.challengeDescription,
        timestamp: DateTime.now(),
        icon: '📅',
        isBonus: false,
      ));

      // Emit new state
      emit(PointsLoaded(
        totalPoints: newTotalPoints,
        weeklyPoints: newWeeklyPoints,
        currentRank: _currentUser!.currentRank,
        pointsToNextRank: _currentUser!.pointsToNextRank,
        rankProgress: _calculateRankProgress(_currentUser!),
        currentStreak: _currentUser!.currentStreak,
        activeBonuses: _calculateActiveBonuses(_currentUser!),
        recentHistory: List.from(_pointHistory),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(PointsError(
        message: 'Failed to award daily challenge points: ${e.toString()}',
        previousState: state,
      ));
    }
  }

  /// Handle rival mode victory event
  Future<void> _onRivalModeVictory(
    RivalModeVictory event,
    Emitter<PointsState> emit,
  ) async {
    if (_currentUser == null || state is! PointsLoaded) return;

    try {
      // Calculate 10% bonus from rival's points
      final bonusPoints = PointsService.calculateRivalVictoryBonus(
        event.rivalWeeklyPoints,
      );

      // Update user points
      final newTotalPoints = _currentUser!.totalPoints + bonusPoints;
      final newWeeklyPoints = _currentUser!.weeklyPoints + bonusPoints;
      
      // Update user model
      _currentUser = _currentUser!.copyWith(
        totalPoints: newTotalPoints,
        weeklyPoints: newWeeklyPoints,
        lastUpdated: DateTime.now(),
      );

      // Update auth bloc
      _updateUserInAuthBloc();

      // Add to history
      _addToHistory(PointHistoryEntry(
        id: 'rival_victory_${DateTime.now().millisecondsSinceEpoch}',
        points: bonusPoints,
        activity: 'Rival Victory',
        description: 'Defeated ${event.rivalUsername} (+10% bonus)',
        timestamp: DateTime.now(),
        icon: '⚔️',
        isBonus: true,
      ));

      // Emit new state
      emit(PointsLoaded(
        totalPoints: newTotalPoints,
        weeklyPoints: newWeeklyPoints,
        currentRank: _currentUser!.currentRank,
        pointsToNextRank: _currentUser!.pointsToNextRank,
        rankProgress: _calculateRankProgress(_currentUser!),
        currentStreak: _currentUser!.currentStreak,
        activeBonuses: _calculateActiveBonuses(_currentUser!),
        recentHistory: List.from(_pointHistory),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(PointsError(
        message: 'Failed to award rival victory bonus: ${e.toString()}',
        previousState: state,
      ));
    }
  }

  /// Handle streak bonus earned event
  Future<void> _onStreakBonusEarned(
    StreakBonusEarned event,
    Emitter<PointsState> emit,
  ) async {
    if (_currentUser == null || state is! PointsLoaded) return;

    try {
      // Calculate bonus points
      final bonusPoints = (event.basePoints * event.bonusMultiplier).round();

      // Update user points
      final newTotalPoints = _currentUser!.totalPoints + bonusPoints;
      final newWeeklyPoints = _currentUser!.weeklyPoints + bonusPoints;
      
      // Update user model with new streak
      _currentUser = _currentUser!.copyWith(
        totalPoints: newTotalPoints,
        weeklyPoints: newWeeklyPoints,
        currentStreak: event.streakDays,
        longestStreak: max(_currentUser!.longestStreak, event.streakDays),
        lastUpdated: DateTime.now(),
      );

      // Update auth bloc
      _updateUserInAuthBloc();

      // Add to history
      _addToHistory(PointHistoryEntry(
        id: 'streak_bonus_${DateTime.now().millisecondsSinceEpoch}',
        points: bonusPoints,
        activity: 'Streak Bonus',
        description: '${event.streakDays}-day streak bonus!',
        timestamp: DateTime.now(),
        icon: '🔥',
        isBonus: true,
      ));

      // Emit new state
      emit(PointsLoaded(
        totalPoints: newTotalPoints,
        weeklyPoints: newWeeklyPoints,
        currentRank: _currentUser!.currentRank,
        pointsToNextRank: _currentUser!.pointsToNextRank,
        rankProgress: _calculateRankProgress(_currentUser!),
        currentStreak: event.streakDays,
        activeBonuses: _calculateActiveBonuses(_currentUser!),
        recentHistory: List.from(_pointHistory),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(PointsError(
        message: 'Failed to award streak bonus: ${e.toString()}',
        previousState: state,
      ));
    }
  }

  /// Handle weekly points reset
  Future<void> _onWeeklyPointsReset(
    WeeklyPointsReset event,
    Emitter<PointsState> emit,
  ) async {
    if (_currentUser == null || state is! PointsLoaded) return;

    try {
      // Reset weekly points
      _currentUser = _currentUser!.copyWith(
        weeklyPoints: 0,
        lastUpdated: DateTime.now(),
      );

      // Update auth bloc
      _updateUserInAuthBloc();

      // Add to history
      _addToHistory(PointHistoryEntry(
        id: 'weekly_reset_${event.weekEndDate.millisecondsSinceEpoch}',
        points: 0,
        activity: 'Weekly Reset',
        description: 'New week started (Previous: ${event.previousWeekPoints} pts)',
        timestamp: DateTime.now(),
        icon: '📊',
        isBonus: false,
      ));

      // Emit new state
      emit(PointsLoaded(
        totalPoints: _currentUser!.totalPoints,
        weeklyPoints: 0,
        currentRank: _currentUser!.currentRank,
        pointsToNextRank: _currentUser!.pointsToNextRank,
        rankProgress: _calculateRankProgress(_currentUser!),
        currentStreak: _currentUser!.currentStreak,
        activeBonuses: _calculateActiveBonuses(_currentUser!),
        recentHistory: List.from(_pointHistory),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(PointsError(
        message: 'Failed to reset weekly points: ${e.toString()}',
        previousState: state,
      ));
    }
  }

  /// Handle points adjustment (penalties/manual)
  Future<void> _onPointsAdjustment(
    PointsAdjustment event,
    Emitter<PointsState> emit,
  ) async {
    if (_currentUser == null || state is! PointsLoaded) return;

    try {
      // Update user points
      final newTotalPoints = max(0, _currentUser!.totalPoints + event.pointsChange);
      final newWeeklyPoints = max(0, _currentUser!.weeklyPoints + event.pointsChange);
      
      // Check for rank change
      final newRank = PointsService.updateUserRank(newTotalPoints);

      // Update user model
      _currentUser = _currentUser!.copyWith(
        totalPoints: newTotalPoints,
        weeklyPoints: newWeeklyPoints,
        currentRank: newRank,
        penaltyCount: event.isPenalty 
            ? _currentUser!.penaltyCount + 1 
            : _currentUser!.penaltyCount,
        lastUpdated: DateTime.now(),
      );

      // Update auth bloc
      _updateUserInAuthBloc();

      // Add to history
      _addToHistory(PointHistoryEntry(
        id: 'adjustment_${DateTime.now().millisecondsSinceEpoch}',
        points: event.pointsChange,
        activity: event.isPenalty ? 'Penalty' : 'Adjustment',
        description: event.reason,
        timestamp: DateTime.now(),
        icon: event.isPenalty ? '⚠️' : '📝',
        isBonus: false,
      ));

      // Emit new state
      emit(PointsLoaded(
        totalPoints: newTotalPoints,
        weeklyPoints: newWeeklyPoints,
        currentRank: newRank,
        pointsToNextRank: _currentUser!.pointsToNextRank,
        rankProgress: _calculateRankProgress(_currentUser!),
        currentStreak: _currentUser!.currentStreak,
        activeBonuses: _calculateActiveBonuses(_currentUser!),
        recentHistory: List.from(_pointHistory),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(PointsError(
        message: 'Failed to adjust points: ${e.toString()}',
        previousState: state,
      ));
    }
  }

  /// Handle refresh points event
  Future<void> _onRefreshPoints(
    RefreshPoints event,
    Emitter<PointsState> emit,
  ) async {
    if (_currentUser == null) return;

    // Re-initialize points
    add(PointsInitialize(userId: _currentUser!.userId));
  }

  /// Handle rank changed event
  Future<void> _onRankChanged(
    RankChanged event,
    Emitter<PointsState> emit,
  ) async {
    if (state is! PointsLoaded) return;

    final currentState = state as PointsLoaded;

    // Calculate rank up bonus (optional)
    const rankUpBonus = 500;

    // Add bonus points
    final newTotalPoints = _currentUser!.totalPoints + rankUpBonus;
    final newWeeklyPoints = _currentUser!.weeklyPoints + rankUpBonus;

    // Update user model
    _currentUser = _currentUser!.copyWith(
      totalPoints: newTotalPoints,
      weeklyPoints: newWeeklyPoints,
      lastUpdated: DateTime.now(),
    );

    // Update auth bloc
    _updateUserInAuthBloc();

    // Add to history
    _addToHistory(PointHistoryEntry(
      id: 'rankup_${DateTime.now().millisecondsSinceEpoch}',
      points: rankUpBonus,
      activity: 'Rank Up!',
      description: 'Promoted to ${event.newRank.name} rank!',
      timestamp: DateTime.now(),
      icon: '🎖️',
      isBonus: true,
    ));

    // Emit rank up state
    emit(RankUpAchieved(
      previousRank: event.previousRank,
      rankUpBonus: rankUpBonus,
      totalPoints: newTotalPoints,
      weeklyPoints: newWeeklyPoints,
      currentRank: event.newRank,
      pointsToNextRank: _currentUser!.pointsToNextRank,
      rankProgress: _calculateRankProgress(_currentUser!),
      currentStreak: currentState.currentStreak,
      activeBonuses: currentState.activeBonuses,
      recentHistory: List.from(_pointHistory),
      lastUpdated: DateTime.now(),
    ));
  }

  /// Calculate active bonuses for user
  ActiveBonuses _calculateActiveBonuses(UserModel user) {
    // Calculate streak bonus
    final streakBonus = PointsService.calculateStreakBonus(user.currentStreak) * 100;

    // Get rank multiplier
    final rankMultiplier = _getRankMultiplier(user.currentRank);

    // Check for other bonuses
    final otherBonuses = <BonusInfo>[];
    
    // Add weekend warrior bonus (example)
    final now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      otherBonuses.add(const BonusInfo(
        name: 'Weekend Warrior',
        description: '+10% points on weekends',
        multiplier: 1.1,
      ));
    }

    return ActiveBonuses(
      streakBonus: streakBonus,
      rankMultiplier: rankMultiplier,
      hasActiveRival: user.hasActiveRival,
      otherBonuses: otherBonuses,
    );
  }

  /// Calculate rank progress percentage
  double _calculateRankProgress(UserModel user) {
    if (user.currentRank == RankLevel.SS) return 100.0;

    // Get points for current and next rank
    final currentRankPoints = _getPointsForRank(user.currentRank);
    final nextRankPoints = _getPointsForRank(_getNextRank(user.currentRank));

    // Calculate progress
    final pointsInCurrentRank = user.totalPoints - currentRankPoints;
    final pointsNeededForNextRank = nextRankPoints - currentRankPoints;

    return (pointsInCurrentRank / pointsNeededForNextRank * 100).clamp(0.0, 100.0);
  }

  /// Get rank multiplier
  double _getRankMultiplier(RankLevel rank) {
    switch (rank) {
      case RankLevel.E:
        return 1.0;
      case RankLevel.D:
        return 1.1;
      case RankLevel.C:
        return 1.2;
      case RankLevel.B:
        return 1.3;
      case RankLevel.A:
        return 1.4;
      case RankLevel.S:
        return 1.5;
      case RankLevel.SS:
        return 1.6;
    }
  }

  /// Get points required for a rank
  int _getPointsForRank(RankLevel rank) {
    switch (rank) {
      case RankLevel.E:
        return 0;
      case RankLevel.D:
        return 1000;
      case RankLevel.C:
        return 3000;
      case RankLevel.B:
        return 7000;
      case RankLevel.A:
        return 15000;
      case RankLevel.S:
        return 30000;
      case RankLevel.SS:
        return 60000;
    }
  }

  /// Get next rank level
  RankLevel _getNextRank(RankLevel currentRank) {
    switch (currentRank) {
      case RankLevel.E:
        return RankLevel.D;
      case RankLevel.D:
        return RankLevel.C;
      case RankLevel.C:
        return RankLevel.B;
      case RankLevel.B:
        return RankLevel.A;
      case RankLevel.A:
        return RankLevel.S;
      case RankLevel.S:
        return RankLevel.SS;
      case RankLevel.SS:
        return RankLevel.SS; // Max rank
    }
  }

  /// Add entry to point history
  void _addToHistory(PointHistoryEntry entry) {
    _pointHistory.insert(0, entry);
    if (_pointHistory.length > 10) {
      _pointHistory.removeLast();
    }
  }

  /// Update user in auth bloc
  void _updateUserInAuthBloc() {
    if (_currentUser != null) {
      // _authBloc.add(AuthUpdateUser(user: _currentUser!)); // TODO: Fix auth update
    }
  }

  /// Set up weekly reset timer
  void _setupWeeklyReset() {
    // Calculate time until next Sunday midnight
    final now = DateTime.now();
    final daysUntilSunday = DateTime.sunday - now.weekday;
    final nextSunday = now.add(Duration(days: daysUntilSunday));
    final sundayMidnight = DateTime(nextSunday.year, nextSunday.month, nextSunday.day);
    
    final timeUntilReset = sundayMidnight.difference(now);

    // Set timer for weekly reset
    _weeklyResetTimer = Timer(timeUntilReset, () {
      if (_currentUser != null) {
        add(WeeklyPointsReset(
          previousWeekPoints: _currentUser!.weeklyPoints,
          weekEndDate: DateTime.now(),
        ));
      }

      // Set up next weekly reset
      _setupWeeklyReset();
    });
  }

  /// Generate mock history for testing
  void _generateMockHistory() {
    final activities = [
      'Morning Workout',
      'Evening Run',
      'Strength Training',
      'Daily Challenge',
      'Cardio Session',
    ];

    for (int i = 0; i < 5; i++) {
      _pointHistory.add(PointHistoryEntry(
        id: 'mock_$i',
        points: Random().nextInt(200) + 50,
        activity: activities[i % activities.length],
        description: 'Completed ${activities[i % activities.length]}',
        timestamp: DateTime.now().subtract(Duration(days: i)),
        icon: ['💪', '🏃', '🏋️', '📅', '🚴'][i % 5],
        isBonus: Random().nextBool(),
      ));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _weeklyResetTimer?.cancel();
    return super.close();
  }
}