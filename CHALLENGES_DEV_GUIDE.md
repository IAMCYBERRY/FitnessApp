# RivalX Challenge Features - Developer Integration Guide

## Overview

This guide provides practical implementation instructions for integrating RivalX challenge features into your Flutter application. It covers BLoC usage patterns, mock data setup, navigation patterns, error handling strategies, and performance optimizations.

## Quick Start Integration

### 1. Basic Challenge BLoC Setup

```dart
// main.dart - App-level BLoC provider setup
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rivalx/blocs/challenge/challenge_bloc.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChallengeBloc>(
          create: (context) => ChallengeBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'RivalX',
        home: HomeScreen(),
      ),
    );
  }
}
```

### 2. Loading Challenges in Your Screen

```dart
// home_screen.dart - Basic challenge loading
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String currentUserId = '123'; // Replace with actual user ID

  @override
  void initState() {
    super.initState();
    // Load challenges when screen initializes
    context.read<ChallengeBloc>().add(LoadChallenges(userId: currentUserId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Challenges')),
      body: BlocBuilder<ChallengeBloc, ChallengeState>(
        builder: (context, state) {
          if (state is ChallengeLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (state is ChallengeError) {
            return _buildErrorWidget(state.message);
          }
          
          if (state is ChallengeLoaded) {
            return _buildChallengeList(state.userChallenges);
          }
          
          return Center(child: Text('No challenges loaded'));
        },
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ChallengeBloc>().add(LoadChallenges(userId: currentUserId));
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeList(List<Challenge> challenges) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No challenges yet'),
            Text('Join your first challenge to get started!'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return ChallengeListItem(challenge: challenge);
      },
    );
  }
}
```

## BLoC Usage Patterns

### 1. Challenge Management Pattern

```dart
// Creating a new challenge
void _createChallenge() {
  final newChallenge = Challenge(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: 'My Custom Challenge',
    description: 'A great fitness challenge',
    type: ChallengeType.private,
    status: ChallengeStatus.active,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 7)),
    creatorId: currentUserId,
    creatorName: 'Current User',
    participantIds: [currentUserId],
    leaderboard: {currentUserId: 0},
    rules: ['Complete 4 workouts per week', 'Log all activities'],
  );

  context.read<ChallengeBloc>().add(CreateChallenge(challenge: newChallenge));
}

// Joining an existing challenge
void _joinChallenge(String challengeId) {
  context.read<ChallengeBloc>().add(JoinChallenge(
    challengeId: challengeId,
    userId: currentUserId,
  ));
}

// Leaving a challenge
void _leaveChallenge(String challengeId) {
  context.read<ChallengeBloc>().add(LeaveChallenge(
    challengeId: challengeId,
    userId: currentUserId,
  ));
}
```

### 2. Real-time Updates Pattern

```dart
// Subscribe to challenge updates for real-time data
class ChallengeWidget extends StatefulWidget {
  final String challengeId;
  
  @override
  State<ChallengeWidget> createState() => _ChallengeWidgetState();
}

class _ChallengeWidgetState extends State<ChallengeWidget> {
  @override
  void initState() {
    super.initState();
    // Subscribe to real-time updates
    context.read<ChallengeBloc>().add(
      SubscribeToChallengeUpdates(challengeId: widget.challengeId)
    );
  }

  @override
  void dispose() {
    // Unsubscribe when widget is disposed
    context.read<ChallengeBloc>().add(
      UnsubscribeFromChallengeUpdates(challengeId: widget.challengeId)
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChallengeBloc, ChallengeState>(
      listener: (context, state) {
        if (state is ChallengeRealTimeUpdate) {
          // Handle real-time updates
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Challenge updated!')),
          );
        }
      },
      child: BlocBuilder<ChallengeBloc, ChallengeState>(
        builder: (context, state) {
          // Build your UI here
          return YourChallengeUI();
        },
      ),
    );
  }
}
```

### 3. Rival Session Pattern

```dart
// Create a rival session
void _createRivalSession(String opponentId, String opponentName) {
  final rivalSession = RivalSession(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    userId1: currentUserId,
    userId2: opponentId,
    user1Name: currentUserName,
    user2Name: opponentName,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 7)),
    isActive: true,
    wagerAmount: 100,
  );

  context.read<ChallengeBloc>().add(CreateRivalSession(rivalSession: rivalSession));
}

// Update rival session points
void _addPointsToRivalSession(String sessionId, int points) {
  context.read<ChallengeBloc>().add(UpdateRivalSessionPoints(
    sessionId: sessionId,
    userId: currentUserId,
    pointsToAdd: points,
  ));
}
```

