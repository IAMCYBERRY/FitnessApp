# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RivalX is a mobile fitness application built with Flutter/Dart that revolutionizes health and wellness through competitive gamification. The app combines comprehensive fitness tracking with rivalry-based mechanics to motivate users through competition, challenges, and social accountability.

## Technology Stack

- **Frontend**: Flutter/Dart (cross-platform mobile)
- **Backend**: Firebase ecosystem
  - Firebase Authentication
  - Firestore Database
  - Firebase Storage
  - Cloud Functions
- **APIs**: 
  - ExerciseDB API for exercise database
  - USDA FDC API for nutrition information
- **Platform Integrations**:
  - iOS: HealthKit, Biometric Authentication, Passkeys
  - Android: Samsung Health/Google Fit, Biometric Authentication

## Core Architecture

The app follows a feature-based architecture with the following major components:

1. **Authentication System**: Firebase Auth with biometric (Fingerprint, FaceID) and passkey support
2. **User Profiles**: Date joined, weight lifted, distance walked, rank progress, total points, penalties
3. **Fitness Tracking**: Workout logging with sets, reps, weight, distance, PRs, and device sync
4. **Nutrition Tracking**: USDA FDC API integration for meals (Breakfast, Lunch, Dinner, Snacks, MicroMeals)
5. **Rival Mode**: Weekly 1v1 competitions with 10% point stealing from winner
6. **Challenge System**: Public (open) and private (invite-only) challenges with chat and leaderboards
7. **Point & Rank System**: E → D → C → B → A → S → SS progression with weighted scoring
8. **Social Features**: Friend search by username/email, friend profiles, and friend-based leaderboards
9. **Daily Challenges**: Equipment-free rotating challenges (e.g., 50 squats, 5-min plank)
10. **Penalty System**: Point deduction or extreme routine for missing workout requirements

## Development Workflow

### Flutter Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for release
flutter build apk  # Android
flutter build ios  # iOS

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Firebase Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

## State Management

The app uses the Bloc pattern for state management. Each feature has its own Bloc for handling business logic and state updates.

## Design System

### Color Scheme
- **Primary Black**: Professional, sleek foundation
- **Slate Grey**: Secondary elements, text, borders
- **Yellow Accent**: Calls-to-action, highlights, achievements

### User Interface Principles
- **Competitive Focus**: Leaderboard prominence, progress visualization, real-time updates
- **Accessibility**: Dynamic text sizing, high color contrast, voice navigation support
- **Design Theme**: Competitive and motivational with rivalry-focused interfaces

## Key Implementation Details

- **Real-time Updates**: Firestore streams for live leaderboards and rival tracking
- **Offline Support**: Cached data entry with sync upon reconnect
- **Security**: Firebase Auth + Firestore rules + HTTPS API usage
- **Performance**: Sub-second load times for major interactions
- **Point System Bonuses**:
  - 7-Day Workout Streak: +5% bonus
  - Rival Mode Win: +10% of rival's weekly points
  - Weighted scoring based on activity importance
- **API Endpoints**:
  - ExerciseDB: https://github.com/ExerciseDB/exercisedb-api
  - USDA FDC: https://fdc.nal.usda.gov/api-guide

## Testing Strategy

- Unit tests for business logic (Blocs, services)
- Widget tests for UI components
- Integration tests for critical user flows
- Firebase emulator for backend testing

## Code Documentation Standards

### Required Documentation
1. **File Headers**: Every file must start with a comment block describing its purpose
2. **Class Documentation**: All classes must have documentation explaining their role
3. **Method Documentation**: All public methods must have:
   - Description of what the method does
   - Parameter descriptions with @param tags
   - Return value description with @return tag
   - Example usage for complex methods
4. **Complex Logic**: Any complex algorithm or business logic must have inline comments
5. **TODO Comments**: Use TODO: for future improvements with ticket numbers if available

### Documentation Format
```dart
/// Brief description of the class/method/variable.
/// 
/// Detailed description if needed, explaining the purpose,
/// behavior, and any important notes.
/// 
/// @param paramName Description of the parameter
/// @return Description of the return value
/// 
/// Example:
/// ```dart
/// final result = methodName(value);
/// ```
```

## Development Phases

1. **Phase 1 (Core)**: 
   - Routine creation with ExerciseDB integration
   - Basic fitness tracking
   - Meal and nutrition tracking with USDA API
   - Point & rank system (E through SS ranks)
   - User profiles and authentication

2. **Phase 2 (Competition)**: 
   - Rival mode (1v1 weekly competitions)
   - Basic challenges (Public/Private)
   - Leaderboards (Daily, Weekly, Monthly, All-Time)
   - Daily challenges
   - Penalty system

3. **Phase 3 (Social)**: 
   - Enhanced social features
   - Advanced leaderboards
   - Challenge chat
   - Friend competitions

4. **Phase 4 (Premium)**: 
   - Analytics & custom coaching
   - Monthly events/seasons with exclusive ranks
   - Wearable integration (Apple Watch, Fitbit, Garmin)
   - Video demonstrations for exercises

## Success Metrics

- **Daily Active Users (DAU)**: > 5,000 within 6 months
- **User Retention**: 40%+ monthly
- **Workouts Logged**: 3+ per user per week average
- **Leaderboard Engagement**: 50% of users in at least 1 challenge or rival pairing
- **App Store Rating**: 4.5+ after 90 days