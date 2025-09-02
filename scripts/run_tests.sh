#!/bin/bash

# RivalX Test Runner Script
# This script runs all tests and generates coverage reports

set -e

echo "🚀 RivalX Test Suite Runner"
echo "=========================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter: https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Not in Flutter project directory"
    echo "Please run this script from the project root"
    exit 1
fi

echo "📦 Installing dependencies..."
flutter pub get

echo "🔧 Generating mock files..."
if flutter packages pub run build_runner build --delete-conflicting-outputs; then
    echo "✅ Mock files generated successfully"
else
    echo "⚠️  Mock generation failed, but continuing with tests..."
fi

echo "🧪 Running unit tests..."
if flutter test test/services/ test/models/ test/blocs/ --reporter compact; then
    echo "✅ Unit tests passed"
else
    echo "❌ Unit tests failed"
    exit 1
fi

echo "🎨 Running widget tests..."
if flutter test test/widgets/ --reporter compact; then
    echo "✅ Widget tests passed"
else
    echo "❌ Widget tests failed"
    exit 1
fi

echo "📊 Running all tests with coverage..."
if flutter test --coverage --reporter compact; then
    echo "✅ All tests passed with coverage"
else
    echo "❌ Some tests failed"
    exit 1
fi

# Check if lcov is available for coverage report
if command -v lcov &> /dev/null; then
    echo "📈 Generating HTML coverage report..."
    
    # Remove old coverage report
    rm -rf coverage/html
    
    # Generate HTML report
    if genhtml coverage/lcov.info -o coverage/html --quiet; then
        echo "✅ Coverage report generated at coverage/html/index.html"
        
        # Try to open coverage report (macOS)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v open &> /dev/null; then
                echo "🌐 Opening coverage report in browser..."
                open coverage/html/index.html
            fi
        fi
        
        # Display coverage summary
        echo ""
        echo "📊 Coverage Summary:"
        echo "==================="
        lcov --summary coverage/lcov.info
    else
        echo "⚠️  Failed to generate HTML coverage report"
    fi
else
    echo "⚠️  lcov not found. Install with:"
    echo "   macOS: brew install lcov"
    echo "   Ubuntu: sudo apt-get install lcov"
    echo "   Then re-run this script to generate HTML coverage report"
fi

echo ""
echo "🎉 Test suite completed successfully!"
echo ""
echo "📋 Summary:"
echo "- Unit tests: ✅ Passed"
echo "- Widget tests: ✅ Passed"
echo "- Coverage report: Available in coverage/ directory"
echo ""
echo "💡 To run individual test suites:"
echo "   flutter test test/services/points_service_test.dart"
echo "   flutter test test/blocs/challenge/challenge_bloc_test.dart"
echo "   flutter test test/models/"
echo "   flutter test test/widgets/"