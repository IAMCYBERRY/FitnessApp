# Challenge Bloc Integration Guide

This guide explains how to integrate the new Challenge Bloc state management system into the RivalX fitness app.

## Overview

The Challenge Bloc provides comprehensive state management for all challenge-related features including:
- Challenge creation and management
- Rival sessions (1v1 competitions)
- Challenge invitations
- Real-time updates
- Challenge history and statistics

## Architecture

### Files Created
- `lib/blocs/challenge/challenge_event.dart` - All challenge events
- `lib/blocs/challenge/challenge_state.dart` - All challenge states  
- `lib/blocs/challenge/challenge_bloc.dart` - Main BLoC implementation
- `lib/blocs/challenge/challenge_barrel.dart` - Barrel export file

### Integration Pattern

1. **Import the BLoC components**:
```dart
import 'package:rivalx/blocs/challenge/challenge_barrel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
```

2. **Provide the BLoC in your app**:
```dart
// In main.dart or app-level provider
BlocProvider<ChallengeBloc>(
  create: (context) => ChallengeBloc(),
  child: YourApp(),
)
```

3. **Use BlocConsumer in screens**:
```dart
BlocConsumer<ChallengeBloc, ChallengeState>(
  listener: (context, state) {
    // Handle side effects (snackbars, navigation, etc.)
  },
  builder: (context, state) {
    // Build UI based on state
  },
)
```

## Key Events

### Loading Data
```dart
// Load all challenges for a user
context.read<ChallengeBloc>().add(LoadChallenges(userId: userId));

// Refresh challenges
context.read<ChallengeBloc>().add(RefreshChallenges(userId: userId));

// Load challenge details
context.read<ChallengeBloc>().add(LoadChallengeDetails(challengeId: challengeId));
```

### Challenge Operations
```dart
// Create new challenge
context.read<ChallengeBloc>().add(CreateChallenge(challenge: newChallenge));

// Join challenge
context.read<ChallengeBloc>().add(JoinChallenge(
  challengeId: challengeId,
  userId: userId,
));

// Leave challenge
context.read<ChallengeBloc>().add(LeaveChallenge(
  challengeId: challengeId,
  userId: userId,
));

// Update challenge points
context.read<ChallengeBloc>().add(UpdateChallengePoints(
  challengeId: challengeId,
  userId: userId,
  pointsToAdd: points,
));
```

### Rival Sessions
```dart
// Create rival session
context.read<ChallengeBloc>().add(CreateRivalSession(rivalSession: session));

// Update rival points
context.read<ChallengeBloc>().add(UpdateRivalSessionPoints(
  sessionId: sessionId,
  userId: userId,
  pointsToAdd: points,
));

// End rival session
context.read<ChallengeBloc>().add(EndRivalSession(
  sessionId: sessionId,
  winnerId: winnerId,
));
```

### Invitations
```dart
// Send invitation
context.read<ChallengeBloc>().add(SendChallengeInvitation(invitation: invitation));

// Respond to invitation
context.read<ChallengeBloc>().add(RespondToInvitation(
  invitationId: invitationId,
  accept: true,
  userId: userId,
));
```

## Key States

### Loading States
- `ChallengeInitial` - Initial state
- `ChallengeLoading` - Loading data
- `ChallengeRefreshing` - Refreshing with previous data available

### Success States
- `ChallengeLoaded` - Main loaded state with all challenge data
- `ChallengeCreated` - Challenge successfully created
- `ChallengeJoined` - Successfully joined challenge
- `InvitationSent` - Invitation sent successfully
- `RivalSessionCreated` - Rival session created

### Error States
- `ChallengeError` - Error occurred with optional previous state

## Screen Integration Examples

### 1. RivalsScreen Integration

Key changes needed:
- Replace direct ChallengeService calls with BLoC events
- Use BlocConsumer to listen for state changes
- Handle loading, error, and success states
- Show snackbars for user feedback

### 2. ChallengeDetailsScreen Integration

```dart
class ChallengeDetailsScreen extends StatefulWidget {
  final Challenge challenge;
  
  @override
  void initState() {
    super.initState();
    // Load detailed challenge data
    context.read<ChallengeBloc>().add(
      LoadChallengeDetails(challengeId: widget.challenge.id),
    );
  }
}
```

