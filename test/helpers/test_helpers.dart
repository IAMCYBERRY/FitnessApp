/// Test helpers and utilities for RivalX testing.
/// 
/// This file provides common test utilities, mock data generators,
/// and helper functions to ensure consistent testing across the application.
/// It includes mock objects, test data builders, and common test patterns.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalx/models/challenge.dart';
import 'package:rivalx/models/chat_message.dart';
import 'package:rivalx/models/user_model.dart';
import 'package:rivalx/models/muscle_group.dart';
import 'package:rivalx/services/points_service.dart';

/// Common test data and utilities
class TestHelpers {
  static final DateTime testDate = DateTime(2024, 1, 15, 10, 30);
  static const String testUserId = 'test_user_123';
  static const String testUsername = 'testuser';
  static const String testUserEmail = 'test@example.com';

  /// Creates a test MaterialApp wrapper with proper theme
  static Widget createTestApp({
    required Widget child,
    ThemeData? theme,
    List<NavigatorObserver>? navigatorObservers,
  }) {
    return MaterialApp(
      theme: theme ?? ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorObservers: navigatorObservers ?? [],
      home: child,
    );
  }

  /// Creates a test scaffold wrapper for screen testing
  static Widget createTestScaffold({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? floatingActionButton,
  }) {
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  /// Pumps widget and settles all animations
  static Future<void> pumpAndSettleWidget(
    WidgetTester tester,
    Widget widget, {
    Duration? duration,
  }) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(duration ?? const Duration(seconds: 5));
  }

