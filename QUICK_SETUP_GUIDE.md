# Quick Setup Guide - Deep Linking

## 🎯 Goal
Make share links work so when users click `https://collabnotes.hostspica.com/note/abc123`, they can open the note in your app.

## ⚡ Quick Setup (5 Steps)

### Step 1: Get Your App's Fingerprint
```bash
cd web_integration
get_sha256.bat
```
Copy the **SHA256** value that appears.

### Step 2: Update Configuration File
1. Open `web_integration/.well-known/assetlinks.json`
2. Replace `YOUR_SHA256_FINGERPRINT_HERE` with the SHA256 you copied
3. Save the file

### Step 3: Upload Files to Your Website

Upload these 3 files to `https://collabnotes.hostspica.com`:

```
📁 Your Website Root
├── 📄 note-redirect.html (or note.php if you use PHP)
└── 📁 .well-known/
    ├── 📄 assetlinks.json
    └── 📄 apple-app-site-association
```

### Step 4: Configure Web Server

Add this to your `.htaccess` (Apache) or server config:

**Apache:**
```apache
RewriteEngine On
RewriteRule ^note/([a-zA-Z0-9-]+)$ /note-redirect.html [L]
```

**Nginx:**
```nginx
location ~ ^/note/([a-zA-Z0-9-]+)$ {
    try_files /note-redirect.html =404;
}
```

### Step 5: Test

1. Visit: `https://collabnotes.hostspica.com/note/test123`
2. Should see: "Open in CollabNotes" page
3. Click "Open in App" button
4. Should open your app (if installed)

## ✅ Verification Checklist

- [ ] SHA-256 fingerprint obtained
- [ ] `assetlinks.json` updated
- [ ] Files uploaded to website
- [ ] Server rewrite rules configured
- [ ] Landing page loads at `/note/test123`
- [ ] `.well-known/assetlinks.json` accessible
- [ ] Tested on Android device

## 🧪 Testing

### Test Landing Page:
```bash
curl -I https://collabnotes.hostspica.com/note/test123
```
Should return: `200 OK`

### Test Android Config:
```bash
curl https://collabnotes.hostspica.com/.well-known/assetlinks.json
```
Should return: JSON with your SHA-256

### Test on Device:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "https://collabnotes.hostspica.com/note/test123" com.hostspica.collabnotes
```
Should open: Your app

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| 404 on landing page | Check server rewrite rules |
| App doesn't open | Wait 24 hours for Android to cache verification |
| "Access denied" error | User must be logged in with invited email |
| Files not accessible | Check file permissions and paths |

## 📚 Full Documentation

- **Complete Guide**: `WEB_INTEGRATION_GUIDE.md`
- **Detailed Setup**: `DEEP_LINKING_SETUP_SUMMARY.md`
- **Share Features**: `SHARE_FUNCTIONALITY.md`

## 🆘 Need Help?

1. Use the test page: Upload `web_integration/test-deep-link.html` to your site
2. Check Android logs: `adb logcat | grep -i "deep"`
3. Verify with Google: https://developers.google.com/digital-asset-links/tools/generator

## 📝 Important Notes

- ⚠️ Deep linking requires HTTPS (SSL certificate)
- ⏰ Android caches verification for 24 hours
- 🔄 Clear app data when testing changes
- 📱 Always test on real devices, not emulators

## 🎉 After Setup

Once working, users can:
1. Share notes from the app
2. Recipients click the link
3. App opens automatically
4. They can collaborate in real-time!
