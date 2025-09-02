/// Mock Authentication BLoC for testing without Firebase.
/// 
/// This BLoC handles authentication operations using the mock auth service
/// to test the UI flow without requiring Firebase setup.

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rivalx/blocs/auth/auth_event.dart';
import 'package:rivalx/blocs/auth/auth_state.dart';
import 'package:rivalx/services/mock_auth_service.dart';
import 'package:rivalx/models/user_model_clean.dart';

/// BLoC for managing mock authentication state and operations
class MockAuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Mock authentication service instance
  final MockAuthService _authService;
  
  /// Subscription to auth state changes
  StreamSubscription<UserModel?>? _authStateSubscription;

  /// Creates a MockAuthBloc instance
  MockAuthBloc({required MockAuthService authService})
      : _authService = authService,
        super(const AuthInitial()) {
    // Register event handlers
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthStateChanged>(_onUserChanged);

    // Listen to auth state changes
    _authStateSubscription = _authService.authStateChanges.listen(
      (user) {
        add(AuthStateChanged(user: user));
      },
    );
  }

  /// Handle auth check requested event
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle sign in requested event
  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      await _authService.signInWithEmailAndPassword(event.email, event.password);
      // User state will be updated via stream subscription
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle sign up requested event
  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      await _authService.createUserWithEmailAndPassword(
        event.email, 
        event.password,
        userName: event.userName,
        displayName: event.displayName,
        height: event.height,
        weight: event.weight,
        goalWeight: event.goalWeight,
        fitnessLevel: event.fitnessLevel,
      );
      // User state will be updated via stream subscription
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle sign out requested event
  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      await _authService.signOut();
      // User state will be updated via stream subscription
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle password reset requested event
  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      await _authService.sendPasswordResetEmail(event.email);
      emit(AuthPasswordResetSent(email: event.email));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle user changed event (from stream subscription)
  void _onUserChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(user: event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}