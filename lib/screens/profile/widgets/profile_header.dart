/// Profile header widget displaying user avatar, name, rank and progress.
/// 
/// This widget shows the main user identification information including
/// profile picture or initials, display name, username, current rank badge,
/// rank progress bar, and total points. It provides a visual overview
/// of the user's identity and progression in the RivalX system.

import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/user_model_clean.dart';
import 'rank_badge.dart';

/// Header section of the profile displaying user info and rank progression
class ProfileHeader extends StatelessWidget {
  /// User model containing profile information
  final UserModel user;

  /// Creates a ProfileHeader widget
  /// 
  /// @param user User model with profile data
  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getRankColor(user.currentRank.name),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Avatar and basic info
          Row(
            children: [
              // Profile Avatar
              _buildAvatar(),
              
              const SizedBox(width: 16),
              
              // Name and username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.userName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_getDaysJoined()} days on RivalX',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Rank Badge
              RankBadge(
                rank: user.currentRank.name,
                size: 60,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Points and rank progress
          _buildRankProgress(context),
        ],
      ),
    );
  }

  /// Builds the profile avatar with initials or profile picture
  /// 
  /// @return Widget containing avatar
  Widget _buildAvatar() {
    if (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(user.profilePictureUrl!),
        backgroundColor: AppTheme.slateGrey,
      );
    } else {
      // Generate initials from display name
      final initials = _getInitials(user.displayName);
      return CircleAvatar(
        radius: 40,
        backgroundColor: AppTheme.getRankColor(user.currentRank.name),
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlack,
          ),
        ),
      );
    }
  }

  /// Builds the rank progress section showing points and progress bar
  /// 
  /// @param context Build context
  /// @return Widget containing rank progress information
  Widget _buildRankProgress(BuildContext context) {
    final pointsToNext = user.pointsToNextRank;
    final isMaxRank = user.currentRank == RankLevel.SS;
    
    return Column(
      children: [
        // Total points display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Points',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              '${user.totalPoints}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.accentYellow,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Rank progress
        if (!isMaxRank) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rank ${user.currentRank.name}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.getRankColor(user.currentRank.name),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$pointsToNext points to ${_getNextRank()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Progress bar
          LinearProgressIndicator(
            value: _calculateProgress(),
            backgroundColor: AppTheme.slateGrey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.getRankColor(user.currentRank.name),
            ),
            minHeight: 6,
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: AppTheme.getRankColor('SS'),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Maximum Rank Achieved!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.getRankColor('SS'),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Gets initials from display name
  /// 
  /// @param name Full display name
  /// @return String containing initials (max 2 characters)
  String _getInitials(String name) {
    if (name.isEmpty) return 'RX';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
    }
  }

  /// Calculates days since user joined
  /// 
  /// @return Number of days since joining
  int _getDaysJoined() {
    final now = DateTime.now();
    final difference = now.difference(user.dateJoined);
    return difference.inDays;
  }

  /// Gets the next rank level
  /// 
  /// @return String representation of next rank
  String _getNextRank() {
    switch (user.currentRank) {
      case RankLevel.E:
        return 'D';
      case RankLevel.D:
        return 'C';
      case RankLevel.C:
        return 'B';
      case RankLevel.B:
        return 'A';
      case RankLevel.A:
        return 'S';
      case RankLevel.S:
        return 'SS';
      case RankLevel.SS:
        return 'SS';
    }
  }

  /// Calculates progress percentage to next rank
  /// 
  /// @return Double between 0.0 and 1.0 representing progress
  double _calculateProgress() {
    final currentRankThreshold = _getCurrentRankThreshold();
    final nextRankThreshold = _getNextRankThreshold();
    
    if (nextRankThreshold == currentRankThreshold) {
      return 1.0; // Max rank
    }
    
    final progress = (user.totalPoints - currentRankThreshold) / 
                    (nextRankThreshold - currentRankThreshold);
    
    return progress.clamp(0.0, 1.0);
  }

  /// Gets the point threshold for current rank
  /// 
  /// @return Point threshold for current rank
  int _getCurrentRankThreshold() {
    switch (user.currentRank) {
      case RankLevel.E:
        return 0;
      case RankLevel.D:
        return 1000;
      case RankLevel.C:
        return 3000;
      case RankLevel.B:
        return 7000;
      case RankLevel.A:
        return 15000;
      case RankLevel.S:
        return 30000;
      case RankLevel.SS:
        return 60000;
    }
  }

  /// Gets the point threshold for next rank
  /// 
  /// @return Point threshold for next rank
  int _getNextRankThreshold() {
    switch (user.currentRank) {
      case RankLevel.E:
        return 1000;
      case RankLevel.D:
        return 3000;
      case RankLevel.C:
        return 7000;
      case RankLevel.B:
        return 15000;
      case RankLevel.A:
        return 30000;
      case RankLevel.S:
        return 60000;
      case RankLevel.SS:
        return 60000; // Max rank
    }
  }
}