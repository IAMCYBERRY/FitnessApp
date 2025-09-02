# RivalX Challenge Features - Technical Documentation

## Overview

This document provides comprehensive technical documentation for all challenge-related features implemented in the RivalX fitness application. The system includes group challenges, 1v1 rival sessions, real-time chat, comprehensive leaderboards, and a robust state management architecture using BLoC pattern.

## Architecture Overview

### Core Components

1. **Challenge Management System**
   - Group challenges (public/private/daily)
   - 1v1 rival sessions
   - Challenge invitations and responses
   - Real-time point tracking and leaderboards

2. **Chat & Communication**
   - Real-time messaging with reactions
   - Achievement sharing and workout announcements
   - Message threading and replies
   - Typing indicators and read receipts

3. **Social Discovery**
   - Friend search and filtering
   - Skill-based matching
   - Challenge invitation management
   - Recent rival tracking

4. **State Management**
   - Comprehensive BLoC architecture
   - Real-time updates and subscriptions
   - Error handling and loading states
   - Data synchronization

## File Structure

```
lib/
├── screens/
│   ├── challenges/
│   │   ├── challenge_chat_screen.dart      # Real-time messaging
│   │   └── full_leaderboard_screen.dart    # Comprehensive rankings
│   └── rivals/
│       ├── challenge_details_screen.dart   # Challenge overview tabs
│       └── find_rival_screen.dart          # Friend discovery & invitations
├── models/
│   ├── challenge.dart                      # Challenge & rival data models
│   ├── chat_message.dart                   # Chat message models
│   └── user_model.dart                     # User and ranking models
├── blocs/
│   └── challenge/
│       ├── challenge_bloc.dart             # State management logic
│       ├── challenge_event.dart            # Event definitions
│       └── challenge_state.dart            # State definitions
└── services/
    └── points_service.dart                 # Points calculation engine
```

## Data Models

### Challenge Model (`lib/models/challenge.dart`)

```dart
class Challenge {
  final String id;
  final String name;
  final String description;
  final ChallengeType type;           // public, private, daily
  final ChallengeStatus status;       // upcoming, active, completed
  final DateTime startDate;
  final DateTime endDate;
  final String creatorId;
  final String creatorName;
  final List<String> participantIds;
  final Map<String, int> leaderboard; // userId -> points
  final int maxParticipants;
  final List<String> rules;
  final int entryFee;                 // Points to join
  final int prizePool;                // Winner rewards
}
```

**Key Methods:**
- `isActive`: Real-time active status checking
- `remainingTime`: Duration calculations
- `sortedLeaderboard`: Ranked participant list
- `getUserRank(userId)`: Individual ranking

### RivalSession Model

```dart
class RivalSession {
  final String id;
  final String userId1, userId2;
  final String user1Name, user2Name;
  final DateTime startDate, endDate;
  final int user1Points, user2Points;
  final bool isActive;
  final String? winnerId;
  final int wagerAmount;
  final Map<String, List<String>> activities;
}
```

**Key Methods:**
- `getOpponentId(userId)`: Dynamic opponent resolution
- `isUserWinning(userId)`: Real-time win status
- `getPointDifference(userId)`: Competitive gap calculation

### Chat Message Model (`lib/models/chat_message.dart`)

```dart
class ChatMessage {
  final String id;
  final String content;
  final String senderId, senderName, senderUsername;
  final DateTime timestamp;
  final MessageType type;              // text, achievement, workout, system
  final Map<String, ReactionType> reactions;
  final List<String> mentions;
  final String? replyToMessageId;
  final Map<String, dynamic>? achievementData, workoutData;
}
```

**Message Types:**
- `text`: Standard messaging
- `achievement`: PR celebrations with metadata
- `workout`: Completion shares with stats
- `system`: Automated notifications

## Screen Components

### 1. Challenge Details Screen (`challenge_details_screen.dart`)

**Purpose**: Comprehensive challenge overview with tabbed interface

**Key Features:**
- Real-time countdown timers
- Dynamic participation management
- Tabbed content organization
- Live leaderboard updates

**Architecture:**
```dart
class ChallengeDetailsScreen extends StatefulWidget {
  final Challenge challenge;
  
  // State management
  late TabController _tabController;
  Timer? _countdownTimer;
  bool _isLoading = false;
  String? _errorMessage;
}
```

**Tab Structure:**
1. **Overview Tab**: Rules, info, participant summary
2. **Leaderboard Tab**: Top 10 ranked participants with rank badges
3. **Activity Tab**: Real-time participant activities
4. **Chat Tab**: Integration point to challenge chat

**Real-time Updates:**
- Countdown timer updates every second
- Leaderboard refreshes on user action
- Join/leave functionality with validation
- Error handling with retry mechanisms

### 2. Full Leaderboard Screen (`full_leaderboard_screen.dart`)

**Purpose**: Comprehensive ranking display with advanced filtering

**Key Features:**
- Animated entry transitions
- Search functionality with debouncing
- Filter system (All Time, Weekly, Daily)
- Pull-to-refresh data updates
- User rank highlighting

