# 🚀 Fix 404 Issue - Vercel + Next.js Setup

## Problem
When users click share links like `https://collabnotes.hostspica.com/note/abc123`, they get a 404 error.

## Solution for Vercel + Next.js

Since you're using Vercel with Next.js, the setup is simpler! Follow these steps:

---

## ✅ STEP 1: Get Your App's SHA-256 Fingerprint

### Windows:
1. Open Command Prompt in your Flutter project folder
2. Run:
```bash
cd web_integration
get_sha256.bat
```

### Alternative:
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

**COPY THE SHA256 VALUE** (the long one with colons like `AA:BB:CC:DD:...`)

---

## ✅ STEP 2: Update Configuration File

1. Open: `web_integration/.well-known/assetlinks.json`
2. Replace `YOUR_SHA256_FINGERPRINT_HERE` with your SHA256 value
3. Save the file

---

## ✅ STEP 3: Add Files to Your Next.js Project

In your Next.js project, you need to add these files:

### File Structure:
```
your-nextjs-project/
├── public/
│   └── .well-known/
│       ├── assetlinks.json
│       └── apple-app-site-association
├── app/
│   └── note/
│       └── [noteId]/
│           └── page.tsx
└── vercel.json (optional, for headers)
```

### 3.1: Copy .well-known Files

Copy these files to your Next.js project:
```bash
# From your Flutter project
web_integration/.well-known/assetlinks.json
web_integration/.well-known/apple-app-site-association

# To your Next.js project
your-nextjs-project/public/.well-known/
```

### 3.2: Create the Note Page

Create this file: `app/note/[noteId]/page.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';

export default function NotePage() {
  const params = useParams();
  const noteId = params.noteId as string;
  const [isMobile, setIsMobile] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  const deepLink = `https://collabnotes.hostspica.com/note/${noteId}`;
  const appScheme = `collabnotes://note/${noteId}`;

  useEffect(() => {
    // Detect mobile
    const mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
      navigator.userAgent
    );
    setIsMobile(mobile);

    // Auto-open app on mobile
    if (mobile) {
      setTimeout(() => {
        window.location.href = deepLink;
      }, 100);

      // Show download option after 2 seconds
      setTimeout(() => {
        setIsLoading(false);
      }, 2000);
    } else {
      setIsLoading(false);
    }
  }, [deepLink]);

  const handleOpenApp = () => {
    setIsLoading(true);
    
    // Try app scheme first
    window.location.href = appScheme;

    // Fallback to https deep link
    setTimeout(() => {
      window.location.href = deepLink;
    }, 500);

    // Show download option if app doesn't open
    setTimeout(() => {
      setIsLoading(false);
    }, 2500);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-600 to-purple-900 flex items-center justify-center p-5">
      <div className="bg-white rounded-3xl p-10 max-w-md w-full shadow-2xl text-center">
        {/* Logo */}
        <div className="w-20 h-20 bg-gradient-to-br from-purple-600 to-purple-900 rounded-2xl mx-auto mb-5 flex items-center justify-center text-4xl">
          📝
        </div>

        {/* Title */}
        <h1 className="text-3xl font-bold text-gray-800 mb-3">
          Open in CollabNotes
        </h1>

        {/* Description */}
        <p className="text-gray-600 mb-8 leading-relaxed">
          You've been invited to collaborate on a note. Open it in the CollabNotes app to start editing together.
        </p>

        {/* Loading State */}
        {isLoading && (
          <div className="my-5">
            <div className="w-10 h-10 border-4 border-gray-200 border-t-purple-600 rounded-full animate-spin mx-auto"></div>
            <p className="mt-3 text-gray-600">Opening app...</p>
          </div>
        )}

        {/* Buttons */}
        {!isLoading && (
          <div className="space-y-4">
            <button
              onClick={handleOpenApp}
              className="w-full bg-gradient-to-r from-purple-600 to-purple-900 text-white py-4 rounded-xl font-semibold text-lg hover:shadow-lg transition-all duration-300 hover:-translate-y-1"
            >
              Open in App
            </button>

            <a
              href="https://play.google.com/store/apps/details?id=com.hostspica.collabnotes"
              className="block w-full bg-gray-100 text-gray-800 py-4 rounded-xl font-semibold text-lg hover:bg-gray-200 transition-all duration-300"
            >
              Download App
            </a>
          </div>
        )}

        {/* Info Box */}
        <div className="mt-8 bg-gray-50 p-4 rounded-xl text-sm text-gray-600">
          <strong className="text-gray-800">Don't have the app?</strong>
          <br />
          Download CollabNotes to collaborate on notes in real-time with your team.
        </div>

        {/* Store Badge */}
        {!isLoading && (
          <div className="mt-5">
            <a
              href="https://play.google.com/store/apps/details?id=com.hostspica.collabnotes"
              target="_blank"
              rel="noopener noreferrer"
            >
              <img
                src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
                alt="Get it on Google Play"
                className="h-14 mx-auto"
              />
            </a>
          </div>
        )}
      </div>
    </div>
  );
}
```

### 3.3: Add Metadata (Optional but Recommended)

Create: `app/note/[noteId]/layout.tsx`

```typescript
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Open in CollabNotes',
  description: 'You\'ve been invited to collaborate on a note.',
  openGraph: {
    title: 'Open in CollabNotes',
    description: 'You\'ve been invited to collaborate on a note.',
    type: 'website',
  },
};

