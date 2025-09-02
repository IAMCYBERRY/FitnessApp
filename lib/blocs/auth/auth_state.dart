/// Authentication states for the auth BLoC.
/// 
/// These states represent the various authentication states the app
/// can be in, such as authenticated, unauthenticated, or loading.

import 'package:equatable/equatable.dart';
import 'package:rivalx/models/user_model_clean.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when authentication is being processed
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is successfully authenticated
class AuthAuthenticated extends AuthState {
  /// The authenticated user's data
  final UserModel user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State when authentication fails with an error
class AuthError extends AuthState {
  /// Error message to display to the user
  final String message;
  
  /// Optional error code for specific error handling
  final String? code;

  const AuthError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// State when password reset email is successfully sent
class AuthPasswordResetSent extends AuthState {
  /// Email address the reset link was sent to
  final String email;

  const AuthPasswordResetSent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// State when biometric authentication is available
class AuthBiometricAvailable extends AuthState {
  /// Whether biometrics are available on the device
  final bool isAvailable;
  
  /// Types of biometrics available (fingerprint, face, etc.)
  final List<String> availableTypes;

  const AuthBiometricAvailable({
    required this.isAvailable,
    required this.availableTypes,
  });

  @override
  List<Object?> get props => [isAvailable, availableTypes];
}