## Mock Data Setup

### 1. Initialize Mock Data in main.dart

```dart
void main() {
  // Initialize mock data
  ChallengeService.addMockData();
  FriendService.addMockData();
  
  runApp(MyApp());
}
```

### 2. Custom Mock Data Creation

```dart
// Create custom challenges for testing
void setupCustomMockData() {
  final customChallenge = Challenge(
    id: 'custom_challenge_1',
    name: 'Developer Test Challenge',
    description: 'A challenge created for testing purposes',
    type: ChallengeType.public,
    status: ChallengeStatus.active,
    startDate: DateTime.now().subtract(Duration(days: 1)),
    endDate: DateTime.now().add(Duration(days: 6)),
    creatorId: 'test_creator',
    creatorName: 'Test Creator',
    participantIds: ['123', 'test_user_1', 'test_user_2'],
    leaderboard: {
      '123': 1500,          // Current user
      'test_user_1': 1400,
      'test_user_2': 1300,
    },
    rules: [
      'Complete at least 3 workouts per week',
      'Log all meals and nutrition',
      'Stay active and motivated!',
    ],
    maxParticipants: 50,
    prizePool: 5000,
  );

  ChallengeService.createChallenge(customChallenge);
}
```

### 3. Mock Points Service Usage

```dart
// Generate mock workout for testing points
void testPointsCalculation() {
  final mockWorkout = PointsService.generateMockStrengthWorkout(
    isPersonalRecord: true,
    intensity: WorkoutIntensity.high,
  );

  final mockUserStats = PointsService.generateMockUserStats(
    streak: 7,
    rank: RankLevel.B,
  );

  final pointsBreakdown = PointsService.calculatePointsWithBreakdown(
    mockWorkout,
    mockUserStats,
  );

  print('Points earned: ${pointsBreakdown.totalPoints}');
  print('Breakdown: ${pointsBreakdown.bonusBreakdown}');
}
```

## Navigation Patterns

### 1. Screen Navigation with BLoC Context

```dart
// Navigate to challenge details
void _navigateToChallengeDetails(Challenge challenge) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: context.read<ChallengeBloc>(),
        child: ChallengeDetailsScreen(challenge: challenge),
      ),
    ),
  );
}

// Navigate to chat with proper context
void _navigateToChat(Challenge challenge) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ChallengeChatScreen(challenge: challenge),
    ),
  );
}

// Navigate to find rival screen
void _navigateToFindRival() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: context.read<ChallengeBloc>(),
        child: FindRivalScreen(),
      ),
    ),
  );
}
```

### 2. Bottom Sheet Navigation Pattern

```dart
// Show challenge options bottom sheet
void _showChallengeOptions(Challenge challenge) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.surfaceColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => ChallengeOptionsSheet(
      challenge: challenge,
      onJoin: () => _joinChallenge(challenge.id),
      onLeave: () => _leaveChallenge(challenge.id),
      onViewDetails: () => _navigateToChallengeDetails(challenge),
    ),
  );
}
```

### 3. Deep Link Integration

```dart
// Handle deep links to challenges
class DeepLinkHandler {
  static void handleChallengeLink(String challengeId, BuildContext context) {
    // Load challenge details
    context.read<ChallengeBloc>().add(LoadChallengeDetails(challengeId: challengeId));
    
    // Navigate to challenge screen
    Navigator.of(context).pushNamed(
      '/challenge/$challengeId',
      arguments: {'challengeId': challengeId},
    );
  }
}

// Route configuration
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/challenge':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => ChallengeDetailsScreen(
            challengeId: args['challengeId'],
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => NotFoundScreen());
    }
  }
}
```

## Error Handling Strategies

### 1. Comprehensive Error Handling

```dart
class ChallengeErrorHandler {
  static void handleChallengeError(ChallengeError error, BuildContext context) {
    String userMessage;
    Widget? action;

    switch (error.code) {
      case 'join-challenge-error':
        userMessage = 'Unable to join challenge. Please try again.';
        action = ElevatedButton(
          onPressed: () => _retryJoinChallenge(context),
          child: Text('Retry'),
        );
        break;
      
      case 'network-error':
        userMessage = 'Connection problem. Check your internet and try again.';
        action = ElevatedButton(
          onPressed: () => _refreshData(context),
          child: Text('Refresh'),
        );
        break;
      
      case 'validation-error':
        userMessage = error.message; // Use specific validation message
        break;
        
      default:
        userMessage = 'Something went wrong. Please try again later.';
    }

    _showErrorDialog(context, userMessage, action);
  }

  static void _showErrorDialog(BuildContext context, String message, Widget? action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Oops!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
}
```

