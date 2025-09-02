/// Recent activity section showing user's latest achievements and activities.
/// 
/// This widget displays a timeline of recent user activities including
/// workouts completed, challenges participated in, personal records set,
/// and achievements earned. It provides users with a quick overview
/// of their recent fitness journey and accomplishments.

import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/user_model_clean.dart';

/// Section displaying recent user activities and achievements
class RecentActivitySection extends StatelessWidget {
  /// User model containing activity data
  final UserModel user;

  /// Creates a RecentActivitySection widget
  /// 
  /// @param user User model with activity information
  const RecentActivitySection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final activities = _generateMockActivities();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textWhite,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full activity screen
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppTheme.accentYellow,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Activity list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _buildActivityItem(activity);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Recent achievements
        _buildRecentAchievements(),
      ],
    );
  }

  /// Builds an individual activity item
  /// 
  /// @param activity Activity data to display
  /// @return Widget containing the activity item
  Widget _buildActivityItem(ActivityItem activity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activity.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Activity icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Activity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Time and points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.timeAgo,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (activity.points > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${activity.points}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentYellow,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Builds recent achievements section
  /// 
  /// @return Widget containing recent achievements
  Widget _buildRecentAchievements() {
    final achievements = _generateMockAchievements();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Achievements',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textWhite,
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementBadge(achievement);
            },
          ),
        ),
      ],
    );
  }

  /// Builds an individual achievement badge
  /// 
  /// @param achievement Achievement data to display
  /// @return Widget containing the achievement badge
  Widget _buildAchievementBadge(AchievementItem achievement) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            achievement.icon,
            color: achievement.color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            achievement.title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Generates mock activity data based on user info
  /// 
  /// @return List of mock activity items
  List<ActivityItem> _generateMockActivities() {
    return [
      ActivityItem(
        icon: Icons.fitness_center,
        title: 'Chest & Triceps Workout',
        description: 'Completed 45-minute strength training',
        timeAgo: '2 hours ago',
        points: 125,
        color: AppTheme.accentYellow,
      ),
      ActivityItem(
        icon: Icons.emoji_events,
        title: 'Challenge Victory',
        description: 'Won "Weekly Push-up Challenge"',
        timeAgo: '1 day ago',
        points: 200,
        color: AppTheme.successGreen,
      ),
      ActivityItem(
        icon: Icons.trending_up,
        title: 'New Personal Record',
        description: 'Deadlift PR: 180kg (+5kg)',
        timeAgo: '2 days ago',
        points: 50,
        color: AppTheme.rankA,
      ),
      ActivityItem(
        icon: Icons.local_fire_department,
        title: '7-Day Streak Bonus',
        description: 'Earned streak bonus multiplier',
        timeAgo: '3 days ago',
        points: 100,
        color: AppTheme.errorRed,
      ),
      ActivityItem(
        icon: Icons.people,
        title: 'Rival Challenge',
        description: 'Started new rivalry with @fitguru23',
        timeAgo: '5 days ago',
        points: 0,
        color: AppTheme.rankB,
      ),
    ];
  }

  /// Generates mock achievement data
  /// 
  /// @return List of mock achievement items
  List<AchievementItem> _generateMockAchievements() {
    return [
      AchievementItem(
        icon: Icons.military_tech,
        title: 'Iron Will',
        color: AppTheme.accentYellow,
      ),
      AchievementItem(
        icon: Icons.local_fire_department,
        title: 'Fire Starter',
        color: AppTheme.errorRed,
      ),
      AchievementItem(
        icon: Icons.emoji_events,
        title: 'Champion',
        color: AppTheme.successGreen,
      ),
      AchievementItem(
        icon: Icons.trending_up,
        title: 'Personal Best',
        color: AppTheme.rankA,
      ),
    ];
  }
}

/// Data class for activity items
class ActivityItem {
  final IconData icon;
  final String title;
  final String description;
  final String timeAgo;
  final int points;
  final Color color;

  ActivityItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.points,
    required this.color,
  });
}

/// Data class for achievement items
class AchievementItem {
  final IconData icon;
  final String title;
  final Color color;

  AchievementItem({
    required this.icon,
    required this.title,
    required this.color,
  });
}