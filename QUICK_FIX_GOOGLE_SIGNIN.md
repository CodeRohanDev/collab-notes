# Quick Fix: Google Sign-In Not Working

## The Problem
You're unable to sign in with Google. This is almost always due to missing SHA-1 fingerprint.

## The Solution (5 Minutes)

### Step 1: Get SHA-1 (1 minute)

**Option A - Use the script:**
```bash
get_sha1.bat
```

**Option B - Manual command:**
```bash
cd android
gradlew signingReport
```

Look for this line:
```
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

Copy the SHA1 value (the part after "SHA1: ")

### Step 2: Add to Firebase (2 minutes)

1. Open: https://console.firebase.google.com/
2. Select project: **collab-note-8450f**
3. Click ⚙️ (Settings) → **Project Settings**
4. Scroll to "Your apps" section
5. Find your Android app (com.hostspica.collabnotes)
6. Click **"Add fingerprint"** button
7. Paste your SHA1
8. Click **Save**

### Step 3: Enable Google Sign-In (1 minute)

1. In Firebase Console, click **Authentication** (left menu)
2. Click **Sign-in method** tab
3. Find **Google** in the list
4. Click on it
5. Toggle **Enable**
6. Add your email as support email
7. Click **Save**

### Step 4: Rebuild App (1 minute)

```bash
flutter clean
flutter pub get
flutter run
```

## That's It!

Now try signing in with Google again. It should work! ✅

## Still Not Working?

### Check 1: Verify SHA-1 was added
- Go back to Firebase Console → Project Settings
- Under your Android app, you should see your SHA-1 listed

### Check 2: Verify Google Sign-In is enabled
- Firebase Console → Authentication → Sign-in method
- Google should show as "Enabled"

### Check 3: Try these commands
```bash
# Uninstall app from device first
flutter clean
flutter pub get
flutter run
```

### Check 4: Look at the error
When you tap "Continue with Google", what happens?

**If nothing happens:**
- SHA-1 not added correctly
- Run get_sha1.bat again and verify

**If you see "Developer Error":**
- SHA-1 definitely not configured
- Follow Step 2 again carefully

**If you see "Sign in failed":**
- Google Sign-In not enabled in Firebase
- Follow Step 3 again

**If Google dialog appears but then fails:**
- Internet connection issue
- Try again with good internet

## Visual Guide

```
Firebase Console
    ↓
⚙️ Project Settings
    ↓
Your apps → Android app
    ↓
Add fingerprint → Paste SHA1 → Save
    ↓
Authentication → Sign-in method
    ↓
Google → Enable → Save
    ↓
Done! ✅
```

## Need the SHA-1 Again?

Run this anytime:
```bash
cd android
gradlew signingReport
```

Or double-click: `get_sha1.bat`

## Success Checklist

- [ ] Got SHA-1 fingerprint
- [ ] Added SHA-1 to Firebase Console
- [ ] Enabled Google Sign-In in Firebase
- [ ] Ran `flutter clean`
- [ ] Ran `flutter pub get`
- [ ] Ran `flutter run`
- [ ] Tested sign-in

## After Success

Once it works:
1. You'll see Google account picker
2. Select your account
3. App will redirect back
4. You'll see the home screen
5. Your name will appear in the app bar

**That's it! You're done!** 🎉

---

**Pro Tip:** Save your SHA-1 somewhere safe. You'll need it again if you:
- Change computers
- Reinstall Android Studio
- Create a release build
