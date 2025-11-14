# Google Sign-In Setup Guide

## Issue: Unable to Sign In with Google

This happens because the SHA-1 fingerprint is not configured in Firebase Console.

## Solution: Add SHA-1 Fingerprint

### Step 1: Get Your SHA-1 Fingerprint

#### For Debug Build (Development)

**Windows:**
```bash
cd android
gradlew signingReport
```

**Mac/Linux:**
```bash
cd android
./gradlew signingReport
```

Look for output like this:
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
SHA-256: ...
```

Copy the **SHA1** value.

#### Alternative Method (Easier)

**Windows:**
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Mac/Linux:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Step 2: Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **collab-note-8450f**
3. Click the gear icon ⚙️ → **Project Settings**
4. Scroll down to **Your apps** section
5. Find your Android app
6. Click **Add fingerprint**
7. Paste your SHA-1 fingerprint
8. Click **Save**

### Step 3: Download Updated google-services.json

1. In Firebase Console, after adding SHA-1
2. Click **Download google-services.json**
3. Replace the file in: `android/app/google-services.json`

### Step 4: Rebuild the App

```bash
flutter clean
flutter pub get
flutter run
```

## Additional Configuration

### Enable Google Sign-In in Firebase

1. Go to Firebase Console
2. Click **Authentication** in left menu
3. Click **Sign-in method** tab
4. Find **Google** provider
5. Click **Enable**
6. Add support email
7. Click **Save**

### Verify AndroidManifest.xml

Check `android/app/src/main/AndroidManifest.xml` has internet permission:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <application
        android:label="collabnotes"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

## For Release Build (Production)

When you're ready to release:

### Step 1: Generate Release Keystore

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Step 2: Get Release SHA-1

```bash
keytool -list -v -keystore ~/upload-keystore.jks -alias upload
```

### Step 3: Add Release SHA-1 to Firebase

Follow the same steps as debug, but add the release SHA-1.

## Troubleshooting

### Issue: Still Can't Sign In

**Solution 1: Clear App Data**
```bash
flutter clean
flutter pub get
flutter run
```

**Solution 2: Uninstall and Reinstall**
1. Uninstall app from device
2. Run `flutter run` again

**Solution 3: Check Package Name**
Verify package name matches in:
- `android/app/build.gradle` → `applicationId`
- Firebase Console → Android app package name
- Should be: `com.hostspica.collabnotes`

### Issue: "Developer Error" or "Error 10"

This means SHA-1 is not configured correctly.

**Fix:**
1. Double-check SHA-1 is added to Firebase
2. Download new google-services.json
3. Clean and rebuild

### Issue: "Sign in failed" with no error

**Fix:**
1. Enable Google Sign-In in Firebase Console
2. Add support email
3. Make sure OAuth consent screen is configured

## Quick Fix Commands

Run these in order:

```bash
# 1. Get SHA-1
cd android
gradlew signingReport

# 2. Add SHA-1 to Firebase Console (manual step)

# 3. Download new google-services.json (manual step)

# 4. Clean and rebuild
cd ..
flutter clean
flutter pub get
flutter run
```

## Verify Setup

After setup, test:

1. Launch app
2. Tap "Continue with Google"
3. Select Google account
4. Should redirect back to app
5. Should see home screen

## Common Errors

### Error: "PlatformException(sign_in_failed)"
- **Cause**: SHA-1 not configured
- **Fix**: Add SHA-1 to Firebase

### Error: "DEVELOPER_ERROR"
- **Cause**: Package name mismatch or SHA-1 issue
- **Fix**: Verify package name and SHA-1

### Error: "Network error"
- **Cause**: No internet or Firebase not configured
- **Fix**: Check internet and Firebase setup

### Error: "User cancelled"
- **Cause**: User closed sign-in dialog
- **Fix**: This is normal, try again

## Success Indicators

✅ Google Sign-In dialog appears
✅ Can select Google account
✅ Redirects back to app
✅ Shows home screen
✅ User name appears in app bar

## Need Help?

If still having issues:

1. Check Firebase Console → Authentication → Users
   - Should see user after successful sign-in

2. Check logs:
   ```bash
   flutter run --verbose
   ```

3. Verify google-services.json is in correct location:
   - `android/app/google-services.json`

4. Make sure Firebase is initialized in main.dart:
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

## Summary

**Required Steps:**
1. ✅ Get SHA-1 fingerprint
2. ✅ Add to Firebase Console
3. ✅ Download new google-services.json
4. ✅ Enable Google Sign-In in Firebase
5. ✅ Clean and rebuild app

**That's it!** Google Sign-In should work now. 🎉