export default function NoteLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
```

---

## ✅ STEP 4: Configure Headers (Optional)

Create `vercel.json` in your Next.js project root:

```json
{
  "headers": [
    {
      "source": "/.well-known/:path*",
      "headers": [
        {
          "key": "Content-Type",
          "value": "application/json"
        },
        {
          "key": "Access-Control-Allow-Origin",
          "value": "*"
        }
      ]
    }
  ]
}
```

---

## ✅ STEP 5: Deploy to Vercel

### Option A: Using Vercel CLI
```bash
cd your-nextjs-project
vercel --prod
```

### Option B: Using Git (Recommended)
1. Commit your changes:
```bash
git add .
git commit -m "Add deep linking support"
git push
```

2. Vercel will automatically deploy

---

## ✅ STEP 6: Test Everything

### Test 1: Landing Page
Visit:
```
https://collabnotes.hostspica.com/note/test123
```

**Expected:** Landing page with "Open in CollabNotes"

### Test 2: Android Verification
Visit:
```
https://collabnotes.hostspica.com/.well-known/assetlinks.json
```

**Expected:** JSON with your package name and SHA-256

### Test 3: iOS Verification
Visit:
```
https://collabnotes.hostspica.com/.well-known/apple-app-site-association
```

**Expected:** JSON with applinks configuration

### Test 4: On Mobile Device
1. Open browser on Android device
2. Visit: `https://collabnotes.hostspica.com/note/test123`
3. Should open app automatically or show landing page

---

## 📁 Complete File Structure

Your Next.js project should look like this:

```
your-nextjs-project/
├── app/
│   ├── note/
│   │   └── [noteId]/
│   │       ├── page.tsx          ← Landing page component
│   │       └── layout.tsx        ← Metadata (optional)
│   ├── layout.tsx
│   └── page.tsx
├── public/
│   └── .well-known/
│       ├── assetlinks.json       ← Android verification
│       └── apple-app-site-association  ← iOS verification
├── vercel.json                   ← Headers config (optional)
├── package.json
└── next.config.js
```

---

## 🎨 Alternative: Using Tailwind CSS

If you're already using Tailwind CSS, the component above will work perfectly.

If not, you can either:
1. Install Tailwind CSS
2. Or use inline styles (I can provide that version if needed)

---

## 🐛 Troubleshooting

### Problem: 404 on landing page

**Solution:**
- Make sure the file is at `app/note/[noteId]/page.tsx`
- Redeploy to Vercel
- Check Vercel deployment logs

### Problem: .well-known files not accessible

**Solution:**
- Ensure files are in `public/.well-known/`
- Check file names are exact (no .json extension for apple-app-site-association)
- Redeploy to Vercel
- Wait a few minutes for CDN to update

### Problem: Styling not working

**Solution:**
If Tailwind isn't configured, use this inline-styled version instead:

```typescript
// I can provide an inline-styled version if needed
```

---

## ✅ Quick Checklist

- [ ] SHA-256 fingerprint obtained
- [ ] `assetlinks.json` updated with SHA-256
- [ ] Files copied to Next.js project:
  - [ ] `public/.well-known/assetlinks.json`
  - [ ] `public/.well-known/apple-app-site-association`
  - [ ] `app/note/[noteId]/page.tsx`
- [ ] Deployed to Vercel
- [ ] Landing page works: `/note/test123` ✓
- [ ] `.well-known/assetlinks.json` accessible ✓
- [ ] `.well-known/apple-app-site-association` accessible ✓
- [ ] Tested on mobile device ✓

---

## 🚀 Deployment Commands

```bash
# Navigate to your Next.js project
cd path/to/your-nextjs-project

# Install dependencies (if needed)
npm install

# Test locally
npm run dev
# Visit: http://localhost:3000/note/test123

# Deploy to Vercel
vercel --prod
```

---

## 📝 Important Notes

- ✅ Vercel automatically handles routing for `[noteId]` dynamic routes
- ✅ Files in `public/` are served at the root URL
- ✅ No need for `.htaccess` or nginx config
- ✅ Vercel's CDN handles everything automatically
- ⏰ Wait 24 hours for Android to cache verification

---

## 🎉 You're Done When...

1. ✅ `https://collabnotes.hostspica.com/note/test123` shows landing page
2. ✅ `.well-known` files are accessible
3. ✅ App opens automatically on mobile (or shows landing page)
4. ✅ Users can collaborate in real-time

---

## 💡 Pro Tips

1. **Test locally first:**
   ```bash
   npm run dev
   # Visit: http://localhost:3000/note/test123
   ```

2. **Check Vercel deployment:**
   - Go to Vercel dashboard
   - Check deployment logs
   - Verify all files are included

3. **Monitor with Vercel Analytics:**
   - Enable Vercel Analytics to track page views
   - Monitor how many users click share links

---

## 🆘 Need Help?

If you encounter issues:

1. **Check Vercel logs:**
   ```bash
   vercel logs
   ```

2. **Test .well-known files:**
   ```bash
   curl https://collabnotes.hostspica.com/.well-known/assetlinks.json
   ```

3. **Verify deployment:**
   - Check Vercel dashboard
   - Look for build errors
   - Verify domain is connected

---

**Start with Step 1 and work through each step. Total time: ~20 minutes! 🚀**