### 2. BLoC Error Handling Pattern

```dart
class ChallengeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChallengeBloc, ChallengeState>(
      listener: (context, state) {
        // Handle error states
        if (state is ChallengeError) {
          ChallengeErrorHandler.handleChallengeError(state, context);
        }
        
        // Handle success states
        if (state is ChallengeJoined) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        return _buildContent(state);
      },
    );
  }
}
```

### 3. Network Error Handling

```dart
class NetworkErrorWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRetry;

  const NetworkErrorWrapper({
    required this.child,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChallengeBloc, ChallengeState>(
      builder: (context, state) {
        if (state is ChallengeError && state.code == 'network-error') {
          return _buildNetworkErrorWidget();
        }
        return child;
      },
    );
  }

  Widget _buildNetworkErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No internet connection'),
          Text('Check your connection and try again'),
          SizedBox(height: 16),
          if (onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
            ),
        ],
      ),
    );
  }
}
```

## Performance Considerations

### 1. Efficient List Building

```dart
// Optimized challenge list with proper keys and builders
class OptimizedChallengeList extends StatelessWidget {
  final List<Challenge> challenges;

  const OptimizedChallengeList({required this.challenges});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Use itemExtent for better performance if items have fixed height
      itemExtent: 120.0,
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return ChallengeListItem(
          key: ValueKey(challenge.id), // Important for Flutter's diff algorithm
          challenge: challenge,
        );
      },
    );
  }
}

// Optimized challenge list item
class ChallengeListItem extends StatelessWidget {
  final Challenge challenge;

  const ChallengeListItem({Key? key, required this.challenge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildChallengeIcon(),
        title: Text(challenge.name),
        subtitle: Text(challenge.description),
        trailing: _buildStatusChip(),
        onTap: () => _navigateToChallengeDetails(context),
      ),
    );
  }

  Widget _buildChallengeIcon() {
    return CircleAvatar(
      backgroundColor: challenge.statusColor,
      child: Icon(challenge.typeIcon, color: Colors.white),
    );
  }

  Widget _buildStatusChip() {
    return Chip(
      label: Text(
        challenge.remainingTimeFormatted,
        style: TextStyle(fontSize: 12),
      ),
      backgroundColor: challenge.statusColor.withOpacity(0.2),
    );
  }

  void _navigateToChallengeDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChallengeDetailsScreen(challenge: challenge),
      ),
    );
  }
}
```

### 2. Memory Management

```dart
class MemoryManagedChallengeScreen extends StatefulWidget {
  @override
  State<MemoryManagedChallengeScreen> createState() => _MemoryManagedChallengeScreenState();
}

class _MemoryManagedChallengeScreenState extends State<MemoryManagedChallengeScreen> {
  late StreamSubscription<ChallengeState> _blocSubscription;
  final List<Challenge> _cachedChallenges = [];

  @override
  void initState() {
    super.initState();
    
    // Set up efficient bloc listening
    _blocSubscription = context.read<ChallengeBloc>().stream.listen((state) {
      if (state is ChallengeLoaded) {
        // Update cache efficiently
        _updateChallengeCache(state.userChallenges);
      }
    });
  }

  @override
  void dispose() {
    // Cancel subscriptions to prevent memory leaks
    _blocSubscription.cancel();
    _cachedChallenges.clear();
    super.dispose();
  }

  void _updateChallengeCache(List<Challenge> newChallenges) {
    // Efficient cache update logic
    _cachedChallenges.clear();
    _cachedChallenges.addAll(newChallenges);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _cachedChallenges.length,
        itemBuilder: (context, index) {
          return ChallengeListItem(challenge: _cachedChallenges[index]);
        },
      ),
    );
  }
}
```

### 3. Image Loading Optimization

```dart
// Optimized image loading for user avatars and challenge images
class OptimizedChallengeImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const OptimizedChallengeImage({
    this.imageUrl,
    this.size = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Loading placeholder
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        // Error placeholder
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
        // Memory cache
        cacheWidth: size.toInt(),
        cacheHeight: size.toInt(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image, color: Colors.grey[600]),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.error, color: Colors.red),
    );
  }
}
```

## Testing Integration

### 1. BLoC Testing Setup

