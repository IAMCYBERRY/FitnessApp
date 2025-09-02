/// Authentication events for the auth BLoC.
/// 
/// These events represent all possible authentication-related actions
/// that can be triggered in the app, such as sign in, sign up, and sign out.

import 'package:equatable/equatable.dart';
import 'package:rivalx/models/user_model_clean.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when checking initial authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event triggered when user attempts to sign up with email/password
class AuthSignUpRequested extends AuthEvent {
  /// Email address for the new account
  final String email;
  
  /// Password for the new account
  final String password;
  
  /// Unique username
  final String userName;
  
  /// Display name for the user
  final String displayName;
  
  /// Optional height in centimeters
  final double? height;
  
  /// Optional weight in kilograms
  final double? weight;
  
  /// Optional goal weight in kilograms
  final double? goalWeight;
  
  /// Optional fitness level
  final FitnessLevel? fitnessLevel;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.userName,
    required this.displayName,
    this.height,
    this.weight,
    this.goalWeight,
    this.fitnessLevel,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        userName,
        displayName,
        height,
        weight,
        goalWeight,
        fitnessLevel,
      ];
}

/// Event triggered when user attempts to sign in with email/password
class AuthSignInRequested extends AuthEvent {
  /// Email address for sign in
  final String email;
  
  /// Password for sign in
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event triggered when user attempts to sign in with biometrics
class AuthBiometricSignInRequested extends AuthEvent {
  const AuthBiometricSignInRequested();
}

/// Event triggered when user requests to sign out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Event triggered when user requests password reset
class AuthPasswordResetRequested extends AuthEvent {
  /// Email address to send reset link to
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event triggered when authentication state changes
class AuthStateChanged extends AuthEvent {
  /// The updated user model, null if signed out
  final UserModel? user;

  const AuthStateChanged({this.user});

  @override
  List<Object?> get props => [user];
}

/// Event triggered to check existing session on app start
class AuthCheckSession extends AuthEvent {
  const AuthCheckSession();
}

/// Event triggered for login with username/email and password
class AuthLogin extends AuthEvent {
  /// Username or email for login
  final String identifier;
  
  /// Password for login
  final String password;
  
  /// Whether to remember user session
  final bool rememberMe;

  const AuthLogin({
    required this.identifier,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [identifier, password, rememberMe];
}

/// Event triggered for user signup
class AuthSignup extends AuthEvent {
  /// Unique username
  final String username;
  
  /// Email address
  final String email;
  
  /// Password
  final String password;
  
  /// Display name
  final String displayName;
  
  /// Optional fitness level
  final FitnessLevel? fitnessLevel;

  const AuthSignup({
    required this.username,
    required this.email,
    required this.password,
    required this.displayName,
    this.fitnessLevel,
  });

  @override
  List<Object?> get props => [username, email, password, displayName, fitnessLevel];
}

/// Event triggered for logout
class AuthLogout extends AuthEvent {
  const AuthLogout();
}

/// Event triggered to update user information
class AuthUpdateUser extends AuthEvent {
  /// Updated user model
  final UserModel user;

  const AuthUpdateUser({required this.user});

  @override
  List<Object?> get props => [user];
}