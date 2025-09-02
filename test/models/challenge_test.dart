/// Comprehensive unit tests for Challenge and RivalSession models.
/// 
/// This test suite covers all model functionality including:
/// - Challenge creation, validation, and computed properties
/// - RivalSession management and utility methods
/// - Time calculations and formatting
/// - Leaderboard sorting and ranking logic
/// - Status and type display methods

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:rivalx/models/challenge.dart';
import 'package:rivalx/models/user_model.dart';

void main() {
  group('Challenge Model', () {
    late Challenge testChallenge;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      testChallenge = Challenge(
        id: 'challenge_1',
        name: 'Test Challenge',
        description: 'A comprehensive test challenge',
        type: ChallengeType.public,
        status: ChallengeStatus.active,
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        creatorId: 'creator_123',
        creatorName: 'Test Creator',
        participantIds: ['user1', 'user2', 'user3'],
        leaderboard: {
          'user1': 1500,
          'user2': 1200,
          'user3': 800,
        },
        rules: ['Rule 1', 'Rule 2', 'Rule 3'],
        maxParticipants: 100,
        entryFee: 50,
        prizePool: 1000,
      );
    });

    group('Basic Properties', () {
      test('should create challenge with all required properties', () {
        expect(testChallenge.id, equals('challenge_1'));
        expect(testChallenge.name, equals('Test Challenge'));
        expect(testChallenge.description, equals('A comprehensive test challenge'));
        expect(testChallenge.type, equals(ChallengeType.public));
        expect(testChallenge.status, equals(ChallengeStatus.active));
        expect(testChallenge.creatorId, equals('creator_123'));
        expect(testChallenge.creatorName, equals('Test Creator'));
        expect(testChallenge.participantIds, hasLength(3));
        expect(testChallenge.leaderboard, hasLength(3));
        expect(testChallenge.rules, hasLength(3));
        expect(testChallenge.maxParticipants, equals(100));
        expect(testChallenge.entryFee, equals(50));
        expect(testChallenge.prizePool, equals(1000));
      });

      test('should handle optional properties with defaults', () {
        final minimalChallenge = Challenge(
          id: 'minimal',
          name: 'Minimal Challenge',
          description: 'Simple challenge',
          type: ChallengeType.private,
          status: ChallengeStatus.upcoming,
          startDate: now,
          endDate: now.add(const Duration(days: 1)),
          creatorId: 'creator',
          creatorName: 'Creator',
          participantIds: [],
          leaderboard: {},
          rules: [],
        );

        expect(minimalChallenge.maxParticipants, equals(100));
        expect(minimalChallenge.imageUrl, isNull);
        expect(minimalChallenge.entryFee, equals(0));
        expect(minimalChallenge.prizePool, equals(0));
        expect(minimalChallenge.inviteStatus, isEmpty);
      });
    });

    group('Active Status', () {
      test('should return true for active challenge within time range', () {
        final activeChallenge = Challenge(
          id: 'active',
          name: 'Active Challenge',
          description: 'Currently active',
          type: ChallengeType.public,
          status: ChallengeStatus.active,
          startDate: now.subtract(const Duration(hours: 1)),
          endDate: now.add(const Duration(hours: 1)),
          creatorId: 'creator',
          creatorName: 'Creator',
          participantIds: [],
          leaderboard: {},
          rules: [],
        );

        expect(activeChallenge.isActive, isTrue);
      });

      test('should return false for challenge not yet started', () {
        final futureChallenge = Challenge(
          id: 'future',
          name: 'Future Challenge',
          description: 'Starts in the future',
          type: ChallengeType.public,
          status: ChallengeStatus.upcoming,
          startDate: now.add(const Duration(hours: 1)),
          endDate: now.add(const Duration(hours: 2)),
          creatorId: 'creator',
          creatorName: 'Creator',
          participantIds: [],
          leaderboard: {},
          rules: [],
        );

        expect(futureChallenge.isActive, isFalse);
      });

      test('should return false for challenge that has ended', () {
        final pastChallenge = Challenge(
          id: 'past',
          name: 'Past Challenge',
          description: 'Already ended',
          type: ChallengeType.public,
          status: ChallengeStatus.completed,
          startDate: now.subtract(const Duration(hours: 2)),
          endDate: now.subtract(const Duration(hours: 1)),
          creatorId: 'creator',
          creatorName: 'Creator',
          participantIds: [],
          leaderboard: {},
          rules: [],
        );

        expect(pastChallenge.isActive, isFalse);
      });
    });

    group('Remaining Time', () {
      test('should calculate remaining time correctly for active challenge', () {
        final remainingTime = testChallenge.remainingTime;
        expect(remainingTime.inDays, equals(5));
        expect(remainingTime.isNegative, isFalse);
      });

      test('should return zero duration for completed challenge', () {
        final completed = testChallenge.copyWith(status: ChallengeStatus.completed);
        expect(completed.remainingTime, equals(Duration.zero));
      });

      test('should format remaining time correctly for days and hours', () {
        final formatted = testChallenge.remainingTimeFormatted;
        expect(formatted, matches(RegExp(r'\d+d \d+h')));
      });

      test('should format remaining time for hours only', () {
        final shortChallenge = testChallenge.copyWith(
          endDate: now.add(const Duration(hours: 3, minutes: 30)),
        );
        final formatted = shortChallenge.remainingTimeFormatted;
        expect(formatted, matches(RegExp(r'\d+h \d+m')));
      });

      test('should format remaining time for minutes only', () {
        final veryShortChallenge = testChallenge.copyWith(
          endDate: now.add(const Duration(minutes: 45)),
        );
        final formatted = veryShortChallenge.remainingTimeFormatted;
        expect(formatted, matches(RegExp(r'\d+m')));
      });

      test('should show "Ended" for past challenges', () {
        final pastChallenge = testChallenge.copyWith(
          endDate: now.subtract(const Duration(hours: 1)),
        );
        expect(pastChallenge.remainingTimeFormatted, equals('Ended'));
      });
    });

    group('Leaderboard Management', () {
      test('should sort leaderboard by points descending', () {
        final sorted = testChallenge.sortedLeaderboard;
        
        expect(sorted, hasLength(3));
        expect(sorted[0].key, equals('user1')); // 1500 points
        expect(sorted[0].value, equals(1500));
        expect(sorted[1].key, equals('user2')); // 1200 points
        expect(sorted[1].value, equals(1200));
        expect(sorted[2].key, equals('user3')); // 800 points
        expect(sorted[2].value, equals(800));
      });

      test('should handle tied scores in leaderboard', () {
        final tiedChallenge = testChallenge.copyWith(
          leaderboard: {
            'user1': 1000,
            'user2': 1000,
            'user3': 800,
          },
        );
        
        final sorted = tiedChallenge.sortedLeaderboard;
        expect(sorted[0].value, equals(1000));
        expect(sorted[1].value, equals(1000));
        expect(sorted[2].value, equals(800));
      });

      test('should handle empty leaderboard', () {
        final emptyChallenge = testChallenge.copyWith(leaderboard: {});
        final sorted = emptyChallenge.sortedLeaderboard;
        expect(sorted, isEmpty);
      });
    });

    group('User Ranking', () {
      test('should return correct rank for existing user', () {
        expect(testChallenge.getUserRank('user1'), equals(1));
        expect(testChallenge.getUserRank('user2'), equals(2));
        expect(testChallenge.getUserRank('user3'), equals(3));
      });

      test('should return -1 for non-participating user', () {
        expect(testChallenge.getUserRank('non_participant'), equals(-1));
      });

      test('should handle tied ranks correctly', () {
        final tiedChallenge = testChallenge.copyWith(
          leaderboard: {
            'user1': 1000,
            'user2': 1000,
            'user3': 800,
          },
        );
        
        // Both users with 1000 points should get rank 1 or 2
        final user1Rank = tiedChallenge.getUserRank('user1');
        final user2Rank = tiedChallenge.getUserRank('user2');
        final user3Rank = tiedChallenge.getUserRank('user3');
        
        expect([1, 2], contains(user1Rank));
        expect([1, 2], contains(user2Rank));
        expect(user3Rank, equals(3));
      });
    });

    group('Type Display Properties', () {
      test('should return correct display name for challenge types', () {
        expect(testChallenge.typeDisplayName, equals('Public Challenge'));
        
        final privateChallenge = testChallenge.copyWith(type: ChallengeType.private);
        expect(privateChallenge.typeDisplayName, equals('Private Challenge'));
        
        final dailyChallenge = testChallenge.copyWith(type: ChallengeType.daily);
        expect(dailyChallenge.typeDisplayName, equals('Daily Challenge'));
      });

      test('should return correct icon for challenge types', () {
        expect(testChallenge.typeIcon, equals(Icons.public));
        
        final privateChallenge = testChallenge.copyWith(type: ChallengeType.private);
        expect(privateChallenge.typeIcon, equals(Icons.lock));
        
        final dailyChallenge = testChallenge.copyWith(type: ChallengeType.daily);
        expect(dailyChallenge.typeIcon, equals(Icons.today));
      });
    });

    group('Status Display Properties', () {
      test('should return correct color for challenge status', () {
        expect(testChallenge.statusColor, equals(Colors.green));
        
        final upcomingChallenge = testChallenge.copyWith(status: ChallengeStatus.upcoming);
        expect(upcomingChallenge.statusColor, equals(Colors.blue));
        
        final completedChallenge = testChallenge.copyWith(status: ChallengeStatus.completed);
        expect(completedChallenge.statusColor, equals(Colors.grey));
      });
    });
  });

  group('RivalSession Model', () {
    late RivalSession testRivalSession;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      testRivalSession = RivalSession(
        id: 'rival_1',
        userId1: 'user_123',
        userId2: 'user_456',
        user1Name: 'John Doe',
        user2Name: 'Jane Smith',
        user1Avatar: 'avatar1.jpg',
        user2Avatar: 'avatar2.jpg',
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        user1Points: 850,
        user2Points: 720,
        isActive: true,
        wagerAmount: 200,
        activities: {
          'user_123': ['Workout 1', 'Workout 2'],
          'user_456': ['Workout A', 'Workout B', 'Workout C'],
        },
      );
    });

    group('Basic Properties', () {
      test('should create rival session with all properties', () {
        expect(testRivalSession.id, equals('rival_1'));
        expect(testRivalSession.userId1, equals('user_123'));
        expect(testRivalSession.userId2, equals('user_456'));
        expect(testRivalSession.user1Name, equals('John Doe'));
        expect(testRivalSession.user2Name, equals('Jane Smith'));
        expect(testRivalSession.user1Points, equals(850));
        expect(testRivalSession.user2Points, equals(720));
        expect(testRivalSession.isActive, isTrue);
        expect(testRivalSession.wagerAmount, equals(200));
        expect(testRivalSession.activities, hasLength(2));
      });

      test('should handle optional properties with defaults', () {
        final minimalSession = RivalSession(
          id: 'minimal',
          userId1: 'user1',
          userId2: 'user2',
          user1Name: 'User 1',
          user2Name: 'User 2',
          startDate: now,
          endDate: now.add(const Duration(days: 1)),
          isActive: true,
        );

        expect(minimalSession.user1Avatar, isNull);
        expect(minimalSession.user2Avatar, isNull);
        expect(minimalSession.user1Points, equals(0));
        expect(minimalSession.user2Points, equals(0));
        expect(minimalSession.winnerId, isNull);
        expect(minimalSession.wagerAmount, equals(0));
        expect(minimalSession.activities, isEmpty);
      });
    });

    group('Opponent Methods', () {
      test('should return correct opponent ID', () {
        expect(testRivalSession.getOpponentId('user_123'), equals('user_456'));
        expect(testRivalSession.getOpponentId('user_456'), equals('user_123'));
      });

      test('should return correct opponent name', () {
        expect(testRivalSession.getOpponentName('user_123'), equals('Jane Smith'));
        expect(testRivalSession.getOpponentName('user_456'), equals('John Doe'));
      });
    });

    group('Point Management', () {
      test('should return correct user points', () {
        expect(testRivalSession.getUserPoints('user_123'), equals(850));
        expect(testRivalSession.getUserPoints('user_456'), equals(720));
      });

      test('should return correct opponent points', () {
        expect(testRivalSession.getOpponentPoints('user_123'), equals(720));
        expect(testRivalSession.getOpponentPoints('user_456'), equals(850));
      });

      test('should correctly identify winning user', () {
        expect(testRivalSession.isUserWinning('user_123'), isTrue);
        expect(testRivalSession.isUserWinning('user_456'), isFalse);
      });

      test('should handle tied scores', () {
        final tiedSession = testRivalSession.copyWith(
          user1Points: 500,
          user2Points: 500,
        );

        expect(tiedSession.isUserWinning('user_123'), isFalse);
        expect(tiedSession.isUserWinning('user_456'), isFalse);
      });

      test('should calculate point difference correctly', () {
        expect(testRivalSession.getPointDifference('user_123'), equals(130)); // 850 - 720
        expect(testRivalSession.getPointDifference('user_456'), equals(-130)); // 720 - 850
      });
    });

    group('Time Management', () {
      test('should calculate remaining time for active session', () {
        final remainingTime = testRivalSession.remainingTime;
        expect(remainingTime.inDays, equals(5));
        expect(remainingTime.isNegative, isFalse);
      });

      test('should return zero duration for inactive session', () {
        final inactiveSession = testRivalSession.copyWith(isActive: false);
        expect(inactiveSession.remainingTime, equals(Duration.zero));
      });

      test('should format remaining time correctly for days', () {
        final formatted = testRivalSession.remainingTimeFormatted;
        expect(formatted, equals('5 days'));
      });

      test('should format remaining time for hours', () {
        final shortSession = testRivalSession.copyWith(
          endDate: now.add(const Duration(hours: 3)),
        );
        final formatted = shortSession.remainingTimeFormatted;
        expect(formatted, equals('3 hours'));
      });

      test('should format remaining time for minutes', () {
        final veryShortSession = testRivalSession.copyWith(
          endDate: now.add(const Duration(minutes: 45)),
        );
        final formatted = veryShortSession.remainingTimeFormatted;
        expect(formatted, equals('45 minutes'));
      });

      test('should show "Ended" for past sessions', () {
        final pastSession = testRivalSession.copyWith(
          endDate: now.subtract(const Duration(hours: 1)),
        );
        expect(pastSession.remainingTimeFormatted, equals('Ended'));
      });
    });
  });

  group('Friend Model', () {
    late Friend testFriend;

    setUp(() {
      testFriend = Friend(
        id: 'friend_1',
        username: 'testuser123',
        displayName: 'John Doe',
        email: 'john.doe@example.com',
        avatarUrl: 'https://example.com/avatar.jpg',
        currentRank: RankLevel.B,
        totalPoints: 12500,
        weeklyPoints: 450,
        fitnessLevel: FitnessLevel.advanced,
        isOnline: true,
        lastActive: DateTime.now().subtract(const Duration(minutes: 15)),
        wins: 8,
        losses: 3,
        currentStreak: 5,
      );
    });

    group('Basic Properties', () {
      test('should create friend with all properties', () {
        expect(testFriend.id, equals('friend_1'));
        expect(testFriend.username, equals('testuser123'));
        expect(testFriend.displayName, equals('John Doe'));
        expect(testFriend.email, equals('john.doe@example.com'));
        expect(testFriend.currentRank, equals(RankLevel.B));
        expect(testFriend.totalPoints, equals(12500));
        expect(testFriend.weeklyPoints, equals(450));
        expect(testFriend.wins, equals(8));
        expect(testFriend.losses, equals(3));
        expect(testFriend.currentStreak, equals(5));
      });
    });

    group('Computed Properties', () {
      test('should generate correct initials from display name', () {
        expect(testFriend.initials, equals('JD'));
        
        final singleName = testFriend.copyWith(displayName: 'Madonna');
        expect(singleName.initials, equals('M'));
        
        final emptyName = testFriend.copyWith(displayName: '');
        expect(emptyName.initials, equals('U'));
      });

      test('should determine correct skill level based on points', () {
        expect(testFriend.skillLevel, equals('Intermediate')); // 12500 points
        
        final expertFriend = testFriend.copyWith(totalPoints: 35000);
        expect(expertFriend.skillLevel, equals('Expert'));
        
        final beginnerFriend = testFriend.copyWith(totalPoints: 2000);
        expect(beginnerFriend.skillLevel, equals('Beginner'));
        
        final newcomerFriend = testFriend.copyWith(totalPoints: 500);
        expect(newcomerFriend.skillLevel, equals('Newcomer'));
      });

      test('should calculate win rate correctly', () {
        expect(testFriend.winRate, closeTo(72.73, 0.01)); // 8/(8+3) * 100
        
        final perfectRecord = testFriend.copyWith(wins: 10, losses: 0);
        expect(perfectRecord.winRate, equals(100.0));
        
        final noGames = testFriend.copyWith(wins: 0, losses: 0);
        expect(noGames.winRate, equals(0.0));
      });

      test('should format last active time correctly', () {
        final now = DateTime.now();
        
        final justActive = testFriend.copyWith(
          lastActive: now.subtract(const Duration(minutes: 2)),
        );
        expect(justActive.lastActiveFormatted, equals('Active now'));
        
        final minutesAgo = testFriend.copyWith(
          lastActive: now.subtract(const Duration(minutes: 30)),
        );
        expect(minutesAgo.lastActiveFormatted, equals('30m ago'));
        
        final hoursAgo = testFriend.copyWith(
          lastActive: now.subtract(const Duration(hours: 5)),
        );
        expect(hoursAgo.lastActiveFormatted, equals('5h ago'));
        
        final daysAgo = testFriend.copyWith(
          lastActive: now.subtract(const Duration(days: 3)),
        );
        expect(daysAgo.lastActiveFormatted, equals('3d ago'));
        
        final weeksAgo = testFriend.copyWith(
          lastActive: now.subtract(const Duration(days: 10)),
        );
        expect(weeksAgo.lastActiveFormatted, equals('1w ago'));
      });
    });
  });

  group('ChallengeInvitation Model', () {
    late ChallengeInvitation testInvitation;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      testInvitation = ChallengeInvitation(
        id: 'invite_1',
        senderId: 'sender_123',
        senderName: 'Sender User',
        receiverId: 'receiver_456',
        receiverName: 'Receiver User',
        challengeType: RivalChallengeType.general,
        duration: 7,
        wagerAmount: 200,
        personalMessage: 'Let\'s compete!',
        status: InvitationStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
        expiresAt: now.add(const Duration(days: 1)),
      );
    });

    group('Basic Properties', () {
      test('should create invitation with all properties', () {
        expect(testInvitation.id, equals('invite_1'));
        expect(testInvitation.senderId, equals('sender_123'));
        expect(testInvitation.senderName, equals('Sender User'));
        expect(testInvitation.receiverId, equals('receiver_456'));
        expect(testInvitation.receiverName, equals('Receiver User'));
        expect(testInvitation.challengeType, equals(RivalChallengeType.general));
        expect(testInvitation.duration, equals(7));
        expect(testInvitation.wagerAmount, equals(200));
        expect(testInvitation.personalMessage, equals('Let\'s compete!'));
        expect(testInvitation.status, equals(InvitationStatus.pending));
      });
    });

    group('Expiration Management', () {
      test('should correctly identify non-expired invitation', () {
        expect(testInvitation.isExpired, isFalse);
      });

      test('should correctly identify expired invitation', () {
        final expiredInvitation = testInvitation.copyWith(
          expiresAt: now.subtract(const Duration(hours: 1)),
        );
        expect(expiredInvitation.isExpired, isTrue);
      });

      test('should handle null expiration date', () {
        final noExpiryInvitation = testInvitation.copyWith(expiresAt: null);
        expect(noExpiryInvitation.isExpired, isFalse);
      });

      test('should calculate time remaining correctly', () {
        final timeRemaining = testInvitation.timeRemaining;
        expect(timeRemaining.inHours, closeTo(24, 1)); // Approximately 1 day
        expect(timeRemaining.isNegative, isFalse);
      });

      test('should return zero for expired invitations', () {
        final expiredInvitation = testInvitation.copyWith(
          expiresAt: now.subtract(const Duration(hours: 1)),
        );
        expect(expiredInvitation.timeRemaining, equals(Duration.zero));
      });

      test('should format time remaining correctly', () {
        final formatted = testInvitation.timeRemainingFormatted;
        expect(formatted, matches(RegExp(r'\d+d \d+h')));
        
        final shortInvitation = testInvitation.copyWith(
          expiresAt: now.add(const Duration(hours: 2, minutes: 30)),
        );
        expect(shortInvitation.timeRemainingFormatted, matches(RegExp(r'\d+h \d+m')));
        
        final veryShortInvitation = testInvitation.copyWith(
          expiresAt: now.add(const Duration(minutes: 45)),
        );
        expect(veryShortInvitation.timeRemainingFormatted, matches(RegExp(r'\d+m')));
        
        final expiredInvitation = testInvitation.copyWith(
          expiresAt: now.subtract(const Duration(hours: 1)),
        );
        expect(expiredInvitation.timeRemainingFormatted, equals('Expired'));
      });
    });

    group('Display Properties', () {
      test('should return correct challenge type display names', () {
        expect(testInvitation.challengeTypeDisplayName, equals('General Fitness'));
        
        final strengthInvitation = testInvitation.copyWith(
          challengeType: RivalChallengeType.strength,
        );
        expect(strengthInvitation.challengeTypeDisplayName, equals('Strength Training'));
        
        final cardioInvitation = testInvitation.copyWith(
          challengeType: RivalChallengeType.cardio,
        );
        expect(cardioInvitation.challengeTypeDisplayName, equals('Cardio & Endurance'));
        
        final customInvitation = testInvitation.copyWith(
          challengeType: RivalChallengeType.custom,
        );
        expect(customInvitation.challengeTypeDisplayName, equals('Custom Challenge'));
      });

      test('should return correct challenge type icons', () {
        expect(testInvitation.challengeTypeIcon, equals(Icons.fitness_center));
        
        final strengthInvitation = testInvitation.copyWith(
          challengeType: RivalChallengeType.strength,
        );
        expect(strengthInvitation.challengeTypeIcon, equals(Icons.sports_gymnastics));
        
        final cardioInvitation = testInvitation.copyWith(
          challengeType: RivalChallengeType.cardio,
        );
        expect(cardioInvitation.challengeTypeIcon, equals(Icons.directions_run));
        
        final customInvitation = testInvitation.copyWith(
          challengeType: RivalChallengeType.custom,
        );
        expect(customInvitation.challengeTypeIcon, equals(Icons.star));
      });

      test('should format duration correctly', () {
        expect(testInvitation.durationFormatted, equals('7 days'));
        
        final oneDayInvitation = testInvitation.copyWith(duration: 1);
        expect(oneDayInvitation.durationFormatted, equals('1 day'));
        
        final oneWeekInvitation = testInvitation.copyWith(duration: 7);
        expect(oneWeekInvitation.durationFormatted, equals('7 days'));
        
        final twoWeeksInvitation = testInvitation.copyWith(duration: 14);
        expect(twoWeeksInvitation.durationFormatted, equals('2 weeks'));
        
        final customDurationInvitation = testInvitation.copyWith(duration: 10);
        expect(customDurationInvitation.durationFormatted, equals('10 days'));
      });
    });
  });

  group('Service Classes', () {
    group('ChallengeService', () {
      setUp(() {
        // Clear any existing mock data
        ChallengeService.addMockData();
      });

      test('should get all challenges', () {
        final challenges = ChallengeService.getAllChallenges();
        expect(challenges, isNotEmpty);
        expect(challenges.any((c) => c.name.contains('Summer Shred')), isTrue);
      });

      test('should get active challenges only', () {
        final activeChallenges = ChallengeService.getActiveChallenges();
        expect(activeChallenges.every((c) => c.status == ChallengeStatus.active), isTrue);
      });

      test('should get user challenges correctly', () {
        final userChallenges = ChallengeService.getUserChallenges('user1');
        expect(userChallenges.every((c) => c.participantIds.contains('user1')), isTrue);
      });

      test('should create new challenge', () {
        final initialCount = ChallengeService.getAllChallenges().length;
        
        final newChallenge = Challenge(
          id: 'new_challenge',
          name: 'New Test Challenge',
          description: 'A test challenge',
          type: ChallengeType.public,
          status: ChallengeStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          creatorId: 'creator',
          creatorName: 'Creator',
          participantIds: [],
          leaderboard: {},
          rules: [],
        );
        
        ChallengeService.createChallenge(newChallenge);
        
        final finalCount = ChallengeService.getAllChallenges().length;
        expect(finalCount, equals(initialCount + 1));
      });

      test('should join challenge correctly', () {
        final challenges = ChallengeService.getAllChallenges();
        final challenge = challenges.first;
        final initialParticipants = challenge.participantIds.length;
        
        ChallengeService.joinChallenge(challenge.id, 'new_user');
        
        final updatedChallenges = ChallengeService.getAllChallenges();
        final updatedChallenge = updatedChallenges.firstWhere((c) => c.id == challenge.id);
        
        expect(updatedChallenge.participantIds.length, equals(initialParticipants + 1));
        expect(updatedChallenge.participantIds.contains('new_user'), isTrue);
        expect(updatedChallenge.leaderboard.containsKey('new_user'), isTrue);
        expect(updatedChallenge.leaderboard['new_user'], equals(0));
      });

      test('should get active rival session', () {
        final rivalSession = ChallengeService.getActiveRivalSession('123');
        expect(rivalSession, isNotNull);
        expect(rivalSession!.isActive, isTrue);
        expect([rivalSession.userId1, rivalSession.userId2], contains('123'));
      });

      test('should return null for user with no active rival session', () {
        final rivalSession = ChallengeService.getActiveRivalSession('non_existent');
        expect(rivalSession, isNull);
      });

      test('should create rival session', () {
        final newRivalSession = RivalSession(
          id: 'new_rival',
          userId1: 'user_a',
          userId2: 'user_b',
          user1Name: 'User A',
          user2Name: 'User B',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          isActive: true,
        );
        
        ChallengeService.createRivalSession(newRivalSession);
        
        final retrievedSession = ChallengeService.getActiveRivalSession('user_a');
        expect(retrievedSession, isNotNull);
        expect(retrievedSession!.id, equals('new_rival'));
      });
    });

    group('FriendService', () {
      setUp(() {
        FriendService.addMockData();
      });

      test('should get all friends', () {
        final friends = FriendService.getAllFriends('current_user');
        expect(friends, isNotEmpty);
        expect(friends.any((f) => f.username == 'fitnessguru22'), isTrue);
      });

      test('should search friends by query', () {
        final results = FriendService.searchFriends('cardio');
        expect(results.any((f) => f.username.contains('cardio')), isTrue);
      });

      test('should return all friends for empty query', () {
        final results = FriendService.searchFriends('');
        expect(results.length, equals(FriendService.getAllFriends('current_user').length));
      });

      test('should get suggested friends', () {
        final suggestions = FriendService.getSuggestedFriends('current_user');
        expect(suggestions, isNotEmpty);
        expect(suggestions.length, lessThanOrEqualTo(5));
        // Should suggest friends with reasonable skill levels
        expect(suggestions.every((f) => f.totalPoints >= 1000 && f.totalPoints <= 10000), isTrue);
      });

      test('should get recent rivals', () {
        final recentRivals = FriendService.getRecentRivals('current_user');
        expect(recentRivals, isNotEmpty);
        expect(recentRivals.length, lessThanOrEqualTo(3));
        // Should return friends active within the last week
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        expect(recentRivals.every((f) => f.lastActive.isAfter(weekAgo)), isTrue);
      });

      test('should get sent invitations', () {
        final sentInvitations = FriendService.getSentInvitations('123');
        expect(sentInvitations.every((inv) => inv.senderId == '123'), isTrue);
        expect(sentInvitations.every((inv) => inv.status == InvitationStatus.pending), isTrue);
      });

      test('should get received invitations', () {
        final receivedInvitations = FriendService.getReceivedInvitations('123');
        expect(receivedInvitations.every((inv) => inv.receiverId == '123'), isTrue);
        expect(receivedInvitations.every((inv) => inv.status == InvitationStatus.pending), isTrue);
      });
    });
  });
}

