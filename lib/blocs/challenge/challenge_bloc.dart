/// Challenge BLoC for managing challenge-related state.
/// 
/// This BLoC handles all challenge-related business logic including
/// loading challenges, creating new challenges, joining/leaving challenges,
/// managing rival sessions, handling invitations, and real-time updates.
/// It integrates with the existing ChallengeService mock data.

import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rivalx/blocs/challenge/challenge_event.dart';
import 'package:rivalx/blocs/challenge/challenge_state.dart';
import 'package:rivalx/models/challenge.dart';
import 'package:rivalx/models/user_model.dart';
/// BLoC for managing challenge state and operations
class ChallengeBloc extends Bloc<ChallengeEvent, ChallengeState> {
  
  /// Stream subscriptions for real-time updates
  final Map<String, StreamSubscription> _challengeSubscriptions = {};
  
  /// Timer for simulating real-time updates
  Timer? _simulationTimer;
  
  /// Cache for loaded challenges
  List<Challenge> _cachedChallenges = [];
  
  /// Cache for rival sessions
  List<RivalSession> _cachedRivalSessions = [];
  
  /// Cache for invitations
  List<ChallengeInvitation> _cachedInvitations = [];

  /// Creates a ChallengeBloc instance
  ChallengeBloc() : super(const ChallengeInitial()) {
    // Register event handlers
    on<LoadChallenges>(_onLoadChallenges);
    on<CreateChallenge>(_onCreateChallenge);
    on<JoinChallenge>(_onJoinChallenge);
    on<LeaveChallenge>(_onLeaveChallenge);
    on<UpdateChallengePoints>(_onUpdateChallengePoints);
    on<RefreshChallenges>(_onRefreshChallenges);
    on<LoadChallengeDetails>(_onLoadChallengeDetails);
    on<SendChallengeInvitation>(_onSendChallengeInvitation);
    on<RespondToInvitation>(_onRespondToInvitation);
    on<LoadRivalSessions>(_onLoadRivalSessions);
    on<CreateRivalSession>(_onCreateRivalSession);
    on<UpdateRivalSessionPoints>(_onUpdateRivalSessionPoints);
    on<EndRivalSession>(_onEndRivalSession);
    on<LoadChallengeInvitations>(_onLoadChallengeInvitations);
    on<SearchChallenges>(_onSearchChallenges);
    on<LoadChallengeHistory>(_onLoadChallengeHistory);
    on<SubscribeToChallengeUpdates>(_onSubscribeToChallengeUpdates);
    on<UnsubscribeFromChallengeUpdates>(_onUnsubscribeFromChallengeUpdates);
    on<AddRivalActivity>(_onAddRivalActivity);

    // Initialize mock data
    _initializeMockData();
  }

  /// Initialize mock data from ChallengeService
  void _initializeMockData() {
    ChallengeService.addMockData();
    FriendService.addMockData();
    _cachedChallenges = ChallengeService.getAllChallenges();
    _cachedRivalSessions = List.from(ChallengeService._rivalSessions);
    _cachedInvitations = List.from(FriendService._invitations);
  }

  /// Handles loading challenges for a user
  Future<void> _onLoadChallenges(
    LoadChallenges event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading(message: 'Loading challenges...'));
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Get all challenges
      final allChallenges = List<Challenge>.from(_cachedChallenges);
      
      // Filter user challenges
      final userChallenges = allChallenges
          .where((c) => c.participantIds.contains(event.userId))
          .toList();
      
      // Filter active challenges
      final activeChallenges = allChallenges
          .where((c) => c.status == ChallengeStatus.active)
          .toList();
      
      // Get active rival session
      final activeRivalSession = _cachedRivalSessions
          .where((r) => r.isActive && (r.userId1 == event.userId || r.userId2 == event.userId))
          .firstOrNull;
      
