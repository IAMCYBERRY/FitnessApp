# RivalX App Reset & Testing Guide

## 🔄 Complete App Reset Instructions

### Option 1: Automated Reset (Recommended)

Run the automated reset script:

```bash
cd /Users/ryanwright/Desktop/RivalX/rivalx
./reset_apps.sh
```

### Option 2: Manual Reset Steps

If the automated script doesn't work, follow these manual steps:

#### 1. Clean Flutter Project
```bash
cd /Users/ryanwright/Desktop/RivalX/rivalx
flutter clean
rm -rf build/ .dart_tool/
flutter pub get
```

#### 2. Reset iOS Simulator
```bash
# List available simulators
xcrun simctl list devices available | grep iPhone

# Reset specific simulator (replace UDID with actual ID)
xcrun simctl shutdown <SIMULATOR_UDID>
xcrun simctl erase <SIMULATOR_UDID>

# Or reset all iOS simulators
xcrun simctl erase all
```

#### 3. Reset Android Emulator
```bash
# List available emulators
emulator -list-avds

# Wipe specific emulator (replace AVD_NAME)
emulator -avd <AVD_NAME> -wipe-data -no-window &
# Wait a few seconds, then kill the process
```

#### 4. Clean iOS Dependencies
```bash
cd ios
pod deintegrate
pod install
cd ..
```

#### 5. Clean Android Dependencies  
```bash
cd android
./gradlew clean
cd ..
```

## 🚀 Testing Workflow

### Phase 1: iOS Testing

1. **Start iOS Simulator**
   ```bash
   open -a Simulator
   ```

2. **Run on iOS**
   ```bash
   flutter run
   ```

3. **Test Core Features**
   - Sign up with new account
   - Complete authentication flow
   - Test points system with workouts
   - Verify data persistence (close/reopen app)

### Phase 2: Android Testing

1. **Start Android Emulator**
   ```bash
   # Replace with your AVD name
   emulator -avd Pixel_7_API_34 &
   ```

2. **Run on Android**
   ```bash
   flutter run -d <android_device_id>
   ```

3. **Test Same Features**
   - Sign up with different account
   - Test all core functionality
   - Verify independent storage from iOS

### Phase 3: Parallel Testing

1. **Run Both Devices Simultaneously**
   ```bash
   # Terminal 1 - iOS
   flutter run -d <ios_simulator_id>
   
   # Terminal 2 - Android  
   flutter run -d <android_device_id>
   ```

2. **Create Different Users**
   - iOS: testuser1@rivalx.com
   - Android: testuser2@rivalx.com

3. **Test Independent Functionality**
   - Each device works independently
   - Data doesn't sync between devices (expected)

## 🛠 In-App Debug Tools

Once the app is running, access debug tools:

1. **Tap the debug button (🐛)** on the home screen
2. **Use available reset options:**
   - **Reset Everything**: Complete local data wipe
   - **Logout Current User**: Clear authentication only
   - **Reset Progress Only**: Clear points but keep users

3. **Create Test Users** (for single-device testing):
   - testuser1 / password123 (Rank D, 1500 pts)
   - testuser2 / password123 (Rank C, 3200 pts)
   - testuser3 / password123 (Rank B, 8500 pts)

## 📱 Device-Specific Testing

### iOS Simulator Testing
- Test biometric authentication (Face ID/Touch ID simulation)
- Test app backgrounding/foregrounding
- Test different iOS versions if available
- Test different device sizes (iPhone 14, iPhone SE, etc.)

### Android Emulator Testing
- Test different Android versions
- Test different screen densities
- Test hardware back button behavior
- Test app lifecycle management

## ✅ Core Features to Test

### Authentication System
- [ ] Sign up with new account
- [ ] Login with existing account
- [ ] Password validation
- [ ] Email/username validation
- [ ] Session persistence
- [ ] Logout functionality

### Points System
- [ ] Complete a workout and earn points
- [ ] Verify points are saved
- [ ] Check rank progression
- [ ] Test streak bonuses
- [ ] Verify weekly points reset

### Data Persistence
- [ ] Close and reopen app
- [ ] User remains logged in
- [ ] Points/progress preserved
- [ ] Workout history maintained

### UI/Navigation
- [ ] All screens accessible
- [ ] Navigation flows work
- [ ] Color scheme consistent
- [ ] Text visibility in all fields
- [ ] Responsive design on different screen sizes

## 🐛 Common Issues & Solutions

### Build Issues
```bash
# If pods fail on iOS
cd ios && pod deintegrate && pod install && cd ..

# If Android build fails
cd android && ./gradlew clean && cd ..
flutter clean && flutter pub get
```

### Simulator Issues
```bash
# iOS simulator stuck
sudo killall -9 com.apple.CoreSimulator.CoreSimulatorService
xcrun simctl erase all

# Android emulator issues
emulator -list-avds
emulator -avd <AVD_NAME> -wipe-data
```

### App State Issues
- Use in-app debug tools to reset specific data
- Check console output for error messages
- Verify local storage is working correctly

## 📊 Expected Test Results

### Single Device Functionality ✅
- Full authentication flow
- Points system working
- Data persistence
- All UI screens functional
- Workout tracking and points

### Multi-Device Limitations ❌
- Users are device-specific
- No real-time sync between devices
- Cannot challenge users on other devices
- Chat system limited to same device

## 🔜 Next Steps for Full Multi-Device Support

To enable cross-device communication:

1. **Implement Firebase Firestore**
   - Real-time database
   - User synchronization
   - Cross-device challenges

2. **Add Network Layer**
   - API for user discovery
   - Real-time notifications
   - Challenge system integration

3. **Testing Network Features**
   - Create cloud-based test environment
   - Test real-time synchronization
   - Verify cross-device functionality

---

## 🚨 Emergency Reset Commands

If everything breaks:

```bash
# Nuclear option - reset everything
cd /Users/ryanwright/Desktop/RivalX/rivalx
rm -rf build/ .dart_tool/ ios/Pods/ android/.gradle/
xcrun simctl erase all
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

This guide ensures you have multiple ways to reset and test the app thoroughly on both platforms!