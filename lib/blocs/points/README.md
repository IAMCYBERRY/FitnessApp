# Points BLoC Documentation

## Overview

The Points BLoC is a comprehensive state management solution for tracking user points, rank progression, and fitness-related achievements in the RivalX application. It integrates with the PointsService for calculations and the MockAuthBloc for user management.

## Features

- **Point Tracking**: Tracks total points, weekly points, and recent point history
- **Rank Progression**: Automatically manages rank changes (E → D → C → B → A → S → SS)
- **Bonus System**: Handles streak bonuses, rank multipliers, and special bonuses
- **Real-time Updates**: Updates user profile when points change
- **Weekly Reset**: Automatically resets weekly points on Sundays
- **History Tracking**: Maintains recent point activity history

## Architecture

```
PointsBloc
├── PointsEvent (input events)
├── PointsState (output states)
├── PointsService (calculation logic)
└── MockAuthBloc (user management)
```

## Events

### Core Events

- **PointsInitialize**: Initialize points for a user
- **WorkoutCompleted**: Award points for completed workouts
- **ChallengeCompleted**: Award points for challenge completion
- **DailyChallengeCompleted**: Award points for daily challenges
- **RivalModeVictory**: Award bonus for rival mode wins
- **StreakBonusEarned**: Apply streak bonuses
- **WeeklyPointsReset**: Reset weekly points
- **PointsAdjustment**: Manual point adjustments/penalties
- **RefreshPoints**: Refresh points from backend
- **RankChanged**: Internal event for rank changes

### Event Usage Examples

```dart
// Complete a workout
context.read<PointsBloc>().add(WorkoutCompleted(
  workout: completedWorkout,
  userStats: userStats,
));

// Complete daily challenge
context.read<PointsBloc>().add(DailyChallengeCompleted(
  challengeId: 'daily_001',
  challengeDescription: '50 Push-ups Challenge',
));

// Rival mode victory
context.read<PointsBloc>().add(RivalModeVictory(
  rivalId: 'rival_123',
  rivalUsername: 'FitnessRival',
  rivalWeeklyPoints: 1200,
  userWeeklyPoints: 1500,
));
```

## States

### Main States

- **PointsInitial**: Initial state before loading
- **PointsLoading**: Loading or calculating points
- **PointsLoaded**: Normal loaded state with all point data
- **PointsAwarding**: Special state for point animation
- **RankUpAchieved**: Celebration state for rank promotions
- **PointsError**: Error state with recovery options

### State Data Structure

```dart
class PointsLoaded extends PointsState {
  final int totalPoints;           // Total accumulated points
  final int weeklyPoints;          // Current week points
  final RankLevel currentRank;     // Current rank (E-SS)
  final int pointsToNextRank;      // Points needed for next rank
  final double rankProgress;       // Percentage to next rank
  final int currentStreak;         // Workout streak days
  final ActiveBonuses activeBonuses; // Current bonuses
  final List<PointHistoryEntry> recentHistory; // Recent activity
  final DateTime lastUpdated;      // Last update timestamp
}
```

## Integration Guide

