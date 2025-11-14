@echo off
echo ========================================
echo Getting SHA-1 Fingerprint for Debug
echo ========================================
echo.

cd android
call gradlew signingReport

echo.
echo ========================================
echo Look for "SHA1:" in the output above
echo Copy that value and add it to Firebase Console
echo ========================================
echo.
echo Next steps:
echo 1. Copy the SHA1 value from above
echo 2. Go to Firebase Console
echo 3. Project Settings ^> Your apps ^> Android app
echo 4. Click "Add fingerprint"
echo 5. Paste SHA1 and save
echo 6. Download new google-services.json
echo 7. Replace android/app/google-services.json
echo 8. Run: flutter clean
echo 9. Run: flutter pub get
echo 10. Run: flutter run
echo.
pause