```dart
// test/blocs/challenge_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalx/blocs/challenge/challenge_bloc.dart';

void main() {
  group('ChallengeBloc', () {
    late ChallengeBloc challengeBloc;

    setUp(() {
      challengeBloc = ChallengeBloc();
    });

    tearDown(() {
      challengeBloc.close();
    });

    blocTest<ChallengeBloc, ChallengeState>(
      'emits [ChallengeLoading, ChallengeLoaded] when LoadChallenges is added',
      build: () => challengeBloc,
      act: (bloc) => bloc.add(LoadChallenges(userId: 'test_user')),
      expect: () => [
        isA<ChallengeLoading>(),
        isA<ChallengeLoaded>(),
      ],
    );

    blocTest<ChallengeBloc, ChallengeState>(
      'emits ChallengeJoined when JoinChallenge succeeds',
      build: () => challengeBloc,
      seed: () => ChallengeLoaded(
        allChallenges: [mockChallenge],
        userChallenges: [],
        activeChallenges: [mockChallenge],
        activeRivalSession: null,
        receivedInvitations: [],
        sentInvitations: [],
      ),
      act: (bloc) => bloc.add(JoinChallenge(
        challengeId: 'test_challenge',
        userId: 'test_user',
      )),
      expect: () => [
        isA<ChallengeLoading>(),
        isA<ChallengeJoined>(),
      ],
    );
  });
}
```

### 2. Widget Testing

```dart
// test/widgets/challenge_list_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('ChallengeList Widget', () {
    late MockChallengeBloc mockChallengeBloc;

    setUp(() {
      mockChallengeBloc = MockChallengeBloc();
    });

    testWidgets('displays loading indicator when state is loading', (tester) async {
      when(mockChallengeBloc.state).thenReturn(ChallengeLoading(message: 'Loading...'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChallengeBloc>.value(
            value: mockChallengeBloc,
            child: ChallengeListWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays challenges when state is loaded', (tester) async {
      final mockChallenges = [
        mockChallenge1,
        mockChallenge2,
      ];

      when(mockChallengeBloc.state).thenReturn(
        ChallengeLoaded(
          allChallenges: mockChallenges,
          userChallenges: mockChallenges,
          activeChallenges: [],
          activeRivalSession: null,
          receivedInvitations: [],
          sentInvitations: [],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChallengeBloc>.value(
            value: mockChallengeBloc,
            child: ChallengeListWidget(),
          ),
        ),
      );

      expect(find.byType(ChallengeListItem), findsNWidgets(2));
    });
  });
}
```

### 3. Integration Testing

```dart
// integration_test/challenge_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rivalx/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Challenge Flow Integration Tests', () {
    testWidgets('complete challenge participation flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to challenges
      await tester.tap(find.text('Challenges'));
      await tester.pumpAndSettle();

      // Find and tap on a challenge
      await tester.tap(find.byType(ChallengeListItem).first);
      await tester.pumpAndSettle();

      // Join the challenge
      await tester.tap(find.text('Join Challenge'));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Successfully joined'), findsOneWidget);

      // Navigate to chat
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      // Send a message
      await tester.enterText(find.byType(TextField), 'Hello everyone!');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Verify message appears
      expect(find.text('Hello everyone!'), findsOneWidget);
    });
  });
}
```

## Common Implementation Patterns

### 1. Refresh Pattern

```dart
class RefreshableChallengeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChallengeBloc>().add(RefreshChallenges(userId: currentUserId));
        
        // Wait for the refresh to complete
        await context.read<ChallengeBloc>().stream.firstWhere(
          (state) => state is! ChallengeRefreshing,
        );
      },
      child: BlocBuilder<ChallengeBloc, ChallengeState>(
        builder: (context, state) {
          return ListView(
            children: [
              // Your challenge list items
            ],
          );
        },
      ),
    );
  }
}
```

### 2. Search Pattern

```dart
class SearchableChallengeList extends StatefulWidget {
  @override
  State<SearchableChallengeList> createState() => _SearchableChallengeListState();
}

class _SearchableChallengeListState extends State<SearchableChallengeList> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Debounce search to avoid too many API calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      context.read<ChallengeBloc>().add(
        SearchChallenges(
          query: _searchController.text,
          limit: 20,
        ),
      );
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search challenges...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<ChallengeBloc, ChallengeState>(
            builder: (context, state) {
              if (state is ChallengeSearchResults) {
                return ListView.builder(
                  itemCount: state.results.length,
                  itemBuilder: (context, index) {
                    return ChallengeListItem(challenge: state.results[index]);
                  },
                );
              }
              return Center(child: Text('Start typing to search...'));
            },
          ),
        ),
      ],
    );
  }
}
```

This developer integration guide provides all the practical patterns and examples needed to successfully implement RivalX challenge features in your Flutter application.