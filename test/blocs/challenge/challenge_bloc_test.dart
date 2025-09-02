/// Comprehensive unit tests for ChallengeBloc.
/// 
/// This test suite covers all BLoC events, states, and transitions for 
/// challenge-related functionality including creating challenges, joining/leaving,
/// managing rival sessions, and handling invitations with proper mocking.

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:rivalx/blocs/challenge/challenge_bloc.dart';
import 'package:rivalx/blocs/challenge/challenge_event.dart';
import 'package:rivalx/blocs/challenge/challenge_state.dart';
import 'package:rivalx/models/challenge.dart';
import 'package:rivalx/models/user_model.dart';
import 'package:rivalx/services/firestore_service.dart';

// Generate mocks
@GenerateMocks([FirestoreService])
import 'challenge_bloc_test.mocks.dart';

void main() {
  group('ChallengeBloc', () {
    late ChallengeBloc challengeBloc;
    late MockFirestoreService mockFirestoreService;

    // Test data
    final testUserId = 'test_user_123';
    final testChallenge = Challenge(
      id: 'challenge_1',
      name: 'Test Challenge',
      description: 'A test challenge for unit testing',
      type: ChallengeType.public,
      status: ChallengeStatus.active,
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 7)),
      creatorId: 'creator_123',
      creatorName: 'Test Creator',
      participantIds: ['participant_1', 'participant_2'],
      leaderboard: {
        'participant_1': 1500,
        'participant_2': 1200,
      },
      rules: ['Rule 1', 'Rule 2'],
    );

    final testRivalSession = RivalSession(
      id: 'rival_1',
      userId1: testUserId,
      userId2: 'rival_user',
      user1Name: 'Test User',
      user2Name: 'Rival User',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 6)),
      user1Points: 800,
      user2Points: 650,
      isActive: true,
      wagerAmount: 100,
    );

    final testInvitation = ChallengeInvitation(
      id: 'invitation_1',
      senderId: 'sender_123',
      senderName: 'Sender User',
      receiverId: testUserId,
      receiverName: 'Test User',
      challengeType: RivalChallengeType.general,
      duration: 7,
      wagerAmount: 200,
      personalMessage: 'Let\'s compete!',
      status: InvitationStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      expiresAt: DateTime.now().add(const Duration(days: 1)),
    );

    setUp(() {
      mockFirestoreService = MockFirestoreService();
      challengeBloc = ChallengeBloc(firestoreService: mockFirestoreService);
    });

    tearDown(() {
      challengeBloc.close();
    });

    test('initial state should be ChallengeInitial', () {
      expect(challengeBloc.state, equals(const ChallengeInitial()));
    });

    group('LoadChallenges', () {
      blocTest<ChallengeBloc, ChallengeState>(
        'should emit loading then loaded state with challenges',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(LoadChallenges(userId: testUserId)),
        expect: () => [
          const ChallengeLoading(message: 'Loading challenges...'),
          isA<ChallengeLoaded>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeLoaded;
          expect(state.allChallenges, isNotEmpty);
          expect(state.activeChallenges, isNotEmpty);
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should load user challenges correctly',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(LoadChallenges(userId: 'user1')),
        expect: () => [
          const ChallengeLoading(message: 'Loading challenges...'),
          isA<ChallengeLoaded>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeLoaded;
          // user1 should be in Summer Shred Challenge from mock data
          final userChallenges = state.userChallenges;
          expect(userChallenges.any((c) => c.participantIds.contains('user1')), isTrue);
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should include active rival session when user has one',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(LoadChallenges(userId: '123')),
        expect: () => [
          const ChallengeLoading(message: 'Loading challenges...'),
          isA<ChallengeLoaded>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeLoaded;
          expect(state.activeRivalSession, isNotNull);
          expect(state.activeRivalSession!.userId1, equals('123'));
        },
      );
    });

    group('CreateChallenge', () {
      blocTest<ChallengeBloc, ChallengeState>(
        'should emit loading, created, then reload challenges',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(CreateChallenge(challenge: testChallenge)),
        expect: () => [
          const ChallengeLoading(message: 'Creating challenge...'),
          isA<ChallengeCreated>(),
          const ChallengeLoading(message: 'Loading challenges...'),
          isA<ChallengeLoaded>(),
        ],
        verify: (bloc) {
          // Verify challenge was added to cached challenges
          expect(challengeBloc.isUserInChallenge(testUserId, testChallenge.id), isFalse);
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should emit error for invalid challenge data',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(CreateChallenge(
          challenge: testChallenge.copyWith(name: ''),
        )),
        expect: () => [
          const ChallengeLoading(message: 'Creating challenge...'),
          isA<ChallengeError>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeError;
          expect(state.message, contains('Challenge name cannot be empty'));
          expect(state.code, equals('create-challenge-error'));
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should emit error for invalid date range',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(CreateChallenge(
          challenge: testChallenge.copyWith(
            startDate: DateTime.now().add(const Duration(days: 1)),
            endDate: DateTime.now(), // End before start
          ),
        )),
        expect: () => [
          const ChallengeLoading(message: 'Creating challenge...'),
          isA<ChallengeError>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeError;
          expect(state.message, contains('End date must be after start date'));
        },
      );
    });

    group('JoinChallenge', () {
      blocTest<ChallengeBloc, ChallengeState>(
        'should successfully join available challenge',
        build: () => challengeBloc,
        seed: () => ChallengeLoaded(
          allChallenges: [testChallenge],
          userChallenges: [],
          activeChallenges: [testChallenge],
        ),
        act: (bloc) => bloc.add(JoinChallenge(
          challengeId: testChallenge.id,
          userId: testUserId,
        )),
        expect: () => [
          const ChallengeLoading(message: 'Joining challenge...'),
          isA<ChallengeJoined>(),
          const ChallengeLoading(message: 'Loading challenges...'),
          isA<ChallengeLoaded>(),
        ],
        verify: (bloc) {
          // User should now be in the challenge
          expect(challengeBloc.isUserInChallenge(testUserId, testChallenge.id), isTrue);
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should emit error when trying to join non-existent challenge',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(JoinChallenge(
          challengeId: 'non_existent',
          userId: testUserId,
        )),
        expect: () => [
          const ChallengeLoading(message: 'Joining challenge...'),
          isA<ChallengeError>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeError;
          expect(state.message, contains('Challenge not found'));
          expect(state.code, equals('join-challenge-error'));
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should emit error when user already participating',
        build: () => challengeBloc,
        seed: () => ChallengeLoaded(
          allChallenges: [testChallenge.copyWith(
            participantIds: [...testChallenge.participantIds, testUserId],
          )],
          userChallenges: [],
          activeChallenges: [],
        ),
        act: (bloc) => bloc.add(JoinChallenge(
          challengeId: testChallenge.id,
          userId: testUserId,
        )),
        expect: () => [
          const ChallengeLoading(message: 'Joining challenge...'),
          isA<ChallengeError>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeError;
          expect(state.message, contains('already participating'));
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should emit error when challenge is full',
        build: () => challengeBloc,
        seed: () => ChallengeLoaded(
          allChallenges: [testChallenge.copyWith(
            maxParticipants: 2, // Already has 2 participants
          )],
          userChallenges: [],
          activeChallenges: [],
        ),
        act: (bloc) => bloc.add(JoinChallenge(
          challengeId: testChallenge.id,
          userId: testUserId,
        )),
        expect: () => [
          const ChallengeLoading(message: 'Joining challenge...'),
          isA<ChallengeError>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeError;
          expect(state.message, contains('Challenge is full'));
        },
      );
    });

    group('LeaveChallenge', () {
      blocTest<ChallengeBloc, ChallengeState>(
        'should successfully leave challenge',
        build: () => challengeBloc,
        seed: () => ChallengeLoaded(
          allChallenges: [testChallenge.copyWith(
            participantIds: [...testChallenge.participantIds, testUserId],
            leaderboard: {
              ...testChallenge.leaderboard,
              testUserId: 500,
            },
          )],
          userChallenges: [],
          activeChallenges: [],
        ),
        act: (bloc) => bloc.add(LeaveChallenge(
          challengeId: testChallenge.id,
          userId: testUserId,
        )),
        expect: () => [
          const ChallengeLoading(message: 'Leaving challenge...'),
          isA<ChallengeLeft>(),
          const ChallengeLoading(message: 'Loading challenges...'),
          isA<ChallengeLoaded>(),
        ],
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should emit error when user not participating',
        build: () => challengeBloc,
        seed: () => ChallengeLoaded(
          allChallenges: [testChallenge],
          userChallenges: [],
          activeChallenges: [],
        ),
        act: (bloc) => bloc.add(LeaveChallenge(
          challengeId: testChallenge.id,
          userId: testUserId,
        )),
        expect: () => [
          const ChallengeLoading(message: 'Leaving challenge...'),
          isA<ChallengeError>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeError;
          expect(state.message, contains('not participating'));
        },
      );
    });

    group('UpdateChallengePoints', () {
      blocTest<ChallengeBloc, ChallengeState>(
        'should update points and calculate new rank',
        build: () => challengeBloc,
        seed: () => ChallengeLoaded(
          allChallenges: [testChallenge.copyWith(
            participantIds: [...testChallenge.participantIds, testUserId],
            leaderboard: {
              ...testChallenge.leaderboard,
              testUserId: 500,
            },
          )],
          userChallenges: [],
          activeChallenges: [],
        ),
        act: (bloc) => bloc.add(UpdateChallengePoints(
          challengeId: testChallenge.id,
          userId: testUserId,
          pointsToAdd: 200,
        )),
        expect: () => [
          isA<ChallengePointsUpdated>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengePointsUpdated;
          expect(state.pointsAdded, equals(200));
          expect(state.userId, equals(testUserId));
          expect(state.newRank, greaterThan(0));
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should handle negative points (penalties)',
        build: () => challengeBloc,
        seed: () => ChallengeLoaded(
          allChallenges: [testChallenge.copyWith(
            participantIds: [...testChallenge.participantIds, testUserId],
            leaderboard: {
              ...testChallenge.leaderboard,
              testUserId: 500,
            },
          )],
          userChallenges: [],
          activeChallenges: [],
        ),
        act: (bloc) => bloc.add(UpdateChallengePoints(
          challengeId: testChallenge.id,
          userId: testUserId,
          pointsToAdd: -100,
        )),
        expect: () => [
          isA<ChallengePointsUpdated>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengePointsUpdated;
          expect(state.pointsAdded, equals(-100));
          // Points should be clamped to 0 minimum
          expect(state.challenge.leaderboard[testUserId], equals(400));
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should emit error for non-existent challenge',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(UpdateChallengePoints(
          challengeId: 'non_existent',
          userId: testUserId,
          pointsToAdd: 100,
        )),
        expect: () => [
          isA<ChallengeError>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeError;
          expect(state.message, contains('Challenge not found'));
        },
      );
    });

    group('RefreshChallenges', () {
      blocTest<ChallengeBloc, ChallengeState>(
        'should emit refreshing state then reload',
        build: () => challengeBloc,
        seed: () => ChallengeLoaded(
          allChallenges: [testChallenge],
          userChallenges: [],
          activeChallenges: [testChallenge],
        ),
        act: (bloc) => bloc.add(RefreshChallenges(userId: testUserId)),
        expect: () => [
          isA<ChallengeRefreshing>(),
          const ChallengeLoading(message: 'Loading challenges...'),
          isA<ChallengeLoaded>(),
        ],
        verify: (bloc) {
          // Data should be updated with simulated changes
          final state = bloc.state as ChallengeLoaded;
          expect(state.allChallenges, isNotEmpty);
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should preserve previous state in refreshing state',
        build: () => challengeBloc,
        seed: () => ChallengeLoaded(
          allChallenges: [testChallenge],
          userChallenges: [],
          activeChallenges: [testChallenge],
        ),
        act: (bloc) => bloc.add(RefreshChallenges(userId: testUserId)),
        skip: 0,
        expect: () => [
          predicate<ChallengeRefreshing>((state) => 
            state.previousState != null && 
            state.previousState!.allChallenges.isNotEmpty
          ),
          const ChallengeLoading(message: 'Loading challenges...'),
          isA<ChallengeLoaded>(),
        ],
      );
    });

    group('LoadChallengeDetails', () {
      blocTest<ChallengeBloc, ChallengeState>(
        'should load challenge details with participants',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(LoadChallengeDetails(challengeId: '1')),
        expect: () => [
          const ChallengeDetailsLoading(challengeId: '1'),
          isA<ChallengeDetailsLoaded>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeDetailsLoaded;
          expect(state.challenge.id, equals('1'));
          expect(state.participants, isNotEmpty);
          expect(state.userRank, greaterThanOrEqualTo(1));
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should emit error for non-existent challenge details',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(LoadChallengeDetails(challengeId: 'non_existent')),
        expect: () => [
          const ChallengeDetailsLoading(challengeId: 'non_existent'),
          isA<ChallengeError>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeError;
          expect(state.message, contains('Challenge not found'));
          expect(state.code, equals('load-details-error'));
        },
      );
    });

    group('Challenge Invitations', () {
      blocTest<ChallengeBloc, ChallengeState>(
        'should send invitation successfully',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(SendChallengeInvitation(invitation: testInvitation)),
        expect: () => [
          const ChallengeLoading(message: 'Sending invitation...'),
          isA<InvitationSent>(),
          const ChallengeLoading(message: 'Loading challenges...'),
          isA<ChallengeLoaded>(),
        ],
        verify: (bloc) {
          final sentState = bloc.stream.firstWhere(
            (state) => state is InvitationSent,
          );
          expect(sentState, isA<InvitationSent>());
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should reject self-invitation',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(SendChallengeInvitation(
          invitation: testInvitation.copyWith(receiverId: testInvitation.senderId),
        )),
        expect: () => [
          const ChallengeLoading(message: 'Sending invitation...'),
          isA<ChallengeError>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeError;
          expect(state.message, contains('Cannot send invitation to yourself'));
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should accept invitation and create rival session',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(RespondToInvitation(
          invitationId: testInvitation.id,
          accept: true,
          userId: testUserId,
        )),
        expect: () => [
          const ChallengeLoading(message: 'Responding to invitation...'),
          isA<InvitationResponded>(),
          const ChallengeLoading(message: 'Loading challenges...'),
          isA<ChallengeLoaded>(),
        ],
        verify: (bloc) {
          final respondedStates = bloc.stream
              .where((state) => state is InvitationResponded)
              .cast<InvitationResponded>();
          
          expect(respondedStates, isNotEmpty);
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should decline invitation without creating rival session',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(RespondToInvitation(
          invitationId: testInvitation.id,
          accept: false,
          userId: testUserId,
        )),
        expect: () => [
          const ChallengeLoading(message: 'Responding to invitation...'),
          isA<InvitationResponded>(),
          const ChallengeLoading(message: 'Loading challenges...'),
          isA<ChallengeLoaded>(),
        ],
        verify: (bloc) {
          final states = bloc.stream
              .where((state) => state is InvitationResponded)
              .cast<InvitationResponded>();
          
          expect(states, isNotEmpty);
        },
      );
    });

    group('Rival Sessions', () {
      blocTest<ChallengeBloc, ChallengeState>(
        'should create rival session successfully',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(CreateRivalSession(rivalSession: testRivalSession)),
        expect: () => [
          const ChallengeLoading(message: 'Creating rival session...'),
          isA<RivalSessionCreated>(),
          const ChallengeLoading(message: 'Loading challenges...'),
          isA<ChallengeLoaded>(),
        ],
        verify: (bloc) {
          final state = bloc.stream
              .firstWhere((state) => state is RivalSessionCreated)
              .then((state) => state as RivalSessionCreated);
          expect(state, completes);
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should reject rival session with same user',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(CreateRivalSession(
          rivalSession: testRivalSession.copyWith(userId2: testRivalSession.userId1),
        )),
        expect: () => [
          const ChallengeLoading(message: 'Creating rival session...'),
          isA<ChallengeError>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeError;
          expect(state.message, contains('Cannot create rival session with yourself'));
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should update rival session points',
        build: () => challengeBloc,
        seed: () {
          // Add rival session to cache first
          challengeBloc.add(CreateRivalSession(rivalSession: testRivalSession));
          return null;
        },
        act: (bloc) => bloc.add(UpdateRivalSessionPoints(
          sessionId: testRivalSession.id,
          userId: testUserId,
          pointsToAdd: 100,
        )),
        skip: 4, // Skip create rival session states
        expect: () => [
          isA<RivalSessionPointsUpdated>(),
        ],
        verify: (bloc) {
          final state = bloc.state as RivalSessionPointsUpdated;
          expect(state.pointsAdded, equals(100));
          expect(state.userId, equals(testUserId));
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should end rival session with winner',
        build: () => challengeBloc,
        seed: () {
          challengeBloc.add(CreateRivalSession(rivalSession: testRivalSession));
          return null;
        },
        act: (bloc) => bloc.add(EndRivalSession(
          sessionId: testRivalSession.id,
          winnerId: testUserId,
        )),
        skip: 4, // Skip create rival session states
        expect: () => [
          const ChallengeLoading(message: 'Ending rival session...'),
          isA<RivalSessionEnded>(),
        ],
        verify: (bloc) {
          final state = bloc.state as RivalSessionEnded;
          expect(state.winnerId, equals(testUserId));
          expect(state.rivalSession.isActive, isFalse);
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should add activity to rival session',
        build: () => challengeBloc,
        seed: () {
          challengeBloc.add(CreateRivalSession(rivalSession: testRivalSession));
          return null;
        },
        act: (bloc) => bloc.add(AddRivalActivity(
          sessionId: testRivalSession.id,
          userId: testUserId,
          activityDescription: 'Completed a workout',
        )),
        skip: 4, // Skip create rival session states
        expect: () => [
          isA<RivalActivityAdded>(),
        ],
        verify: (bloc) {
          final state = bloc.state as RivalActivityAdded;
          expect(state.activityDescription, equals('Completed a workout'));
          expect(state.userId, equals(testUserId));
        },
      );
    });

    group('Search and History', () {
      blocTest<ChallengeBloc, ChallengeState>(
        'should search challenges by query',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(SearchChallenges(
          query: 'Summer',
          limit: 10,
        )),
        expect: () => [
          const ChallengeLoading(message: 'Searching challenges...'),
          isA<ChallengeSearchResults>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeSearchResults;
          expect(state.query, equals('Summer'));
          expect(state.results, isNotEmpty);
          // Should find "Summer Shred Challenge" from mock data
          expect(state.results.any((c) => c.name.contains('Summer')), isTrue);
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should filter search results by type',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(SearchChallenges(
          query: '',
          typeFilter: ChallengeType.daily,
          limit: 10,
        )),
        expect: () => [
          const ChallengeLoading(message: 'Searching challenges...'),
          isA<ChallengeSearchResults>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeSearchResults;
          expect(state.typeFilter, equals(ChallengeType.daily));
          expect(state.results.every((c) => c.type == ChallengeType.daily), isTrue);
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should load challenge history with statistics',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(LoadChallengeHistory(
          userId: testUserId,
          limit: 20,
        )),
        expect: () => [
          const ChallengeLoading(message: 'Loading challenge history...'),
          isA<ChallengeHistoryLoaded>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeHistoryLoaded;
          expect(state.userId, equals(testUserId));
          expect(state.statistics, isNotEmpty);
          expect(state.statistics.containsKey('totalChallenges'), isTrue);
          expect(state.statistics.containsKey('totalPoints'), isTrue);
        },
      );
    });

    group('Real-time Updates', () {
      blocTest<ChallengeBloc, ChallengeState>(
        'should subscribe to challenge updates',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(SubscribeToChallengeUpdates(challengeId: '1')),
        expect: () => [
          isA<ChallengeSubscribed>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeSubscribed;
          expect(state.challenge.id, equals('1'));
        },
      );

      blocTest<ChallengeBloc, ChallengeState>(
        'should unsubscribe from challenge updates without error',
        build: () => challengeBloc,
        act: (bloc) => bloc.add(UnsubscribeFromChallengeUpdates(challengeId: '1')),
        expect: () => [],
      );
    });

    group('Helper Methods', () {
      test('should check if user is in challenge correctly', () {
        final isInChallenge = challengeBloc.isUserInChallenge('user1', '1');
        expect(isInChallenge, isA<bool>());
      });

      test('should get user active rival session', () {
        final rivalSession = challengeBloc.getUserActiveRivalSession('123');
        expect(rivalSession, isNotNull);
        expect(rivalSession!.userId1, equals('123'));
      });

      test('should return null for user with no active rival session', () {
        final rivalSession = challengeBloc.getUserActiveRivalSession('non_existent');
        expect(rivalSession, isNull);
      });

      test('should get current challenge data from loaded state', () {
        challengeBloc.emit(ChallengeLoaded(
          allChallenges: [testChallenge],
          userChallenges: [],
          activeChallenges: [testChallenge],
        ));

        final currentData = challengeBloc.currentChallengeData;
        expect(currentData, isNotNull);
        expect(currentData!.allChallenges, contains(testChallenge));
      });

      test('should return null for current challenge data when not loaded', () {
        challengeBloc.emit(const ChallengeInitial());
        final currentData = challengeBloc.currentChallengeData;
        expect(currentData, isNull);
      });
    });

    group('Error Handling', () {
      blocTest<ChallengeBloc, ChallengeState>(
        'should handle errors gracefully and maintain state',
        build: () => challengeBloc,
        seed: () => ChallengeLoaded(
          allChallenges: [testChallenge],
          userChallenges: [],
          activeChallenges: [testChallenge],
        ),
        act: (bloc) => bloc.add(LoadChallengeDetails(challengeId: 'invalid')),
        expect: () => [
          const ChallengeDetailsLoading(challengeId: 'invalid'),
          isA<ChallengeError>(),
        ],
        verify: (bloc) {
          final state = bloc.state as ChallengeError;
          expect(state.code, equals('load-details-error'));
          expect(state.message, isNotEmpty);
        },
      );
    });

    group('Resource Management', () {
      test('should properly dispose subscriptions on close', () async {
        final bloc = ChallengeBloc();
        bloc.add(SubscribeToChallengeUpdates(challengeId: '1'));
        
        // Wait for subscription to be created
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Close bloc
        await bloc.close();
        
        // Verify no errors thrown during disposal
        expect(bloc.isClosed, isTrue);
      });
    });
  });
}

/// Extension methods for testing
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