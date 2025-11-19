# Creating Android App Bundle for Google Play Store

## Step 1: Create Keystore

Run this command in your terminal (replace the values with your own):

```bash
keytool -genkey -v -keystore c:\Users\Prem` Jha\Desktop\Notes\collabnotes\android\app\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

You'll be asked for:
- Keystore password (remember this!)
- Key password (can be same as keystore password)
- Your name
- Organization
- City
- State
- Country code

**IMPORTANT**: Save these passwords securely! You'll need them to update your app.

## Step 2: Create key.properties file

Create a file at `android/key.properties` with this content:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

Replace YOUR_KEYSTORE_PASSWORD and YOUR_KEY_PASSWORD with the passwords you just created.

## Step 3: Update build.gradle.kts

The build.gradle.kts file needs to be updated to use the keystore for release builds.

## Step 4: Remove Debug Logging

Before release, remove all print statements and debug code.

## Step 5: Build the App Bundle

Run this command:

```bash
flutter build appbundle --release
```

The AAB file will be created at:
`build/app/outputs/bundle/release/app-release.aab`

## Step 6: Upload to Google Play Console

1. Go to https://play.google.com/console
2. Create a new app or select existing
3. Go to "Release" > "Production"
4. Upload the AAB file
5. Fill in store listing details
6. Submit for review

## Important Notes

- Never commit key.properties or keystore files to version control
- Add them to .gitignore
- Keep backups of your keystore file - if you lose it, you can't update your app!
