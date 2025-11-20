# 🔧 Fix the 404 Issue - Action Plan

## Problem
When users click share links like `https://collabnotes.hostspica.com/note/abc123`, they get a 404 error.

---

## 🚀 Using Vercel + Next.js?

**If you're using Vercel with Next.js, use this guide instead:**
👉 **`VERCEL_QUICK_START.md`** (Super quick - 15 minutes)
👉 **`VERCEL_NEXTJS_SETUP.md`** (Detailed version)

The guide below is for Apache/Nginx/cPanel hosting.

---

## Solution in 5 Simple Steps

---

## ✅ STEP 1: Get Your App's SHA-256 Fingerprint

### Windows:
1. Open Command Prompt in your project folder
2. Run this command:
```bash
cd web_integration
get_sha256.bat
```

### Alternative (if batch file doesn't work):
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```
Enter your keystore password when prompted.

### What to look for:
You'll see output like this:
```
Certificate fingerprints:
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA256: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00
```

**COPY THE SHA256 VALUE** (the long one with colons)

---

## ✅ STEP 2: Update the Configuration File

1. Open this file: `web_integration/.well-known/assetlinks.json`

2. Find this line:
```json
"YOUR_SHA256_FINGERPRINT_HERE"
```

3. Replace it with your SHA256 value (keep the quotes):
```json
"AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00"
```

4. Save the file

---

## ✅ STEP 3: Upload Files to Your Website

You need to upload **3 files** to your website at `https://collabnotes.hostspica.com`

### Files to Upload:

#### File 1: Landing Page
**Choose ONE based on your hosting:**

**If you have static hosting (HTML only):**
- Upload: `web_integration/note-redirect.html`
- To: Root directory of your website
- Final URL: `https://collabnotes.hostspica.com/note-redirect.html`

**If you have PHP hosting:**
- Upload: `web_integration/note.php`
- To: Root directory of your website
- Final URL: `https://collabnotes.hostspica.com/note.php`

#### File 2: Android Verification
- Upload: `web_integration/.well-known/assetlinks.json`
- To: `/.well-known/` folder (create if doesn't exist)
- Final URL: `https://collabnotes.hostspica.com/.well-known/assetlinks.json`

#### File 3: iOS Verification
- Upload: `web_integration/.well-known/apple-app-site-association`
- To: `/.well-known/` folder
- Final URL: `https://collabnotes.hostspica.com/.well-known/apple-app-site-association`

### Your Website Structure Should Look Like:
```
https://collabnotes.hostspica.com/
├── note-redirect.html (or note.php)
└── .well-known/
    ├── assetlinks.json
    └── apple-app-site-association
```

---

## ✅ STEP 4: Configure Your Web Server

You need to tell your web server to route `/note/*` URLs to your landing page.

### Option A: Apache (Most Common)

1. Create or edit `.htaccess` file in your website root
2. Add these lines:

**If using note-redirect.html:**
```apache
RewriteEngine On
RewriteRule ^note/([a-zA-Z0-9-]+)$ /note-redirect.html [L]

# Ensure .well-known files are accessible
<FilesMatch "^(assetlinks\.json|apple-app-site-association)$">
    Header set Content-Type "application/json"
    Header set Access-Control-Allow-Origin "*"
</FilesMatch>
```

**If using note.php:**
```apache
RewriteEngine On
RewriteRule ^note/([a-zA-Z0-9-]+)$ /note.php?id=$1 [L]

# Ensure .well-known files are accessible
<FilesMatch "^(assetlinks\.json|apple-app-site-association)$">
    Header set Content-Type "application/json"
    Header set Access-Control-Allow-Origin "*"
</FilesMatch>
```

3. Save and upload `.htaccess` to your website root

### Option B: Nginx

1. Edit your nginx configuration file
2. Add this inside your `server` block:

```nginx
server {
    listen 443 ssl;
    server_name collabnotes.hostspica.com;

    # Route /note/* to landing page
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

3. Save and reload nginx:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

### Option C: cPanel / Hosting Control Panel

1. Log into your hosting control panel
2. Go to "File Manager"
3. Navigate to your website root
4. Create/edit `.htaccess` file
5. Add the Apache rules from Option A
6. Save

---

## ✅ STEP 5: Test Everything

### Test 1: Landing Page
Open your browser and visit:
```
https://collabnotes.hostspica.com/note/test123
```

**Expected Result:** You should see a page with:
- "Open in CollabNotes" heading
- "Open in App" button
- App information

**If you see 404:** Go back to Step 4 and check your server configuration

### Test 2: Android Verification File
Open your browser and visit:
```
https://collabnotes.hostspica.com/.well-known/assetlinks.json
```

**Expected Result:** You should see JSON like:
```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.hostspica.collabnotes",
      "sha256_cert_fingerprints": [
        "YOUR_SHA256_HERE"
      ]
    }
  }
]
```

**If you see 404:** Check that you uploaded the file to the correct location

### Test 3: iOS Verification File
Open your browser and visit:
```
https://collabnotes.hostspica.com/.well-known/apple-app-site-association
```

**Expected Result:** You should see JSON with applinks configuration

**If you see 404:** Check that you uploaded the file to the correct location

### Test 4: On Android Device
1. Install your app on an Android device
2. Open browser on the device
3. Visit: `https://collabnotes.hostspica.com/note/test123`
4. **Expected:** App should open automatically OR landing page shows with "Open in App" button
5. Tap "Open in App" button
6. **Expected:** App opens

