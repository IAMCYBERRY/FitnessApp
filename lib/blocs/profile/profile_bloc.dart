/// Profile BLoC for managing user profile state.
/// 
/// This BLoC handles all profile-related business logic including
/// loading user data, updating profile information, managing points
/// and streaks, and handling rival relationships.

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rivalx/blocs/profile/profile_event.dart';
import 'package:rivalx/blocs/profile/profile_state.dart';
import 'package:rivalx/services/firestore_service.dart';
import 'package:rivalx/models/user_model.dart';

/// BLoC for managing user profile state and operations
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  /// Firestore service instance
  final FirestoreService _firestoreService;
  
  /// Stream subscription for real-time user updates
  StreamSubscription<UserModel?>? _userSubscription;

  /// Creates a ProfileBloc instance
  /// 
  /// @param firestoreService The Firestore service to use
  ProfileBloc({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
        super(const ProfileInitial()) {
    // Register event handlers
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileFieldsUpdateRequested>(_onProfileFieldsUpdateRequested);
    on<ProfilePointsUpdateRequested>(_onProfilePointsUpdateRequested);
    on<ProfileStreakUpdateRequested>(_onProfileStreakUpdateRequested);
    on<ProfileVolumeUpdateRequested>(_onProfileVolumeUpdateRequested);
    on<ProfileDistanceUpdateRequested>(_onProfileDistanceUpdateRequested);
    on<ProfileRivalSetRequested>(_onProfileRivalSetRequested);
    on<ProfileRivalRemoveRequested>(_onProfileRivalRemoveRequested);
    on<ProfilePenaltyAddRequested>(_onProfilePenaltyAddRequested);
    on<ProfileUsersSearchRequested>(_onProfileUsersSearchRequested);
    on<ProfileLeaderboardPositionRequested>(_onProfileLeaderboardPositionRequested);
  }

  /// Handles profile load request
  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    
    try {
      // Cancel existing subscription
      await _userSubscription?.cancel();
      
      // Set up real-time subscription
      _userSubscription = _firestoreService
          .getUserStream(event.userId)
          .listen((user) {
        if (user != null) {
          emit(ProfileLoaded(user: user));
        } else {
          emit(const ProfileError(
            message: 'User not found',
            code: 'user-not-found',
          ));
        }
      });
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Handles profile update request
  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating(user: event.user));
    
    try {
      await _firestoreService.updateUser(event.user);
      emit(ProfileUpdated(
        user: event.user,
        message: 'Profile updated successfully',
      ));
    } catch (e) {
      emit(ProfileError(
        message: e.toString(),
        user: event.user,
      ));
    }
  }

  /// Handles profile fields update request
  Future<void> _onProfileFieldsUpdateRequested(
    ProfileFieldsUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _firestoreService.updateUserFields(event.userId, event.fields);
      // Note: The real-time subscription will handle the state update
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Handles points update request
  Future<void> _onProfilePointsUpdateRequested(
    ProfilePointsUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final currentUser = await _firestoreService.getUser(event.userId);
      if (currentUser == null) {
        emit(const ProfileError(message: 'User not found'));
        return;
      }

      final oldRank = currentUser.currentRank;
      
      // Update total points
      await _firestoreService.updateUserPoints(event.userId, event.pointsToAdd);
      
      // Update weekly points if requested
      if (event.updateWeeklyPoints) {
        await _firestoreService.updateWeeklyPoints(event.userId, event.pointsToAdd);
      }

      // Get updated user to check rank change
      final updatedUser = await _firestoreService.getUser(event.userId);
      if (updatedUser != null) {
        final rankChanged = updatedUser.currentRank != oldRank;
        
        emit(ProfilePointsUpdated(
          user: updatedUser,
          pointsAdded: event.pointsToAdd,
          rankChanged: rankChanged,
        ));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Handles streak update request
  Future<void> _onProfileStreakUpdateRequested(
    ProfileStreakUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final currentUser = await _firestoreService.getUser(event.userId);
      if (currentUser == null) {
        emit(const ProfileError(message: 'User not found'));
        return;
      }

      final newLongestStreak = event.newStreak > currentUser.longestStreak;
      
      await _firestoreService.updateWorkoutStreak(event.userId, event.newStreak);
      
      final updatedUser = await _firestoreService.getUser(event.userId);
      if (updatedUser != null) {
        emit(ProfileStreakUpdated(
          user: updatedUser,
          newLongestStreak: newLongestStreak,
        ));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Handles volume update request
  Future<void> _onProfileVolumeUpdateRequested(
    ProfileVolumeUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _firestoreService.updateVolumeLifted(event.userId, event.volumeToAdd);
      // Note: The real-time subscription will handle the state update
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Handles distance update request
  Future<void> _onProfileDistanceUpdateRequested(
    ProfileDistanceUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _firestoreService.updateDistanceWalked(event.userId, event.distanceToAdd);
      // Note: The real-time subscription will handle the state update
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Handles rival set request
  Future<void> _onProfileRivalSetRequested(
    ProfileRivalSetRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      // Get rival user data
      final rival = await _firestoreService.getUser(event.rivalId);
      if (rival == null) {
        emit(const ProfileError(message: 'Rival user not found'));
        return;
      }

      await _firestoreService.setCurrentRival(event.userId, event.rivalId);
      
      final updatedUser = await _firestoreService.getUser(event.userId);
      if (updatedUser != null) {
        emit(ProfileRivalSet(
          user: updatedUser,
          rival: rival,
        ));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Handles rival remove request
  Future<void> _onProfileRivalRemoveRequested(
    ProfileRivalRemoveRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _firestoreService.removeCurrentRival(event.userId);
      
      final updatedUser = await _firestoreService.getUser(event.userId);
      if (updatedUser != null) {
        emit(ProfileRivalRemoved(user: updatedUser));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Handles penalty add request
  Future<void> _onProfilePenaltyAddRequested(
    ProfilePenaltyAddRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _firestoreService.addPenalty(event.userId);
      
      final updatedUser = await _firestoreService.getUser(event.userId);
      if (updatedUser != null) {
        emit(ProfilePenaltyAdded(user: updatedUser));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Handles user search request
  Future<void> _onProfileUsersSearchRequested(
    ProfileUsersSearchRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileSearching());
    
    try {
      final users = await _firestoreService.searchUsers(
        event.searchTerm,
        limit: event.limit,
      );
      
      emit(ProfileSearchResults(
        users: users,
        searchTerm: event.searchTerm,
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Handles leaderboard position request
  Future<void> _onProfileLeaderboardPositionRequested(
    ProfileLeaderboardPositionRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final user = await _firestoreService.getUser(event.userId);
      if (user == null) {
        emit(const ProfileError(message: 'User not found'));
        return;
      }

      emit(ProfileLeaderboardPositionLoading(user: user));
      
      final position = await _firestoreService.getUserLeaderboardPosition(event.userId);
      if (position != null) {
        emit(ProfileLeaderboardPositionLoaded(
          user: user,
          position: position,
        ));
      } else {
        emit(ProfileError(
          message: 'Could not determine leaderboard position',
          user: user,
        ));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Gets the current user from state
  /// 
  /// @return Current UserModel if available, null otherwise
  UserModel? get currentUser {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      return currentState.user;
    } else if (currentState is ProfileUpdated) {
      return currentState.user;
    } else if (currentState is ProfilePointsUpdated) {
      return currentState.user;
    } else if (currentState is ProfileStreakUpdated) {
      return currentState.user;
    } else if (currentState is ProfileRivalSet) {
      return currentState.user;
    } else if (currentState is ProfileRivalRemoved) {
      return currentState.user;
    } else if (currentState is ProfilePenaltyAdded) {
      return currentState.user;
    } else if (currentState is ProfileError) {
      return currentState.user;
    }
    return null;
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}