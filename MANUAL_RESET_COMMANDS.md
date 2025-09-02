# Manual App Reset Commands

## Complete Reset for Both iOS and Android

### Step 1: Stop All Running Apps
First, stop any running Flutter instances:
```bash
# Kill all Flutter processes
killall Flutter
killall dart
```

### Step 2: Delete App from Devices

#### iOS Simulator:
1. In the iOS Simulator, long press the RivalX app icon
2. Click the X to delete the app
3. OR use terminal:
```bash
# List all iOS simulators
xcrun simctl list devices

# Delete app from specific simulator (replace DEVICE_ID)
xcrun simctl uninstall DEVICE_ID com.rivalx.rivalx

# Or delete app from all booted simulators
xcrun simctl uninstall booted com.rivalx.rivalx

# Reset entire simulator (nuclear option)
xcrun simctl erase all
```

#### Android Emulator:
1. In Android emulator, go to Settings → Apps → RivalX → Uninstall
2. OR use terminal:
```bash
# List running emulators
adb devices

# Uninstall app
adb uninstall com.rivalx.rivalx

# Clear app data without uninstalling
adb shell pm clear com.rivalx.rivalx
```

### Step 3: Clean Flutter Project
```bash
cd /Users/ryanwright/Desktop/RivalX/rivalx
flutter clean
rm -rf build/
rm -rf .dart_tool/
```

### Step 4: Rebuild and Run

#### For iOS:
```bash
flutter run
```

#### For Android:
```bash
flutter run -d <android_device_id>
```

## Quick Terminal Commands for Complete Reset

### iOS Complete Reset:
```bash
# Navigate to project
cd /Users/ryanwright/Desktop/RivalX/rivalx

# Stop everything
killall Flutter dart

# Uninstall from all simulators
xcrun simctl uninstall booted com.rivalx.rivalx

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Android Complete Reset:
```bash
# Navigate to project
cd /Users/ryanwright/Desktop/RivalX/rivalx

# Stop everything
killall Flutter dart

# Uninstall from emulator
adb uninstall com.rivalx.rivalx

# Clean and rebuild
flutter clean
flutter pub get
flutter run -d <android_device_id>
```

## Verify Reset Worked

After reinstalling, you should see:
1. **Login screen** appears (not home screen)
2. **Login attempts fail** with "No account found"
3. **Debug menu** shows 0 users in database
4. **No saved preferences** or session data

## If Reset Still Doesn't Work

Try the nuclear option:

### iOS Nuclear Reset:
```bash
# Reset ALL simulators completely
xcrun simctl erase all

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/

# Clean everything
cd /Users/ryanwright/Desktop/RivalX/rivalx
flutter clean
rm -rf ios/Pods ios/.symlinks
cd ios && pod deintegrate && pod install && cd ..
flutter run
```

### Android Nuclear Reset:
```bash
# Wipe emulator data
emulator -list-avds
emulator -avd <AVD_NAME> -wipe-data

# Or from AVD Manager in Android Studio:
# - Click "Wipe Data" button next to your emulator

# Clean and rebuild
cd /Users/ryanwright/Desktop/RivalX/rivalx
flutter clean
rm -rf android/.gradle android/app/build
flutter run -d <android_device_id>
```