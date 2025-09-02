# RivalX Variable Naming Conventions

## Overview

This document defines the variable naming conventions used throughout the RivalX codebase. Consistent naming improves code readability, maintainability, and reduces cognitive load for developers.

## General Principles

1. **Be Descriptive**: Variable names should clearly indicate their purpose
2. **Be Consistent**: Use the same naming pattern throughout the codebase
3. **Avoid Abbreviations**: Use full words unless the abbreviation is widely understood
4. **Use English**: All names should be in English

## Dart/Flutter Naming Conventions

### Classes and Enums
- **Pattern**: PascalCase
- **Examples**:
  ```dart
  class UserProfile { }
  class WorkoutSession { }
  class RivalChallenge { }
  enum RankLevel { E, D, C, B, A, S, SS }
  enum WorkoutType { strength, cardio, flexibility }
  ```

### Variables and Parameters
- **Pattern**: camelCase
- **Examples**:
  ```dart
  String userName;
  int totalPoints;
  double workoutDuration;
  bool isRivalModeActive;
  List<Exercise> selectedExercises;
  ```

### Constants
- **Pattern**: camelCase (Dart convention, not SCREAMING_SNAKE_CASE)
- **Examples**:
  ```dart
  const int maxRivalsPerWeek = 1;
  const double pointMultiplier = 1.5;
  const String apiBaseUrl = 'https://api.rivalx.com';
  ```

### Private Members
- **Pattern**: Leading underscore + camelCase
- **Examples**:
  ```dart
  String _privateUserId;
  int _cachedPoints;
  void _calculateBonus() { }
  ```

### Boolean Variables
- **Pattern**: Prefix with is, has, can, should
- **Examples**:
  ```dart
  bool isAuthenticated;
  bool hasCompletedOnboarding;
  bool canCreateChallenge;
  bool shouldShowNotification;
  ```

## Specific Naming Patterns

### Screen Names
- **Pattern**: [Feature]Screen
- **Examples**:
  ```dart
  class LoginScreen extends StatelessWidget { }
  class WorkoutDetailScreen extends StatelessWidget { }
  class RivalSelectionScreen extends StatelessWidget { }
  ```

### Widget Names
- **Pattern**: [Description]Widget or [Description]Card/Button/etc
- **Examples**:
  ```dart
  class ExerciseCard extends StatelessWidget { }
  class PointsProgressBar extends StatelessWidget { }
  class RivalChallengeButton extends StatelessWidget { }
  ```

### BLoC Components
- **Pattern**: [Feature]Bloc, [Feature]Event, [Feature]State
- **Examples**:
  ```dart
  class AuthBloc extends Bloc<AuthEvent, AuthState> { }
  class WorkoutEvent { }
  class LeaderboardState { }
  ```

### Service Classes
- **Pattern**: [Feature]Service
- **Examples**:
  ```dart
  class AuthService { }
  class WorkoutTrackingService { }
  class NutritionApiService { }
  ```

### Repository Classes
- **Pattern**: [Feature]Repository
- **Examples**:
  ```dart
  class UserRepository { }
  class WorkoutRepository { }
  class ChallengeRepository { }
  ```

### Model Classes
- **Pattern**: Singular noun representing the entity
- **Examples**:
  ```dart
  class User { }
  class Workout { }
  class Exercise { }
  class Meal { }
  class Challenge { }
  ```

## Database Field Names

### Firestore Collections
- **Pattern**: Plural, lowercase with underscores
- **Examples**:
  ```
  users
  workouts
  challenges
  rival_matches
  daily_challenges
  ```

### Firestore Document Fields
- **Pattern**: camelCase
- **Examples**:
  ```dart
  {
    'userId': 'abc123',
    'displayName': 'John Doe',
    'totalPoints': 1500,
    'currentRank': 'C',
    'createdAt': Timestamp,
    'lastWorkoutDate': Timestamp
  }
  ```

## File Names

### Dart Files
- **Pattern**: lowercase_with_underscores.dart
- **Examples**:
  ```
  user_profile.dart
  workout_service.dart
  rival_challenge_screen.dart
  points_calculator.dart
  ```

### Asset Files
- **Pattern**: lowercase_with_underscores
- **Examples**:
  ```
  logo_yellow.png
  rank_badge_s.svg
  workout_complete_sound.mp3
  ```

