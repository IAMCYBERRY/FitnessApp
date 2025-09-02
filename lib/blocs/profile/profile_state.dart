/// Profile states for the profile BLoC.
/// 
/// These states represent the various profile states the app
/// can be in, such as loaded, loading, error, or updated.

import 'package:equatable/equatable.dart';
import 'package:rivalx/models/user_model.dart';

/// Base class for all profile states
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state when profile BLoC is created
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// State when profile data is being loaded
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// State when profile data is successfully loaded
class ProfileLoaded extends ProfileState {
  /// The loaded user profile
  final UserModel user;
  
  /// User's current leaderboard position (optional)
  final int? leaderboardPosition;

  const ProfileLoaded({
    required this.user,
    this.leaderboardPosition,
  });

  @override
  List<Object?> get props => [user, leaderboardPosition];
}

/// State when profile data is being updated
class ProfileUpdating extends ProfileState {
  /// The current user data (before update)
  final UserModel user;

  const ProfileUpdating({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State when profile is successfully updated
class ProfileUpdated extends ProfileState {
  /// The updated user profile
  final UserModel user;
  
  /// Success message to display
  final String message;

  const ProfileUpdated({
    required this.user,
    required this.message,
  });

  @override
  List<Object?> get props => [user, message];
}

/// State when profile operation fails with an error
class ProfileError extends ProfileState {
  /// Error message to display to the user
  final String message;
  
  /// Optional error code for specific error handling
  final String? code;
  
  /// Current user data (if available)
  final UserModel? user;

  const ProfileError({
    required this.message,
    this.code,
    this.user,
  });

  @override
  List<Object?> get props => [message, code, user];
}

/// State when user search is being performed
class ProfileSearching extends ProfileState {
  const ProfileSearching();
}

/// State when user search results are available
class ProfileSearchResults extends ProfileState {
  /// List of users matching search criteria
  final List<UserModel> users;
  
  /// Search term used
  final String searchTerm;

  const ProfileSearchResults({
    required this.users,
    required this.searchTerm,
  });

  @override
  List<Object?> get props => [users, searchTerm];
}

/// State when leaderboard position is being fetched
class ProfileLeaderboardPositionLoading extends ProfileState {
  /// Current user data
  final UserModel user;

  const ProfileLeaderboardPositionLoading({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State when leaderboard position is successfully fetched
class ProfileLeaderboardPositionLoaded extends ProfileState {
  /// Current user data
  final UserModel user;
  
  /// User's position in global leaderboard
  final int position;

  const ProfileLeaderboardPositionLoaded({
    required this.user,
    required this.position,
  });

  @override
  List<Object?> get props => [user, position];
}

/// State when points are successfully updated
class ProfilePointsUpdated extends ProfileState {
  /// Updated user profile
  final UserModel user;
  
  /// Points that were added
  final int pointsAdded;
  
  /// Whether rank changed
  final bool rankChanged;

  const ProfilePointsUpdated({
    required this.user,
    required this.pointsAdded,
    required this.rankChanged,
  });

  @override
  List<Object?> get props => [user, pointsAdded, rankChanged];
}

/// State when streak is successfully updated
class ProfileStreakUpdated extends ProfileState {
  /// Updated user profile
  final UserModel user;
  
  /// Whether a new longest streak was achieved
  final bool newLongestStreak;

  const ProfileStreakUpdated({
    required this.user,
    required this.newLongestStreak,
  });

  @override
  List<Object?> get props => [user, newLongestStreak];
}

/// State when rival is successfully set
class ProfileRivalSet extends ProfileState {
  /// Updated user profile
  final UserModel user;
  
  /// The rival user
  final UserModel rival;

  const ProfileRivalSet({
    required this.user,
    required this.rival,
  });

  @override
  List<Object?> get props => [user, rival];
}

/// State when rival is successfully removed
class ProfileRivalRemoved extends ProfileState {
  /// Updated user profile
  final UserModel user;

  const ProfileRivalRemoved({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State when penalty is successfully added
class ProfilePenaltyAdded extends ProfileState {
  /// Updated user profile
  final UserModel user;

  const ProfilePenaltyAdded({required this.user});

  @override
  List<Object?> get props => [user];
}