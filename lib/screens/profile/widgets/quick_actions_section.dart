/// Quick actions section providing easy access to profile functions.
/// 
/// This widget displays a set of action buttons for common profile
/// operations including editing profile, accessing settings, sharing
/// profile, and logging out. The actions are presented in a clean
/// grid layout with icons and labels for easy navigation.

import 'package:flutter/material.dart';
import '../../../config/theme.dart';

/// Section displaying quick action buttons for profile management
class QuickActionsSection extends StatelessWidget {
  /// Callback for edit profile action
  final VoidCallback onEditProfile;
  
  /// Callback for settings action
  final VoidCallback onSettings;
  
  /// Callback for share profile action
  final VoidCallback onShareProfile;
  
  /// Callback for logout action
  final VoidCallback onLogout;

  /// Creates a QuickActionsSection widget
  /// 
  /// @param onEditProfile Callback when edit profile is tapped
  /// @param onSettings Callback when settings is tapped
  /// @param onShareProfile Callback when share profile is tapped
  /// @param onLogout Callback when logout is tapped
  const QuickActionsSection({
    super.key,
    required this.onEditProfile,
    required this.onSettings,
    required this.onShareProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textWhite,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Actions grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            _buildActionCard(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Update your info',
              color: AppTheme.accentYellow,
              onTap: onEditProfile,
            ),
            _buildActionCard(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'App preferences',
              color: AppTheme.textSecondary,
              onTap: onSettings,
            ),
            _buildActionCard(
              icon: Icons.share_outlined,
              title: 'Share Profile',
              subtitle: 'Show your progress',
              color: AppTheme.rankB,
              onTap: onShareProfile,
            ),
            _buildActionCard(
              icon: Icons.logout_outlined,
              title: 'Logout',
              subtitle: 'Sign out of app',
              color: AppTheme.errorRed,
              onTap: onLogout,
            ),
          ],
        ),
      ],
    );
  }

  /// Builds an individual action card
  /// 
  /// @param icon Icon to display
  /// @param title Main title of the action
  /// @param subtitle Descriptive subtitle
  /// @param color Accent color for the action
  /// @param onTap Callback when card is tapped
  /// @return Widget containing the action card
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}