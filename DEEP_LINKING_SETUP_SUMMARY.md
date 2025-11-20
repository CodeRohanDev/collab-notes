# Deep Linking Setup Summary

## Problem Solved
When users click share links like `https://collabnotes.hostspica.com/note/abc123`, they were getting 404 errors because your website doesn't have that route.

## Solution Implemented

### 1. App-Side (Already Done ✅)
- Deep link handler configured in Android
- BLoC events for fetching shared notes
- Repository methods for collaboration
- Share dialog with proper URL generation

### 2. Web-Side (You Need to Do 📋)

Created files in `web_integration/` folder that you need to upload to your website:

#### Files to Upload:

1. **Landing Page** (Choose one):
   - `note-redirect.html` - For static hosting
   - `note.php` - For PHP hosting
   
2. **Deep Link Verification**:
   - `.well-known/assetlinks.json` - For Android
   - `.well-known/apple-app-site-association` - For iOS

3. **Helper Script**:
   - `get_sha256.bat` - To get your app's fingerprint

## Step-by-Step Setup

### Step 1: Get SHA-256 Fingerprint
```bash
cd web_integration
get_sha256.bat
```
Copy the SHA256 value that appears.

### Step 2: Update assetlinks.json
Open `web_integration/.well-known/assetlinks.json` and replace `YOUR_SHA256_FINGERPRINT_HERE` with the value you copied.

### Step 3: Upload to Your Website

Upload these files to `https://collabnotes.hostspica.com`:

```
Your Website Root/
├── note-redirect.html (or note.php)
└── .well-known/
    ├── assetlinks.json
    └── apple-app-site-association
```

### Step 4: Configure Your Web Server

**If using Apache**, create/update `.htaccess`:
```apache
RewriteEngine On
RewriteRule ^note/([a-zA-Z0-9-]+)$ /note-redirect.html [L]
```

**If using Nginx**, add to your config:
```nginx
location ~ ^/note/([a-zA-Z0-9-]+)$ {
    try_files /note-redirect.html =404;
}
```

**If using PHP**, use this rewrite:
```apache
RewriteEngine On
RewriteRule ^note/([a-zA-Z0-9-]+)$ /note.php?id=$1 [L]
```

### Step 5: Test

1. **Test landing page:**
   Visit: `https://collabnotes.hostspica.com/note/test123`
   Should show: "Open in CollabNotes" page

2. **Test Android verification:**
   ```bash
   curl https://collabnotes.hostspica.com/.well-known/assetlinks.json
   ```
   Should return: JSON with your SHA-256 fingerprint

3. **Test on device:**
   - Share a note from the app
   - Click the link on another device
   - Should open the app automatically (if installed)
   - Or show landing page with "Open in App" button

## How It Works

### When User Clicks Share Link:

**On Mobile with App Installed:**
```
Click link → Android/iOS detects app → Opens app directly → Shows note
```

**On Mobile without App:**
```
Click link → Opens browser → Landing page → "Download App" button → Play Store
```

**On Desktop:**
```
Click link → Opens browser → Landing page → Shows app info
```

## Verification Checklist

- [ ] SHA-256 fingerprint obtained
- [ ] `assetlinks.json` updated with fingerprint
- [ ] Files uploaded to web server
- [ ] `.well-known/assetlinks.json` accessible at correct URL
- [ ] `.well-known/apple-app-site-association` accessible at correct URL
- [ ] Web server rewrite rules configured
- [ ] Landing page loads at `/note/test123`
- [ ] Tested on Android device
- [ ] Tested on iOS device (if applicable)

## Testing Commands

### Test with ADB (Android):
```bash
adb shell am start -W -a android.intent.action.VIEW -d "https://collabnotes.hostspica.com/note/test123" com.hostspica.collabnotes
```

### Test with curl:
```bash
# Test landing page
curl -I https://collabnotes.hostspica.com/note/test123

# Test Android verification
curl https://collabnotes.hostspica.com/.well-known/assetlinks.json

# Test iOS verification
curl https://collabnotes.hostspica.com/.well-known/apple-app-site-association
```

## Common Issues

### Issue: 404 on landing page
**Solution:** Check web server rewrite rules are configured correctly

### Issue: App doesn't open automatically
**Solution:** 
- Verify `.well-known` files are accessible
- Check SHA-256 fingerprint is correct
- Wait 24 hours for Android to cache the verification file
- Clear app data and reinstall

### Issue: "You do not have access to this note"
**Solution:** User needs to be logged in with the same email that was added as collaborator

## Important Notes

1. **SSL Required**: Deep linking only works with HTTPS
2. **Wait Time**: Android caches verification files for 24 hours
3. **Testing**: Always test on real devices, not just emulators
4. **Reinstall**: Clear app data or reinstall when testing changes

## Documentation

- **Complete Guide**: `WEB_INTEGRATION_GUIDE.md`
- **Share Features**: `SHARE_FUNCTIONALITY.md`
- **Web Files**: `web_integration/README.md`

## Support

If you encounter issues:
1. Check all files are uploaded correctly
2. Verify `.well-known` files return 200 status
3. Test with Google's Digital Asset Links tool
4. Check Android logcat: `adb logcat | grep -i "deep"`

## Next Steps

After setup is complete:
1. Test sharing between two devices
2. Verify collaboration works
3. Update Play Store listing with deep link support
4. Add screenshots showing collaboration features
5. Promote the sharing feature to users
