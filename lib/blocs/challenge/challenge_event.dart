/// Challenge events for the challenge BLoC.
/// 
/// These events represent all possible challenge-related actions
/// that can be triggered in the app, such as loading challenges,
/// creating new challenges, joining/leaving challenges, and managing
/// rival sessions and invitations.

import 'package:equatable/equatable.dart';
import 'package:rivalx/models/challenge.dart';

/// Base class for all challenge events
abstract class ChallengeEvent extends Equatable {
  const ChallengeEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when loading all challenges for the current user
class LoadChallenges extends ChallengeEvent {
  /// User ID to load challenges for
  final String userId;

  const LoadChallenges({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event triggered when creating a new challenge
class CreateChallenge extends ChallengeEvent {
  /// Challenge data to create
  final Challenge challenge;

  const CreateChallenge({required this.challenge});

  @override
  List<Object?> get props => [challenge];
}

/// Event triggered when joining an existing challenge
class JoinChallenge extends ChallengeEvent {
  /// ID of the challenge to join
  final String challengeId;
  
  /// User ID of the person joining
  final String userId;

  const JoinChallenge({
    required this.challengeId,
    required this.userId,
  });

  @override
  List<Object?> get props => [challengeId, userId];
}

/// Event triggered when leaving a challenge
class LeaveChallenge extends ChallengeEvent {
  /// ID of the challenge to leave
  final String challengeId;
  
  /// User ID of the person leaving
  final String userId;

  const LeaveChallenge({
    required this.challengeId,
    required this.userId,
  });

  @override
  List<Object?> get props => [challengeId, userId];
}

/// Event triggered when updating user points in a challenge
class UpdateChallengePoints extends ChallengeEvent {
  /// ID of the challenge to update
  final String challengeId;
  
  /// User ID whose points to update
  final String userId;
  
  /// Points to add (can be negative for penalties)
  final int pointsToAdd;

  const UpdateChallengePoints({
    required this.challengeId,
    required this.userId,
    required this.pointsToAdd,
  });

  @override
  List<Object?> get props => [challengeId, userId, pointsToAdd];
}

/// Event triggered when refreshing challenge data
class RefreshChallenges extends ChallengeEvent {
  /// User ID to refresh challenges for
  final String userId;

  const RefreshChallenges({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event triggered when loading specific challenge details
class LoadChallengeDetails extends ChallengeEvent {
  /// ID of the challenge to load details for
  final String challengeId;

  const LoadChallengeDetails({required this.challengeId});

  @override
  List<Object?> get props => [challengeId];
}

/// Event triggered when sending a challenge invitation to a friend
class SendChallengeInvitation extends ChallengeEvent {
  /// Invitation data to send
  final ChallengeInvitation invitation;

  const SendChallengeInvitation({required this.invitation});

  @override
  List<Object?> get props => [invitation];
}

/// Event triggered when responding to a challenge invitation
class RespondToInvitation extends ChallengeEvent {
  /// ID of the invitation to respond to
  final String invitationId;
  
  /// Whether to accept (true) or decline (false) the invitation
  final bool accept;
  
  /// ID of the user responding
  final String userId;

  const RespondToInvitation({
    required this.invitationId,
    required this.accept,
    required this.userId,
  });

  @override
  List<Object?> get props => [invitationId, accept, userId];
}

/// Event triggered when loading rival sessions for a user
class LoadRivalSessions extends ChallengeEvent {
  /// User ID to load rival sessions for
  final String userId;

  const LoadRivalSessions({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event triggered when creating a new rival session
class CreateRivalSession extends ChallengeEvent {
  /// Rival session data to create
  final RivalSession rivalSession;

  const CreateRivalSession({required this.rivalSession});

  @override
  List<Object?> get props => [rivalSession];
}

/// Event triggered when updating rival session points
class UpdateRivalSessionPoints extends ChallengeEvent {
  /// ID of the rival session to update
  final String sessionId;
  
  /// User ID whose points to update
  final String userId;
  
  /// Points to add
  final int pointsToAdd;

  const UpdateRivalSessionPoints({
    required this.sessionId,
    required this.userId,
    required this.pointsToAdd,
  });

  @override
  List<Object?> get props => [sessionId, userId, pointsToAdd];
}

/// Event triggered when ending a rival session
class EndRivalSession extends ChallengeEvent {
  /// ID of the rival session to end
  final String sessionId;
  
  /// ID of the winner (optional, can be null for tie)
  final String? winnerId;

  const EndRivalSession({
    required this.sessionId,
    this.winnerId,
  });

  @override
  List<Object?> get props => [sessionId, winnerId];
}

/// Event triggered when loading challenge invitations
class LoadChallengeInvitations extends ChallengeEvent {
  /// User ID to load invitations for
  final String userId;

  const LoadChallengeInvitations({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event triggered when searching for available challenges
class SearchChallenges extends ChallengeEvent {
  /// Search query string
  final String query;
  
  /// Challenge type filter (optional)
  final ChallengeType? typeFilter;
  
  /// Challenge status filter (optional)
  final ChallengeStatus? statusFilter;
  
  /// Maximum number of results
  final int limit;

  const SearchChallenges({
    required this.query,
    this.typeFilter,
    this.statusFilter,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, typeFilter, statusFilter, limit];
}

/// Event triggered when loading user's challenge history
class LoadChallengeHistory extends ChallengeEvent {
  /// User ID to load history for
  final String userId;
  
  /// Number of challenges to load
  final int limit;

  const LoadChallengeHistory({
    required this.userId,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [userId, limit];
}

/// Event triggered when subscribing to real-time challenge updates
class SubscribeToChallengeUpdates extends ChallengeEvent {
  /// ID of the challenge to subscribe to
  final String challengeId;

  const SubscribeToChallengeUpdates({required this.challengeId});

  @override
  List<Object?> get props => [challengeId];
}

/// Event triggered when unsubscribing from real-time challenge updates
class UnsubscribeFromChallengeUpdates extends ChallengeEvent {
  /// ID of the challenge to unsubscribe from
  final String challengeId;

  const UnsubscribeFromChallengeUpdates({required this.challengeId});

  @override
  List<Object?> get props => [challengeId];
}

/// Event triggered when adding activity to a rival session
class AddRivalActivity extends ChallengeEvent {
  /// ID of the rival session
  final String sessionId;
  
  /// User ID adding the activity
  final String userId;
  
  /// Activity description
  final String activityDescription;

  const AddRivalActivity({
    required this.sessionId,
    required this.userId,
    required this.activityDescription,
  });

  @override
  List<Object?> get props => [sessionId, userId, activityDescription];
}