      // Get invitations
      final receivedInvitations = _cachedInvitations
          .where((inv) => inv.receiverId == event.userId && inv.status == InvitationStatus.pending)
          .toList();
      
      final sentInvitations = _cachedInvitations
          .where((inv) => inv.senderId == event.userId && inv.status == InvitationStatus.pending)
          .toList();

      emit(ChallengeLoaded(
        allChallenges: allChallenges,
        userChallenges: userChallenges,
        activeChallenges: activeChallenges,
        activeRivalSession: activeRivalSession,
        receivedInvitations: receivedInvitations,
        sentInvitations: sentInvitations,
      ));
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to load challenges: ${e.toString()}',
        code: 'load-challenges-error',
      ));
    }
  }

  /// Handles creating a new challenge
  Future<void> _onCreateChallenge(
    CreateChallenge event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading(message: 'Creating challenge...'));
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Validate challenge data
      if (event.challenge.name.isEmpty) {
        throw Exception('Challenge name cannot be empty');
      }
      
      if (event.challenge.endDate.isBefore(event.challenge.startDate)) {
        throw Exception('End date must be after start date');
      }
      
      // Add to cached challenges
      _cachedChallenges.add(event.challenge);
      
      emit(ChallengeCreated(
        challenge: event.challenge,
        message: 'Challenge "${event.challenge.name}" created successfully!',
      ));
      
      // Reload challenges to update the UI
      add(LoadChallenges(userId: event.challenge.creatorId));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to create challenge: ${e.toString()}',
        code: 'create-challenge-error',
      ));
    }
  }

  /// Handles joining a challenge
  Future<void> _onJoinChallenge(
    JoinChallenge event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading(message: 'Joining challenge...'));
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Find the challenge
      final challengeIndex = _cachedChallenges.indexWhere((c) => c.id == event.challengeId);
      if (challengeIndex == -1) {
        throw Exception('Challenge not found');
      }
      
      final challenge = _cachedChallenges[challengeIndex];
      
      // Check if user is already participating
      if (challenge.participantIds.contains(event.userId)) {
        throw Exception('You are already participating in this challenge');
      }
      
      // Check if challenge is full
      if (challenge.participantIds.length >= challenge.maxParticipants) {
        throw Exception('Challenge is full');
      }
      
      // Check if challenge is active
      if (challenge.status != ChallengeStatus.active) {
        throw Exception('Challenge is not active');
      }
      
      // Add user to participants and initialize points
      challenge.participantIds.add(event.userId);
      challenge.leaderboard[event.userId] = 0;
      
      emit(ChallengeJoined(
        challenge: challenge,
        userId: event.userId,
        message: 'Successfully joined "${challenge.name}"!',
      ));
      
      // Reload challenges to update the UI
      add(LoadChallenges(userId: event.userId));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to join challenge: ${e.toString()}',
        code: 'join-challenge-error',
      ));
    }
  }

  /// Handles leaving a challenge
  Future<void> _onLeaveChallenge(
    LeaveChallenge event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading(message: 'Leaving challenge...'));
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      // Find the challenge
      final challengeIndex = _cachedChallenges.indexWhere((c) => c.id == event.challengeId);
      if (challengeIndex == -1) {
        throw Exception('Challenge not found');
      }
      
      final challenge = _cachedChallenges[challengeIndex];
      
      // Check if user is participating
      if (!challenge.participantIds.contains(event.userId)) {
        throw Exception('You are not participating in this challenge');
      }
      
      // Remove user from participants and leaderboard
      challenge.participantIds.remove(event.userId);
      challenge.leaderboard.remove(event.userId);
      
      emit(ChallengeLeft(
        challenge: challenge,
        userId: event.userId,
        message: 'Successfully left "${challenge.name}"',
      ));
      
      // Reload challenges to update the UI
      add(LoadChallenges(userId: event.userId));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to leave challenge: ${e.toString()}',
        code: 'leave-challenge-error',
      ));
    }
  }

  /// Handles updating challenge points
  Future<void> _onUpdateChallengePoints(
    UpdateChallengePoints event,
    Emitter<ChallengeState> emit,
  ) async {
    try {
      // Find the challenge
      final challengeIndex = _cachedChallenges.indexWhere((c) => c.id == event.challengeId);
      if (challengeIndex == -1) {
        throw Exception('Challenge not found');
      }
      
      final challenge = _cachedChallenges[challengeIndex];
      
      // Check if user is participating
      if (!challenge.participantIds.contains(event.userId)) {
        throw Exception('User is not participating in this challenge');
      }
      
      // Update points
      final currentPoints = challenge.leaderboard[event.userId] ?? 0;
      final newPoints = (currentPoints + event.pointsToAdd).clamp(0, double.infinity).toInt();
      challenge.leaderboard[event.userId] = newPoints;
      
      // Calculate new rank
      final sortedLeaderboard = challenge.sortedLeaderboard;
      final newRank = sortedLeaderboard.indexWhere((entry) => entry.key == event.userId) + 1;
      
      emit(ChallengePointsUpdated(
        challenge: challenge,
        userId: event.userId,
        pointsAdded: event.pointsToAdd,
        newRank: newRank,
      ));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to update challenge points: ${e.toString()}',
        code: 'update-points-error',
      ));
    }
  }

  /// Handles refreshing challenges
  Future<void> _onRefreshChallenges(
    RefreshChallenges event,
    Emitter<ChallengeState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is ChallengeLoaded) {
      emit(ChallengeRefreshing(previousState: currentState));
    } else {
      emit(const ChallengeLoading(message: 'Refreshing challenges...'));
    }
    
    // Simulate some data changes during refresh
    _simulateDataChanges();
    
    // Reload challenges
    add(LoadChallenges(userId: event.userId));
  }

  /// Handles loading challenge details
  Future<void> _onLoadChallengeDetails(
    LoadChallengeDetails event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(ChallengeDetailsLoading(challengeId: event.challengeId));
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Find the challenge
      final challenge = _cachedChallenges.firstWhere(
        (c) => c.id == event.challengeId,
        orElse: () => throw Exception('Challenge not found'),
      );
      
      // Get participant details (mock data)
      final participants = <Friend>[];
      for (final userId in challenge.participantIds) {
        // Create mock participant data
        final friend = Friend(
          id: userId,
          username: 'user_$userId',
          displayName: 'User ${userId.substring(0, 3)}',
          email: 'user$userId@example.com',
          currentRank: RankLevel.values[Random().nextInt(RankLevel.values.length)],
          totalPoints: challenge.leaderboard[userId] ?? 0,
          weeklyPoints: Random().nextInt(500),
          isOnline: Random().nextBool(),
          lastActive: DateTime.now().subtract(Duration(hours: Random().nextInt(24))),
        );
        participants.add(friend);
      }
      
      // Calculate user rank (assuming first participant is current user)
      final userRank = challenge.getUserRank(challenge.participantIds.isNotEmpty ? challenge.participantIds.first : '');
      
      emit(ChallengeDetailsLoaded(
        challenge: challenge,
        participants: participants,
        userRank: userRank > 0 ? userRank : 1,
      ));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to load challenge details: ${e.toString()}',
        code: 'load-details-error',
      ));
    }
  }

  /// Handles sending challenge invitation
  Future<void> _onSendChallengeInvitation(
    SendChallengeInvitation event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading(message: 'Sending invitation...'));
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Validate invitation
      if (event.invitation.senderId == event.invitation.receiverId) {
        throw Exception('Cannot send invitation to yourself');
      }
      
      // Add to cached invitations
      _cachedInvitations.add(event.invitation);
      
      emit(InvitationSent(
        invitation: event.invitation,
        message: 'Challenge invitation sent to ${event.invitation.receiverName}!',
      ));
      
      // Reload invitations
      add(LoadChallengeInvitations(userId: event.invitation.senderId));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to send invitation: ${e.toString()}',
        code: 'send-invitation-error',
      ));
    }
  }

  /// Handles responding to invitation
  Future<void> _onRespondToInvitation(
    RespondToInvitation event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading(message: 'Responding to invitation...'));
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Find the invitation
      final invitationIndex = _cachedInvitations.indexWhere((inv) => inv.id == event.invitationId);
      if (invitationIndex == -1) {
        throw Exception('Invitation not found');
      }
      
      final invitation = _cachedInvitations[invitationIndex];
      
      // Update invitation status
      final updatedInvitation = ChallengeInvitation(
        id: invitation.id,
        senderId: invitation.senderId,
        senderName: invitation.senderName,
        receiverId: invitation.receiverId,
        receiverName: invitation.receiverName,
        challengeType: invitation.challengeType,
        duration: invitation.duration,
        wagerAmount: invitation.wagerAmount,
        personalMessage: invitation.personalMessage,
        status: event.accept ? InvitationStatus.accepted : InvitationStatus.declined,
        createdAt: invitation.createdAt,
        respondedAt: DateTime.now(),
        expiresAt: invitation.expiresAt,
      );
      
      _cachedInvitations[invitationIndex] = updatedInvitation;
      
      RivalSession? createdRivalSession;
      
      // Create rival session if accepted
      if (event.accept) {
        createdRivalSession = RivalSession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId1: invitation.senderId,
          userId2: invitation.receiverId,
          user1Name: invitation.senderName,
          user2Name: invitation.receiverName,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: invitation.duration)),
          isActive: true,
          wagerAmount: invitation.wagerAmount,
        );
        
        _cachedRivalSessions.add(createdRivalSession);
      }
      
      final message = event.accept 
          ? 'Challenge accepted! Rival session created.'
          : 'Challenge invitation declined.';
      
      emit(InvitationResponded(
        invitation: updatedInvitation,
        accepted: event.accept,
        message: message,
        createdRivalSession: createdRivalSession,
      ));
      
      // Reload data
      add(LoadChallenges(userId: event.userId));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to respond to invitation: ${e.toString()}',
        code: 'respond-invitation-error',
      ));
    }
  }

  /// Handles loading rival sessions
  Future<void> _onLoadRivalSessions(
    LoadRivalSessions event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading(message: 'Loading rival sessions...'));
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      // This is handled in the main LoadChallenges event
      add(LoadChallenges(userId: event.userId));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to load rival sessions: ${e.toString()}',
        code: 'load-rival-sessions-error',
      ));
    }
  }

  /// Handles creating rival session
  Future<void> _onCreateRivalSession(
    CreateRivalSession event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading(message: 'Creating rival session...'));
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Validate rival session
      if (event.rivalSession.userId1 == event.rivalSession.userId2) {
        throw Exception('Cannot create rival session with yourself');
      }
      
      // Add to cached rival sessions
      _cachedRivalSessions.add(event.rivalSession);
      
      emit(RivalSessionCreated(
        rivalSession: event.rivalSession,
        message: 'Rival session created successfully!',
      ));
      
      // Reload data
      add(LoadChallenges(userId: event.rivalSession.userId1));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to create rival session: ${e.toString()}',
        code: 'create-rival-session-error',
      ));
    }
  }

  /// Handles updating rival session points
  Future<void> _onUpdateRivalSessionPoints(
    UpdateRivalSessionPoints event,
    Emitter<ChallengeState> emit,
  ) async {
    try {
      // Find the rival session
      final sessionIndex = _cachedRivalSessions.indexWhere((r) => r.id == event.sessionId);
      if (sessionIndex == -1) {
        throw Exception('Rival session not found');
      }
      
      final session = _cachedRivalSessions[sessionIndex];
      
      // Update points
      final updatedSession = RivalSession(
        id: session.id,
        userId1: session.userId1,
        userId2: session.userId2,
        user1Name: session.user1Name,
        user2Name: session.user2Name,
        user1Avatar: session.user1Avatar,
        user2Avatar: session.user2Avatar,
        startDate: session.startDate,
        endDate: session.endDate,
        user1Points: event.userId == session.userId1 
            ? session.user1Points + event.pointsToAdd 
            : session.user1Points,
        user2Points: event.userId == session.userId2 
            ? session.user2Points + event.pointsToAdd 
            : session.user2Points,
        isActive: session.isActive,
        winnerId: session.winnerId,
        wagerAmount: session.wagerAmount,
        activities: session.activities,
      );
      
      _cachedRivalSessions[sessionIndex] = updatedSession;
      
      emit(RivalSessionPointsUpdated(
        rivalSession: updatedSession,
        userId: event.userId,
        pointsAdded: event.pointsToAdd,
      ));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to update rival session points: ${e.toString()}',
        code: 'update-rival-points-error',
      ));
    }
  }

  /// Handles ending rival session
  Future<void> _onEndRivalSession(
    EndRivalSession event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading(message: 'Ending rival session...'));
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      // Find the rival session
      final sessionIndex = _cachedRivalSessions.indexWhere((r) => r.id == event.sessionId);
      if (sessionIndex == -1) {
        throw Exception('Rival session not found');
      }
      
      final session = _cachedRivalSessions[sessionIndex];
      
      // Update session to ended
      final endedSession = RivalSession(
        id: session.id,
        userId1: session.userId1,
        userId2: session.userId2,
        user1Name: session.user1Name,
        user2Name: session.user2Name,
        user1Avatar: session.user1Avatar,
        user2Avatar: session.user2Avatar,
        startDate: session.startDate,
        endDate: session.endDate,
        user1Points: session.user1Points,
        user2Points: session.user2Points,
        isActive: false,
        winnerId: event.winnerId,
        wagerAmount: session.wagerAmount,
        activities: session.activities,
      );
      
      _cachedRivalSessions[sessionIndex] = endedSession;
      
      final winnerName = event.winnerId == session.userId1 
          ? session.user1Name 
          : event.winnerId == session.userId2 
              ? session.user2Name 
              : null;
      
      final message = winnerName != null 
          ? 'Rival session ended. Winner: $winnerName'
          : 'Rival session ended in a tie';
      
      emit(RivalSessionEnded(
        rivalSession: endedSession,
        winnerId: event.winnerId,
        message: message,
      ));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to end rival session: ${e.toString()}',
        code: 'end-rival-session-error',
      ));
    }
  }

  /// Handles loading challenge invitations
  Future<void> _onLoadChallengeInvitations(
    LoadChallengeInvitations event,
    Emitter<ChallengeState> emit,
  ) async {
    // This is handled in the main LoadChallenges event
    add(LoadChallenges(userId: event.userId));
  }

  /// Handles searching challenges
  Future<void> _onSearchChallenges(
    SearchChallenges event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading(message: 'Searching challenges...'));
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      var results = List<Challenge>.from(_cachedChallenges);
      
      // Apply search query filter
      if (event.query.isNotEmpty) {
        results = results.where((challenge) =>
            challenge.name.toLowerCase().contains(event.query.toLowerCase()) ||
            challenge.description.toLowerCase().contains(event.query.toLowerCase()) ||
            challenge.creatorName.toLowerCase().contains(event.query.toLowerCase())
        ).toList();
      }
      
      // Apply type filter
      if (event.typeFilter != null) {
        results = results.where((challenge) => challenge.type == event.typeFilter).toList();
      }
      
      // Apply status filter
      if (event.statusFilter != null) {
        results = results.where((challenge) => challenge.status == event.statusFilter).toList();
      }
      
      // Limit results
      if (results.length > event.limit) {
        results = results.take(event.limit).toList();
      }
      
      emit(ChallengeSearchResults(
        results: results,
        query: event.query,
        typeFilter: event.typeFilter,
        statusFilter: event.statusFilter,
      ));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to search challenges: ${e.toString()}',
        code: 'search-challenges-error',
      ));
    }
  }

  /// Handles loading challenge history
  Future<void> _onLoadChallengeHistory(
    LoadChallengeHistory event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading(message: 'Loading challenge history...'));
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Get completed challenges for user
      final completedChallenges = _cachedChallenges
          .where((c) => c.status == ChallengeStatus.completed && c.participantIds.contains(event.userId))
          .take(event.limit)
          .toList();
      
      // Calculate statistics
      final totalChallenges = completedChallenges.length;
      final totalPoints = completedChallenges.fold<int>(
        0, 
        (sum, challenge) => sum + (challenge.leaderboard[event.userId] ?? 0)
      );
      final avgPoints = totalChallenges > 0 ? (totalPoints / totalChallenges).round() : 0;
      final topRank = completedChallenges.isEmpty ? 0 : completedChallenges
          .map((c) => c.getUserRank(event.userId))
          .where((rank) => rank > 0)
          .fold<int>(1000, (min, rank) => rank < min ? rank : min);
      
      final statistics = {
        'totalChallenges': totalChallenges,
        'totalPoints': totalPoints,
        'averagePoints': avgPoints,
        'bestRank': topRank == 1000 ? 0 : topRank,
      };
      
      emit(ChallengeHistoryLoaded(
        completedChallenges: completedChallenges,
        userId: event.userId,
        statistics: statistics,
      ));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to load challenge history: ${e.toString()}',
        code: 'load-history-error',
      ));
    }
  }

  /// Handles subscribing to challenge updates
  Future<void> _onSubscribeToChallengeUpdates(
    SubscribeToChallengeUpdates event,
    Emitter<ChallengeState> emit,
  ) async {
    try {
      // Find the challenge
      final challenge = _cachedChallenges.firstWhere(
        (c) => c.id == event.challengeId,
        orElse: () => throw Exception('Challenge not found'),
      );
      
      // Cancel existing subscription
      _challengeSubscriptions[event.challengeId]?.cancel();
      
      // Create simulated real-time updates
      _challengeSubscriptions[event.challengeId] = 
          Stream.periodic(const Duration(seconds: 30), (i) => i)
              .listen((_) {
        // Simulate random point updates
        if (challenge.participantIds.isNotEmpty) {
          final randomUserId = challenge.participantIds[Random().nextInt(challenge.participantIds.length)];
          final randomPoints = Random().nextInt(50) + 10;
          
          // Update points silently
          final currentPoints = challenge.leaderboard[randomUserId] ?? 0;
          challenge.leaderboard[randomUserId] = currentPoints + randomPoints;
          
          // Emit real-time update
          emit(ChallengeRealTimeUpdate(
            challenge: challenge,
            updateType: 'points_update',
          ));
        }
      });
      
      emit(ChallengeSubscribed(
        challenge: challenge,
        message: 'Subscribed to real-time updates for "${challenge.name}"',
      ));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to subscribe to challenge updates: ${e.toString()}',
        code: 'subscribe-error',
      ));
    }
  }

  /// Handles unsubscribing from challenge updates
  Future<void> _onUnsubscribeFromChallengeUpdates(
    UnsubscribeFromChallengeUpdates event,
    Emitter<ChallengeState> emit,
  ) async {
    try {
      // Cancel subscription
      _challengeSubscriptions[event.challengeId]?.cancel();
      _challengeSubscriptions.remove(event.challengeId);
      
      // No need to emit a state for unsubscribe
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to unsubscribe from challenge updates: ${e.toString()}',
        code: 'unsubscribe-error',
      ));
    }
  }

  /// Handles adding rival activity
  Future<void> _onAddRivalActivity(
    AddRivalActivity event,
    Emitter<ChallengeState> emit,
  ) async {
    try {
      // Find the rival session
      final sessionIndex = _cachedRivalSessions.indexWhere((r) => r.id == event.sessionId);
      if (sessionIndex == -1) {
        throw Exception('Rival session not found');
      }
      
      final session = _cachedRivalSessions[sessionIndex];
      
      // Add activity
      final updatedActivities = Map<String, List<String>>.from(session.activities);
      if (!updatedActivities.containsKey(event.userId)) {
        updatedActivities[event.userId] = [];
      }
      updatedActivities[event.userId]!.add(event.activityDescription);
      
      // Update session
      final updatedSession = RivalSession(
        id: session.id,
        userId1: session.userId1,
        userId2: session.userId2,
        user1Name: session.user1Name,
        user2Name: session.user2Name,
        user1Avatar: session.user1Avatar,
        user2Avatar: session.user2Avatar,
        startDate: session.startDate,
        endDate: session.endDate,
        user1Points: session.user1Points,
        user2Points: session.user2Points,
        isActive: session.isActive,
        winnerId: session.winnerId,
        wagerAmount: session.wagerAmount,
        activities: updatedActivities,
      );
      
      _cachedRivalSessions[sessionIndex] = updatedSession;
      
      emit(RivalActivityAdded(
        rivalSession: updatedSession,
        userId: event.userId,
        activityDescription: event.activityDescription,
      ));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to add rival activity: ${e.toString()}',
        code: 'add-activity-error',
      ));
    }
  }

  /// Simulate data changes during refresh
  void _simulateDataChanges() {
    // Simulate some point updates
    for (final challenge in _cachedChallenges) {
      if (challenge.status == ChallengeStatus.active && challenge.participantIds.isNotEmpty) {
        for (final userId in challenge.participantIds) {
          if (Random().nextDouble() < 0.3) { // 30% chance of point update
            final currentPoints = challenge.leaderboard[userId] ?? 0;
            final addedPoints = Random().nextInt(100) + 10;
            challenge.leaderboard[userId] = currentPoints + addedPoints;
          }
        }
      }
    }
  }

  /// Get current challenge data from state
  /// 
  /// @return Current ChallengeLoaded state if available, null otherwise
  ChallengeLoaded? get currentChallengeData {
    final currentState = state;
    if (currentState is ChallengeLoaded) {
      return currentState;
    } else if (currentState is ChallengeRefreshing && currentState.previousState != null) {
      return currentState.previousState;
    }
    return null;
  }

  /// Check if user is in a challenge
  /// 
  /// @param userId User ID to check
  /// @param challengeId Challenge ID to check
  /// @return true if user is participating in the challenge
  bool isUserInChallenge(String userId, String challengeId) {
    final challenge = _cachedChallenges.firstWhere(
      (c) => c.id == challengeId,
      orElse: () => Challenge(
        id: '',
        name: '',
        description: '',
        type: ChallengeType.public,
        status: ChallengeStatus.completed,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        creatorId: '',
        creatorName: '',
        participantIds: [],
        leaderboard: {},
        rules: [],
      ),
    );
    return challenge.participantIds.contains(userId);
  }

  /// Get user's active rival session
  /// 
  /// @param userId User ID
  /// @return Active RivalSession if found, null otherwise
  RivalSession? getUserActiveRivalSession(String userId) {
    try {
      return _cachedRivalSessions.firstWhere(
        (r) => r.isActive && (r.userId1 == userId || r.userId2 == userId),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> close() {
    // Cancel all subscriptions
    for (final subscription in _challengeSubscriptions.values) {
      subscription.cancel();
    }
    _challengeSubscriptions.clear();
    
    // Cancel simulation timer
    _simulationTimer?.cancel();
    
    return super.close();
  }
}