---

## 🎉 Success Checklist

- [ ] SHA-256 fingerprint obtained
- [ ] `assetlinks.json` updated with SHA-256
- [ ] Landing page uploaded to website
- [ ] `.well-known/assetlinks.json` uploaded
- [ ] `.well-known/apple-app-site-association` uploaded
- [ ] Server rewrite rules configured
- [ ] Landing page loads at `/note/test123` ✓
- [ ] `.well-known/assetlinks.json` accessible ✓
- [ ] `.well-known/apple-app-site-association` accessible ✓
- [ ] Tested on Android device ✓

---

## 🐛 Troubleshooting

### Problem: "404 Not Found" on landing page

**Solution:**
1. Check that landing page file is uploaded to root directory
2. Verify server rewrite rules are configured correctly
3. Check file permissions (should be 644)
4. Try accessing the file directly:
   - `https://collabnotes.hostspica.com/note-redirect.html`

### Problem: "404 Not Found" on .well-known files

**Solution:**
1. Create `.well-known` folder in website root
2. Upload both files to this folder
3. Check file permissions (folder: 755, files: 644)
4. Some servers block `.well-known` - check your hosting settings

### Problem: App doesn't open automatically

**Solution:**
1. **Wait 24 hours** - Android caches verification for 24 hours
2. Clear app data: Settings → Apps → CollabNotes → Clear Data
3. Uninstall and reinstall the app
4. Verify SHA-256 fingerprint is correct
5. Check that `assetlinks.json` is accessible

### Problem: "You do not have access to this note"

**Solution:**
1. User must be logged in (not guest mode)
2. User's email must match the email added as collaborator
3. Note must have sync enabled

### Problem: Changes not syncing between devices

**Solution:**
1. Both users must be logged in (not guest mode)
2. Both devices must have internet connection
3. Note must have sync enabled
4. Check Firebase Firestore rules

---

## 📞 Need More Help?

### Quick Commands to Test:

**Test landing page:**
```bash
curl -I https://collabnotes.hostspica.com/note/test123
```
Should return: `HTTP/2 200`

**Test Android config:**
```bash
curl https://collabnotes.hostspica.com/.well-known/assetlinks.json
```
Should return: JSON with your package name

**Test on device via ADB:**
```bash
adb shell am start -W -a android.intent.action.VIEW -d "https://collabnotes.hostspica.com/note/test123" com.hostspica.collabnotes
```
Should open: Your app

### Additional Resources:

- **Complete Guide:** `WEB_INTEGRATION_GUIDE.md`
- **Quick Reference:** `QUICK_SETUP_GUIDE.md`
- **Checklist:** `web_integration/SETUP_CHECKLIST.txt`
- **Flow Diagram:** `web_integration/FLOW_DIAGRAM.txt`
- **Test Tool:** Upload `web_integration/test-deep-link.html` to your site

### Verify with Google:
https://developers.google.com/digital-asset-links/tools/generator

---

## ⏱️ Time Estimate

- **Step 1:** 2 minutes
- **Step 2:** 1 minute
- **Step 3:** 5 minutes
- **Step 4:** 5-10 minutes
- **Step 5:** 5 minutes

**Total:** 15-25 minutes

---

## 🚀 After Setup

Once everything is working:

1. **Test with real users:**
   - Share a note from Device A
   - Click link on Device B
   - Verify collaboration works

2. **Monitor for issues:**
   - Check Android logs: `adb logcat | grep -i "deep"`
   - Monitor user feedback

3. **Update app listing:**
   - Add screenshots showing sharing feature
   - Mention collaboration in description

---

## 📝 Important Notes

- ⚠️ **HTTPS Required:** Deep linking only works with HTTPS (SSL certificate)
- ⏰ **Wait Time:** Android caches verification for 24 hours after first check
- 📱 **Real Devices:** Always test on real devices, not just emulators
- 🔄 **Clear Data:** Clear app data when testing changes

---

## ✅ You're Done When...

1. You can visit `https://collabnotes.hostspica.com/note/test123` and see the landing page
2. The `.well-known` files are accessible
3. Clicking a share link on mobile opens your app (or shows landing page)
4. Two users can collaborate on the same note in real-time

---

**Start with Step 1 and work through each step in order. Good luck! 🎉**
