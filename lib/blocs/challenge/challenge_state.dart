/// Challenge states for the challenge BLoC.
/// 
/// These states represent the various challenge states the app
/// can be in, such as loaded, loading, error, or specific
/// operation success states.

import 'package:equatable/equatable.dart';
import 'package:rivalx/models/challenge.dart';

/// Base class for all challenge states
abstract class ChallengeState extends Equatable {
  const ChallengeState();

  @override
  List<Object?> get props => [];
}

/// Initial state when challenge BLoC is created
class ChallengeInitial extends ChallengeState {
  const ChallengeInitial();
}

/// State when challenge data is being loaded
class ChallengeLoading extends ChallengeState {
  /// Optional message describing what is being loaded
  final String? message;

  const ChallengeLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// State when challenges are successfully loaded
class ChallengeLoaded extends ChallengeState {
  /// List of all challenges
  final List<Challenge> allChallenges;
  
  /// List of challenges the user is participating in
  final List<Challenge> userChallenges;
  
  /// List of active challenges
  final List<Challenge> activeChallenges;
  
  /// Current active rival session (if any)
  final RivalSession? activeRivalSession;
  
  /// List of challenge invitations received
  final List<ChallengeInvitation> receivedInvitations;
  
  /// List of challenge invitations sent
  final List<ChallengeInvitation> sentInvitations;

  const ChallengeLoaded({
    required this.allChallenges,
    required this.userChallenges,
    required this.activeChallenges,
    this.activeRivalSession,
    this.receivedInvitations = const [],
    this.sentInvitations = const [],
  });

  @override
  List<Object?> get props => [
        allChallenges,
        userChallenges,
        activeChallenges,
        activeRivalSession,
        receivedInvitations,
        sentInvitations,
      ];

  /// Create a copy of this state with some updated values
  ChallengeLoaded copyWith({
    List<Challenge>? allChallenges,
    List<Challenge>? userChallenges,
    List<Challenge>? activeChallenges,
    RivalSession? activeRivalSession,
    List<ChallengeInvitation>? receivedInvitations,
    List<ChallengeInvitation>? sentInvitations,
  }) {
    return ChallengeLoaded(
      allChallenges: allChallenges ?? this.allChallenges,
      userChallenges: userChallenges ?? this.userChallenges,
      activeChallenges: activeChallenges ?? this.activeChallenges,
      activeRivalSession: activeRivalSession ?? this.activeRivalSession,
      receivedInvitations: receivedInvitations ?? this.receivedInvitations,
      sentInvitations: sentInvitations ?? this.sentInvitations,
    );
  }
}

/// State when challenge operation fails with an error
class ChallengeError extends ChallengeState {
  /// Error message to display to the user
  final String message;
  
  /// Optional error code for specific error handling
  final String? code;
  
  /// Previous state data (if available) to maintain UI context
  final ChallengeLoaded? previousState;

  const ChallengeError({
    required this.message,
    this.code,
    this.previousState,
  });

  @override
  List<Object?> get props => [message, code, previousState];
}

/// State when a challenge is successfully created
class ChallengeCreated extends ChallengeState {
  /// The newly created challenge
  final Challenge challenge;
  
  /// Success message
  final String message;

  const ChallengeCreated({
    required this.challenge,
    this.message = 'Challenge created successfully',
  });

  @override
  List<Object?> get props => [challenge, message];
}

/// State when successfully joined a challenge
class ChallengeJoined extends ChallengeState {
  /// The challenge that was joined
  final Challenge challenge;
  
  /// User ID that joined
  final String userId;
  
  /// Success message
  final String message;

  const ChallengeJoined({
    required this.challenge,
    required this.userId,
    this.message = 'Successfully joined challenge',
  });

  @override
  List<Object?> get props => [challenge, userId, message];
}

/// State when successfully left a challenge
class ChallengeLeft extends ChallengeState {
  /// The challenge that was left
  final Challenge challenge;
  
  /// User ID that left
  final String userId;
  
  /// Success message
  final String message;

  const ChallengeLeft({
    required this.challenge,
    required this.userId,
    this.message = 'Successfully left challenge',
  });

  @override
  List<Object?> get props => [challenge, userId, message];
}

/// State when challenge invitation is successfully sent
class InvitationSent extends ChallengeState {
  /// The invitation that was sent
  final ChallengeInvitation invitation;
  
  /// Success message
  final String message;

  const InvitationSent({
    required this.invitation,
    this.message = 'Challenge invitation sent successfully',
  });

  @override
  List<Object?> get props => [invitation, message];
}

/// State when successfully responded to an invitation
class InvitationResponded extends ChallengeState {
  /// The invitation that was responded to
  final ChallengeInvitation invitation;
  
  /// Whether the invitation was accepted
  final bool accepted;
  
  /// Success message
  final String message;
  
  /// Rival session created (if invitation was accepted)
  final RivalSession? createdRivalSession;

  const InvitationResponded({
    required this.invitation,
    required this.accepted,
    required this.message,
    this.createdRivalSession,
  });

