# CollabNotes Setup Guide

## Firebase Configuration

### 1. Deploy Firestore Security Rules

```bash
firebase deploy --only firestore:rules
```

Or manually copy the contents of `firestore.rules` to your Firebase Console:
- Go to Firebase Console → Firestore Database → Rules
- Paste the rules and publish

### 2. Deploy Storage Security Rules

```bash
firebase deploy --only storage
```

Or manually copy the contents of `storage.rules` to your Firebase Console:
- Go to Firebase Console → Storage → Rules
- Paste the rules and publish

### 3. Enable Authentication

1. Go to Firebase Console → Authentication
2. Click "Get Started"
3. Enable "Google" sign-in provider
4. Add your app's SHA-1 fingerprint (for Android)

#### Get SHA-1 for Android:
```bash
cd android
./gradlew signingReport
```

### 4. Create Firestore Database

1. Go to Firebase Console → Firestore Database
2. Click "Create Database"
3. Choose "Start in production mode"
4. Select your preferred location

### 5. Create Storage Bucket

1. Go to Firebase Console → Storage
2. Click "Get Started"
3. Use the default security rules (we'll update them)

## Android Setup

### 1. Update google-services.json

The file should already be in `android/app/google-services.json`

### 2. Add SHA-1 Fingerprint

For debug builds:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Add the SHA-1 to Firebase Console → Project Settings → Your Android App

### 3. Update AndroidManifest.xml

Add internet permission (should already be there):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

## iOS Setup

### 1. Update GoogleService-Info.plist

The file should already be in `ios/Runner/GoogleService-Info.plist`

### 2. Update Info.plist

Add URL schemes for Google Sign-In:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

Replace `YOUR-CLIENT-ID` with the reversed client ID from GoogleService-Info.plist

## Running the App

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Code
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run on Device/Emulator
```bash
flutter run
```

## Testing Offline Functionality

1. Launch the app and sign in
2. Create a few notes
3. Turn off WiFi/Mobile data
4. Create/edit notes (they'll be marked as "pending sync")
5. Turn on connectivity
6. Notes will automatically sync to Firestore

## Troubleshooting

### Google Sign-In Not Working

**Android:**
- Verify SHA-1 is added to Firebase Console
- Check google-services.json is up to date
- Ensure Google Sign-In is enabled in Firebase Console

**iOS:**
- Verify GoogleService-Info.plist is correct
- Check URL schemes in Info.plist
- Ensure bundle ID matches Firebase configuration

### Firestore Permission Denied

- Check security rules are deployed
- Verify user is authenticated
- Check user ID matches document owner

### Build Errors

If you get Hive adapter errors:
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Next Development Steps

1. **Add Real-time Sync Listeners**
   - Listen to Firestore changes
   - Update local storage automatically

2. **Implement Conflict Resolution**
   - Handle simultaneous edits
   - Merge changes intelligently

3. **Add Collaboration Features**
   - Share notes with other users
   - Real-time editing indicators
   - Comment threads

4. **Rich Text Editor**
   - Integrate flutter_quill
   - Add formatting toolbar
   - Support images and media

5. **Workspaces**
   - Create workspace UI
   - Manage members
   - Workspace-level permissions

## Useful Commands

```bash
# Check for outdated packages
flutter pub outdated

# Update packages
flutter pub upgrade

# Clean build
flutter clean

# Run with specific device
flutter run -d <device-id>

# Build APK
flutter build apk

# Build iOS
flutter build ios
```
