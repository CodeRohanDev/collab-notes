# 🔧 Fix Google Sign-In in Release Build

## Problem
Google Sign-In works in **debug mode** but fails in **release mode** with:
```
PlatformException: Failed to sign in with Google
```

---

## ✅ Solution Checklist

### 1. Get BOTH SHA Fingerprints (Debug + Release)

You need **TWO different SHA fingerprints**:
- **Debug SHA** (for testing)
- **Release SHA** (for production)

#### Get Release SHA-1 and SHA-256:

**Using your keystore:**
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

Enter your keystore password when prompted.

**Copy BOTH:**
- SHA1: `XX:XX:XX:XX:...`
- SHA256: `AA:BB:CC:DD:...`

---

### 2. Add Release SHA to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Project Settings** (gear icon)
4. Scroll down to **Your apps**
5. Click on your Android app
6. Scroll to **SHA certificate fingerprints**
7. Click **"Add fingerprint"**
8. Paste your **Release SHA-1**
9. Click **"Add fingerprint"** again
10. Paste your **Release SHA-256**
11. Click **Save**

**Important:** You should now have **4 fingerprints total**:
- Debug SHA-1
- Debug SHA-256
- Release SHA-1
- Release SHA-256

---

### 3. Download New google-services.json

After adding the SHA fingerprints:

1. In Firebase Console, go to **Project Settings**
2. Scroll to **Your apps**
3. Click on your Android app
4. Click **"Download google-services.json"**
5. Replace the old file:
   ```
   android/app/google-services.json
   ```

---

### 4. Verify OAuth 2.0 Client

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project
3. Go to **APIs & Services** → **Credentials**
4. You should see **TWO** OAuth 2.0 Client IDs:
   - **Android client (auto created by Google Service)**
   - **Web client (auto created by Firebase)**

**If you don't see them:**
- They should be auto-created when you add SHA fingerprints
- Wait a few minutes and refresh
- If still missing, create them manually

---

### 5. Check android/app/build.gradle.kts

Verify your package name matches Firebase:

```kotlin
defaultConfig {
    applicationId = "com.hostspica.collabnotes"  // Must match Firebase
    // ...
}
```

---

### 6. Clean and Rebuild

```bash
# Clean everything
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Or build App Bundle
flutter build appbundle --release
```

---

### 7. Verify SHA Fingerprints Match

**Get SHA from your APK:**
```bash
# Extract SHA from built APK
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

**Compare with Firebase:**
- The SHA-1 from APK should match one in Firebase
- If they don't match, you added the wrong SHA

---

## 🐛 Common Issues

### Issue 1: Wrong SHA Fingerprint

**Problem:** Added debug SHA instead of release SHA

**Solution:**
```bash
# Get RELEASE SHA (not debug)
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

### Issue 2: Old google-services.json

**Problem:** Using old google-services.json without new SHA

**Solution:**
- Download fresh google-services.json from Firebase
- Replace android/app/google-services.json
- Rebuild app

### Issue 3: Package Name Mismatch

**Problem:** Package name in build.gradle doesn't match Firebase

**Solution:**
- Check Firebase: `com.hostspica.collabnotes`
- Check build.gradle.kts: `applicationId = "com.hostspica.collabnotes"`
- They must match exactly

### Issue 4: OAuth Client Not Created

**Problem:** Google Cloud Console doesn't have OAuth clients

**Solution:**
- Wait 5-10 minutes after adding SHA
- Refresh Google Cloud Console
- OAuth clients should appear automatically

### Issue 5: Multiple google-services.json

**Problem:** Multiple google-services.json files in project

**Solution:**
- Only keep one: `android/app/google-services.json`
- Delete any others

---

## 📝 Step-by-Step Fix

### Step 1: Get Release SHA (2 min)

```bash
cd android
keytool -list -v -keystore app/upload-keystore.jks -alias upload
```

**Copy both SHA-1 and SHA-256**

### Step 2: Add to Firebase (2 min)

1. Firebase Console → Project Settings
2. Your Android app → SHA certificate fingerprints
3. Add fingerprint → Paste SHA-1 → Save
4. Add fingerprint → Paste SHA-256 → Save

### Step 3: Download google-services.json (1 min)

1. Firebase Console → Project Settings
2. Your Android app → Download google-services.json
3. Replace: `android/app/google-services.json`