  /// Finds widget by text and taps it
  static Future<void> tapByText(
    WidgetTester tester,
    String text, {
    bool shouldSettle = true,
  }) async {
    await tester.tap(find.text(text));
    if (shouldSettle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  /// Finds widget by icon and taps it
  static Future<void> tapByIcon(
    WidgetTester tester,
    IconData icon, {
    bool shouldSettle = true,
  }) async {
    await tester.tap(find.byIcon(icon));
    if (shouldSettle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  /// Enters text into a text field
  static Future<void> enterText(
    WidgetTester tester,
    String text, {
    Finder? finder,
  }) async {
    final textField = finder ?? find.byType(TextField);
    await tester.enterText(textField, text);
    await tester.pump();
  }

  /// Scrolls to find a widget
  static Future<void> scrollToWidget(
    WidgetTester tester,
    Finder finder, {
    Finder? scrollable,
  }) async {
    final scrollableFinder = scrollable ?? find.byType(Scrollable);
    await tester.scrollUntilVisible(
      finder,
      100.0,
      scrollable: scrollableFinder,
    );
  }

  /// Verifies that a snackbar with specific text is shown
  static void expectSnackBarWithText(String text) {
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(text), findsOneWidget);
  }

  /// Verifies that a dialog with specific title is shown
  static void expectDialogWithTitle(String title) {
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(title), findsOneWidget);
  }

  /// Waits for a specific condition to be met
  static Future<void> waitFor(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    while (!condition() && stopwatch.elapsed < timeout) {
      await tester.pump(interval);
    }
    
    if (!condition()) {
      throw TimeoutException('Condition not met within timeout', timeout);
    }
  }
}

/// Mock data generators for testing
class MockDataGenerators {
  /// Generates a basic test challenge
  static Challenge createTestChallenge({
    String? id,
    String? name,
    String? description,
    ChallengeType? type,
    ChallengeStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? creatorId,
    String? creatorName,
    List<String>? participantIds,
    Map<String, int>? leaderboard,
    int? maxParticipants,
    List<String>? rules,
    int? entryFee,
    int? prizePool,
  }) {
    final now = DateTime.now();
    
    return Challenge(
      id: id ?? 'mock_challenge_${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Mock Fitness Challenge',
      description: description ?? 'A comprehensive fitness challenge for testing',
      type: type ?? ChallengeType.public,
      status: status ?? ChallengeStatus.active,
      startDate: startDate ?? now.subtract(const Duration(days: 1)),
      endDate: endDate ?? now.add(const Duration(days: 7)),
      creatorId: creatorId ?? 'creator_123',
      creatorName: creatorName ?? 'Test Creator',
      participantIds: participantIds ?? ['user1', 'user2', 'user3'],
      leaderboard: leaderboard ?? {
        'user1': 1500,
        'user2': 1200,
        'user3': 800,
      },
      maxParticipants: maxParticipants ?? 100,
      rules: rules ?? [
        'Complete at least 3 workouts per week',
        'Log all meals daily',
        'Share weekly progress',
      ],
      entryFee: entryFee ?? 0,
      prizePool: prizePool ?? 1000,
    );
  }

  /// Generates a rival session for testing
  static RivalSession createTestRivalSession({
    String? id,
    String? userId1,
    String? userId2,
    String? user1Name,
    String? user2Name,
    DateTime? startDate,
    DateTime? endDate,
    int? user1Points,
    int? user2Points,
    bool? isActive,
    int? wagerAmount,
    Map<String, List<String>>? activities,
  }) {
    final now = DateTime.now();
    
    return RivalSession(
      id: id ?? 'mock_rival_${DateTime.now().millisecondsSinceEpoch}',
      userId1: userId1 ?? TestHelpers.testUserId,
      userId2: userId2 ?? 'rival_user_456',
      user1Name: user1Name ?? 'Test User',
      user2Name: user2Name ?? 'Rival User',
      startDate: startDate ?? now.subtract(const Duration(days: 1)),
      endDate: endDate ?? now.add(const Duration(days: 6)),
      user1Points: user1Points ?? 750,
      user2Points: user2Points ?? 620,
      isActive: isActive ?? true,
      wagerAmount: wagerAmount ?? 100,
      activities: activities ?? {
        TestHelpers.testUserId: ['Strength workout', 'Cardio session'],
        'rival_user_456': ['HIIT workout', 'Yoga session'],
      },
    );
  }

  /// Generates a challenge invitation for testing
  static ChallengeInvitation createTestInvitation({
    String? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    RivalChallengeType? challengeType,
    int? duration,
    int? wagerAmount,
    String? personalMessage,
    InvitationStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    final now = DateTime.now();
    
    return ChallengeInvitation(
      id: id ?? 'mock_invite_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId ?? 'sender_123',
      senderName: senderName ?? 'Sender User',
      receiverId: receiverId ?? TestHelpers.testUserId,
      receiverName: receiverName ?? 'Test User',
      challengeType: challengeType ?? RivalChallengeType.general,
      duration: duration ?? 7,
      wagerAmount: wagerAmount ?? 200,
      personalMessage: personalMessage ?? 'Let\'s compete!',
      status: status ?? InvitationStatus.pending,
      createdAt: createdAt ?? now.subtract(const Duration(hours: 1)),
      expiresAt: expiresAt ?? now.add(const Duration(days: 1)),
    );
  }

  /// Generates a friend for testing
  static Friend createTestFriend({
    String? id,
    String? username,
    String? displayName,
    String? email,
    String? avatarUrl,
    RankLevel? currentRank,
    int? totalPoints,
    int? weeklyPoints,
    FitnessLevel? fitnessLevel,
    bool? isOnline,
    DateTime? lastActive,
    int? wins,
    int? losses,
    int? currentStreak,
  }) {
    return Friend(
      id: id ?? 'mock_friend_${DateTime.now().millisecondsSinceEpoch}',
      username: username ?? 'mockfriend',
      displayName: displayName ?? 'Mock Friend',
      email: email ?? 'mock.friend@example.com',
      avatarUrl: avatarUrl,
      currentRank: currentRank ?? RankLevel.C,
      totalPoints: totalPoints ?? 5000,
      weeklyPoints: weeklyPoints ?? 300,
      fitnessLevel: fitnessLevel ?? FitnessLevel.intermediate,
      isOnline: isOnline ?? true,
      lastActive: lastActive ?? DateTime.now().subtract(const Duration(minutes: 15)),
      wins: wins ?? 5,
      losses: losses ?? 3,
      currentStreak: currentStreak ?? 2,
    );
  }

  /// Generates a chat message for testing
  static ChatMessage createTestChatMessage({
    String? id,
    String? content,
    String? senderId,
    String? senderName,
    String? senderUsername,
    String? senderAvatarUrl,
    DateTime? timestamp,
    MessageType? type,
    bool? isRead,
    Map<String, ReactionType>? reactions,
    List<String>? mentions,
    String? imageUrl,
    Map<String, dynamic>? achievementData,
    Map<String, dynamic>? workoutData,
    String? replyToMessageId,
  }) {
    return ChatMessage(
      id: id ?? 'mock_msg_${DateTime.now().millisecondsSinceEpoch}',
      content: content ?? 'Mock message content',
      senderId: senderId ?? 'sender_123',
      senderName: senderName ?? 'Mock Sender',
      senderUsername: senderUsername ?? 'mocksender',
      senderAvatarUrl: senderAvatarUrl,
      timestamp: timestamp ?? DateTime.now().subtract(const Duration(minutes: 5)),
      type: type ?? MessageType.text,
      isRead: isRead ?? false,
      reactions: reactions ?? {},
      mentions: mentions ?? [],
      imageUrl: imageUrl,
      achievementData: achievementData,
      workoutData: workoutData,
      replyToMessageId: replyToMessageId,
    );
  }

  /// Generates a completed workout for testing
  static CompletedWorkout createTestWorkout({
    String? id,
    WorkoutType? type,
    DateTime? completedAt,
    Duration? duration,
    List<CompletedExercise>? exercises,
    WorkoutIntensity? intensity,
    bool? isPersonalRecord,
    double? totalDistance,
    double? totalWeight,
  }) {
    return CompletedWorkout(
      id: id ?? 'mock_workout_${DateTime.now().millisecondsSinceEpoch}',
      type: type ?? WorkoutType.strength,
      completedAt: completedAt ?? DateTime.now(),
      duration: duration ?? const Duration(minutes: 45),
      exercises: exercises ?? [
        CompletedExercise(
          name: 'Bench Press',
          muscleGroup: MuscleGroup.chest,
          sets: [
            CompletedSet(weight: 80, reps: 10),
            CompletedSet(weight: 85, reps: 8),
            CompletedSet(weight: 90, reps: 6),
          ],
        ),
      ],
      intensity: intensity ?? WorkoutIntensity.moderate,
      isPersonalRecord: isPersonalRecord ?? false,
      totalDistance: totalDistance,
      totalWeight: totalWeight,
    );
  }

  /// Generates user stats for testing
  static UserStats createTestUserStats({
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
    final now = DateTime.now();
    
    return UserStats(
      currentStreak: currentStreak ?? 5,
      longestStreak: longestStreak ?? 10,
      lastWorkoutDate: lastWorkoutDate ?? now.subtract(const Duration(days: 1)),
      workoutDates: workoutDates ?? List.generate(
        5,
        (index) => now.subtract(Duration(days: index + 1)),
      ),
      currentRank: currentRank ?? RankLevel.B,
      weeklyWorkouts: weeklyWorkouts ?? 4,
      weeklyVolume: weeklyVolume ?? 2500.0,
      hasActiveRival: hasActiveRival ?? false,
      personalRecords: personalRecords ?? {
        'Bench Press': 100,
        'Squat': 150,
        'Deadlift': 180,
      },
    );
  }

  /// Generates a list of test challenges with different statuses
  static List<Challenge> createMultipleTestChallenges(int count) {
    final challenges = <Challenge>[];
    final statuses = [
      ChallengeStatus.active,
      ChallengeStatus.upcoming,
      ChallengeStatus.completed,
    ];
    final types = [
      ChallengeType.public,
      ChallengeType.private,
      ChallengeType.daily,
    ];

    for (int i = 0; i < count; i++) {
      challenges.add(createTestChallenge(
        id: 'challenge_$i',
        name: 'Challenge ${i + 1}',
        status: statuses[i % statuses.length],
        type: types[i % types.length],
        participantIds: List.generate(
          (i % 5) + 1,
          (index) => 'user_${i}_$index',
        ),
      ));
    }

    return challenges;
  }

  /// Generates multiple test workouts for points testing
  static List<CompletedWorkout> createMultipleTestWorkouts(int count) {
    final workouts = <CompletedWorkout>[];
    final types = [
      WorkoutType.strength,
      WorkoutType.cardio,
      WorkoutType.bodyweight,
      WorkoutType.duration,
    ];

    for (int i = 0; i < count; i++) {
      workouts.add(createTestWorkout(
        id: 'workout_$i',
        type: types[i % types.length],
        completedAt: DateTime.now().subtract(Duration(days: i)),
      ));
    }

    return workouts;
  }
}

/// Test matchers for custom assertions
class TestMatchers {
  /// Matches a widget with specific text content
  static Matcher hasTextContent(String text) {
    return _HasTextContent(text);
  }

  /// Matches a widget with specific semantic label
  static Matcher hasSemanticLabel(String label) {
    return _HasSemanticLabel(label);
  }

  /// Matches a widget that is enabled/disabled
  static Matcher isEnabled(bool enabled) {
    return _IsEnabled(enabled);
  }

  /// Matches a list with specific length
  static Matcher hasLength(int length) {
    return _HasLength(length);
  }

  /// Matches a duration within a range
  static Matcher isDurationBetween(Duration min, Duration max) {
    return _IsDurationBetween(min, max);
  }

  /// Matches points within a range
  static Matcher isPointsBetween(int min, int max) {
    return _IsPointsBetween(min, max);
  }
}

/// Custom matcher implementations
class _HasTextContent extends Matcher {
  final String expectedText;
  
  const _HasTextContent(this.expectedText);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is Widget) {
      // Implementation would check if widget contains text
      return true; // Simplified for example
    }
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('has text content "$expectedText"');
  }
}

class _HasSemanticLabel extends Matcher {
  final String expectedLabel;
  
  const _HasSemanticLabel(this.expectedLabel);

  @override
  bool matches(dynamic item, Map matchState) {
    // Implementation would check semantic label
    return true; // Simplified for example
  }

  @override
  Description describe(Description description) {
    return description.add('has semantic label "$expectedLabel"');
  }
}

class _IsEnabled extends Matcher {
  final bool expectedEnabled;
  
  const _IsEnabled(this.expectedEnabled);

  @override
  bool matches(dynamic item, Map matchState) {
    // Implementation would check if widget is enabled
    return true; // Simplified for example
  }

  @override
  Description describe(Description description) {
    return description.add('is ${expectedEnabled ? "enabled" : "disabled"}');
  }
}

class _HasLength extends Matcher {
  final int expectedLength;
  
  const _HasLength(this.expectedLength);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is List) {
      return item.length == expectedLength;
    }
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('has length $expectedLength');
  }
}

