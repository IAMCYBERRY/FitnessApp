/// Workout tracking screen for logging exercises and fitness activities.
/// 
/// This screen allows users to:
/// - Start a new workout session
/// - Log exercises with sets, reps, and weight
/// - Track workout duration
/// - View recent workouts
/// - Access their workout routines

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../models/workout_routine.dart';
import '../../models/user_model_clean.dart';
import '../../blocs/points/points_bloc.dart';
import '../../blocs/points/points_state.dart';
import 'active_workout_screen.dart';
import 'create_routine_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<WorkoutRoutine> _routines = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRoutines();
  }

  void _loadRoutines() {
    setState(() {
      _routines = RoutineService.getAllRoutines();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar with Points
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Workout',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          // Points display
                          BlocBuilder<PointsBloc, PointsState>(
                            builder: (context, state) {
                              if (state is PointsLoaded) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentYellow.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.accentYellow.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.stars,
                                        color: AppTheme.accentYellow,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${state.totalPoints} pts',
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        state.currentRank.name,
                                        style: TextStyle(
                                          color: AppTheme.accentYellow,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.history),
                            color: AppTheme.textPrimary,
                            onPressed: () {
                              // TODO: Navigate to workout history
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Rank progress bar
                  BlocBuilder<PointsBloc, PointsState>(
                    builder: (context, state) {
                      if (state is PointsLoaded && state.currentRank.index < 6) {
                        return Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progress to ${_getNextRankName(state.currentRank)}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    '${state.pointsToNextRank} pts to go',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: state.rankProgress / 100,
                                backgroundColor: AppTheme.surfaceColor,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.accentYellow,
                                ),
                                minHeight: 4,
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.accentYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: AppTheme.textSecondary,
                tabs: const [
                  Tab(text: 'Start'),
                  Tab(text: 'Active'),
                  Tab(text: 'Routines'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStartWorkoutTab(),
                  _buildActiveWorkoutTab(),
                  _buildRoutinesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartWorkoutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Start Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentYellow.withOpacity(0.3),
                  AppTheme.accentYellow.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.accentYellow.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.play_circle_fill,
                  size: 60,
                  color: AppTheme.accentYellow,
                ),
                const SizedBox(height: 16),
                Text(
                  'Start Empty Workout',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Begin a workout and add exercises as you go',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _startEmptyWorkout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentYellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Start Workout'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Recent Workouts
          Text(
            'Recent Workouts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentWorkoutsList(),
          const SizedBox(height: 24),
          // Quick Templates
          Text(
            'Quick Templates',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickTemplatesList(),
        ],
      ),
    );
  }

  Widget _buildActiveWorkoutTab() {
    // TODO: Check if there's an active workout
    bool hasActiveWorkout = false;

    if (!hasActiveWorkout) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Workout',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a workout to track your exercises',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Active workout content will go here
        ],
      ),
    );
  }

  Widget _buildRoutinesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create New Routine Button
          InkWell(
            onTap: _createNewRoutine,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
              child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.accentYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppTheme.accentYellow,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Routine',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Build a custom workout routine',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 24),
          // My Routines
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Routines',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all routines
                },
                child: const Text(
                  'See All',
                  style: TextStyle(color: AppTheme.accentYellow),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRoutinesList(),
        ],
      ),
    );
  }

  Widget _buildRecentWorkoutsList() {
    final recentWorkouts = [
      {'name': 'Upper Body Strength', 'date': '2 days ago', 'duration': '45 min'},
      {'name': 'Cardio & Core', 'date': '4 days ago', 'duration': '30 min'},
      {'name': 'Leg Day', 'date': '6 days ago', 'duration': '52 min'},
    ];

    return Column(
      children: recentWorkouts.map((workout) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.darkBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppTheme.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout['name']!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workout['date']} • ${workout['duration']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: AppTheme.accentYellow,
                  size: 20,
                ),
                onPressed: () {
                  _repeatWorkout(workout['name']!);
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickTemplatesList() {
    final templates = [
      {'name': 'Push Day', 'exercises': '6 exercises', 'icon': Icons.arrow_upward},
      {'name': 'Pull Day', 'exercises': '5 exercises', 'icon': Icons.arrow_downward},
      {'name': 'Leg Day', 'exercises': '7 exercises', 'icon': Icons.directions_run},
      {'name': 'Full Body', 'exercises': '8 exercises', 'icon': Icons.accessibility},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return InkWell(
          onTap: () => _startTemplate(template['name']! as String),
          borderRadius: BorderRadius.circular(12),
          child: Container(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  template['icon'] as IconData,
                  color: AppTheme.accentYellow,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  template['name']! as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  template['exercises']! as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoutinesList() {
    if (_routines.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
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
            Icon(
              Icons.list_alt_outlined,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No routines created yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first routine to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: _routines.map((routine) {
        final lastUsedText = routine.lastUsedAt != null
            ? 'Last used ${_getTimeAgo(routine.lastUsedAt!)}'
            : 'Never used';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () => _showRoutineOptions(routine),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (routine.color ?? AppTheme.accentYellow).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.list_alt,
                      color: routine.color ?? AppTheme.accentYellow,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${routine.totalExercises} exercises • ${routine.totalPlannedSets} sets',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (routine.timesUsed > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            lastUsedText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _startEmptyWorkout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ActiveWorkoutScreen(),
      ),
    );
  }

  void _repeatWorkout(String workoutName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ActiveWorkoutScreen(),
      ),
    );
  }

  void _startTemplate(String templateName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ActiveWorkoutScreen(),
      ),
    );
  }

  void _createNewRoutine() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateRoutineScreen(),
      ),
    ).then((result) {
      if (result != null) {
        _loadRoutines();
      }
    });
  }

  void _showRoutineOptions(WorkoutRoutine routine) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (routine.color ?? AppTheme.accentYellow).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.list_alt,
                    color: routine.color ?? AppTheme.accentYellow,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${routine.totalExercises} exercises • ${routine.totalPlannedSets} sets',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Actions
            _buildBottomSheetOption(
              icon: Icons.play_arrow,
              title: 'Start Workout',
              subtitle: 'Begin this routine as a new workout',
              onTap: () {
                Navigator.pop(context);
                _startWorkoutFromRoutine(routine);
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.edit,
              title: 'Edit Routine',
              subtitle: 'Modify exercises and sets',
              onTap: () {
                Navigator.pop(context);
                _editRoutine(routine);
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.delete,
              title: 'Delete Routine',
              subtitle: 'Remove this routine permanently',
              onTap: () {
                Navigator.pop(context);
                _deleteRoutine(routine);
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppTheme.textPrimary,
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
                      color: isDestructive ? Colors.red : AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDestructive ? Colors.red.withOpacity(0.7) : AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startWorkoutFromRoutine(WorkoutRoutine routine) {
    RoutineService.markRoutineAsUsed(routine.id);
    _loadRoutines();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActiveWorkoutScreen(routine: routine),
      ),
    );
  }

  void _editRoutine(WorkoutRoutine routine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateRoutineScreen(existingRoutine: routine),
      ),
    ).then((result) {
      if (result != null) {
        _loadRoutines();
      }
    });
  }

  void _deleteRoutine(WorkoutRoutine routine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Delete Routine?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${routine.name}"? This action cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              RoutineService.deleteRoutine(routine.id);
              _loadRoutines();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Routine deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Gets next rank name for progress display
  String _getNextRankName(RankLevel currentRank) {
    switch (currentRank) {
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
}