/// Authentication wrapper that manages the authentication state.
/// 
/// This widget determines whether to show the authentication screens
/// or the main app based on the user's authentication status.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/local_auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../screens/auth/login_screen.dart';
import '../main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalAuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // User is authenticated, show main app
          return const MainScreen();
        } else if (state is AuthUnauthenticated) {
          // User is not authenticated, show login screen
          return const LoginScreen();
        } else if (state is AuthLoading) {
          // Authentication is in progress, show loading
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          // Initial state, show login screen
          return const LoginScreen();
        }
      },
    );
  }
}