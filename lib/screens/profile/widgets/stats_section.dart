/// Statistics section displaying key user fitness metrics.
/// 
/// This widget presents various fitness and activity statistics
/// in an organized grid layout with cards. Each stat is displayed
/// with an icon, value, and label for easy comprehension.
/// Statistics include workouts, streaks, volume, distance, and more.

import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/user_model_clean.dart';

/// Section displaying user fitness statistics in card format
class StatsSection extends StatelessWidget {
  /// User model containing statistics data
  final UserModel user;

  /// Creates a StatsSection widget
  /// 
  /// @param user User model with statistics information
  const StatsSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textWhite,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Main stats grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard(
              icon: Icons.fitness_center,
              title: 'Total Workouts',
              value: '${_calculateTotalWorkouts()}',
              color: AppTheme.accentYellow,
            ),
            _buildStatCard(
              icon: Icons.local_fire_department,
              title: 'Current Streak',
              value: '${user.currentStreak} days',
              color: AppTheme.errorRed,
            ),
            _buildStatCard(
              icon: Icons.monitor_weight,
              title: 'Weight Lifted',
              value: '${_formatWeight(user.volumeLifted)}',
              color: AppTheme.successGreen,
            ),
            _buildStatCard(
              icon: Icons.directions_walk,
              title: 'Distance',
              value: '${_formatDistance(user.distanceWalked)}',
              color: AppTheme.rankB,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Additional stats row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.emoji_events,
                title: 'Weekly Points',
                value: '${user.weeklyPoints}',
                color: AppTheme.getRankColor(user.currentRank.name),
                isWide: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.warning,
                title: 'Penalties',
                value: '${user.penaltyCount}',
                color: AppTheme.errorRed,
                isWide: true,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Achievement stats
        _buildAchievementStats(context),
      ],
    );
  }

  /// Builds an individual stat card
  /// 
  /// @param icon Icon to display
  /// @param title Title of the statistic
  /// @param value Value to display
  /// @param color Accent color for the card
  /// @param isWide Whether this is a wide card layout
  /// @return Widget containing the stat card
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: isWide ? 20 : 24,
              ),
              if (isWide)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Week',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            value,
            style: TextStyle(
              fontSize: isWide ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            title,
            style: TextStyle(
              fontSize: isWide ? 11 : 12,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Builds the achievement statistics section
  /// 
  /// @return Widget containing achievement stats
  Widget _buildAchievementStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentYellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.military_tech,
                color: AppTheme.accentYellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAchievementItem(
                'Challenges',
                '${_calculateChallengesCompleted()}',
                Icons.emoji_events,
              ),
              _buildAchievementItem(
                'Rival Wins',
                '${_calculateRivalWins()}',
                Icons.emoji_events_outlined,
              ),
              _buildAchievementItem(
                'Best Streak',
                '${user.longestStreak}',
                Icons.local_fire_department_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds an individual achievement item
  /// 
  /// @param label Label for the achievement
  /// @param value Value to display
  /// @param icon Icon for the achievement
  /// @return Widget containing achievement item
  Widget _buildAchievementItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.textSecondary,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textWhite,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Calculate total workouts completed (mock calculation)
  /// 
  /// @return Estimated number of workouts
  int _calculateTotalWorkouts() {
    // Mock calculation based on points and streak
    return (user.totalPoints / 50).round() + user.longestStreak;
  }

  /// Calculate total challenges completed (mock calculation)
  /// 
  /// @return Estimated number of challenges completed
  int _calculateChallengesCompleted() {
    // Mock calculation based on total points
    return (user.totalPoints / 200).round();
  }

  /// Calculate rival wins (mock calculation)
  /// 
  /// @return Estimated number of rival wins
  int _calculateRivalWins() {
    // Mock calculation based on total points and current rank
    final rankMultiplier = user.currentRank.index + 1;
    return (user.totalPoints / (300 * rankMultiplier)).round();
  }

  /// Format weight value for display
  /// 
  /// @param weight Weight in kilograms
  /// @return Formatted weight string
  String _formatWeight(double weight) {
    if (weight >= 1000) {
      return '${(weight / 1000).toStringAsFixed(1)}t';
    } else {
      return '${weight.toStringAsFixed(0)}kg';
    }
  }

  /// Format distance value for display
  /// 
  /// @param distance Distance in kilometers
  /// @return Formatted distance string
  String _formatDistance(double distance) {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}Mkm';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
}