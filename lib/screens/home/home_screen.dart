/// Home screen dashboard for the RivalX app.
/// 
/// Displays user stats, rank progress, quick actions, and activity summaries.
/// Serves as the main hub for users to see their fitness journey at a glance.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../models/user_model_clean.dart';
import '../../models/muscle_group.dart';
import '../../blocs/auth/local_auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/points/points_bloc.dart';
import '../../blocs/points/points_state.dart';
import '../debug/debug_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalAuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            backgroundColor: AppTheme.darkBackground,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.accentYellow),
            ),
          );
        }

        final user = authState.user;

        return BlocBuilder<PointsBloc, PointsState>(
          builder: (context, pointsState) {
            // Use real user data from authenticated state and points
            final currentUser = pointsState is PointsLoaded 
                ? user.copyWith(
                    totalPoints: pointsState.totalPoints,
                    weeklyPoints: pointsState.weeklyPoints,
                    currentRank: pointsState.currentRank,
                    currentStreak: pointsState.currentStreak,
                  )
                : user;

            return _buildHomeContent(context, currentUser, pointsState);
          },
        );
      },
    );
  }

  Widget _buildHomeContent(BuildContext context, UserModel user, PointsState pointsState) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: AppTheme.darkBackground,
              elevation: 0,
              pinned: true,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: SizedBox(
                  height: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: AppTheme.textPrimary,
                  onPressed: () {
                    // TODO: Navigate to notifications
                  },
                ),
                // Debug button for development
                IconButton(
                  icon: const Icon(Icons.bug_report),
                  color: AppTheme.textSecondary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DebugScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Rank Progress Card
                  _buildRankProgressCard(context, user),
                  const SizedBox(height: 16),
                  // Stats Grid
                  _buildStatsGrid(context, user),
                  const SizedBox(height: 24),
                  // Muscle Group Breakdown
                  _buildMuscleGroupBreakdown(context),
                  const SizedBox(height: 24),
                  // Quick Actions
                  _buildQuickActionsSection(context),
                  const SizedBox(height: 24),
                  // Recent Activity
                  _buildRecentActivitySection(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankProgressCard(BuildContext context, UserModel user) {
    final nextRank = _getNextRank(user.currentRank);
    final progress = _calculateRankProgress(user.totalPoints);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.getRankColor(user.currentRank.name).withOpacity(0.3),
            AppTheme.getRankColor(user.currentRank.name).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getRankColor(user.currentRank.name).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.getRankColor(user.currentRank.name),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.getRankColor(user.currentRank.name).withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.currentRank.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Rank',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${user.totalPoints} Points',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress to Rank $nextRank',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.getRankColor(nextRank),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.surfaceColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.getRankColor(nextRank),
                ),
                minHeight: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, UserModel user) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          context,
          icon: Icons.fitness_center,
          title: 'Weight Lifted',
          value: '${(user.volumeLifted / 1000).toStringAsFixed(1)}k lbs',
          color: AppTheme.accentYellow,
        ),
        _buildStatCard(
          context,
          icon: Icons.directions_walk,
          title: 'Distance',
          value: '${user.distanceWalked.toStringAsFixed(1)} km',
          color: Colors.blue,
        ),
        _buildStatCard(
          context,
          icon: Icons.local_fire_department,
          title: 'Streak',
          value: '${user.currentStreak} days',
          color: Colors.orange,
        ),
        _buildStatCard(
          context,
          icon: Icons.emoji_events,
          title: 'Weekly Points',
          value: user.weeklyPoints.toString(),
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionButton(
              context,
              icon: Icons.add_circle,
              label: 'Log Workout',
              color: AppTheme.accentYellow,
              onTap: () {
                // TODO: Navigate to workout logging
              },
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.restaurant_menu,
              label: 'Log Meal',
              color: Colors.green,
              onTap: () {
                // TODO: Navigate to meal logging
              },
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.sports_martial_arts,
              label: 'Daily Challenge',
              color: Colors.orange,
              onTap: () {
                // TODO: Navigate to daily challenge
              },
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.person_add,
              label: 'Find Rival',
              color: Colors.red,
              onTap: () {
                // TODO: Navigate to rival search
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to activity history
              },
              child: const Text(
                'See All',
                style: TextStyle(color: AppTheme.accentYellow),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Activity items
        _buildActivityItem(
          context,
          icon: Icons.fitness_center,
          title: 'Upper Body Workout',
          subtitle: '45 minutes • 8,240 lbs lifted',
          time: '2 hours ago',
          points: '+45',
        ),
        _buildActivityItem(
          context,
          icon: Icons.restaurant,
          title: 'Lunch Logged',
          subtitle: 'Grilled Chicken Salad • 420 cal',
          time: '4 hours ago',
          points: '+10',
        ),
        _buildActivityItem(
          context,
          icon: Icons.emoji_events,
          title: 'Rival Mode Victory!',
          subtitle: 'Defeated @musclemike • Stole 23 points',
          time: 'Yesterday',
          points: '+23',
          isHighlight: true,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required String points,
    bool isHighlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppTheme.accentYellow.withOpacity(0.1)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight
              ? AppTheme.accentYellow.withOpacity(0.3)
              : AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isHighlight
                  ? AppTheme.accentYellow.withOpacity(0.2)
                  : AppTheme.darkBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isHighlight ? AppTheme.accentYellow : AppTheme.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isHighlight ? AppTheme.accentYellow : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleGroupBreakdown(BuildContext context) {
    // Mock muscle group data - in real app this would come from workout history
    final muscleGroupData = _getMockMuscleGroupData();
    final topMuscleGroups = muscleGroupData.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Muscle Groups Trained',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to detailed muscle group analysis
              },
              child: const Text(
                'View All',
                style: TextStyle(color: AppTheme.accentYellow),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              ...topMuscleGroups.map((data) => 
                _buildMuscleGroupItem(context, data)),
              const SizedBox(height: 16),
              // Overall progress indicator
              Row(
                children: [
                  Text(
                    'Weekly Training Balance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_calculateOverallBalance()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _calculateOverallBalance() / 100,
                backgroundColor: AppTheme.darkBackground,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentYellow),
                minHeight: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleGroupItem(BuildContext context, Map<String, dynamic> data) {
    final muscleGroup = data['group'] as MuscleGroup;
    final percentage = data['percentage'] as double;
    final sets = data['sets'] as int;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Muscle group icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: MuscleGroupExtension.getColor(muscleGroup).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                muscleGroup.icon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Muscle group info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      muscleGroup.displayName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MuscleGroupExtension.getColor(muscleGroup),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppTheme.darkBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          MuscleGroupExtension.getColor(muscleGroup),
                        ),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$sets sets',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockMuscleGroupData() {
    // Mock data representing user's muscle group training distribution
    return [
      {
        'group': MuscleGroup.chest,
        'percentage': 25.5,
        'sets': 42,
      },
      {
        'group': MuscleGroup.shoulders,
        'percentage': 18.3,
        'sets': 31,
      },
      {
        'group': MuscleGroup.quads,
        'percentage': 16.7,
        'sets': 28,
      },
      {
        'group': MuscleGroup.biceps,
        'percentage': 12.4,
        'sets': 21,
      },
      {
        'group': MuscleGroup.triceps,
        'percentage': 11.8,
        'sets': 20,
      },
      {
        'group': MuscleGroup.abs,
        'percentage': 8.2,
        'sets': 14,
      },
      {
        'group': MuscleGroup.calves,
        'percentage': 7.1,
        'sets': 12,
      },
    ];
  }

  int _calculateOverallBalance() {
    // Calculate how balanced the training is across muscle groups
    // In a real app, this would analyze the distribution for optimal balance
    return 73; // Mock value representing 73% balance
  }

  String _getNextRank(RankLevel currentRank) {
    const ranks = [RankLevel.E, RankLevel.D, RankLevel.C, RankLevel.B, RankLevel.A, RankLevel.S, RankLevel.SS];
    final currentIndex = ranks.indexOf(currentRank);
    if (currentIndex < ranks.length - 1) {
      return ranks[currentIndex + 1].name;
    }
    return currentRank.name;
  }

  double _calculateRankProgress(int totalPoints) {
    // Mock calculation - in real app this would be based on rank thresholds
    return (totalPoints % 1000) / 1000;
  }
}