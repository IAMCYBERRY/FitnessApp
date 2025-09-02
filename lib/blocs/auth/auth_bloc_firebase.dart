/// Authentication BLoC for managing authentication state.
/// 
/// This BLoC handles all authentication-related business logic including
/// sign in, sign up, sign out, and biometric authentication. It coordinates
/// between the UI layer and the authentication service.

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rivalx/blocs/auth/auth_event.dart';
import 'package:rivalx/blocs/auth/auth_state.dart';
import 'package:rivalx/services/auth_service.dart';
import 'package:rivalx/models/user_model.dart';

/// BLoC for managing authentication state and operations
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Authentication service instance
  final AuthService _authService;
  
  /// Subscription to auth state changes
  StreamSubscription<User?>? _authStateSubscription;

  /// Creates an AuthBloc instance
  /// 
  /// @param authService The authentication service to use
  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthInitial()) {
    // Register event handlers
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthBiometricSignInRequested>(_onAuthBiometricSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Listen to auth state changes
    _authStateSubscription = _authService.authStateChanges.listen(
      (user) async {
        if (user != null) {
          // Fetch user data from Firestore
          try {
            final userDoc = await _authService
                .currentUser!
                .getIdTokenResult();
            // Note: In production, fetch user data from Firestore here
            // For now, we'll trigger AuthCheckRequested
            add(const AuthCheckRequested());
          } catch (e) {
            add(const AuthStateChanged(user: null));
          }
        } else {
          add(const AuthStateChanged(user: null));
        }
      },
    );
  }

  /// Handles initial authentication check
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // In production, fetch user data from Firestore
        // For now, create a temporary user model
        final user = UserModel(
          userId: currentUser.uid,
          email: currentUser.email ?? '',
          userName: currentUser.displayName ?? 'User',
          displayName: currentUser.displayName ?? 'User',
          currentRank: RankLevel.E,
          totalPoints: 0,
          weeklyPoints: 0,
          dateJoined: currentUser.metadata.creationTime ?? DateTime.now(),
          volumeLifted: 0,
          distanceWalked: 0,
          penaltyCount: 0,
          currentStreak: 0,
          longestStreak: 0,
          lastUpdated: DateTime.now(),
        );
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles sign up request
  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authService.signUpWithEmailPassword(
        email: event.email,
        password: event.password,
        userName: event.userName,
        displayName: event.displayName,
        height: event.height,
        weight: event.weight,
        goalWeight: event.goalWeight,
        fitnessLevel: event.fitnessLevel,
      );
      
      emit(AuthAuthenticated(user: user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(
        message: e.message ?? 'Sign up failed',
        code: e.code,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles sign in request
  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authService.signInWithEmailPassword(
        email: event.email,
        password: event.password,
      );
      
      emit(AuthAuthenticated(user: user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(
        message: e.message ?? 'Sign in failed',
        code: e.code,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles biometric sign in request
  Future<void> _onAuthBiometricSignInRequested(
    AuthBiometricSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authService.signInWithBiometrics();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles sign out request
  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      await _authService.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles password reset request
  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      await _authService.sendPasswordResetEmail(event.email);
      emit(AuthPasswordResetSent(email: event.email));
      
      // Return to unauthenticated state after showing success
      await Future.delayed(const Duration(seconds: 3));
      emit(const AuthUnauthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(
        message: e.message ?? 'Failed to send reset email',
        code: e.code,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles authentication state changes
  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user != null) {
      emit(AuthAuthenticated(user: event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Checks if biometric authentication is available
  /// 
  /// @return true if biometrics are available
  Future<bool> isBiometricAvailable() async {
    return await _authService.isBiometricAvailable();
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}