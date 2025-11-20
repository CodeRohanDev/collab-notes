# ⚡ Vercel + Next.js - Super Quick Start

## 3 Simple Steps to Fix the 404 Issue

---

## Step 1: Get SHA-256 Fingerprint (2 min)

In your **Flutter project** folder:

```bash
cd web_integration
get_sha256.bat
```

**Copy the SHA256 value** (looks like: `AA:BB:CC:DD:EE:...`)

---

## Step 2: Update & Copy Files (3 min)

### 2.1: Update SHA-256

1. Open: `web_integration/.well-known/assetlinks.json`
2. Replace `YOUR_SHA256_FINGERPRINT_HERE` with your SHA256
3. Save

### 2.2: Copy Files to Your Next.js Project

Copy these files from your Flutter project to your Next.js project:

```
FROM (Flutter project):
web_integration/.well-known/assetlinks.json
web_integration/.well-known/apple-app-site-association

TO (Next.js project):
your-nextjs-project/public/.well-known/
```

**Create the `.well-known` folder in `public/` if it doesn't exist**

---

## Step 3: Create the Note Page (5 min)

In your **Next.js project**, create this file:

**File:** `app/note/[noteId]/page.tsx`

**Choose ONE version:**

### Option A: With Tailwind CSS (if you have it)
Copy the code from: `VERCEL_NEXTJS_SETUP.md` (Step 3.2)

### Option B: Without Tailwind (inline styles)
Copy the code from: `web_integration/nextjs-note-page-inline-styles.tsx`

---

## Step 4: Deploy (2 min)

### If using Git (Recommended):
```bash
git add .
git commit -m "Add deep linking support"
git push
```
Vercel will auto-deploy!

### If using Vercel CLI:
```bash
vercel --prod
```

---

## Step 5: Test (2 min)

Visit these URLs:

1. **Landing page:**
   ```
   https://collabnotes.hostspica.com/note/test123
   ```
   Should show: "Open in CollabNotes" page

2. **Android config:**
   ```
   https://collabnotes.hostspica.com/.well-known/assetlinks.json
   ```
   Should show: JSON with your package name

3. **On mobile device:**
   - Open browser
   - Visit the landing page URL
   - Should open app or show "Open in App" button

---

## ✅ Done!

**Total time: ~15 minutes**

Your file structure should look like:

```
your-nextjs-project/
├── app/
│   └── note/
│       └── [noteId]/
│           └── page.tsx          ← You created this
├── public/
│   └── .well-known/
│       ├── assetlinks.json       ← You copied this
│       └── apple-app-site-association  ← You copied this
└── ...
```

---

## 🐛 Troubleshooting

**404 on landing page?**
- Check file is at `app/note/[noteId]/page.tsx`
- Redeploy to Vercel

**404 on .well-known files?**
- Check files are in `public/.well-known/`
- Wait 2-3 minutes for Vercel CDN to update
- Redeploy if needed

**App doesn't open?**
- Wait 24 hours for Android to cache verification
- Clear app data and reinstall
- Verify SHA-256 is correct

---

## 📚 Full Documentation

- **Complete Guide:** `VERCEL_NEXTJS_SETUP.md`
- **General Guide:** `FIX_404_ISSUE.md`
- **Features:** `SHARE_FUNCTIONALITY.md`

---

**That's it! Share links will now work! 🎉**
