#!/bin/bash

# Script to run RivalX on both iOS and Android simultaneously

echo "🚀 Starting RivalX on iOS and Android..."
echo "========================================"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Not in Flutter project directory"
    echo "Please run from: /Users/ryanwright/Desktop/RivalX/rivalx"
    exit 1
fi

# Get Flutter dependencies first
echo -e "${BLUE}📦 Getting Flutter dependencies...${NC}"
flutter pub get

# Check for iOS pods
if [ -d "ios" ]; then
    echo -e "${BLUE}📱 Checking iOS pods...${NC}"
    cd ios
    pod install --repo-update
    cd ..
fi

# List available devices
echo -e "\n${YELLOW}📱 Available devices:${NC}"
flutter devices

# Get device IDs
echo -e "\n${BLUE}🔍 Detecting devices...${NC}"
IOS_DEVICE=$(flutter devices | grep "ios" | head -1 | awk '{print $NF}' | tr -d '()')
ANDROID_DEVICE=$(flutter devices | grep "android" | head -1 | awk '{print $NF}' | tr -d '()')

if [ -z "$IOS_DEVICE" ]; then
    echo "⚠️  No iOS simulator found. Starting one..."
    open -a Simulator
    sleep 5
    IOS_DEVICE=$(flutter devices | grep "ios" | head -1 | awk '{print $NF}' | tr -d '()')
fi

echo -e "\n${GREEN}Found devices:${NC}"
echo "iOS Device: ${IOS_DEVICE:-Not found}"
echo "Android Device: ${ANDROID_DEVICE:-Not found}"

# Function to run Flutter in background
run_flutter() {
    local device=$1
    local platform=$2
    echo -e "\n${BLUE}Starting $platform app on device: $device${NC}"
    flutter run -d "$device" &
}

# Run on iOS
if [ ! -z "$IOS_DEVICE" ]; then
    run_flutter "$IOS_DEVICE" "iOS"
    echo -e "${GREEN}✅ iOS app starting...${NC}"
else
    echo -e "${YELLOW}⚠️  No iOS device available${NC}"
fi

# Wait a bit before starting Android
sleep 3

# Run on Android
if [ ! -z "$ANDROID_DEVICE" ]; then
    run_flutter "$ANDROID_DEVICE" "Android"
    echo -e "${GREEN}✅ Android app starting...${NC}"
else
    echo -e "${YELLOW}⚠️  No Android device available${NC}"
fi

echo -e "\n${GREEN}========================================"
echo "🎯 Apps are launching!"
echo "========================================${NC}"
echo ""
echo "📝 Testing Instructions:"
echo "1. Both apps should show the login screen"
echo "2. Try to login - should see 'No account found'"
echo "3. Sign up with different accounts on each device"
echo "4. Test that each device works independently"
echo ""
echo "🐛 Debug Tools:"
echo "• Tap the bug icon (🐛) on home screen for debug menu"
echo "• Use 'Reset Everything' to clear all data"
echo "• Check 'App State' to see user count"
echo ""
echo "Press Ctrl+C to stop both apps"

# Wait for user to stop
wait