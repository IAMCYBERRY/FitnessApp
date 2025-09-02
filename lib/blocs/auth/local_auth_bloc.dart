/// Local Authentication BLoC for RivalX app.
/// 
/// This BLoC handles user authentication using local storage instead of Firebase.
/// Provides signup, login, logout functionality with persistent sessions.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import '../../models/user_model_clean.dart';
import '../../services/local_storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Local authentication BLoC implementation
class LocalAuthBloc extends Bloc<AuthEvent, AuthState> {
  LocalAuthBloc() : super(const AuthInitial()) {
    on<AuthLogin>(_onLogin);
    on<AuthSignup>(_onSignup);
    on<AuthLogout>(_onLogout);
    on<AuthCheckSession>(_onCheckSession);
    on<AuthUpdateUser>(_onUpdateUser);
  }

  /// Handle login event
  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      // Debug: Check if database has any users
      final allUsers = await UserStorageService.getAllUsers();
      print('🔍 Login attempt for: ${event.identifier}');
      print('📊 Total users in database: ${allUsers.length}');
      
      // Find user by email or username
      UserModel? user;
      
      if (event.identifier.contains('@')) {
        user = await UserStorageService.getUserByEmail(event.identifier);
        if (user == null) {
          emit(AuthError(message: 'No account found with email: ${event.identifier}'));
          return;
        }
      } else {
        user = await UserStorageService.getUserByUsername(event.identifier);
        if (user == null) {
          emit(AuthError(message: 'No account found with username: ${event.identifier}'));
          return;
        }
      }

      // Verify password
      final storedPassword = await _getStoredPassword(user.userId);
      
      // Check if password exists (user has signed up)
      if (storedPassword == null) {
        emit(const AuthError(message: 'Invalid email or password. Please try again.'));
        return;
      }
      
      // Hash the provided password and compare
      final hashedPassword = _hashPassword(event.password, user.userId);
      
      if (storedPassword != hashedPassword) {
        emit(const AuthError(message: 'Invalid email or password. Please try again.'));
        return;
      }

      // Save session
      await AuthStorageService.saveUserSession(user, rememberMe: event.rememberMe);
      
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: 'Login failed: ${e.toString()}'));
    }
  }

  /// Handle signup event
  Future<void> _onSignup(AuthSignup event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      // Validate input
      final validationError = _validateSignupData(
        event.username,
        event.email,
        event.password,
        event.displayName,
      );

      if (validationError != null) {
        emit(AuthError(message: validationError));
        return;
      }

      // Check if username or email already exists
      if (await UserStorageService.usernameExists(event.username)) {
        emit(const AuthError(message: 'Username already exists. Please choose a different one.'));
        return;
      }

      if (await UserStorageService.emailExists(event.email)) {
        emit(const AuthError(message: 'Email already registered. Please use a different email.'));
        return;
      }

      // Create new user
      final userId = _generateUserId();
      final user = UserModel(
        userId: userId,
        userName: event.username,
        email: event.email,
        displayName: event.displayName,
        totalPoints: 0,
        weeklyPoints: 0,
        currentRank: RankLevel.E,
        currentStreak: 0,
        longestStreak: 0,
        volumeLifted: 0.0,
        distanceWalked: 0.0,
        penaltyCount: 0,
        fitnessLevel: event.fitnessLevel,
        dateJoined: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      // Save user to database
      await UserStorageService.saveUser(user);
      
      // Store password hash
      await _storePassword(userId, event.password);
      
      // Save session
      await AuthStorageService.saveUserSession(user);
      
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: 'Signup failed: ${e.toString()}'));
    }
  }

  /// Handle logout event
  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    try {
      await AuthStorageService.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Logout failed: ${e.toString()}'));
    }
  }

  /// Handle check session event
  Future<void> _onCheckSession(AuthCheckSession event, Emitter<AuthState> emit) async {
    try {
      final user = await AuthStorageService.getCurrentUser();
      
      if (user != null) {
        // Refresh user data from database
        final freshUser = await UserStorageService.getUser(user.userId);
        
        if (freshUser != null) {
          emit(AuthAuthenticated(user: freshUser));
        } else {
          // User not found in database, clear session
          await AuthStorageService.logout();
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle user update event
  Future<void> _onUpdateUser(AuthUpdateUser event, Emitter<AuthState> emit) async {
    if (state is AuthAuthenticated) {
      try {
        await UserStorageService.updateUser(event.user);
        emit(AuthAuthenticated(user: event.user));
      } catch (e) {
        emit(AuthError(message: 'Failed to update user: ${e.toString()}'));
      }
    }
  }

  /// Validate signup data
  String? _validateSignupData(String username, String email, String password, String displayName) {
    // Username validation
    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    if (username.length > 20) {
      return 'Username must be 20 characters or less';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    // Email validation
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // Password validation
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    // Display name validation
    if (displayName.trim().length < 2) {
      return 'Display name must be at least 2 characters long';
    }

    if (displayName.trim().length > 50) {
      return 'Display name must be 50 characters or less';
    }

    return null;
  }

  /// Generate unique user ID
  String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'user_${timestamp}_$random';
  }

  /// Hash password with salt
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Store password hash
  Future<void> _storePassword(String userId, String password) async {
    final hashedPassword = _hashPassword(password, userId);
    final prefs = LocalStorageService.instance.prefs;
    await prefs.setString('password_$userId', hashedPassword);
  }

  /// Get stored password hash
  Future<String?> _getStoredPassword(String userId) async {
    final prefs = LocalStorageService.instance.prefs;
    return prefs.getString('password_$userId');
  }
}

/// Authentication helper methods
extension LocalAuthBlocHelpers on LocalAuthBloc {
  /// Get current authenticated user
  UserModel? get currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
    }
    return null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => state is AuthAuthenticated;

  /// Get user ID if authenticated
  String? get currentUserId => currentUser?.userId;
}