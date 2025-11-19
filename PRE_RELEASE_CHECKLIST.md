# Pre-Release Checklist for CollabNotes

Complete this checklist before submitting to Google Play Store.

## Code Quality ✅

- [x] All debug print statements removed
- [x] No hardcoded API keys or secrets in code
- [x] ProGuard rules configured
- [x] Code obfuscation enabled
- [ ] All TODO comments addressed or documented
- [ ] No test/debug code in production

## Configuration ✅

- [x] App name finalized in `AndroidManifest.xml`
- [x] Package name set correctly
- [x] Version number updated in `pubspec.yaml`
- [x] Minimum SDK version appropriate (minSdk: 21)
- [x] Target SDK version up to date (targetSdk: 34)
- [x] App icon added (all densities)
- [ ] Splash screen configured

## Security 🔒

- [x] Keystore created and secured
- [x] `key.properties` file created (NOT in git)
- [x] `.gitignore` updated
- [x] Firebase configuration files present
- [ ] Firebase security rules reviewed
- [ ] Firestore rules tested
- [ ] Storage rules tested
- [ ] API keys restricted in Google Cloud Console

## Features Testing 🧪

### Authentication
- [ ] Guest mode works correctly
- [ ] Google Sign-In works
- [ ] Guest data migrates to authenticated user
- [ ] Sign out works properly
- [ ] Session persistence works

### Notes Management
- [ ] Create note works
- [ ] Edit note works
- [ ] Delete note works
- [ ] Archive/unarchive works
- [ ] Pin/unpin works
- [ ] Favorite works
- [ ] Rich text formatting works
- [ ] Click anywhere to type works

### Sync Features
- [ ] Cloud sync toggle works
- [ ] Local-only notes persist
- [ ] Cloud notes sync properly
- [ ] Sync status indicators show correctly
- [ ] Offline mode works
- [ ] Sync after reconnection works

### UI/UX
- [ ] All screens render correctly
- [ ] Navigation works smoothly
- [ ] Bottom sheets work
- [ ] Dialogs display properly
- [ ] Snackbars show appropriate messages
- [ ] Loading states display
- [ ] Error states display
- [ ] Empty states display

### Edge Cases
- [ ] App works without internet
- [ ] App handles network errors gracefully
- [ ] App handles Firebase errors
- [ ] App doesn't crash on rotation
- [ ] App handles low memory situations
- [ ] App handles background/foreground transitions

## Performance ⚡

- [ ] App starts quickly (< 3 seconds)
- [ ] No memory leaks
- [ ] Smooth scrolling (60 FPS)
- [ ] Images load efficiently
- [ ] Database queries optimized
- [ ] No ANR (Application Not Responding) issues

## Permissions 📋

Review permissions in `AndroidManifest.xml`:
- [ ] INTERNET - Required for Firebase
- [ ] ACCESS_NETWORK_STATE - For checking connectivity
- [ ] All permissions are necessary and justified

## Google Play Store Assets 🎨

Prepare these before submission:

### Required
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Screenshots (at least 2, up to 8)
  - [ ] Phone screenshots (16:9 or 9:16)
  - [ ] Tablet screenshots (optional)
- [ ] Short description (80 characters max)
- [ ] Full description (4000 characters max)
- [ ] Privacy policy URL
- [ ] App category selected
- [ ] Content rating questionnaire completed

### Optional but Recommended
- [ ] Promotional video
- [ ] Promo graphic (180x120 PNG)
- [ ] TV banner (optional)

## Legal & Compliance ⚖️

- [ ] Privacy policy created and hosted
- [ ] Terms of service created (if applicable)
- [ ] GDPR compliance reviewed (if targeting EU)
- [ ] COPPA compliance (if app is for children)
- [ ] Data deletion policy documented
- [ ] Third-party licenses acknowledged

## Firebase Setup 🔥

- [ ] Firebase project created
- [ ] Google Sign-In configured
- [ ] SHA-1 fingerprint added to Firebase
- [ ] `google-services.json` in correct location
- [ ] Firestore database created
- [ ] Firestore security rules deployed
- [ ] Storage bucket created (if using)
- [ ] Storage security rules deployed (if using)
- [ ] Firebase Authentication enabled
- [ ] Google provider enabled in Authentication

## Build Process 🏗️

- [ ] Keystore created (see `CREATE_KEYSTORE.md`)
- [ ] `key.properties` configured
- [ ] Release build successful: `flutter build appbundle --release`
- [ ] APK/AAB file tested on real device
- [ ] App installs correctly
- [ ] App runs without crashes
- [ ] All features work in release mode

## Documentation 📚

- [ ] README.md updated
- [ ] CHANGELOG.md created
- [ ] API documentation (if applicable)
- [ ] User guide (if needed)
- [ ] Developer setup guide

## Post-Release Preparation 📊

- [ ] Crash reporting set up (Firebase Crashlytics)
- [ ] Analytics configured (Firebase Analytics)
- [ ] Performance monitoring enabled
- [ ] Remote config set up (optional)
- [ ] A/B testing plan (optional)
- [ ] Update strategy planned
- [ ] Support email/channel established

## Final Checks ✔️

- [ ] App name is unique and not trademarked
- [ ] Package name is unique
- [ ] Version code incremented from previous release
- [ ] All team members reviewed the build
- [ ] Backup of keystore and passwords secured
- [ ] Release notes prepared
- [ ] Marketing materials ready
- [ ] Support documentation ready

## Build Commands Reference

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release AAB
flutter build appbundle --release

# Build release APK
flutter build apk --release

# Install and test
flutter install --release
```

## Emergency Rollback Plan

If critical issues are found after release:

1. Halt rollout in Play Console (if staged rollout)
2. Fix the issue immediately
3. Increment version code
4. Build new release
5. Submit update with priority
6. Communicate with affected users

---

## Sign-Off

- [ ] Developer tested and approved
- [ ] QA tested and approved (if applicable)
- [ ] Product owner approved (if applicable)
- [ ] Ready for submission to Google Play Store

**Date:** _______________

**Submitted by:** _______________

**Version:** _______________

---

**Next Step:** Follow `RELEASE_BUILD_GUIDE.md` to build and submit your app!
