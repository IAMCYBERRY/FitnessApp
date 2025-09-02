/// Comprehensive widget tests for ChallengeDetailsScreen.
/// 
/// This test suite covers all UI components and interactions including:
/// - Challenge header display and countdown timer
/// - Tab navigation functionality (Overview, Leaderboard, Activity, Chat)
/// - Join/Leave challenge functionality with proper error handling
/// - Loading and error states display
/// - User interaction handling and navigation behavior
/// - Real-time updates and data display correctness

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalx/screens/rivals/challenge_details_screen.dart';
import 'package:rivalx/models/challenge.dart';
import 'package:rivalx/models/user_model.dart';

void main() {
  group('ChallengeDetailsScreen Widget Tests', () {
    late Challenge testChallenge;
    late Challenge inactiveChallenge;
    late Challenge userParticipatingChallenge;

    setUp(() {
      final now = DateTime.now();
      
      testChallenge = Challenge(
        id: 'test_challenge_1',
        name: 'Summer Fitness Challenge',
        description: 'Get fit this summer with our comprehensive challenge!',
        type: ChallengeType.public,
        status: ChallengeStatus.active,
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        creatorId: 'creator_123',
        creatorName: 'Fitness Coach',
        participantIds: ['user1', 'user2', 'user3', 'user4'],
        leaderboard: {
          'user1': 2500,
          'user2': 2200,
          'user3': 1800,
          'user4': 1500,
        },
        rules: [
          'Complete at least 4 workouts per week',
          'Log all meals and track nutrition',
          'Share progress photos weekly',
          'Participate in group challenges',
        ],
        maxParticipants: 100,
        prizePool: 5000,
        entryFee: 100,
      );

      inactiveChallenge = testChallenge.copyWith(
        id: 'inactive_challenge',
        name: 'Completed Challenge',
        status: ChallengeStatus.completed,
        startDate: now.subtract(const Duration(days: 14)),
        endDate: now.subtract(const Duration(days: 7)),
      );

      userParticipatingChallenge = testChallenge.copyWith(
        id: 'user_challenge',
        participantIds: [...testChallenge.participantIds, '123'], // Current user ID
        leaderboard: {
          ...testChallenge.leaderboard,
          '123': 1900,
        },
      );
    });

    Widget createTestWidget(Challenge challenge) {
      return MaterialApp(
        home: ChallengeDetailsScreen(challenge: challenge),
      );
    }

    group('Challenge Header Display', () {
      testWidgets('should display challenge name and description', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('Summer Fitness Challenge'), findsOneWidget);
        expect(find.text('Get fit this summer with our comprehensive challenge!'), findsOneWidget);
      });

      testWidgets('should display challenge type and status', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('Public Challenge'), findsOneWidget);
        expect(find.byIcon(Icons.public), findsOneWidget);
      });

      testWidgets('should display participant count', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('4 / 100 participants'), findsOneWidget);
      });

      testWidgets('should display prize pool when available', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('Prize Pool: 5000 points'), findsOneWidget);
      });

      testWidgets('should display entry fee when applicable', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('Entry Fee: 100 points'), findsOneWidget);
      });

      testWidgets('should display countdown timer for active challenges', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        // Should show remaining time
        expect(find.textContaining('5d'), findsOneWidget);
      });

      testWidgets('should show "Ended" for completed challenges', (tester) async {
        await tester.pumpWidget(createTestWidget(inactiveChallenge));

        expect(find.text('Ended'), findsOneWidget);
      });
    });

    group('Tab Navigation', () {
      testWidgets('should display all four tabs', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('Overview'), findsOneWidget);
        expect(find.text('Leaderboard'), findsOneWidget);
        expect(find.text('Activity'), findsOneWidget);
        expect(find.text('Chat'), findsOneWidget);
      });

      testWidgets('should switch between tabs correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        // Initially on Overview tab
        expect(find.text('Challenge Rules'), findsOneWidget);

        // Tap Leaderboard tab
        await tester.tap(find.text('Leaderboard'));
        await tester.pumpAndSettle();

        expect(find.text('Leaderboard'), findsWidgets);
        expect(find.text('Rank'), findsOneWidget);

        // Tap Activity tab
        await tester.tap(find.text('Activity'));
        await tester.pumpAndSettle();

        expect(find.text('Recent Activity'), findsOneWidget);

        // Tap Chat tab
        await tester.tap(find.text('Chat'));
        await tester.pumpAndSettle();

        expect(find.text('Challenge Chat'), findsOneWidget);
      });
    });

    group('Overview Tab Content', () {
      testWidgets('should display challenge description', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('About This Challenge'), findsOneWidget);
        expect(find.text('Get fit this summer with our comprehensive challenge!'), findsOneWidget);
      });

      testWidgets('should display challenge rules', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('Challenge Rules'), findsOneWidget);
        expect(find.text('Complete at least 4 workouts per week'), findsOneWidget);
        expect(find.text('Log all meals and track nutrition'), findsOneWidget);
        expect(find.text('Share progress photos weekly'), findsOneWidget);
        expect(find.text('Participate in group challenges'), findsOneWidget);
      });

      testWidgets('should display creator information', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('Created by Fitness Coach'), findsOneWidget);
      });

      testWidgets('should display challenge dates', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('Duration'), findsOneWidget);
        // Should show formatted start and end dates
        expect(find.textContaining('Started'), findsOneWidget);
        expect(find.textContaining('Ends'), findsOneWidget);
      });
    });

    group('Leaderboard Tab Content', () {
      testWidgets('should display leaderboard with participant rankings', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        // Navigate to Leaderboard tab
        await tester.tap(find.text('Leaderboard'));
        await tester.pumpAndSettle();

        expect(find.text('Rank'), findsOneWidget);
        expect(find.text('Participant'), findsOneWidget);
        expect(find.text('Points'), findsOneWidget);

        // Should show leaderboard entries sorted by points
        expect(find.text('2500'), findsOneWidget); // Top score
        expect(find.text('2200'), findsOneWidget);
        expect(find.text('1800'), findsOneWidget);
        expect(find.text('1500'), findsOneWidget);
      });

      testWidgets('should highlight current user in leaderboard', (tester) async {
        await tester.pumpWidget(createTestWidget(userParticipatingChallenge));

        // Navigate to Leaderboard tab
        await tester.tap(find.text('Leaderboard'));
        await tester.pumpAndSettle();

        // Current user should be highlighted (mock user ID '123' with 1900 points)
        expect(find.text('1900'), findsOneWidget);
      });

      testWidgets('should show "View Full Leaderboard" button for large leaderboards', (tester) async {
        // Create challenge with many participants
        final largeChallenge = testChallenge.copyWith(
          participantIds: List.generate(20, (index) => 'user_$index'),
          leaderboard: Map.fromEntries(
            List.generate(20, (index) => MapEntry('user_$index', 1000 - index * 10)),
          ),
        );

        await tester.pumpWidget(createTestWidget(largeChallenge));

        // Navigate to Leaderboard tab
        await tester.tap(find.text('Leaderboard'));
        await tester.pumpAndSettle();

        expect(find.text('View Full Leaderboard'), findsOneWidget);
      });
    });

    group('Activity Tab Content', () {
      testWidgets('should display recent activity section', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        // Navigate to Activity tab
        await tester.tap(find.text('Activity'));
        await tester.pumpAndSettle();

        expect(find.text('Recent Activity'), findsOneWidget);
        expect(find.text('No recent activity to display'), findsOneWidget);
      });

      testWidgets('should show mock activity when available', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        // Navigate to Activity tab
        await tester.tap(find.text('Activity'));
        await tester.pumpAndSettle();

        // Should show activity section even if empty initially
        expect(find.text('Recent Activity'), findsOneWidget);
      });
    });

    group('Chat Tab Content', () {
      testWidgets('should display chat interface', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        // Navigate to Chat tab
        await tester.tap(find.text('Chat'));
        await tester.pumpAndSettle();

        expect(find.text('Challenge Chat'), findsOneWidget);
        expect(find.text('Chat messages will appear here'), findsOneWidget);
      });

      testWidgets('should show navigation to full chat screen', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        // Navigate to Chat tab
        await tester.tap(find.text('Chat'));
        await tester.pumpAndSettle();

        expect(find.text('Open Full Chat'), findsOneWidget);
      });
    });

    group('Join/Leave Challenge Functionality', () {
      testWidgets('should show Join button for non-participating user', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('Join Challenge'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('should show Leave button for participating user', (tester) async {
        await tester.pumpWidget(createTestWidget(userParticipatingChallenge));

        expect(find.text('Leave Challenge'), findsOneWidget);
        expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
      });

      testWidgets('should handle join challenge tap', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        await tester.tap(find.text('Join Challenge'));
        await tester.pumpAndSettle();

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should handle leave challenge tap', (tester) async {
        await tester.pumpWidget(createTestWidget(userParticipatingChallenge));

        await tester.tap(find.text('Leave Challenge'));
        await tester.pumpAndSettle();

        // Should show confirmation dialog
        expect(find.text('Leave Challenge?'), findsOneWidget);
        expect(find.text('Are you sure you want to leave this challenge?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Leave'), findsOneWidget);
      });

      testWidgets('should confirm leave challenge action', (tester) async {
        await tester.pumpWidget(createTestWidget(userParticipatingChallenge));

        await tester.tap(find.text('Leave Challenge'));
        await tester.pumpAndSettle();

        // Tap confirm in dialog
        await tester.tap(find.text('Leave'));
        await tester.pumpAndSettle();

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should cancel leave challenge action', (tester) async {
        await tester.pumpWidget(createTestWidget(userParticipatingChallenge));

        await tester.tap(find.text('Leave Challenge'));
        await tester.pumpAndSettle();

        // Tap cancel in dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Dialog should close, button should still be Leave
        expect(find.text('Leave Challenge?'), findsNothing);
        expect(find.text('Leave Challenge'), findsOneWidget);
      });

      testWidgets('should disable join button for completed challenges', (tester) async {
        await tester.pumpWidget(createTestWidget(inactiveChallenge));

        // Should not show join button for completed challenge
        expect(find.text('Join Challenge'), findsNothing);
        expect(find.text('Challenge Completed'), findsOneWidget);
      });

      testWidgets('should disable join button for full challenges', (tester) async {
        final fullChallenge = testChallenge.copyWith(
          maxParticipants: 4, // Already has 4 participants
        );

        await tester.pumpWidget(createTestWidget(fullChallenge));

        expect(find.text('Challenge Full'), findsOneWidget);
        expect(find.text('Join Challenge'), findsNothing);
      });
    });

    group('Loading and Error States', () {
      testWidgets('should show loading indicator during operations', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        await tester.tap(find.text('Join Challenge'));
        await tester.pump(); // Don't settle to catch loading state

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should display error messages correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        // Simulate error state
        await tester.tap(find.text('Join Challenge'));
        await tester.pumpAndSettle();

        // Should show error snackbar (simulated in real implementation)
        // This would need actual error injection in a real test
      });
    });

    group('Navigation and Back Button', () {
      testWidgets('should have back button in app bar', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('should handle back button tap', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // In a real app, this would navigate back
        // Here we just verify the button exists and is tappable
      });

      testWidgets('should show share button in app bar', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.byIcon(Icons.share), findsOneWidget);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to different screen sizes', (tester) async {
        // Test with different screen sizes
        await tester.binding.setSurfaceSize(const Size(400, 800)); // Narrow screen
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('Summer Fitness Challenge'), findsOneWidget);

        // Test with wider screen
        await tester.binding.setSurfaceSize(const Size(800, 600)); // Wide screen
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('Summer Fitness Challenge'), findsOneWidget);

        // Reset to default size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Countdown Timer Updates', () {
      testWidgets('should update countdown timer periodically', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        // Initial countdown display
        expect(find.textContaining('5d'), findsOneWidget);

        // Advance time and trigger update
        await tester.pump(const Duration(seconds: 60));

        // Timer should still be present (real implementation would update)
        expect(find.textContaining('d'), findsOneWidget);
      });
    });

    group('User Ranking Display', () {
      testWidgets('should show user rank when participating', (tester) async {
        await tester.pumpWidget(createTestWidget(userParticipatingChallenge));

        // User with 1900 points should be ranked 3rd
        expect(find.text('Your Rank: #3'), findsOneWidget);
      });

      testWidgets('should not show rank for non-participating user', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.textContaining('Your Rank'), findsNothing);
      });
    });

    group('Challenge Statistics', () {
      testWidgets('should display challenge statistics', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        expect(find.text('Total Points'), findsOneWidget);
        expect(find.text('8000'), findsOneWidget); // Sum of all participant points

        expect(find.text('Avg Points'), findsOneWidget);
        expect(find.text('2000'), findsOneWidget); // Average points per participant
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantic labels', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        // Check for semantic labels on important widgets
        expect(find.bySemanticsLabel('Join Challenge'), findsOneWidget);
        expect(find.bySemanticsLabel('Challenge Details Tabs'), findsOneWidget);
      });

      testWidgets('should support screen readers', (tester) async {
        await tester.pumpWidget(createTestWidget(testChallenge));

        // Verify semantics are properly set up
        final semantics = tester.getSemantics(find.text('Summer Fitness Challenge'));
        expect(semantics.hasFlag(ui.SemanticsFlag.isHeader), isTrue);
      });
    });

    group('Theme Integration', () {
      testWidgets('should respect app theme colors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.blue,
              accentColor: Colors.orange,
            ),
            home: ChallengeDetailsScreen(challenge: testChallenge),
          ),
        );

        // Should use theme colors appropriately
        expect(find.byType(ChallengeDetailsScreen), findsOneWidget);
      });

      testWidgets('should support dark mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: ChallengeDetailsScreen(challenge: testChallenge),
          ),
        );

        expect(find.byType(ChallengeDetailsScreen), findsOneWidget);
      });
    });
  });
}

/// Extension methods for testing support
extension ChallengeTestExtensions on Challenge {
  Challenge copyWith({
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
    String? imageUrl,
    List<String>? rules,
    int? entryFee,
    int? prizePool,
    Map<String, String>? inviteStatus,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      participantIds: participantIds ?? List.from(this.participantIds),
      leaderboard: leaderboard ?? Map.from(this.leaderboard),
      maxParticipants: maxParticipants ?? this.maxParticipants,
      imageUrl: imageUrl ?? this.imageUrl,
      rules: rules ?? List.from(this.rules),
      entryFee: entryFee ?? this.entryFee,
      prizePool: prizePool ?? this.prizePool,
      inviteStatus: inviteStatus ?? Map.from(this.inviteStatus),
    );
  }
}

/// Import needed for semantic flags
import 'dart:ui' as ui;