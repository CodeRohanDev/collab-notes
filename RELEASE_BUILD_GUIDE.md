# Release Build Guide for CollabNotes

This guide will help you create a production-ready Android App Bundle (AAB) or APK for Google Play Store.

## Prerequisites Completed ✅

- ✅ Keystore configuration added to `build.gradle.kts`
- ✅ ProGuard rules configured
- ✅ Debug print statements removed
- ✅ `.gitignore` updated to protect sensitive files

## Step 1: Create Keystore (One-time setup)

Follow the instructions in `CREATE_KEYSTORE.md` to create your keystore file.

**Important:** After creating the keystore, create a `key.properties` file in the `android/` directory:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

**⚠️ NEVER commit `key.properties` or `upload-keystore.jks` to version control!**

## Step 2: Update App Version

Before building, update the version in `pubspec.yaml`:

```yaml
version: 1.0.0+1  # Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

- First number (1.0.0) is the version name shown to users
- Second number (+1) is the version code (must increment for each release)

## Step 3: Build Release Bundle (AAB) for Play Store

Run this command to create an Android App Bundle:

```bash
flutter build appbundle --release
```

The AAB file will be created at:
```
build/app/outputs/bundle/release/app-release.aab
```

## Step 4: Build Release APK (Alternative)

If you need an APK instead of AAB:

```bash
flutter build apk --release
```

The APK will be created at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Build Split APKs (Smaller file sizes)

```bash
flutter build apk --split-per-abi --release
```

This creates separate APKs for different CPU architectures:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit Intel)

## Step 5: Test the Release Build

Before uploading to Play Store, test the release build:

```bash
# Install the release APK
flutter install --release

# Or manually install
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Step 6: Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app (or create a new one)
3. Navigate to **Production** → **Create new release**
4. Upload the `app-release.aab` file
5. Fill in release notes
6. Review and roll out

## Troubleshooting

### Error: "key.properties not found"

Create the `android/key.properties` file with your keystore credentials.

### Error: "Keystore file not found"

Make sure you've created the keystore using the instructions in `CREATE_KEYSTORE.md` and the path in `key.properties` is correct.

### Error: "Execution failed for task ':app:lintVitalAnalyzeRelease'"

Add this to `android/app/build.gradle.kts`:

```kotlin
android {
    lintOptions {
        checkReleaseBuilds = false
        abortOnError = false
    }
}
```

### Build is too large

The ProGuard rules are already configured to shrink and obfuscate your code. If you need further optimization:

1. Enable R8 full mode (already enabled in `gradle.properties`)
2. Use split APKs: `flutter build apk --split-per-abi`
3. Remove unused resources

## Security Checklist

Before releasing:

- [ ] All debug print statements removed ✅
- [ ] API keys moved to environment variables or secure storage
- [ ] ProGuard enabled ✅
- [ ] Keystore file NOT in version control ✅
- [ ] `key.properties` NOT in version control ✅
- [ ] Test on multiple devices
- [ ] Test all critical features
- [ ] Check app permissions in manifest

## Next Steps After Release

1. Monitor crash reports in Play Console
2. Set up Firebase Crashlytics for detailed crash reporting
3. Monitor user reviews and ratings
4. Plan for updates and new features

## Useful Commands

```bash
# Check app size
flutter build appbundle --release --analyze-size

# Build with verbose output
flutter build appbundle --release --verbose

# Clean build
flutter clean && flutter pub get && flutter build appbundle --release

# Check what's in the bundle
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app.apks
```

## Version History

- **1.0.0+1** - Initial release
  - Rich text editor with formatting
  - Guest mode and Google Sign-In
  - Cloud sync with selective note syncing
  - Archive, pin, favorite features
  - Tags and color coding
  - Comments system
  - Offline-first architecture

---

**Ready to build?** Run: `flutter build appbundle --release`
