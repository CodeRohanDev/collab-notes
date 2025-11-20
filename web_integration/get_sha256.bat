@echo off
echo ========================================
echo Getting SHA-256 Fingerprint for Android
echo ========================================
echo.

echo Checking for keystore file...
if exist "..\android\app\upload-keystore.jks" (
    echo Found upload-keystore.jks
    echo.
    echo Enter keystore password when prompted:
    keytool -list -v -keystore ..\android\app\upload-keystore.jks -alias upload
) else (
    echo upload-keystore.jks not found!
    echo.
    echo Getting debug keystore fingerprint instead...
    echo.
    
    set DEBUG_KEYSTORE=%USERPROFILE%\.android\debug.keystore
    
    if exist "%DEBUG_KEYSTORE%" (
        keytool -list -v -keystore "%DEBUG_KEYSTORE%" -alias androiddebugkey -storepass android -keypass android
    ) else (
        echo Debug keystore not found at: %DEBUG_KEYSTORE%
        echo.
        echo Please run the app once to generate debug keystore.
    )
)

echo.
echo ========================================
echo Copy the SHA256 value and update it in:
echo web_integration/.well-known/assetlinks.json
echo ========================================
echo.
pause