### 3. CreateChallengeScreen Integration

```dart
void _createChallenge() {
  final newChallenge = Challenge(/* challenge data */);
  context.read<ChallengeBloc>().add(CreateChallenge(challenge: newChallenge));
}

// Listen for creation success
BlocListener<ChallengeBloc, ChallengeState>(
  listener: (context, state) {
    if (state is ChallengeCreated) {
      Navigator.pop(context); // Go back to previous screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourCreateForm(),
)
```

## Error Handling

The Challenge Bloc provides comprehensive error handling:

```dart
BlocListener<ChallengeBloc, ChallengeState>(
  listener: (context, state) {
    if (state is ChallengeError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              // Retry the failed operation
              context.read<ChallengeBloc>().add(RetryLastOperation());
            },
          ),
        ),
      );
    }
  },
)
```

## Real-time Updates

Subscribe to real-time challenge updates:

```dart
// Subscribe to updates
context.read<ChallengeBloc>().add(
  SubscribeToChallengeUpdates(challengeId: challengeId),
);

// Listen for real-time updates
BlocListener<ChallengeBloc, ChallengeState>(
  listener: (context, state) {
    if (state is ChallengeRealTimeUpdate) {
      // Update UI with new data
      _updateChallengeData(state.challenge);
    }
  },
)

// Don't forget to unsubscribe
@override
void dispose() {
  context.read<ChallengeBloc>().add(
    UnsubscribeFromChallengeUpdates(challengeId: challengeId),
  );
  super.dispose();
}
```

## Performance Considerations

1. **Caching**: The BLoC maintains internal caches for better performance
2. **Lazy Loading**: Only load data when needed
3. **Real-time Management**: Properly subscribe/unsubscribe to avoid memory leaks
4. **State Preservation**: Previous state is maintained during refreshes and errors

## Testing

The Challenge Bloc is designed to be easily testable:

```dart
void main() {
  group('ChallengeBloc', () {
    late ChallengeBloc challengeBloc;

    setUp(() {
      challengeBloc = ChallengeBloc();
    });

    tearDown(() {
      challengeBloc.close();
    });

    test('initial state is ChallengeInitial', () {
      expect(challengeBloc.state, equals(const ChallengeInitial()));
    });

    blocTest<ChallengeBloc, ChallengeState>(
      'emits [ChallengeLoading, ChallengeLoaded] when LoadChallenges is added',
      build: () => challengeBloc,
      act: (bloc) => bloc.add(const LoadChallenges(userId: 'test')),
      expect: () => [
        isA<ChallengeLoading>(),
        isA<ChallengeLoaded>(),
      ],
    );
  });
}
```

## Migration Steps

1. **Add BLoC dependencies** to pubspec.yaml (if not already present)
2. **Create BLoC provider** at app level
3. **Update screens one by one** to use BLoC instead of direct service calls
4. **Test each screen** thoroughly after migration
5. **Remove unused direct service calls** once all screens are migrated

## File Integration Requirements

### Screens to Update:
- `lib/screens/rivals/rivals_screen.dart`
- `lib/screens/rivals/challenge_details_screen.dart`
- `lib/screens/rivals/create_challenge_screen.dart`
- `lib/screens/rivals/find_rival_screen.dart`
- `lib/screens/challenges/challenge_chat_screen.dart`

### Provider Setup:
Add to your main app provider or create a dedicated challenge provider:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(create: (context) => AuthBloc(/* dependencies */)),
    BlocProvider<ProfileBloc>(create: (context) => ProfileBloc(/* dependencies */)),
    BlocProvider<ChallengeBloc>(create: (context) => ChallengeBloc(/* dependencies */)),
  ],
  child: YourApp(),
)
```

## Notes

- The BLoC integrates seamlessly with existing mock data from ChallengeService
- All operations are asynchronous with proper loading states
- Error handling includes both user-friendly messages and error codes
- The system is designed for future Firebase integration
- Real-time updates are simulated but can be easily replaced with actual streams

This implementation provides a solid foundation for scalable challenge management in the RivalX app while maintaining backward compatibility with existing mock services.