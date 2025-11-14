# Quick Start Checklist

## ✅ Pre-flight Checklist

Before running the app, make sure you've completed these steps:

### 1. Dependencies Installed
```bash
flutter pub get
```

### 2. Code Generated
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Firebase Setup
- [ ] Firebase project created
- [ ] google-services.json in android/app/ (Android)
- [ ] GoogleService-Info.plist in ios/Runner/ (iOS)
- [ ] Google Sign-In enabled in Firebase Console
- [ ] Firestore database created
- [ ] Storage bucket created

### 4. Security Rules Deployed
- [ ] Firestore rules deployed (see firestore.rules)
- [ ] Storage rules deployed (see storage.rules)

### 5. Android Configuration (if testing on Android)
- [ ] SHA-1 fingerprint added to Firebase Console
- [ ] Internet permissions in AndroidManifest.xml

### 6. iOS Configuration (if testing on iOS)
- [ ] URL schemes added to Info.plist
- [ ] Reversed client ID configured

## 🚀 Run the App

```bash
flutter run
```

## 📱 Test the App

### Basic Flow
1. **Launch App** → Should show login screen
2. **Tap "Continue with Google"** → Google sign-in dialog appears
3. **Sign in** → Redirects to home screen
4. **Tap + button** → Opens note editor
5. **Type title and content** → Auto-saves locally
6. **Tap ✓ button** → Returns to home screen
7. **See your note** → Note appears in list

### Offline Test
1. **Create a note while online** → Note syncs (no sync icon)
2. **Turn off WiFi/data**
3. **Create another note** → Note saved locally (sync icon appears)
4. **Turn on WiFi/data**
5. **Wait a moment** → Sync icon disappears (note synced)

### Edit Test
1. **Tap on a note** → Opens editor
2. **Modify content**
3. **Tap ✓** → Changes saved
4. **Return to home** → Updated note appears

### Delete Test
1. **Tap trash icon on a note** → Note deleted
2. **Note removed from list**

## 🐛 Troubleshooting

### App won't build
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Google Sign-In fails
- Check SHA-1 is added (Android)
- Verify google-services.json is correct
- Ensure Google Sign-In is enabled in Firebase Console

### Notes won't sync
- Check internet connection
- Verify Firestore rules are deployed
- Check Firebase Console for errors

### "Permission denied" errors
- Deploy security rules from firestore.rules
- Ensure user is authenticated
- Check user owns the note

## 📊 What's Working

✅ **Implemented Features**:
- Google authentication
- Create notes (offline-first)
- Edit notes
- Delete notes
- Auto-sync when online
- Sync status indicators
- Local storage with Hive
- Cloud storage with Firestore

## 🚧 What's Next

**To be implemented** (from docs.md):
- Real-time collaboration
- Rich text editing (flutter_quill)
- Image/media attachments
- Workspaces
- Sharing notes
- Comment threads
- Live cursors
- AI features (future)

## 📝 Development Commands

```bash
# Run app
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Hot reload (while app is running)
r

# Hot restart (while app is running)
R

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Clean build
flutter clean

# Update dependencies
flutter pub upgrade

# Check for issues
flutter doctor

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Watch for changes (auto-generate)
dart run build_runner watch
```

## 🎯 Success Criteria

Your app is working correctly if:
- ✅ You can sign in with Google
- ✅ You can create notes
- ✅ Notes appear in the list
- ✅ You can edit notes
- ✅ You can delete notes
- ✅ Notes sync when online
- ✅ Notes save locally when offline
- ✅ Sync indicators show pending status

## 📚 Documentation

- **README.md** - Project overview
- **SETUP_GUIDE.md** - Detailed setup instructions
- **ARCHITECTURE.md** - Technical architecture
- **docs.md** - Full feature specification

## 🆘 Need Help?

1. Check the error message in the console
2. Review SETUP_GUIDE.md for configuration
3. Verify Firebase Console settings
4. Check security rules are deployed
5. Ensure all dependencies are installed

## 🎉 You're Ready!

If all checklist items are complete, you're ready to start developing!

Next steps:
1. Run the app and test basic functionality
2. Review the codebase structure
3. Start implementing additional features from docs.md
4. Customize the UI to your liking

Happy coding! 🚀
