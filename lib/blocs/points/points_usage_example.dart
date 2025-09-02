/// Example usage of the Points BLoC in a Flutter widget.
/// 
/// This file demonstrates how to integrate the PointsBloc into your
/// UI components for displaying and updating user points.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rivalx/blocs/points/points_barrel.dart';
import 'package:rivalx/blocs/auth/mock_auth_bloc.dart';
import 'package:rivalx/services/points_service.dart';
import 'package:rivalx/services/mock_auth_service.dart';

/// Example widget showing how to use PointsBloc
class PointsDisplayWidget extends StatelessWidget {
  const PointsDisplayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PointsBloc, PointsState>(
      builder: (context, state) {
        if (state is PointsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (state is PointsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                ElevatedButton(
                  onPressed: () {
                    context.read<PointsBloc>().add(const RefreshPoints());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state is PointsLoaded) {
          return _buildPointsDisplay(context, state);
        }
        
        return const Center(
          child: Text('Initialize points to get started'),
        );
      },
    );
  }

  Widget _buildPointsDisplay(BuildContext context, PointsLoaded state) {
    // Handle special states
    if (state is PointsAwarding) {
      return _buildAwardingAnimation(context, state);
    }
    
    if (state is RankUpAchieved) {
      return _buildRankUpCelebration(context, state);
    }

    // Normal loaded state
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Points summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Points: ${state.totalPoints}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Weekly Points: ${state.weeklyPoints}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // Rank display
                  Row(
                    children: [
                      Text(
                        'Rank: ${state.currentRank.name}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: state.rankProgress / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getRankColor(state.currentRank),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${state.pointsToNextRank} points to next rank',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Streak display
                  if (state.currentStreak > 0)
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          '${state.currentStreak} day streak!',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Active bonuses
          if (state.activeBonuses.streakBonus > 0 || 
              state.activeBonuses.otherBonuses.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Bonuses',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (state.activeBonuses.streakBonus > 0)
                      Text('• Streak Bonus: +${state.activeBonuses.streakBonus.toStringAsFixed(0)}%'),
                    Text('• Rank Multiplier: ${state.activeBonuses.rankMultiplier}x'),
                    for (final bonus in state.activeBonuses.otherBonuses)
                      Text('• ${bonus.name}: ${bonus.description}'),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Recent history
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: state.recentHistory.length,
              itemBuilder: (context, index) {
                final entry = state.recentHistory[index];
                return ListTile(
                  leading: Text(
                    entry.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(entry.activity),
                  subtitle: Text(entry.description),
                  trailing: Text(
                    '${entry.points > 0 ? '+' : ''}${entry.points} pts',
                    style: TextStyle(
                      color: entry.points > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Action buttons for testing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _completeWorkout(context),
                child: const Text('Complete Workout'),
              ),
              ElevatedButton(
                onPressed: () => _completeDailyChallenge(context),
                child: const Text('Daily Challenge'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAwardingAnimation(BuildContext context, PointsAwarding state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.celebration,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          Text(
            '+${state.pointsAwarded} Points!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.breakdown.description,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (state.isRankUp)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'RANK UP! ${state.newRank?.name}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRankUpCelebration(BuildContext context, RankUpAchieved state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.military_tech,
            size: 100,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          Text(
            'RANK UP!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.previousRank.name} → ${state.currentRank.name}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            '+${state.rankUpBonus} Bonus Points!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.read<PointsBloc>().add(const RefreshPoints());
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _completeWorkout(BuildContext context) {
    // Create mock workout data
    final workout = PointsService.generateMockStrengthWorkout(
      isPersonalRecord: false,
      intensity: WorkoutIntensity.moderate,
    );
    
    final userStats = PointsService.generateMockUserStats(
      streak: 5,
      rank: RankLevel.B,
    );
    
    // Add workout completed event
    context.read<PointsBloc>().add(WorkoutCompleted(
      workout: workout,
      userStats: userStats,
    ));
  }

  void _completeDailyChallenge(BuildContext context) {
    // Add daily challenge completed event
    context.read<PointsBloc>().add(const DailyChallengeCompleted(
      challengeId: 'daily_001',
      challengeDescription: '50 Push-ups Challenge',
      completionTime: Duration(minutes: 5),
    ));
  }

  Color _getRankColor(RankLevel rank) {
    switch (rank) {
      case RankLevel.E:
        return Colors.grey;
      case RankLevel.D:
        return Colors.brown;
      case RankLevel.C:
        return Colors.grey[600]!;
      case RankLevel.B:
        return Colors.amber;
      case RankLevel.A:
        return Colors.lightBlue;
      case RankLevel.S:
        return Colors.purple;
      case RankLevel.SS:
        return Colors.red;
    }
  }
}

/// Example of how to provide the PointsBloc in your app
class PointsExampleApp extends StatelessWidget {
  const PointsExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MockAuthBloc>(
          create: (context) => MockAuthBloc(
            authService: MockAuthService(), // You need to provide this
          ),
        ),
        BlocProvider<PointsBloc>(
          create: (context) => PointsBloc(
            authBloc: context.read<MockAuthBloc>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'RivalX Points Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: SafeArea(
            child: PointsDisplayWidget(),
          ),
        ),
      ),
    );
  }
}