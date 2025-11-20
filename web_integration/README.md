# Web Integration Files

This folder contains files needed to set up deep linking on your website `https://collabnotes.hostspica.com`.

## Files Overview

### Landing Pages
- **note-redirect.html** - Static HTML landing page (use if you have static hosting)
- **note.php** - PHP version of landing page (use if you have PHP hosting)

### Deep Link Configuration
- **.well-known/assetlinks.json** - Android App Links verification
- **.well-known/apple-app-site-association** - iOS Universal Links verification

### Utilities
- **get_sha256.bat** - Windows script to get your app's SHA-256 fingerprint

## Quick Start

### 1. Choose Your Landing Page

**If you have static hosting (HTML only):**
- Use `note-redirect.html`
- Configure your server to serve this file for all `/note/*` routes

**If you have PHP hosting:**
- Use `note.php`
- Rename to `index.php` or configure as default handler for `/note/` directory

### 2. Get SHA-256 Fingerprint

Run the batch script:
```bash
cd web_integration
get_sha256.bat
```

Copy the SHA256 value and update it in `.well-known/assetlinks.json`

### 3. Upload Files

Upload to your web server:
```
https://collabnotes.hostspica.com/
├── note-redirect.html (or note.php)
└── .well-known/
    ├── assetlinks.json
    └── apple-app-site-association
```

### 4. Configure Server

**Apache (.htaccess):**
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

**PHP:**
```apache
RewriteEngine On
RewriteRule ^note/([a-zA-Z0-9-]+)$ /note.php?id=$1 [L]
```

### 5. Test

Visit: `https://collabnotes.hostspica.com/note/test123`

You should see the landing page with "Open in App" button.

## Verification

### Test Android Asset Links:
```bash
curl https://collabnotes.hostspica.com/.well-known/assetlinks.json
```

### Test iOS Universal Links:
```bash
curl https://collabnotes.hostspica.com/.well-known/apple-app-site-association
```

### Validate with Google:
https://developers.google.com/digital-asset-links/tools/generator

## Troubleshooting

**404 on landing page:**
- Check server rewrite rules
- Verify file permissions
- Check file path is correct

**Deep link not working:**
- Verify `.well-known` files are accessible
- Check SHA-256 fingerprint is correct
- Wait 24 hours for Android to cache the file
- Clear app data and reinstall

**Landing page loads but app doesn't open:**
- Check app is installed
- Verify AndroidManifest.xml has correct intent filters
- Test with: `adb shell am start -W -a android.intent.action.VIEW -d "https://collabnotes.hostspica.com/note/test" com.hostspica.collabnotes`

## Need Help?

See the complete guide: `../WEB_INTEGRATION_GUIDE.md`