/// Extension methods to support copyWith for testing
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

extension RivalSessionTestExtensions on RivalSession {
  RivalSession copyWith({
    String? id,
    String? userId1,
    String? userId2,
    String? user1Name,
    String? user2Name,
    String? user1Avatar,
    String? user2Avatar,
    DateTime? startDate,
    DateTime? endDate,
    int? user1Points,
    int? user2Points,
    bool? isActive,
    String? winnerId,
    int? wagerAmount,
    Map<String, List<String>>? activities,
  }) {
    return RivalSession(
      id: id ?? this.id,
      userId1: userId1 ?? this.userId1,
      userId2: userId2 ?? this.userId2,
      user1Name: user1Name ?? this.user1Name,
      user2Name: user2Name ?? this.user2Name,
      user1Avatar: user1Avatar ?? this.user1Avatar,
      user2Avatar: user2Avatar ?? this.user2Avatar,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      user1Points: user1Points ?? this.user1Points,
      user2Points: user2Points ?? this.user2Points,
      isActive: isActive ?? this.isActive,
      winnerId: winnerId ?? this.winnerId,
      wagerAmount: wagerAmount ?? this.wagerAmount,
      activities: activities ?? Map.from(this.activities),
    );
  }
}

extension FriendTestExtensions on Friend {
  Friend copyWith({
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
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentRank: currentRank ?? this.currentRank,
      totalPoints: totalPoints ?? this.totalPoints,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}

extension ChallengeInvitationTestExtensions on ChallengeInvitation {
  ChallengeInvitation copyWith({
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
    DateTime? respondedAt,
    DateTime? expiresAt,
  }) {
    return ChallengeInvitation(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      challengeType: challengeType ?? this.challengeType,
      duration: duration ?? this.duration,
      wagerAmount: wagerAmount ?? this.wagerAmount,
      personalMessage: personalMessage ?? this.personalMessage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}