## Function and Method Names

### General Methods
- **Pattern**: camelCase, verb + noun
- **Examples**:
  ```dart
  void createWorkout() { }
  Future<User> fetchUserProfile() { }
  double calculatePoints() { }
  bool validateEmail(String email) { }
  ```

### Event Handlers
- **Pattern**: on + Event or handle + Event
- **Examples**:
  ```dart
  void onLoginPressed() { }
  void handleWorkoutComplete() { }
  void onRivalSelected(String rivalId) { }
  ```

### Getters and Setters
- **Pattern**: Simple noun for getters, set + Noun for setters
- **Examples**:
  ```dart
  String get userName => _userName;
  set userName(String value) => _userName = value;
  
  bool get isEligibleForChallenge => totalPoints > 100;
  ```

## Common Variable Names

### User-Related
```dart
User currentUser;
String userId;
String userName;
String userEmail;
UserProfile userProfile;
List<User> friends;
User selectedRival;
```

### Workout-Related
```dart
Workout currentWorkout;
List<Exercise> exercises;
int sets;
int reps;
double weight;
Duration workoutDuration;
DateTime workoutDate;
WorkoutType workoutType;
```

### Points and Ranking
```dart
int totalPoints;
int weeklyPoints;
int dailyPoints;
RankLevel currentRank;
int pointsToNextRank;
double pointMultiplier;
int streakDays;
```

### Challenge-Related
```dart
Challenge activeChallenge;
List<Challenge> availableChallenges;
String challengeId;
ChallengeType challengeType;
List<User> challengeParticipants;
DateTime challengeEndDate;
```

### UI State
```dart
bool isLoading;
bool hasError;
String errorMessage;
bool isRefreshing;
ScrollController scrollController;
TabController tabController;
```

## API and Network

### Request/Response
```dart
Map<String, dynamic> requestBody;
http.Response response;
Map<String, dynamic> responseData;
String apiEndpoint;
Map<String, String> headers;
```

### Status Codes
```dart
int statusCode;
bool isSuccess;
String errorCode;
String errorDescription;
```

## Time and Date

```dart
DateTime currentDate;
DateTime startDate;
DateTime endDate;
Duration timeElapsed;
int dayOfWeek;
Timestamp lastUpdated;
DateTime createdAt;
```

## Collections

### Lists
```dart
List<User> users;          // Not: userList
List<Workout> workouts;    // Not: workoutList
List<String> exerciseIds;  // Not: exerciseIdList
```

### Maps
```dart
Map<String, User> userMap;
Map<String, int> pointsByUserId;
Map<DateTime, List<Workout>> workoutsByDate;
```

## Avoid These Patterns

1. **Single Letter Variables** (except in loops: i, j, k)
   ```dart
   // Bad
   String n;
   int p;
   
   // Good
   String name;
   int points;
   ```

2. **Hungarian Notation**
   ```dart
   // Bad
   String strName;
   int intAge;
   
   // Good
   String name;
   int age;
   ```

3. **Unclear Abbreviations**
   ```dart
   // Bad
   int usrPts;
   String wktDt;
   
   // Good
   int userPoints;
   String workoutDate;
   ```

4. **Redundant Type Information**
   ```dart
   // Bad
   List<User> userList;
   Map<String, User> userMap;
   
   // Good (when context is clear)
   List<User> users;
   Map<String, User> usersByid;
   ```

## Special Cases

### Temporary Variables in Loops
```dart
for (int i = 0; i < items.length; i++) { }
for (final user in users) { }
users.forEach((user) => print(user.name));
```

### Builder Pattern
```dart
Widget build(BuildContext context) { }
itemBuilder: (context, index) { }
builder: (context, snapshot) { }
```

### Stream and Future
```dart
Stream<List<User>> userStream;
Future<void> futureWorkout;
StreamController<int> pointsController;
```

## Comments for Variable Declaration

When the purpose isn't immediately clear, add a comment:

```dart
// Multiplier applied when user wins rival mode
final double rivalWinMultiplier = 1.1;

// Maximum number of exercises per workout routine
final int maxExercisesPerRoutine = 20;

// Time window for accepting rival challenges (in hours)
final int challengeAcceptanceWindow = 24;
```