### 1. Add to your BlocProvider

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<MockAuthBloc>(
      create: (context) => MockAuthBloc(authService: authService),
    ),
    BlocProvider<PointsBloc>(
      create: (context) => PointsBloc(
        authBloc: context.read<MockAuthBloc>(),
      ),
    ),
  ],
  child: MyApp(),
)
```

### 2. Use in your widgets

```dart
class PointsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PointsBloc, PointsState>(
      builder: (context, state) {
        if (state is PointsLoaded) {
          return Column(
            children: [
              Text('Total Points: ${state.totalPoints}'),
              Text('Rank: ${state.currentRank.name}'),
              LinearProgressIndicator(
                value: state.rankProgress / 100,
              ),
              // ... more UI
            ],
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### 3. Handle special states

```dart
BlocListener<PointsBloc, PointsState>(
  listener: (context, state) {
    if (state is RankUpAchieved) {
      // Show rank up celebration
      showDialog(
        context: context,
        builder: (_) => RankUpDialog(
          previousRank: state.previousRank,
          newRank: state.currentRank,
          bonusPoints: state.rankUpBonus,
        ),
      );
    }
    
    if (state is PointsAwarding) {
      // Show points animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+${state.pointsAwarded} points!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  },
  child: PointsWidget(),
)
```

## Point Calculation System

### Base Points

- **Strength Training**: 10 points per set (modified by weight/reps)
- **Cardio**: 50 points per kilometer
- **Bodyweight**: 1 point per rep
- **Duration**: 5 points per minute
- **Daily Challenge**: 100 base points
- **Challenge Completion**: 250 base points

### Multipliers and Bonuses

1. **Intensity Multipliers**:
   - Low: 0.8x
   - Moderate: 1.0x
   - High: 1.3x
   - Extreme: 1.6x

2. **Rank Multipliers**:
   - E: 1.0x
   - D: 1.1x
   - C: 1.2x
   - B: 1.3x
   - A: 1.4x
   - S: 1.5x
   - SS: 1.6x

3. **Streak Bonuses**:
   - 3+ days: +2%
   - 7+ days: +5%
   - 14+ days: +10%

4. **Special Bonuses**:
   - Personal Record: +20%
   - Rival Victory: +10% of rival's weekly points
   - Challenge Placement: 1st: +50%, 2nd: +30%, 3rd: +15%

### Rank Thresholds

| Rank | Points Required | Display Name |
|------|----------------|--------------|
| E    | 0              | Rookie       |
| D    | 1,000          | Bronze       |
| C    | 3,000          | Silver       |
| B    | 7,000          | Gold         |
| A    | 15,000         | Platinum     |
| S    | 30,000         | Diamond      |
| SS   | 60,000         | Champion     |

## Testing

The BLoC includes comprehensive test utilities:

```dart
// Generate mock workout for testing
final workout = PointsService.generateMockStrengthWorkout(
  isPersonalRecord: true,
  intensity: WorkoutIntensity.high,
);

// Generate mock user stats
final userStats = PointsService.generateMockUserStats(
  streak: 7,
  rank: RankLevel.B,
);

// Test point calculation
final points = PointsService.calculateWorkoutPoints(workout, userStats);
expect(points, greaterThan(0));
```

## Error Handling

The BLoC includes robust error handling:

- **Validation**: Prevents impossible point claims
- **Recovery**: Maintains previous state for error recovery
- **Retry Logic**: Automatic retry for transient failures
- **Fallback**: Graceful degradation for backend issues

## Performance Considerations

- **Caching**: In-memory caching of recent point history
- **Batching**: Efficient batch updates for multiple events
- **Throttling**: Rate limiting for rapid point awards
- **Memory**: Automatic cleanup of old history entries

## Future Enhancements

- **Persistence**: Save point history to local storage
- **Sync**: Background sync with Firebase backend
- **Analytics**: Detailed point analytics and insights
- **Notifications**: Push notifications for achievements
- **Leaderboards**: Integration with global/friend leaderboards

## Troubleshooting

### Common Issues

1. **Points not updating**: Check if user is authenticated
2. **Rank not changing**: Verify point thresholds
3. **Bonuses not applying**: Check streak and rank data
4. **Memory leaks**: Ensure proper bloc disposal

### Debug Information

Enable debug logging by setting `debugMode = true` in the BLoC constructor.

## Files Structure

```
lib/blocs/points/
├── points_bloc.dart           # Main BLoC implementation
├── points_event.dart          # Event definitions
├── points_state.dart          # State definitions
├── points_barrel.dart         # Barrel export file
├── points_usage_example.dart  # Usage examples
└── README.md                  # This documentation
```

## Dependencies

- `flutter_bloc: ^8.1.3` - BLoC pattern implementation
- `equatable: ^2.0.5` - Value equality for events/states
- Existing `PointsService` - Point calculation logic
- Existing `MockAuthBloc` - User authentication

## Migration Guide

If upgrading from a previous points system:

1. Replace direct PointsService calls with BLoC events
2. Update UI to use BlocBuilder/BlocListener
3. Migrate stored point data to new format
4. Update tests to use BLoC testing utilities

For more examples and advanced usage, see `points_usage_example.dart`.