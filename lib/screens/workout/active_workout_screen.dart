/// Active workout screen for manually logging exercises and sets.
/// 
/// This screen allows users to:
/// - Add exercises manually
/// - Log sets with reps and weight
/// - Track workout duration
/// - Save completed workouts

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../config/theme.dart';
import '../../models/muscle_group.dart';
import '../../models/workout_routine.dart';
import '../../models/user_model_clean.dart';
import '../../blocs/points/points_bloc.dart';
import '../../blocs/points/points_state.dart';
import '../../blocs/points/points_event.dart';
import '../../blocs/auth/local_auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../services/points_service.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutRoutine? routine;
  
  const ActiveWorkoutScreen({
    super.key,
    this.routine,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final List<WorkoutExercise> _exercises = [];
  late Timer _timer;
  int _elapsedSeconds = 0;
  bool _isWorkoutActive = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadRoutineExercises();
  }

  void _loadRoutineExercises() {
    if (widget.routine != null) {
      // Convert routine exercises to workout exercises
      for (final routineExercise in widget.routine!.exercises) {
        final workoutExercise = WorkoutExercise(
          name: routineExercise.name,
          muscleGroup: routineExercise.muscleGroup,
          sets: routineExercise.plannedSets.map((plannedSet) {
            return WorkoutSet(
              weight: plannedSet.targetWeight ?? 0,
              reps: plannedSet.targetReps ?? 0,
            );
          }).toList(),
        );
        _exercises.add(workoutExercise);
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isWorkoutActive) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        title: Text(
          widget.routine != null ? '${widget.routine!.name}' : 'Active Workout',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          TextButton(
            onPressed: _finishWorkout,
            child: const Text(
              'Finish',
              style: TextStyle(
                color: AppTheme.accentYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Timer and Stats Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Main stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Duration', _formatDuration(_elapsedSeconds)),
                    _buildStatItem('Exercises', '${_exercises.length}'),
                    _buildStatItem('Sets', '${_getTotalSets()}'),
                    _buildStatItem('Volume', '${_getTotalVolume().toStringAsFixed(0)} lbs'),
                  ],
                ),
                const SizedBox(height: 12),
                // Points preview row
                BlocBuilder<PointsBloc, PointsState>(
                  builder: (context, state) {
                    if (state is PointsLoaded) {
                      final potentialPoints = _calculatePotentialPoints(state);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentYellow.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.accentYellow.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.stars,
                                  color: AppTheme.accentYellow,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Current: ${state.totalPoints} pts (${state.currentRank.name})',
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Potential: +$potentialPoints pts',
                              style: TextStyle(
                                color: AppTheme.accentYellow,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
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
          // Exercises List
          Expanded(
            child: _exercises.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      return _buildExerciseCard(_exercises[index], index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        backgroundColor: AppTheme.accentYellow,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
            'No exercises added yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first exercise',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(WorkoutExercise exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Exercise Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentYellow.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Muscle group icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: MuscleGroupExtension.getColor(exercise.muscleGroup).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    exercise.muscleGroup.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        exercise.muscleGroup.displayName,
                        style: TextStyle(
                          color: MuscleGroupExtension.getColor(exercise.muscleGroup),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: () => _removeExercise(index),
                ),
              ],
            ),
          ),
          // Sets List
          ...exercise.sets.asMap().entries.map((entry) {
            final setIndex = entry.key;
            final set = entry.value;
            return _buildSetRow(exercise, setIndex, set);
          }),
          // Add Set Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _addSet(exercise),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Set'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentYellow,
                  side: const BorderSide(color: AppTheme.accentYellow),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(WorkoutExercise exercise, int setIndex, WorkoutSet set) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Set Number
          SizedBox(
            width: 40,
            child: Text(
              '${setIndex + 1}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Weight Input
          Expanded(
            child: TextFormField(
              initialValue: set.weight > 0 ? set.weight.toString() : '',
              decoration: const InputDecoration(
                labelText: 'Weight (lbs)',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final weight = double.tryParse(value) ?? 0;
                setState(() {
                  exercise.sets[setIndex] = set.copyWith(weight: weight);
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          // Reps Input
          Expanded(
            child: TextFormField(
              initialValue: set.reps > 0 ? set.reps.toString() : '',
              decoration: const InputDecoration(
                labelText: 'Reps',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final reps = int.tryParse(value) ?? 0;
                setState(() {
                  exercise.sets[setIndex] = set.copyWith(reps: reps);
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          // Delete Set Button
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            color: Colors.red,
            onPressed: () => _removeSet(exercise, setIndex),
          ),
        ],
      ),
    );
  }

  void _addExercise() {
    showDialog(
      context: context,
      builder: (context) => _AddExerciseDialog(
        onAdd: (name, muscleGroup) {
          setState(() {
            _exercises.add(WorkoutExercise(name: name, muscleGroup: muscleGroup));
          });
        },
      ),
    );
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _addSet(WorkoutExercise exercise) {
    setState(() {
      exercise.sets.add(WorkoutSet());
    });
  }

  void _removeSet(WorkoutExercise exercise, int setIndex) {
    setState(() {
      exercise.sets.removeAt(setIndex);
    });
  }

  int _getTotalSets() {
    return _exercises.fold(0, (total, exercise) => total + exercise.sets.length);
  }

  double _getTotalVolume() {
    return _exercises.fold(0.0, (total, exercise) {
      return total + exercise.sets.fold(0.0, (exerciseTotal, set) {
        return exerciseTotal + (set.weight * set.reps);
      });
    });
  }

  /// Calculates potential points for the current workout
  int _calculatePotentialPoints(PointsLoaded pointsState) {
    if (_exercises.isEmpty) return 0;

    // Create mock completed workout for point calculation
    final completedWorkout = _createCompletedWorkout();
    final userStats = _createUserStats(pointsState);

    // Calculate points using PointsService
    final breakdown = PointsService.calculatePointsWithBreakdown(
      completedWorkout,
      userStats,
    );

    return breakdown.totalPoints;
  }

  /// Creates CompletedWorkout object from current workout data
  CompletedWorkout _createCompletedWorkout() {
    final completedExercises = _exercises.map((exercise) {
      final completedSets = exercise.sets.map((set) {
        return CompletedSet(
          weight: set.weight * 0.453592, // Convert lbs to kg
          reps: set.reps > 0 ? set.reps : null,
          rpe: null,
        );
      }).toList();

      return CompletedExercise(
        name: exercise.name,
        muscleGroup: exercise.muscleGroup,
        sets: completedSets,
      );
    }).toList();

    return CompletedWorkout(
      id: 'active_workout_${DateTime.now().millisecondsSinceEpoch}',
      type: WorkoutType.strength,
      completedAt: DateTime.now(),
      duration: Duration(seconds: _elapsedSeconds),
      exercises: completedExercises,
      intensity: _getWorkoutIntensity(),
      totalWeight: _getTotalVolume() * 0.453592, // Convert lbs to kg
    );
  }

  /// Creates UserStats object from current points state
  UserStats _createUserStats(PointsLoaded pointsState) {
    return UserStats(
      currentStreak: pointsState.currentStreak,
      longestStreak: pointsState.currentStreak,
      lastWorkoutDate: DateTime.now().subtract(const Duration(days: 1)),
      workoutDates: [],
      currentRank: pointsState.currentRank,
      weeklyWorkouts: 3, // Mock value
      weeklyVolume: _getTotalVolume(),
      hasActiveRival: false, // Mock value
      personalRecords: {},
    );
  }

  /// Determines workout intensity based on volume and duration
  WorkoutIntensity _getWorkoutIntensity() {
    final volume = _getTotalVolume();
    final durationMinutes = _elapsedSeconds / 60;

    if (volume > 15000 || durationMinutes > 90) {
      return WorkoutIntensity.high;
    } else if (volume > 8000 || durationMinutes > 60) {
      return WorkoutIntensity.moderate;
    } else {
      return WorkoutIntensity.low;
    }
  }

  /// Saves workout and awards points through PointsBloc
  void _saveWorkoutAndAwardPoints() {
    final pointsBloc = context.read<PointsBloc>();
    final authBloc = context.read<LocalAuthBloc>();
    
    // Check if user is authenticated
    if (authBloc.state is! AuthAuthenticated) {
      _showErrorSnackBar('User not authenticated. Please log in again.');
      return;
    }

    final authState = authBloc.state as AuthAuthenticated;
    
    // Check if points are loaded
    if (pointsBloc.state is! PointsLoaded) {
      _showErrorSnackBar('Points system not ready. Please try again.');
      return;
    }

    final pointsState = pointsBloc.state as PointsLoaded;

    try {
      // Create completed workout and user stats
      final completedWorkout = _createCompletedWorkout();
      final userStats = _createUserStats(pointsState);

      // Validate workout has actual data
      if (!_validateWorkoutData()) {
        _showErrorSnackBar('Please add exercises and sets before finishing workout.');
        return;
      }

      // Dispatch workout completed event to PointsBloc
      pointsBloc.add(WorkoutCompleted(
        workout: completedWorkout,
        userStats: userStats,
      ));

      // Navigate back and listen for points awarding
      Navigator.of(context).pop();
      _listenForPointsAwarding();

    } catch (e) {
      _showErrorSnackBar('Failed to save workout: ${e.toString()}');
    }
  }

  /// Validates workout has meaningful data
  bool _validateWorkoutData() {
    if (_exercises.isEmpty) return false;
    
    // Check that at least one exercise has at least one set with data
    for (final exercise in _exercises) {
      for (final set in exercise.sets) {
        if (set.weight > 0 && set.reps > 0) {
          return true;
        }
      }
    }
    return false;
  }

  /// Listens for points awarding and shows appropriate feedback
  void _listenForPointsAwarding() {
    final pointsBloc = context.read<PointsBloc>();
    
    // Listen to the stream for points awarding state
    final subscription = pointsBloc.stream.listen((state) {
      if (state is PointsAwarding) {
        _showPointsAwardedDialog(state);
      } else if (state is RankUpAchieved) {
        _showRankUpDialog(state);
      } else if (state is PointsError) {
        _showErrorSnackBar(state.message);
      }
    });

    // Cancel subscription after a timeout to prevent memory leaks
    Timer(const Duration(seconds: 10), () {
      subscription.cancel();
    });
  }

  /// Shows points awarded celebration dialog  
  void _showPointsAwardedDialog(PointsAwarding state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Row(
          children: [
            const Icon(
              Icons.celebration,
              color: AppTheme.accentYellow,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Workout Complete!',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Points earned
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accentYellow.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '+${state.pointsAwarded}',
                    style: const TextStyle(
                      color: AppTheme.accentYellow,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'POINTS EARNED',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Points breakdown
            if (state.breakdown.bonusBreakdown.isNotEmpty) ...[
              const Text(
                'Bonuses Applied:',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...state.breakdown.bonusBreakdown.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '+${entry.value}',
                        style: const TextStyle(
                          color: AppTheme.accentYellow,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
            // Total points and rank
            Text(
              'Total Points: ${state.totalPoints}',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Current Rank: ${state.currentRank.name}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentYellow,
              foregroundColor: Colors.black,
            ),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  /// Shows rank up celebration dialog
  void _showRankUpDialog(RankUpAchieved state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Row(
          children: [
            const Icon(
              Icons.military_tech,
              color: AppTheme.accentYellow,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'RANK UP!',
              style: TextStyle(
                color: AppTheme.accentYellow,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentYellow.withOpacity(0.2),
                    AppTheme.accentYellow.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accentYellow.withOpacity(0.5),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${state.previousRank.name} → ${state.currentRank.name}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Congratulations! You\'ve been promoted to ${state.currentRank.name} rank!',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Rank Up Bonus: +${state.rankUpBonus} pts',
                      style: const TextStyle(
                        color: AppTheme.accentYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentYellow,
              foregroundColor: Colors.black,
            ),
            child: const Text('Amazing!'),
          ),
        ],
      ),
    );
  }

  /// Shows error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _finishWorkout() {
    final potentialPoints = context.read<PointsBloc>().state is PointsLoaded 
        ? _calculatePotentialPoints(context.read<PointsBloc>().state as PointsLoaded)
        : 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Finish Workout?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Save this workout to your history?',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            // Workout summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.darkBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workout Summary',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Duration: ${_formatDuration(_elapsedSeconds)}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  Text(
                    'Exercises: ${_exercises.length}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  Text(
                    'Total Sets: ${_getTotalSets()}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  Text(
                    'Total Volume: ${_getTotalVolume().toStringAsFixed(0)} lbs',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Points to earn: +$potentialPoints pts',
                      style: const TextStyle(
                        color: AppTheme.accentYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _saveWorkoutAndAwardPoints();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentYellow,
              foregroundColor: Colors.black,
            ),
            child: const Text('Save Workout'),
          ),
        ],
      ),
    );
  }
}

class _AddExerciseDialog extends StatefulWidget {
  final Function(String, MuscleGroup) onAdd;

  const _AddExerciseDialog({required this.onAdd});

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final _controller = TextEditingController();
  MuscleGroup _selectedMuscleGroup = MuscleGroup.chest;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      title: const Text(
        'Add Exercise',
        style: TextStyle(color: AppTheme.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Exercise Name',
              hintText: 'e.g., Bench Press, Squats, etc.',
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                widget.onAdd(value.trim(), _selectedMuscleGroup);
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<MuscleGroup>(
            value: _selectedMuscleGroup,
            decoration: const InputDecoration(
              labelText: 'Muscle Group',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            isExpanded: true,
            items: MuscleGroup.values.map((group) {
              return DropdownMenuItem(
                value: group,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      group.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        group.displayName,
                        style: TextStyle(
                          color: MuscleGroupExtension.getColor(group),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedMuscleGroup = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onAdd(_controller.text.trim(), _selectedMuscleGroup);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class WorkoutExercise {
  final String name;
  final MuscleGroup muscleGroup;
  final List<WorkoutSet> sets;

  WorkoutExercise({
    required this.name,
    required this.muscleGroup,
    List<WorkoutSet>? sets,
  }) : sets = sets ?? [WorkoutSet()];
}

class WorkoutSet {
  final double weight;
  final int reps;

  WorkoutSet({
    this.weight = 0,
    this.reps = 0,
  });

  WorkoutSet copyWith({
    double? weight,
    int? reps,
  }) {
    return WorkoutSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
    );
  }
}