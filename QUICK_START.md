# ⚡ Quick Start - Run App on Your Device NOW

## 🎯 3-Minute Quick Start

### Step 1: Connect Your Device (30 seconds)
1. Plug Android phone into PC with USB cable
2. On phone: Settings → About Phone → Tap "Build Number" 7 times
3. Go to Settings → Developer Options → Enable "USB Debugging"
4. Tap "OK" to allow USB debugging

### Step 2: Open Terminal (30 seconds)
```powershell
cd c:\Users\MANULA NIMSARA\Desktop\flutterProject
```

### Step 3: Verify Device (30 seconds)
```powershell
flutter devices
```
You should see your phone listed.

### Step 4: First Time Setup (1 minute)
```powershell
flutter clean
flutter pub get
```

### Step 5: Run App (1 minute)
```powershell
flutter run
```

**That's it! 🎉 Your app is running!**

---

## 🎮 What to Try

1. **Home screen** - See list of events
2. **Tap an event** - View event details
3. **Login** - Create new account or login
4. **Book ticket** - Try booking a ticket
5. **Profile** - View your profile

---

## 🛑 If It Doesn't Work

### Device Not Detected?
```powershell
adb kill-server
adb start-server
flutter devices
```

### Build Fails?
```powershell
flutter clean
flutter pub get
flutter run -v
```

### See Full Logs?
```powershell
flutter run -v
```

---

## 🐛 Debug in VS Code

1. Press **F5**
2. Choose **Flutter: Debug**
3. Select your device
4. Set breakpoints by clicking line numbers
5. Step through code

---

## 📖 Full Documentation

- **Device Setup**: See [DEVICE_DEPLOYMENT_GUIDE.md](./DEVICE_DEPLOYMENT_GUIDE.md)
- **Project Status**: See [PROJECT_STATUS.md](./PROJECT_STATUS.md)
- **Original README**: See [README.md](./README.md)

---

**Ready? Run this now:**
```powershell
flutter run
```