**Search & Filter System:**
```dart
// Filter implementation
enum LeaderboardFilter { allTime, daily, weekly }

void _filterEntries() {
  _filteredEntries = _allEntries.where((entry) {
    final matchesSearch = _searchQuery.isEmpty ||
        entry.userName.toLowerCase().contains(_searchQuery) ||
        entry.displayName.toLowerCase().contains(_searchQuery);
    return matchesSearch && _applyTimeFilter(entry);
  }).toList();
}
```

**Ranking System:**
- Gold/Silver/Bronze badges for top 3
- Activity indicators (online/offline status)
- Point differential display
- Personal record highlighting

### 3. Challenge Chat Screen (`challenge_chat_screen.dart`)

**Purpose**: Real-time communication hub for challenge participants

**Key Features:**
- Real-time messaging with Socket.IO-style updates
- Message reactions system (👍🔥💪🎉)
- Reply threading functionality
- Achievement and workout sharing
- Typing indicators and read receipts

**Message Architecture:**
```dart
class _ChallengeChatScreenState extends State<ChallengeChatScreen> {
  final TextEditingController _messageController;
  final ScrollController _scrollController;
  List<ChatMessage> _messages = [];
  bool _showQuickResponses = false;
  ChatMessage? _replyingToMessage;
}
```

**Real-time Features:**
- Auto-scroll to new messages
- Message status indicators
- Reaction animations
- Quick response suggestions
- Keyboard handling optimization

### 4. Find Rival Screen (`find_rival_screen.dart`)

**Purpose**: Social discovery and challenge invitation management

**Key Features:**
- Multi-tab interface (Discover, Friends, Invitations)
- Advanced friend filtering and search
- Quick challenge matching
- Invitation management system
- User statistics display

**Tab Architecture:**
1. **Discover Tab**: Recent rivals, suggestions, quick challenge
2. **Friends Tab**: Full friend list with filtering options
3. **Invitations Tab**: Sent and received challenge invites

**Search & Discovery:**
```dart
// Friend filtering system
void _applyFilters() {
  List<Friend> filtered = List.from(_filteredFriends);
  
  if (_selectedSkillFilter != 'All') {
    filtered = filtered.where((friend) => 
      friend.skillLevel == _selectedSkillFilter).toList();
  }
  
  if (_selectedActivityFilter == 'Online') {
    filtered = filtered.where((friend) => friend.isOnline).toList();
  }
}
```

## State Management (BLoC Architecture)

### Challenge BLoC (`challenge_bloc.dart`)

**Purpose**: Centralized state management for all challenge operations

**Key Events:**
```dart
// Challenge management
abstract class ChallengeEvent extends Equatable {}

class LoadChallenges extends ChallengeEvent {
  final String userId;
}

class CreateChallenge extends ChallengeEvent {
  final Challenge challenge;
}

class JoinChallenge extends ChallengeEvent {
  final String challengeId;
  final String userId;
}

// Rival session management
class CreateRivalSession extends ChallengeEvent {
  final RivalSession rivalSession;
}

class UpdateRivalSessionPoints extends ChallengeEvent {
  final String sessionId;
  final String userId;
  final int pointsToAdd;
}

// Invitation management
class SendChallengeInvitation extends ChallengeEvent {
  final ChallengeInvitation invitation;
}

class RespondToInvitation extends ChallengeEvent {
  final String invitationId;
  final String userId;
  final bool accept;
}
```

**Key States:**
```dart
abstract class ChallengeState extends Equatable {}

class ChallengeLoaded extends ChallengeState {
  final List<Challenge> allChallenges;
  final List<Challenge> userChallenges;
  final List<Challenge> activeChallenges;
  final RivalSession? activeRivalSession;
  final List<ChallengeInvitation> receivedInvitations;
  final List<ChallengeInvitation> sentInvitations;
}

class ChallengeLoading extends ChallengeState {
  final String message;
}

class ChallengeError extends ChallengeState {
  final String message;
  final String code;
}
```

**Real-time Subscriptions:**
```dart
// Real-time challenge updates
Future<void> _onSubscribeToChallengeUpdates(
  SubscribeToChallengeUpdates event,
  Emitter<ChallengeState> emit,
) async {
  _challengeSubscriptions[event.challengeId] = 
      Stream.periodic(const Duration(seconds: 30), (i) => i)
          .listen((_) {
    // Simulate real-time point updates
    emit(ChallengeRealTimeUpdate(
      challenge: challenge,
      updateType: 'points_update',
    ));
  });
}
```

## Points Calculation System (`points_service.dart`)

### Core Calculation Engine

**Purpose**: Comprehensive points calculation with bonuses and validation

**Key Features:**
- Weighted scoring by activity type
- Rank-based multipliers
- Streak bonuses (3, 7, 14 day tiers)
- Personal record bonuses
- Anti-exploitation validation