### Step 4: Rebuild (3 min)

```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Step 5: Test (2 min)

1. Install APK on phone
2. Try Google Sign-In
3. Should work now! ✅

---

## 🔍 Verify Everything

### Check 1: Firebase Console

**Project Settings → Your apps → Android app**

Should show:
```
SHA certificate fingerprints:
- XX:XX:XX:XX:... (Debug SHA-1)
- AA:BB:CC:DD:... (Debug SHA-256)
- YY:YY:YY:YY:... (Release SHA-1)
- BB:CC:DD:EE:... (Release SHA-256)
```

### Check 2: Google Cloud Console

**APIs & Services → Credentials**

Should show:
```
OAuth 2.0 Client IDs:
- Android client (auto created by Google Service)
- Web client (auto created by Firebase)
```

### Check 3: Package Name

**Firebase:**
```
com.hostspica.collabnotes
```

**build.gradle.kts:**
```kotlin
applicationId = "com.hostspica.collabnotes"
```

Must match exactly!

---

## 🧪 Test Commands

### Get SHA from Keystore:
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

### Get SHA from APK:
```bash
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

### Get Debug SHA:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Verify Package Name:
```bash
# In build.gradle.kts
grep "applicationId" android/app/build.gradle.kts
```

---

## 💡 Pro Tips

### Tip 1: Keep Both SHAs

Always add **both debug and release** SHA fingerprints to Firebase:
- Debug: For testing during development
- Release: For production builds

### Tip 2: Fresh google-services.json

After adding new SHA fingerprints:
- Always download fresh google-services.json
- Don't reuse old files

### Tip 3: Wait for Propagation

After adding SHA to Firebase:
- Wait 5-10 minutes
- Google needs time to propagate changes
- Then rebuild and test

### Tip 4: Clean Build

Always clean before release build:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🎯 Quick Fix (Most Common)

**90% of the time, this is the issue:**

1. You added **debug SHA** to Firebase
2. But you're building **release APK**
3. Release APK uses **different SHA** (from your keystore)

**Solution:**
```bash
# Get RELEASE SHA
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload

# Add to Firebase
# Download new google-services.json
# Rebuild
flutter clean && flutter build apk --release
```

---

## 📞 Still Not Working?

### Check Logs:

```bash
# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Watch logs
adb logcat | grep -i "google\|auth\|signin"
```

Look for errors like:
- "SHA-1 mismatch"
- "OAuth client not found"
- "Package name mismatch"

### Verify OAuth Setup:

1. Google Cloud Console
2. APIs & Services → Credentials
3. Check OAuth 2.0 Client IDs exist
4. Check package name matches

### Re-create OAuth Client:

If OAuth clients are missing:
1. Delete existing ones (if any)
2. Remove SHA from Firebase
3. Re-add SHA to Firebase
4. Wait 10 minutes
5. Check Google Cloud Console
6. OAuth clients should appear

---

## ✅ Success Checklist

- [ ] Got Release SHA-1 from keystore
- [ ] Got Release SHA-256 from keystore
- [ ] Added Release SHA-1 to Firebase
- [ ] Added Release SHA-256 to Firebase
- [ ] Downloaded new google-services.json
- [ ] Replaced android/app/google-services.json
- [ ] Verified package name matches
- [ ] Ran flutter clean
- [ ] Ran flutter pub get
- [ ] Built release APK
- [ ] Installed on phone
- [ ] Tested Google Sign-In
- [ ] Works! ✅

---

## 📚 Related Files

- **Keystore:** `android/app/upload-keystore.jks`
- **Config:** `android/app/google-services.json`
- **Build:** `android/app/build.gradle.kts`
- **Guide:** `CREATE_KEYSTORE.md`
- **Setup:** `GOOGLE_SIGNIN_SETUP.md`

---

## 🎉 Summary

**The issue:** Release build uses different SHA than debug build

**The fix:** Add release SHA fingerprints to Firebase

**Time to fix:** 10 minutes

**Steps:**
1. Get release SHA from keystore
2. Add to Firebase
3. Download new google-services.json
4. Rebuild app
5. Test

**Result:** Google Sign-In works in release build! ✅

---

**Most common mistake:** Adding debug SHA instead of release SHA

**Quick fix:** Get SHA from your keystore (not debug.keystore)

**Command:**
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

🚀 **Good luck!**
