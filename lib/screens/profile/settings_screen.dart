/// Settings screen for managing user preferences and account settings.
/// 
/// This screen provides access to various app settings including
/// account management, notification preferences, privacy settings,
/// app preferences, and general information. It follows the RivalX
/// design theme and provides a comprehensive settings experience.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../blocs/auth/local_auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';

/// Settings screen containing various user and app preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock settings state
  bool notificationsEnabled = true;
  bool challengeNotifications = true;
  bool rivalNotifications = true;
  bool achievementNotifications = true;
  bool darkModeEnabled = true;
  bool analyticsEnabled = false;
  bool biometricsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Settings
            _buildSettingsSection(
              title: 'Account',
              children: [
                _buildSettingsTile(
                  icon: Icons.person_outlined,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () => _showComingSoon(context),
                ),
                _buildSettingsTile(
                  icon: Icons.lock_outlined,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () => _showComingSoon(context),
                ),
                _buildSettingsTile(
                  icon: Icons.fingerprint,
                  title: 'Biometric Login',
                  subtitle: 'Use fingerprint or face unlock',
                  trailing: Switch(
                    value: biometricsEnabled,
                    onChanged: (value) {
                      setState(() {
                        biometricsEnabled = value;
                      });
                    },
                    activeColor: AppTheme.accentYellow,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notification Settings
            _buildSettingsSection(
              title: 'Notifications',
              children: [
                _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Enable or disable all notifications',
                  trailing: Switch(
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                    activeColor: AppTheme.accentYellow,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.emoji_events_outlined,
                  title: 'Challenge Updates',
                  subtitle: 'Notifications for challenge activities',
                  trailing: Switch(
                    value: challengeNotifications,
                    onChanged: notificationsEnabled ? (value) {
                      setState(() {
                        challengeNotifications = value;
                      });
                    } : null,
                    activeColor: AppTheme.accentYellow,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.people_outlined,
                  title: 'Rival Activities',
                  subtitle: 'Updates from your rivals',
                  trailing: Switch(
                    value: rivalNotifications,
                    onChanged: notificationsEnabled ? (value) {
                      setState(() {
                        rivalNotifications = value;
                      });
                    } : null,
                    activeColor: AppTheme.accentYellow,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.military_tech_outlined,
                  title: 'Achievements',
                  subtitle: 'Notifications for new achievements',
                  trailing: Switch(
                    value: achievementNotifications,
                    onChanged: notificationsEnabled ? (value) {
                      setState(() {
                        achievementNotifications = value;
                      });
                    } : null,
                    activeColor: AppTheme.accentYellow,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Privacy Settings
            _buildSettingsSection(
              title: 'Privacy',
              children: [
                _buildSettingsTile(
                  icon: Icons.visibility_outlined,
                  title: 'Profile Visibility',
                  subtitle: 'Control who can see your profile',
                  onTap: () => _showComingSoon(context),
                ),
                _buildSettingsTile(
                  icon: Icons.analytics_outlined,
                  title: 'Analytics & Data',
                  subtitle: 'Help improve the app with usage data',
                  trailing: Switch(
                    value: analyticsEnabled,
                    onChanged: (value) {
                      setState(() {
                        analyticsEnabled = value;
                      });
                    },
                    activeColor: AppTheme.accentYellow,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.block_outlined,
                  title: 'Blocked Users',
                  subtitle: 'Manage blocked users',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Preferences
            _buildSettingsSection(
              title: 'App Preferences',
              children: [
                _buildSettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Use dark theme (recommended)',
                  trailing: Switch(
                    value: darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        darkModeEnabled = value;
                      });
                    },
                    activeColor: AppTheme.accentYellow,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.fitness_center_outlined,
                  title: 'Unit Preferences',
                  subtitle: 'Metric or Imperial units',
                  onTap: () => _showComingSoon(context),
                ),
                _buildSettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'English (US)',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // About & Support
            _buildSettingsSection(
              title: 'About & Support',
              children: [
                _buildSettingsTile(
                  icon: Icons.help_outlined,
                  title: 'Help & Support',
                  subtitle: 'Get help with using RivalX',
                  onTap: () => _showComingSoon(context),
                ),
                _buildSettingsTile(
                  icon: Icons.info_outlined,
                  title: 'About RivalX',
                  subtitle: 'Version 1.0.0',
                  onTap: () => _showAbout(context),
                ),
                _buildSettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms and conditions',
                  onTap: () => _showComingSoon(context),
                ),
                _buildSettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'How we protect your data',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Danger Zone
            _buildSettingsSection(
              title: 'Account Management',
              children: [
                _buildSettingsTile(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  titleColor: AppTheme.errorRed,
                  onTap: () => _showLogoutDialog(context),
                ),
                _buildSettingsTile(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  titleColor: AppTheme.errorRed,
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Builds a settings section with title and children
  /// 
  /// @param title Section title
  /// @param children List of settings items
  /// @return Widget containing the settings section
  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textWhite,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  /// Builds an individual settings tile
  /// 
  /// @param icon Icon for the setting
  /// @param title Setting title
  /// @param subtitle Setting description
  /// @param onTap Tap callback
  /// @param trailing Optional trailing widget
  /// @param titleColor Optional title color override
  /// @return Widget containing the settings tile
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: titleColor ?? AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows coming soon dialog
  /// 
  /// @param context Build context
  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text(
            'Coming Soon',
            style: TextStyle(color: AppTheme.textWhite),
          ),
          content: const Text(
            'This feature is coming in a future update!',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: AppTheme.accentYellow),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows about dialog
  /// 
  /// @param context Build context
  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text(
            'About RivalX',
            style: TextStyle(color: AppTheme.textWhite),
          ),
          content: const Text(
            'RivalX v1.0.0\n\nRevolutionizing fitness through competitive gamification. '
            'Track your workouts, challenge friends, and rise through the ranks!\n\n'
            'Made with ❤️ for fitness enthusiasts.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: AppTheme.accentYellow),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows logout confirmation dialog
  /// 
  /// @param context Build context
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text(
            'Sign Out',
            style: TextStyle(color: AppTheme.textWhite),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close settings
                context.read<LocalAuthBloc>().add(const AuthLogout());
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: AppTheme.errorRed),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows delete account confirmation dialog
  /// 
  /// @param context Build context
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text(
            'Delete Account',
            style: TextStyle(color: AppTheme.errorRed),
          ),
          content: const Text(
            'This action cannot be undone. All your data will be permanently deleted.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showComingSoon(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppTheme.errorRed),
              ),
            ),
          ],
        );
      },
    );
  }
}