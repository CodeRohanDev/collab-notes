# Web Integration Guide for Deep Linking

## Problem
When users click share links like `https://collabnotes.hostspica.com/note/abc123` in a browser, they get a 404 error because your website doesn't have that route.

## Solution
Set up a landing page that detects if the user has the app and redirects them appropriately.

## Setup Instructions

### Step 1: Upload Files to Your Web Server

Upload the following files to your web server at `https://collabnotes.hostspica.com`:

1. **Landing Page** - `web_integration/note-redirect.html`
   - Upload to: `/note/[noteId].html` or configure your server to serve this for all `/note/*` routes

2. **Android Asset Links** - `web_integration/.well-known/assetlinks.json`
   - Upload to: `/.well-known/assetlinks.json`
   - Must be accessible at: `https://collabnotes.hostspica.com/.well-known/assetlinks.json`

3. **iOS Universal Links** - `web_integration/.well-known/apple-app-site-association`
   - Upload to: `/.well-known/apple-app-site-association`
   - Must be accessible at: `https://collabnotes.hostspica.com/.well-known/apple-app-site-association`

### Step 2: Configure Your Web Server

#### Option A: Using Apache (.htaccess)

Create/update `.htaccess` in your web root:

```apache
# Enable rewrite engine
RewriteEngine On

# Redirect all /note/* requests to the landing page
RewriteRule ^note/([a-zA-Z0-9-]+)$ /note-redirect.html [L]

# Ensure .well-known files are accessible
<FilesMatch "^(assetlinks\.json|apple-app-site-association)$">
    Header set Content-Type "application/json"
    Header set Access-Control-Allow-Origin "*"
</FilesMatch>
```

#### Option B: Using Nginx

Add to your nginx configuration:

```nginx
server {
    listen 443 ssl;
    server_name collabnotes.hostspica.com;

    # Serve landing page for /note/* routes
    location ~ ^/note/([a-zA-Z0-9-]+)$ {
        try_files /note-redirect.html =404;
    }

    # Serve .well-known files
    location /.well-known/ {
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
    }
}
```

#### Option C: Using Node.js/Express

```javascript
const express = require('express');
const app = express();

// Serve landing page for note routes
app.get('/note/:noteId', (req, res) => {
    res.sendFile(__dirname + '/note-redirect.html');
});

// Serve .well-known files
app.get('/.well-known/assetlinks.json', (req, res) => {
    res.type('application/json');
    res.sendFile(__dirname + '/.well-known/assetlinks.json');
});

app.get('/.well-known/apple-app-site-association', (req, res) => {
    res.type('application/json');
    res.sendFile(__dirname + '/.well-known/apple-app-site-association');
});
```

### Step 3: Get Your SHA-256 Fingerprint (Android)

You need to update `assetlinks.json` with your app's SHA-256 fingerprint.

**For Debug Build:**
```bash
cd android
./gradlew signingReport
```

**For Release Build (using your keystore):**
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

Copy the SHA-256 fingerprint and update it in `assetlinks.json`.

### Step 4: Get Your Team ID (iOS)

For iOS universal links, you need your Apple Team ID:

1. Go to https://developer.apple.com/account
2. Click on "Membership" in the sidebar
3. Copy your Team ID
4. Update `apple-app-site-association` with your Team ID

### Step 5: Verify Setup

#### Test Android Asset Links:
```bash
# Check if file is accessible
curl https://collabnotes.hostspica.com/.well-known/assetlinks.json

# Verify with Google's tool
# Visit: https://developers.google.com/digital-asset-links/tools/generator
```

#### Test iOS Universal Links:
```bash
# Check if file is accessible
curl https://collabnotes.hostspica.com/.well-known/apple-app-site-association

# Verify with Apple's validator
# Visit: https://search.developer.apple.com/appsearch-validation-tool/
```

#### Test Landing Page:
```bash
# Visit in browser
https://collabnotes.hostspica.com/note/test123
```

## How It Works

### User Flow:

1. **User A shares a note** → Generates link: `https://collabnotes.hostspica.com/note/abc123`

2. **User B clicks link:**
   - **On Mobile (with app installed):**
     - Android: System automatically opens the app (via App Links)
     - iOS: System automatically opens the app (via Universal Links)
   
   - **On Mobile (without app):**
     - Landing page loads
     - Shows "Open in App" button
     - Shows "Download App" button
     - Redirects to Play Store/App Store
   
   - **On Desktop:**
     - Landing page loads
     - Shows information about the app
     - Shows download links

### Technical Flow:

```
User clicks: https://collabnotes.hostspica.com/note/abc123
    ↓
Mobile OS checks: Is app installed?
    ↓
YES → Opens app directly with deep link
    ↓
NO → Opens browser → Landing page
    ↓
Landing page tries to open app
    ↓
If fails → Shows download button
```

## Important Notes

### SSL Certificate Required
- Deep linking ONLY works with HTTPS
- Your domain must have a valid SSL certificate
- Both `.well-known` files must be served over HTTPS

### Content-Type Headers
- `assetlinks.json` must be served with `Content-Type: application/json`
- `apple-app-site-association` must be served with `Content-Type: application/json`
- No `.json` extension for `apple-app-site-association`

### File Accessibility
- `.well-known` files must be publicly accessible
- No authentication required
- No redirects allowed
- Must return 200 status code

### Testing Tips

1. **Clear app data** before testing deep links
2. **Uninstall and reinstall** app to test fresh installation
3. **Test on real devices**, not just emulators
4. **Wait 24-48 hours** after uploading `.well-known` files (Android caches them)

## Troubleshooting

### Link opens in browser instead of app:

**Android:**
- Verify `assetlinks.json` is accessible
- Check SHA-256 fingerprint is correct
- Clear app data and reinstall
- Wait 24 hours for Google to cache the file

**iOS:**
- Verify `apple-app-site-association` is accessible
- Check Team ID is correct
- Ensure Associated Domains capability is added in Xcode
- Test with Safari (not Chrome)

### 404 Error on landing page:
- Check web server configuration
- Verify rewrite rules are working
- Check file permissions
- Test with: `curl -I https://collabnotes.hostspica.com/note/test`

### Deep link not working:
- Check AndroidManifest.xml has correct intent filters
- Verify domain matches exactly
- Test with ADB: `adb shell am start -W -a android.intent.action.VIEW -d "https://collabnotes.hostspica.com/note/test123" com.hostspica.collabnotes`

## Alternative: Use Firebase Dynamic Links

If you want a simpler solution without managing your own web server:

1. Set up Firebase Dynamic Links
2. Use Firebase-generated short links
3. Firebase handles all the redirects automatically

However, this requires:
- Firebase project setup
- Additional dependencies
- Firebase Dynamic Links quota limits

## Quick Start Checklist

- [ ] Upload `note-redirect.html` to web server
- [ ] Upload `.well-known/assetlinks.json`
- [ ] Upload `.well-known/apple-app-site-association`
- [ ] Configure web server rewrite rules
- [ ] Get SHA-256 fingerprint and update `assetlinks.json`
- [ ] Get Apple Team ID and update `apple-app-site-association`
- [ ] Test `.well-known` files are accessible
- [ ] Test landing page loads correctly
- [ ] Test deep link on Android device
- [ ] Test deep link on iOS device
- [ ] Verify app opens automatically when installed

## Support

If you encounter issues:
1. Check browser console for errors
2. Verify all files are accessible via curl
3. Test with Google's Digital Asset Links tool
4. Test with Apple's Universal Links validator
5. Check Android logcat for deep link errors: `adb logcat | grep -i "deep"`