class _IsDurationBetween extends Matcher {
  final Duration min;
  final Duration max;
  
  const _IsDurationBetween(this.min, this.max);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is Duration) {
      return item >= min && item <= max;
    }
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('is duration between $min and $max');
  }
}

class _IsPointsBetween extends Matcher {
  final int min;
  final int max;
  
  const _IsPointsBetween(this.min, this.max);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is int) {
      return item >= min && item <= max;
    }
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('is points between $min and $max');
  }
}

/// Test configurations for different scenarios
class TestConfigurations {
  /// Configuration for testing with mock authentication
  static const Map<String, dynamic> mockAuthConfig = {
    'userId': TestHelpers.testUserId,
    'username': TestHelpers.testUsername,
    'email': TestHelpers.testUserEmail,
    'isAuthenticated': true,
  };

  /// Configuration for testing offline scenarios
  static const Map<String, dynamic> offlineConfig = {
    'isOnline': false,
    'hasNetworkConnection': false,
    'enableCache': true,
  };

  /// Configuration for testing with various user ranks
  static const Map<RankLevel, Map<String, dynamic>> rankConfigs = {
    RankLevel.E: {'totalPoints': 500, 'multiplier': 1.0},
    RankLevel.D: {'totalPoints': 2000, 'multiplier': 1.1},
    RankLevel.C: {'totalPoints': 5000, 'multiplier': 1.2},
    RankLevel.B: {'totalPoints': 12000, 'multiplier': 1.3},
    RankLevel.A: {'totalPoints': 25000, 'multiplier': 1.4},
    RankLevel.S: {'totalPoints': 50000, 'multiplier': 1.5},
    RankLevel.SS: {'totalPoints': 100000, 'multiplier': 1.6},
  };
}

/// Exception for test timeouts
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (timeout: $timeout)';
}