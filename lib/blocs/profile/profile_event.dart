/// Profile events for the profile BLoC.
/// 
/// These events represent all possible profile-related actions
/// that can be triggered in the app, such as loading, updating,
/// and managing user profile data.

import 'package:equatable/equatable.dart';
import 'package:rivalx/models/user_model.dart';

/// Base class for all profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when loading user profile
class ProfileLoadRequested extends ProfileEvent {
  /// User ID whose profile to load
  final String userId;

  const ProfileLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event triggered when updating user profile
class ProfileUpdateRequested extends ProfileEvent {
  /// Updated user model
  final UserModel user;

  const ProfileUpdateRequested({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Event triggered when updating specific profile fields
class ProfileFieldsUpdateRequested extends ProfileEvent {
  /// User ID to update
  final String userId;
  
  /// Map of fields to update
  final Map<String, dynamic> fields;

  const ProfileFieldsUpdateRequested({
    required this.userId,
    required this.fields,
  });

  @override
  List<Object?> get props => [userId, fields];
}

/// Event triggered when updating user points
class ProfilePointsUpdateRequested extends ProfileEvent {
  /// User ID to update
  final String userId;
  
  /// Points to add (can be negative for penalties)
  final int pointsToAdd;
  
  /// Whether to update weekly points as well
  final bool updateWeeklyPoints;

  const ProfilePointsUpdateRequested({
    required this.userId,
    required this.pointsToAdd,
    this.updateWeeklyPoints = true,
  });

  @override
  List<Object?> get props => [userId, pointsToAdd, updateWeeklyPoints];
}

/// Event triggered when updating workout streak
class ProfileStreakUpdateRequested extends ProfileEvent {
  /// User ID to update
  final String userId;
  
  /// New streak value
  final int newStreak;

  const ProfileStreakUpdateRequested({
    required this.userId,
    required this.newStreak,
  });

  @override
  List<Object?> get props => [userId, newStreak];
}

/// Event triggered when updating volume lifted
class ProfileVolumeUpdateRequested extends ProfileEvent {
  /// User ID to update
  final String userId;
  
  /// Volume in kg to add
  final double volumeToAdd;

  const ProfileVolumeUpdateRequested({
    required this.userId,
    required this.volumeToAdd,
  });

  @override
  List<Object?> get props => [userId, volumeToAdd];
}

/// Event triggered when updating distance walked
class ProfileDistanceUpdateRequested extends ProfileEvent {
  /// User ID to update
  final String userId;
  
  /// Distance in km to add
  final double distanceToAdd;

  const ProfileDistanceUpdateRequested({
    required this.userId,
    required this.distanceToAdd,
  });

  @override
  List<Object?> get props => [userId, distanceToAdd];
}

/// Event triggered when setting current rival
class ProfileRivalSetRequested extends ProfileEvent {
  /// User ID
  final String userId;
  
  /// Rival's user ID
  final String rivalId;

  const ProfileRivalSetRequested({
    required this.userId,
    required this.rivalId,
  });

  @override
  List<Object?> get props => [userId, rivalId];
}

/// Event triggered when removing current rival
class ProfileRivalRemoveRequested extends ProfileEvent {
  /// User ID
  final String userId;

  const ProfileRivalRemoveRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event triggered when adding a penalty
class ProfilePenaltyAddRequested extends ProfileEvent {
  /// User ID to add penalty to
  final String userId;

  const ProfilePenaltyAddRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event triggered when searching for users
class ProfileUsersSearchRequested extends ProfileEvent {
  /// Search term (username)
  final String searchTerm;
  
  /// Maximum number of results
  final int limit;

  const ProfileUsersSearchRequested({
    required this.searchTerm,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [searchTerm, limit];
}

/// Event triggered when getting user's leaderboard position
class ProfileLeaderboardPositionRequested extends ProfileEvent {
  /// User ID
  final String userId;

  const ProfileLeaderboardPositionRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}