  @override
  List<Object?> get props => [invitation, accepted, message, createdRivalSession];
}

/// State when challenge details are being loaded
class ChallengeDetailsLoading extends ChallengeState {
  /// ID of the challenge being loaded
  final String challengeId;

  const ChallengeDetailsLoading({required this.challengeId});

  @override
  List<Object?> get props => [challengeId];
}

/// State when challenge details are successfully loaded
class ChallengeDetailsLoaded extends ChallengeState {
  /// The loaded challenge
  final Challenge challenge;
  
  /// Participants data with user details
  final List<Friend> participants;
  
  /// User's rank in the challenge
  final int userRank;

  const ChallengeDetailsLoaded({
    required this.challenge,
    required this.participants,
    required this.userRank,
  });

  @override
  List<Object?> get props => [challenge, participants, userRank];
}

/// State when challenge points are successfully updated
class ChallengePointsUpdated extends ChallengeState {
  /// The updated challenge
  final Challenge challenge;
  
  /// User ID whose points were updated
  final String userId;
  
  /// Points that were added
  final int pointsAdded;
  
  /// User's new rank in the challenge
  final int newRank;

  const ChallengePointsUpdated({
    required this.challenge,
    required this.userId,
    required this.pointsAdded,
    required this.newRank,
  });

  @override
  List<Object?> get props => [challenge, userId, pointsAdded, newRank];
}

/// State when rival session is successfully created
class RivalSessionCreated extends ChallengeState {
  /// The created rival session
  final RivalSession rivalSession;
  
  /// Success message
  final String message;

  const RivalSessionCreated({
    required this.rivalSession,
    this.message = 'Rival session created successfully',
  });

  @override
  List<Object?> get props => [rivalSession, message];
}

/// State when rival session points are successfully updated
class RivalSessionPointsUpdated extends ChallengeState {
  /// The updated rival session
  final RivalSession rivalSession;
  
  /// User ID whose points were updated
  final String userId;
  
  /// Points that were added
  final int pointsAdded;

  const RivalSessionPointsUpdated({
    required this.rivalSession,
    required this.userId,
    required this.pointsAdded,
  });

  @override
  List<Object?> get props => [rivalSession, userId, pointsAdded];
}

/// State when rival session is successfully ended
class RivalSessionEnded extends ChallengeState {
  /// The ended rival session
  final RivalSession rivalSession;
  
  /// Winner ID (if any)
  final String? winnerId;
  
  /// Success message
  final String message;

  const RivalSessionEnded({
    required this.rivalSession,
    this.winnerId,
    required this.message,
  });

  @override
  List<Object?> get props => [rivalSession, winnerId, message];
}

/// State when challenge search results are available
class ChallengeSearchResults extends ChallengeState {
  /// Search results
  final List<Challenge> results;
  
  /// Search query used
  final String query;
  
  /// Applied filters
  final ChallengeType? typeFilter;
  final ChallengeStatus? statusFilter;

  const ChallengeSearchResults({
    required this.results,
    required this.query,
    this.typeFilter,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [results, query, typeFilter, statusFilter];
}

/// State when challenge history is successfully loaded
class ChallengeHistoryLoaded extends ChallengeState {
  /// Challenge history for the user
  final List<Challenge> completedChallenges;
  
  /// User ID
  final String userId;
  
  /// Statistics summary
  final Map<String, dynamic> statistics;

  const ChallengeHistoryLoaded({
    required this.completedChallenges,
    required this.userId,
    required this.statistics,
  });

  @override
  List<Object?> get props => [completedChallenges, userId, statistics];
}

/// State when subscribed to real-time challenge updates
class ChallengeSubscribed extends ChallengeState {
  /// Challenge being subscribed to
  final Challenge challenge;
  
  /// Success message
  final String message;

  const ChallengeSubscribed({
    required this.challenge,
    this.message = 'Subscribed to challenge updates',
  });

  @override
  List<Object?> get props => [challenge, message];
}

/// State when real-time challenge update is received
class ChallengeRealTimeUpdate extends ChallengeState {
  /// Updated challenge data
  final Challenge challenge;
  
  /// Type of update received
  final String updateType;

  const ChallengeRealTimeUpdate({
    required this.challenge,
    required this.updateType,
  });

  @override
  List<Object?> get props => [challenge, updateType];
}

/// State when activity is successfully added to rival session
class RivalActivityAdded extends ChallengeState {
  /// Updated rival session
  final RivalSession rivalSession;
  
  /// User ID who added the activity
  final String userId;
  
  /// Activity description
  final String activityDescription;

  const RivalActivityAdded({
    required this.rivalSession,
    required this.userId,
    required this.activityDescription,
  });

  @override
  List<Object?> get props => [rivalSession, userId, activityDescription];
}

/// State when challenges are being refreshed
class ChallengeRefreshing extends ChallengeState {
  /// Previous loaded state to maintain UI
  final ChallengeLoaded? previousState;

  const ChallengeRefreshing({this.previousState});

  @override
  List<Object?> get props => [previousState];
}