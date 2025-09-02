#!/bin/bash

# RivalX App Reset Script
# This script completely resets both iOS and Android apps for fresh testing

set -e  # Exit on any error

echo "🧹 Starting complete app reset for iOS and Android..."
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Not in Flutter project directory. Please run from project root."
    exit 1
fi

print_status "Step 1: Stopping any running Flutter processes..."
flutter --version > /dev/null 2>&1 && {
    pkill -f "flutter" || true
    pkill -f "dart" || true
} || {
    print_warning "Flutter not found in PATH. Continuing anyway..."
}

print_status "Step 2: Cleaning Flutter build cache..."
flutter clean || print_warning "Flutter clean failed, continuing..."

print_status "Step 3: Removing all build artifacts..."
rm -rf build/
rm -rf .dart_tool/
rm -rf ios/Pods/
rm -rf ios/.symlinks/
rm -rf android/.gradle/
rm -rf android/app/build/

print_success "Build artifacts removed"

print_status "Step 4: Resetting iOS Simulator data..."
# List available iOS simulators
IOS_SIMULATORS=$(xcrun simctl list devices available | grep "iPhone" | head -3 | sed 's/.*(\([^)]*\)).*/\1/')

if [ ! -z "$IOS_SIMULATORS" ]; then
    echo "$IOS_SIMULATORS" | while read -r UDID; do
        if [ ! -z "$UDID" ]; then
            print_status "Resetting iOS Simulator: $UDID"
            xcrun simctl shutdown "$UDID" 2>/dev/null || true
            xcrun simctl erase "$UDID" 2>/dev/null || print_warning "Could not erase simulator $UDID"
        fi
    done
    print_success "iOS Simulators reset"
else
    print_warning "No iOS simulators found"
fi

print_status "Step 5: Resetting Android Emulator data..."
# Get Android emulator names
ANDROID_EMULATORS=$(emulator -list-avds 2>/dev/null | head -3)

if [ ! -z "$ANDROID_EMULATORS" ]; then
    echo "$ANDROID_EMULATORS" | while read -r AVD_NAME; do
        if [ ! -z "$AVD_NAME" ]; then
            print_status "Wiping Android Emulator: $AVD_NAME"
            emulator -avd "$AVD_NAME" -wipe-data -no-window -no-audio &
            EMU_PID=$!
            sleep 5
            kill $EMU_PID 2>/dev/null || true
        fi
    done
    print_success "Android Emulators reset"
else
    print_warning "No Android emulators found"
fi

print_status "Step 6: Installing fresh dependencies..."
flutter pub get || {
    print_error "Failed to get dependencies"
    exit 1
}

print_status "Step 7: Updating iOS pods..."
cd ios
pod deintegrate || true
pod install || print_warning "Pod install failed"
cd ..

print_status "Step 8: Cleaning Android Gradle cache..."
cd android
./gradlew clean || true
cd ..

print_success "✅ Complete app reset finished!"
echo ""
echo "=================================================="
echo "🚀 Ready for fresh testing!"
echo ""
echo "Next steps:"
echo "1. Start your iOS simulator: open -a Simulator"
echo "2. Start your Android emulator: emulator -avd <your_avd_name>"
echo "3. Run on iOS: flutter run"
echo "4. Run on Android: flutter run -d <android_device_id>"
echo ""
echo "💡 In the app, tap the debug button (🐛) on the home screen"
echo "   to access reset tools and create test users."
echo "=================================================="