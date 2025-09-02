/// Comprehensive profile screen for the RivalX fitness app.
/// 
/// This screen displays user profile information, fitness statistics,
/// rank progression, recent activities, and provides access to settings
/// and account management features. It serves as the central hub for
/// users to view their fitness journey and manage their account.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../models/user_model_clean.dart';
import '../../blocs/auth/local_auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'settings_screen.dart';
import 'widgets/profile_header.dart';
import 'widgets/stats_section.dart';
import 'widgets/quick_actions_section.dart';
import 'widgets/recent_activity_section.dart';

/// Main profile screen displaying user information and statistics
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalAuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return _buildProfileContent(context, state.user);
        } else if (state is AuthLoading) {
          return const Scaffold(
            backgroundColor: AppTheme.darkBackground,
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentYellow,
              ),
            ),
          );
        } else {
          return const Scaffold(
            backgroundColor: AppTheme.darkBackground,
            body: Center(
              child: Text(
                'Not authenticated',
                style: TextStyle(color: AppTheme.textWhite),
              ),
            ),
          );
        }
      },
    );
  }

  /// Builds the main profile content when user is authenticated
  /// 
  /// @param context Build context
  /// @param user Authenticated user model
  /// @return Widget containing complete profile UI
  Widget _buildProfileContent(BuildContext context, UserModel user) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppTheme.accentYellow,
            ),
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            ProfileHeader(user: user),
            
            const SizedBox(height: 24),
            
            // Stats Section
            StatsSection(user: user),
            
            const SizedBox(height: 24),
            
            // Quick Actions Section
            QuickActionsSection(
              onEditProfile: () => _editProfile(context),
              onSettings: () => _navigateToSettings(context),
              onShareProfile: () => _shareProfile(context),
              onLogout: () => _logout(context),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Activity Section
            RecentActivitySection(user: user),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Navigate to settings screen
  /// 
  /// @param context Build context
  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  /// Handle edit profile action
  /// 
  /// @param context Build context
  void _editProfile(BuildContext context) {
    // TODO: Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit profile feature coming soon!'),
        backgroundColor: AppTheme.accentYellow,
      ),
    );
  }

  /// Handle share profile action
  /// 
  /// @param context Build context
  void _shareProfile(BuildContext context) {
    // TODO: Implement profile sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share profile feature coming soon!'),
        backgroundColor: AppTheme.accentYellow,
      ),
    );
  }

  /// Handle logout action
  /// 
  /// @param context Build context
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text(
            'Logout',
            style: TextStyle(color: AppTheme.textWhite),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<LocalAuthBloc>().add(const AuthLogout());
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: AppTheme.accentYellow),
              ),
            ),
          ],
        );
      },
    );
  }
}