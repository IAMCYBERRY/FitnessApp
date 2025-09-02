# RivalX Test Suite

This directory contains comprehensive tests for the RivalX fitness application challenge features.

## Test Structure

```
test/
├── blocs/
│   └── challenge/
│       └── challenge_bloc_test.dart          # Challenge BLoC tests
├── models/
│   ├── challenge_test.dart                   # Challenge model tests
│   └── chat_message_test.dart                # Chat message model tests
├── services/
│   └── points_service_test.dart              # Points service tests
├── widgets/
│   └── challenge_details_screen_test.dart    # Widget tests
├── helpers/
│   └── test_helpers.dart                     # Test utilities and mock data
└── README.md                                 # This file
```

## Test Coverage

### Unit Tests

1. **Points Service Tests** (`test/services/points_service_test.dart`)
   - Base point calculations for all workout types
   - Intensity multipliers and rank bonuses
   - Streak bonuses and personal record bonuses
   - Point validation and anti-fraud measures
   - Edge cases and boundary conditions
   - Mock data generators

2. **Challenge BLoC Tests** (`test/blocs/challenge/challenge_bloc_test.dart`)
   - All event handlers with proper state transitions
   - Error handling and edge cases
   - Real-time subscription management
   - Mock service integration
   - Helper method testing

3. **Challenge Model Tests** (`test/models/challenge_test.dart`)
   - Challenge creation and validation
   - Time calculations and formatting
   - Leaderboard sorting and ranking
   - Status and type display methods
   - RivalSession functionality
   - Friend model properties

4. **Chat Message Tests** (`test/models/chat_message_test.dart`)
   - Message creation and serialization
   - Time formatting and display
   - Reaction management
   - Mention extraction
   - Chat service operations

### Widget Tests

1. **Challenge Details Screen Tests** (`test/widgets/challenge_details_screen_test.dart`)
   - UI component rendering
   - Tab navigation functionality
   - User interaction handling
   - Loading and error states
   - Join/Leave challenge flow
   - Accessibility testing

### Test Helpers

1. **Test Helpers** (`test/helpers/test_helpers.dart`)
   - Common test utilities
   - Mock data generators
   - Custom matchers
   - Test configurations
   - Widget test helpers

## Running Tests

### Prerequisites

Make sure you have the required dependencies installed:

```bash
flutter pub get
```

### Generate Mock Files

Before running BLoC tests, generate the required mock files:

```bash
flutter packages pub run build_runner build
```

### Run All Tests

```bash
flutter test
```

### Run Specific Test Files

```bash
# Run points service tests
flutter test test/services/points_service_test.dart

# Run challenge bloc tests
flutter test test/blocs/challenge/challenge_bloc_test.dart

# Run model tests
flutter test test/models/challenge_test.dart
flutter test test/models/chat_message_test.dart

# Run widget tests
flutter test test/widgets/challenge_details_screen_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

### View Coverage Report

```bash
# Install lcov (on macOS)
brew install lcov

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```

## Test Configuration

### Dependencies

The following test dependencies are required in `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.4
  mockito: ^5.4.2
  build_runner: ^2.4.7
```

### Mock Generation

Mock classes are generated using the `@GenerateMocks` annotation. The generated files will be created in the same directory as the test files with a `.mocks.dart` extension.

## Testing Best Practices

### 1. Test Structure

Follow the AAA pattern:
- **Arrange**: Set up test data and mocks
- **Act**: Execute the code under test
- **Assert**: Verify the expected results

### 2. Test Naming

Use descriptive test names that explain what is being tested:
```dart
test('should calculate streak bonus correctly for 7-day streak', () {
  // Test implementation
});
```

### 3. Mock Usage

Use mocks for external dependencies:
```dart
@GenerateMocks([FirestoreService])
void main() {
  late MockFirestoreService mockFirestoreService;
  
  setUp(() {
    mockFirestoreService = MockFirestoreService();
  });
}
```

### 4. Widget Testing

Use `pumpWidget` and `pumpAndSettle` for widget tests:
```dart
testWidgets('should display challenge name', (tester) async {
  await tester.pumpWidget(createTestWidget(testChallenge));
  expect(find.text('Challenge Name'), findsOneWidget);
});
```

### 5. BLoC Testing

Use `bloc_test` package for testing BLoCs:
```dart
blocTest<ChallengeBloc, ChallengeState>(
  'should emit loading then loaded state',
  build: () => challengeBloc,
  act: (bloc) => bloc.add(LoadChallenges(userId: 'test')),
  expect: () => [
    isA<ChallengeLoading>(),
    isA<ChallengeLoaded>(),
  ],
);
```

## Coverage Goals

- **Unit Tests**: 90%+ coverage for business logic
- **BLoC Tests**: 80%+ coverage for state management
- **Widget Tests**: 70%+ coverage for UI components
- **Integration Tests**: All critical user flows

## Continuous Integration

Tests should be run in CI/CD pipeline:

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter packages pub run build_runner build
      - run: flutter test --coverage
      - run: flutter analyze
```

## Troubleshooting

### Common Issues

1. **Missing Mock Files**: Run `flutter packages pub run build_runner build`
2. **Import Errors**: Make sure all dependencies are in `pubspec.yaml`
3. **Widget Test Failures**: Check if `MaterialApp` wrapper is used
4. **BLoC Test Failures**: Verify mock setup and state expectations

### Debug Tips

1. Use `debugPrint` in tests for troubleshooting
2. Add `print` statements to understand test flow
3. Use `tester.binding.debugAssertAllFoundersArePainted = false` for widget tests
4. Check console output for detailed error messages

## Contributing

When adding new tests:

1. Follow existing test patterns and structure
2. Add appropriate documentation and comments
3. Ensure tests are deterministic and isolated
4. Update this README if adding new test categories
5. Maintain high test coverage standards

## Additional Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [BLoC Testing Documentation](https://bloclibrary.dev/#/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Widget Testing Best Practices](https://docs.flutter.dev/testing/widget-tests)