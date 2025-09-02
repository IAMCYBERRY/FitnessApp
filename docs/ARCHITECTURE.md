# RivalX Architecture Documentation

## Overview

RivalX follows a clean architecture pattern with clear separation of concerns, making the codebase maintainable, testable, and scalable. The app uses Flutter with the BLoC pattern for state management and Firebase as the backend infrastructure.

## Architecture Layers

### 1. Presentation Layer
Located in `/lib/screens` and `/lib/widgets`

- **Screens**: Full-page views that users navigate between
- **Widgets**: Reusable UI components
- **Responsibilities**:
  - Display UI elements
  - Handle user interactions
  - Delegate business logic to BLoCs
  - No direct data manipulation

### 2. Business Logic Layer (BLoC)
Located in `/lib/blocs`

- **BLoCs**: Business Logic Components that manage state
- **Events**: User actions or system triggers
- **States**: Different UI states (loading, success, error, etc.)
- **Responsibilities**:
  - Process events and emit states
  - Coordinate between repositories
  - Handle business rules and validation
  - Manage app state

### 3. Data Layer
Located in `/lib/services` and `/lib/models`

- **Models**: Data structures representing domain entities
- **Repositories**: Abstract interfaces for data operations
- **Services**: Concrete implementations of repositories
- **Responsibilities**:
  - Define data structures
  - Handle API calls
  - Manage local storage
  - Data transformation

### 4. Core/Shared
Located in `/lib/utils` and `/lib/config`

- **Utils**: Helper functions and utilities
- **Config**: App configuration, themes, constants
- **Responsibilities**:
  - Provide common functionality
  - Define app-wide settings
  - Handle cross-cutting concerns

## Directory Structure

```
lib/
├── blocs/                 # Business Logic Components
│   ├── auth/             # Authentication BLoC
│   ├── profile/          # User Profile BLoC
│   ├── workout/          # Workout tracking BLoC
│   ├── nutrition/        # Nutrition tracking BLoC
│   ├── challenges/       # Challenges BLoC
│   ├── rival/            # Rival mode BLoC
│   ├── leaderboard/      # Leaderboard BLoC
│   └── points/           # Points system BLoC
│
├── config/               # App Configuration
│   ├── theme.dart       # App theme and colors
│   ├── constants.dart   # App constants
│   └── routes.dart      # Navigation routes
│
├── models/              # Data Models
│   ├── user.dart        # User model
│   ├── workout.dart     # Workout model
│   ├── exercise.dart    # Exercise model
│   ├── meal.dart        # Meal/Nutrition model
│   ├── challenge.dart   # Challenge model
│   ├── rival.dart       # Rival mode model
│   └── points.dart      # Points/Rank model
│
├── screens/             # App Screens
│   ├── auth/           # Authentication screens
│   ├── home/           # Home/Dashboard screens
│   ├── workout/        # Workout screens
│   ├── nutrition/      # Nutrition screens
│   ├── challenges/     # Challenge screens
│   ├── rival/          # Rival mode screens
│   ├── leaderboard/    # Leaderboard screens
│   └── profile/        # Profile screens
│
├── services/           # External Services
│   ├── auth_service.dart        # Firebase Auth
│   ├── firestore_service.dart   # Firestore operations
│   ├── exercise_api.dart        # ExerciseDB API
│   ├── nutrition_api.dart       # USDA FDC API
│   ├── health_service.dart      # HealthKit/Google Fit
│   └── storage_service.dart     # Local storage
│
├── utils/              # Utilities
│   ├── validators.dart  # Input validators
│   ├── formatters.dart  # Data formatters
│   ├── extensions.dart  # Dart extensions
│   └── helpers.dart     # Helper functions
│
└── widgets/            # Reusable Widgets
    ├── common/         # Common widgets
    ├── buttons/        # Button widgets
    ├── cards/          # Card widgets
    ├── charts/         # Chart widgets
    └── forms/          # Form widgets
```

## State Management Pattern (BLoC)

### Event Flow
1. User interaction triggers an event
2. Screen dispatches event to BLoC
3. BLoC processes event using repositories
4. BLoC emits new state
5. Screen rebuilds based on new state

### Example Flow: User Login
```
LoginScreen -> LoginButtonPressed -> AuthBloc -> AuthService -> Firebase
    ↑                                    ↓
    └────── AuthState (Success) ←────────┘
```

## Data Flow

### Remote Data (Firebase)
1. **Firestore**: Main database for user data, workouts, challenges
2. **Firebase Auth**: User authentication
3. **Cloud Functions**: Server-side logic for leaderboards, point calculations
4. **Firebase Storage**: Profile pictures, workout images

### Local Data
1. **Shared Preferences**: User preferences, settings
2. **Hive**: Offline data caching
3. **Memory Cache**: Temporary data during app session

### External APIs
1. **ExerciseDB API**: Exercise database
2. **USDA FDC API**: Food and nutrition data
3. **HealthKit/Google Fit**: Device health data

## Security Architecture

### Authentication Flow
1. Email/Password or Biometric authentication
2. Firebase Auth token generation
3. Token stored securely
4. Token attached to all API requests
5. Token refresh on expiration

### Data Security
1. All API calls use HTTPS
2. Sensitive data encrypted in local storage
3. Firestore security rules enforce access control
4. User data isolation at database level

## Navigation Architecture

### Route Management
- Named routes for all screens
- Route guards for authentication
- Deep linking support
- Bottom navigation for main sections

### Screen Hierarchy
```
SplashScreen
    ↓
AuthCheck
    ├── LoginScreen → SignupScreen
    └── MainScreen (Bottom Nav)
         ├── HomeScreen
         ├── WorkoutScreen
         ├── NutritionScreen
         ├── ChallengesScreen
         └── ProfileScreen
```

## Performance Considerations

### Optimization Strategies
1. **Lazy Loading**: Load data as needed
2. **Pagination**: For large lists (leaderboards, exercises)
3. **Image Caching**: Cache profile pictures and exercise images
4. **Offline Support**: Queue actions when offline
5. **State Persistence**: Maintain state across app restarts

### Memory Management
1. Dispose BLoCs when not needed
2. Cancel stream subscriptions
3. Clear image cache periodically
4. Limit in-memory data size

## Testing Architecture

### Unit Tests
- Test BLoCs independently
- Test services with mocked dependencies
- Test models and utilities

### Widget Tests
- Test individual widgets
- Test screen interactions
- Test navigation flows

### Integration Tests
- Test complete user flows
- Test Firebase integration
- Test external API integration

## Deployment Architecture

### Build Variants
1. **Development**: Points to dev Firebase project
2. **Staging**: Points to staging Firebase project
3. **Production**: Points to production Firebase project

### CI/CD Pipeline
1. Code push triggers build
2. Run tests
3. Build APK/IPA
4. Deploy to app stores

## Scalability Considerations

### Horizontal Scaling
- Firebase automatically scales
- Cloud Functions scale on demand
- CDN for static assets

### Vertical Scaling
- Optimize database queries
- Implement caching strategies
- Use pagination for large datasets

## Future Architecture Considerations

### Potential Enhancements
1. **Microservices**: Split backend into services
2. **GraphQL**: For more efficient data fetching
3. **Real-time Sync**: For live competition updates
4. **ML Integration**: For workout recommendations
5. **WebSocket**: For real-time rival tracking