**Calculation Flow:**
```dart
static PointsBreakdown calculatePointsWithBreakdown(
  CompletedWorkout workout,
  UserStats userStats,
) {
  // 1. Base points by workout type
  int basePoints = _calculateBasePoints(workout);
  
  // 2. Apply intensity multiplier
  basePoints = (basePoints * _intensityMultipliers[workout.intensity]).round();
  
  // 3. Apply rank multiplier for weighted scoring
  basePoints = (basePoints * _rankMultipliers[userStats.currentRank]).round();
  
  // 4. Calculate bonuses
  final streakBonus = _calculateStreakBonus(userStats.currentStreak);
  final prBonus = workout.isPersonalRecord ? 0.2 : 0.0;
  
  return PointsBreakdown(/* comprehensive breakdown */);
}
```

**Validation System:**
```dart
static bool validatePointClaim(int points, CompletedWorkout workout) {
  if (points > _maxPointsPerWorkout) return false;
  if (workout.duration.inMinutes < 5) return false;
  
  // Type-specific validation
  switch (workout.type) {
    case WorkoutType.strength:
      // Validate set counts, weights, reps
      break;
    case WorkoutType.cardio:
      // Validate distance limits
      break;
  }
  
  return true;
}
```

## Integration Patterns

### BLoC Integration Example

```dart
class ChallengeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChallengeBloc()..add(LoadChallenges(userId: currentUserId)),
      child: BlocBuilder<ChallengeBloc, ChallengeState>(
        builder: (context, state) {
          if (state is ChallengeLoaded) {
            return ChallengeList(challenges: state.userChallenges);
          } else if (state is ChallengeLoading) {
            return const CircularProgressIndicator();
          } else if (state is ChallengeError) {
            return ErrorWidget(message: state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

### Navigation Patterns

```dart
// Challenge details navigation
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ChallengeDetailsScreen(challenge: challenge),
  ),
);

// Chat integration
void _openChallengeChat() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ChallengeChatScreen(challenge: _currentChallenge),
    ),
  );
}
```

### Data Synchronization

```dart
// Real-time data updates
class ChallengeService {
  static Stream<List<Challenge>> getChallengeUpdates(String userId) {
    return Stream.periodic(const Duration(seconds: 30), (_) {
      return _challenges.where((c) => c.participantIds.contains(userId)).toList();
    });
  }
}
```

## Error Handling

### Comprehensive Error Management

```dart
class ChallengeBloc extends Bloc<ChallengeEvent, ChallengeState> {
  Future<void> _onJoinChallenge(
    JoinChallenge event,
    Emitter<ChallengeState> emit,
  ) async {
    try {
      // Validation checks
      if (challenge.participantIds.contains(event.userId)) {
        throw Exception('Already participating in this challenge');
      }
      
      if (challenge.participantIds.length >= challenge.maxParticipants) {
        throw Exception('Challenge is full');
      }
      
      // Success flow
      emit(ChallengeJoined(challenge: challenge, userId: event.userId));
      
    } catch (e) {
      emit(ChallengeError(
        message: 'Failed to join challenge: ${e.toString()}',
        code: 'join-challenge-error',
      ));
    }
  }
}
```

## Performance Optimizations

### Efficient Data Handling

1. **Lazy Loading**: Load challenge details only when needed
2. **Caching**: In-memory cache for frequently accessed data
3. **Pagination**: Leaderboard pagination for large participant lists
4. **Debouncing**: Search input debouncing to reduce API calls
5. **Animation Optimization**: Efficient list animations and transitions

### Memory Management

```dart
@override
void dispose() {
  // Cancel all subscriptions
  for (final subscription in _challengeSubscriptions.values) {
    subscription.cancel();
  }
  _challengeSubscriptions.clear();
  
  // Dispose controllers
  _messageController.dispose();
  _scrollController.dispose();
  
  super.dispose();
}
```

## Testing Strategy

### Unit Tests
- Points calculation validation
- BLoC event/state transitions
- Model serialization/deserialization
- Business logic validation

### Widget Tests
- Screen rendering with different states
- User interaction flows
- Error state handling
- Animation behaviors

### Integration Tests
- Complete challenge participation flow
- Real-time chat functionality
- Invitation acceptance/decline flow
- Points earning and leaderboard updates

## Future Extensions

### Planned Enhancements
1. **Push Notifications**: Real-time challenge updates
2. **Video Sharing**: Workout video attachments in chat
3. **Advanced Analytics**: Detailed performance metrics
4. **Tournament Mode**: Multi-round elimination challenges
5. **Team Challenges**: Group vs group competitions
6. **Wearable Integration**: Apple Watch, Fitbit sync

### Scalability Considerations
- Firestore real-time listeners for production
- Cloud Functions for server-side point validation
- FCM for push notifications
- CDN integration for media content
- Advanced caching strategies

## Dependencies

### Key Packages
```yaml
dependencies:
  flutter_bloc: ^8.1.3        # State management
  equatable: ^2.0.5           # Value equality
  flutter: ^3.10.0            # Core framework
  
dev_dependencies:
  mockito: ^5.4.2             # Testing mocks
  bloc_test: ^9.1.4           # BLoC testing utilities
```

This technical documentation provides a comprehensive overview of the challenge features architecture, implementation patterns, and integration strategies used in the RivalX application.