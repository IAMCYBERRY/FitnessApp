#!/bin/bash

# Force Reset Script for RivalX App
# This ensures complete removal of the app from both platforms

echo "🔥 Force Reset - Removing RivalX from all devices..."
echo "================================================"

# Kill any running Flutter processes
echo "⏹️  Stopping Flutter processes..."
killall Flutter 2>/dev/null || true
killall dart 2>/dev/null || true
pkill -f flutter 2>/dev/null || true

# Uninstall from iOS simulators
echo "📱 Removing from iOS simulators..."
if command -v xcrun &> /dev/null; then
    # Get all booted simulators and uninstall
    xcrun simctl uninstall booted com.rivalx.rivalx 2>/dev/null || true
    
    # Also try to uninstall from all simulators
    xcrun simctl list devices | grep -E "iPhone|iPad" | grep -oE "[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}" | while read -r device_id; do
        echo "  Removing from device: $device_id"
        xcrun simctl uninstall "$device_id" com.rivalx.rivalx 2>/dev/null || true
    done
else
    echo "  ⚠️  Xcode command line tools not found"
fi

# Uninstall from Android devices
echo "🤖 Removing from Android devices..."
if command -v adb &> /dev/null; then
    # Check if any devices are connected
    if adb devices | grep -q "device$"; then
        adb uninstall com.rivalx.rivalx 2>/dev/null || echo "  App not installed on Android"
        # Also clear any remaining data
        adb shell pm clear com.rivalx.rivalx 2>/dev/null || true
    else
        echo "  ⚠️  No Android devices connected"
    fi
else
    echo "  ⚠️  ADB not found"
fi

# Clean Flutter project
echo "🧹 Cleaning Flutter project..."
flutter clean 2>/dev/null || echo "  ⚠️  Flutter clean failed"

# Remove build directories
echo "🗑️  Removing build artifacts..."
rm -rf build/
rm -rf .dart_tool/
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies

# iOS specific cleanup
rm -rf ios/Pods/
rm -rf ios/.symlinks/
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec

# Android specific cleanup  
rm -rf android/.gradle/
rm -rf android/app/build/
rm -rf android/build/

echo ""
echo "✅ Force reset complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Run: flutter pub get"
echo "2. For iOS: cd ios && pod install && cd .."
echo "3. Run the app: flutter run"
echo ""
echo "The app should now:"
echo "• Show login screen (not home)"
echo "• Reject login attempts with 'No account found'"
echo "• Have 0 users in database"
echo ""

# Ask if user wants to reinstall dependencies
read -p "Do you want to reinstall dependencies now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📦 Installing dependencies..."
    flutter pub get
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "📱 Installing iOS pods..."
        cd ios && pod install && cd ..
    fi
    
    echo "✅ Dependencies installed!"
    echo ""
    echo "Ready to run:"
    echo "• iOS: flutter run"
    echo "• Android: flutter run -d <device_id>"
fi