/// Mock authentication service for testing the app flow without Firebase.
/// 
/// This service simulates authentication operations to test the UI and flow
/// without requiring Firebase setup. Uses in-memory state management.

import 'dart:async';
import '../models/user_model_clean.dart';

class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  UserModel? _currentUser;
  final StreamController<UserModel?> _userController = StreamController<UserModel?>.broadcast();

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges => _userController.stream;

  /// Get current user
  UserModel? get currentUser => _currentUser;

  /// Mock login with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Simple validation for testing
    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = UserModel(
        userId: 'mock_user_123',
        email: email,
        userName: email.split('@')[0],
        displayName: 'Test User',
        currentRank: RankLevel.B,
        totalPoints: 2345,
        weeklyPoints: 156,
        dateJoined: DateTime.now().subtract(const Duration(days: 30)),
        height: 175.0,
        weight: 70.0,
        goalWeight: 68.0,
        fitnessLevel: FitnessLevel.intermediate,
        volumeLifted: 15420.5,
        distanceWalked: 42.3,
        penaltyCount: 0,
        currentStreak: 7,
        longestStreak: 12,
        profilePictureUrl: null,
        lastUpdated: DateTime.now(),
        currentRivalId: 'rival_456',
        rivalSelectionDate: DateTime.now().subtract(const Duration(days: 2)),
      );
      
      _userController.add(_currentUser);
      return _currentUser;
    } else {
      throw Exception('Invalid email or password');
    }
  }

  /// Mock signup with email and password and optional profile data
  Future<UserModel?> createUserWithEmailAndPassword(
    String email, 
    String password, {
    String? userName,
    String? displayName,
    double? height,
    double? weight,
    double? goalWeight,
    FitnessLevel? fitnessLevel,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 2000));

    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = UserModel(
        userId: 'mock_new_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        userName: userName ?? email.split('@')[0],
        displayName: displayName ?? 'New User',
        currentRank: RankLevel.E,
        totalPoints: 0,
        weeklyPoints: 0,
        dateJoined: DateTime.now(),
        height: height,
        weight: weight,
        goalWeight: goalWeight,
        fitnessLevel: fitnessLevel ?? FitnessLevel.beginner,
        volumeLifted: 0.0,
        distanceWalked: 0.0,
        penaltyCount: 0,
        currentStreak: 0,
        longestStreak: 0,
        profilePictureUrl: null,
        lastUpdated: DateTime.now(),
        currentRivalId: null,
        rivalSelectionDate: null,
      );
      
      _userController.add(_currentUser);
      return _currentUser;
    } else {
      throw Exception('Invalid email or password');
    }
  }

  /// Mock sign out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _userController.add(null);
  }

  /// Mock password reset
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // Just simulate success for testing
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
  }

  /// Check initial auth state
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  /// Dispose resources
  void dispose() {
    _userController.close();
  }
}