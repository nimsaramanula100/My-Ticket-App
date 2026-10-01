# MyTickets App - Device Deployment Guide

## ✅ Pre-Deployment Checklist

### Project Status
- ✅ No compilation errors
- ✅ All dependencies installed
- ✅ Firebase configured (mytickets-483fb)
- ✅ Android manifest configured
- ✅ Debug launch configurations added
- ✅ App structure complete

### System Requirements
- ✅ Flutter SDK 3.0.0+ (You have 3.41.6)
- ✅ Android SDK installed and configured
- ✅ Java 17+ (Kotlin JVM target = 17)
- ✅ Android device or emulator with Android 6.0+ (minSdk = 23)

---

## 📱 Option 1: Run on Android Device (Recommended)

### Step 1: Prepare Your Device
1. Connect your Android device to your PC via USB
2. Enable **Developer Mode**:
   - Go to **Settings** → **About Phone**
   - Tap **Build Number** 7 times
   - Go to **Settings** → **Developer Options**
   - Enable **USB Debugging**
3. Tap "OK" to allow USB debugging when the prompt appears

### Step 2: Verify Device Connection
Open PowerShell and run:
```powershell
flutter devices
```
You should see your device listed. Example:
```
MANULA NIMSARA's Device (android) • 01a2b3c4d5 • android-arm64 • Android 13
```

### Step 3: Clean Build (First Time Only)
```powershell
cd c:\Users\MANULA NIMSARA\Desktop\flutterProject
flutter clean
flutter pub get
```

### Step 4: Run on Device
```powershell
flutter run
```

### Step 5: Debug in VS Code (Optional)
1. In VS Code, open **Command Palette** (Ctrl+Shift+P)
2. Select **Flutter: Select Device**
3. Choose your connected device
4. Press **F5** or go to **Run** → **Start Debugging**
5. Choose **Flutter: Debug**

---

## 🔧 Option 2: Run on Android Emulator

### Step 1: Check Available Emulators
```powershell
flutter emulators
```

### Step 2: Launch Emulator (if not already running)
```powershell
flutter emulators --launch <emulator_name>
```
Example:
```powershell
flutter emulators --launch Pixel_5_API_30
```

### Step 3: Run App
```powershell
flutter run
```

---

## 🐛 Debug Configurations Available

In VS Code, press **F5** and select from these configurations:

1. **Flutter: Debug** (Default)
   - Standard debug build with hot reload
   - Slower but most informative
   - Use this for development

2. **Flutter: Release**
   - Optimized release build
   - Fastest performance
   - Use for final testing

3. **Flutter: Profile**
   - Profiling mode for performance analysis
   - Good balance between debug and release
   - Use to check performance

---

## 🔥 Firebase Configuration

### Current Firebase Project
- **Project ID**: mytickets-483fb
- **Android Package**: com.example.mytickets_app
- **Configuration File**: android/app/google-services.json

### Verify Firebase Setup
1. The app will automatically use configured Firebase credentials
2. Debug device will use Firebase App Check with debug provider
3. All Firebase services are enabled in your Firebase project

### First-Time Setup Only
If you see a Firebase error:
1. Go to https://console.firebase.google.com
2. Ensure your project has:
   - ✅ Authentication (Email/Password enabled)
   - ✅ Firestore Database (created)
   - ✅ Firebase Storage (created)
   - ✅ App Check (Android app added)

---

## ⚡ Common Issues & Solutions

### Issue 1: Device Not Detected
```powershell
adb devices
adb kill-server
adb start-server
flutter devices
```

### Issue 2: "No devices" Error
- Ensure USB cable is connected
- Check **USB Debugging** is enabled on device
- Try different USB port
- Reinstall USB drivers if needed

### Issue 3: Build Fails
```powershell
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

### Issue 4: Firebase Error
- Verify google-services.json exists at: `android/app/google-services.json`
- Check Firebase credentials in: `lib/firebase_options.dart`
- Ensure Android package matches Firebase console

### Issue 5: App Crashes on Launch
- Check logcat: `adb logcat | grep -i flutter`
- Check console output in VS Code debugger
- Enable verbose logging: `flutter run -v`

---

## 📊 Firebase Firestore Collections Setup

Before running the app, create these collections in Firebase Console:

```
/events
  - id (auto)
  - eventName: "Concert XYZ"
  - eventDate: timestamp
  - price: 50.00
  - ...

/users
  - uid (user ID)
  - name: "John Doe"
  - email: "john@example.com"
  - ...

/bookings
  - id (auto)
  - userId: "uid..."
  - eventId: "event..."
  - quantity: 2
  - ...

/organizers
  - id (auto)
  - userId: "uid..."
  - organizerName: "Event Co"
  - ...
```

---

## ✨ App Features to Test

After deployment, verify these features work:

1. **Home Screen** - See list of available events
2. **Event Details** - Tap event to see full details
3. **Authentication** - Login/Register new account
4. **Booking** - Book tickets for an event
5. **User Profile** - View and edit profile
6. **Admin Panel** - Access admin features (if admin)

---

## 📋 Release Build (For Production)

When ready to release:

```powershell
flutter build apk --release
```

Output APK will be at:
```
build\app\outputs\flutter-apk\app-release.apk
```

For production AAB (Android Bundle):
```powershell
flutter build appbundle --release
```

---

## 🎯 Next Steps

1. **Immediate**: Connect device and run `flutter run`
2. **Testing**: Test all features mentioned above
3. **Firebase**: Add sample event data to Firestore
4. **Customization**: Update app theme, icons, and branding as needed
5. **Deployment**: When ready, build release APK or AAB

---

## 📞 Troubleshooting Command Reference

```powershell
# View all devices
flutter devices

# Run with verbose output (best for debugging)
flutter run -v

# Run on specific device
flutter run -d <device_id>

# View real-time logs
adb logcat | grep -i flutter

# Stop running app
Press 'q' in terminal or Ctrl+C

# Full system info
flutter doctor

# Clean all build artifacts
flutter clean

# Get updated dependencies
flutter pub get

# Analyze code for issues
flutter analyze

# Format code
dart format lib/
```

---

## ✅ Final Deployment Checklist

- [ ] Device connected and USB debugging enabled
- [ ] `flutter devices` shows your device
- [ ] `flutter clean` and `flutter pub get` completed
- [ ] Firebase credentials verified
- [ ] App runs without errors with `flutter run`
- [ ] Can navigate between screens
- [ ] Can login/register user
- [ ] Network requests working (Firestore data loading)
- [ ] No crash on startup
- [ ] Ready for testing and distribution

---

**Good luck! Your app is ready to deploy! 🚀**
