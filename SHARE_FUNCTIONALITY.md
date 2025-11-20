# Share & Collaboration Functionality

## Overview
CollabNotes now supports sharing notes with other users through deep linking, allowing real-time collaboration on notes.

## 🚀 Quick Start
See `QUICK_SETUP_GUIDE.md` for a 5-step setup process to get deep linking working on your website.

## Features

### 1. Share Notes
- Users can share notes with collaborators via email
- Share links are generated using the format: `https://collabnotes.hostspica.com/note/{noteId}`
- Collaborators can be added directly from the share dialog

### 2. Deep Linking
- App handles deep links in the format: `https://collabnotes.hostspica.com/note/{noteId}`
- When a user clicks a share link:
  - If the app is installed, it opens directly to the shared note
  - User is automatically added as a collaborator
  - Note is synced to their local device

### 3. Collaboration
- Multiple users can work on the same note simultaneously
- Changes are synced in real-time through Firebase Firestore
- Collaborators can view and edit shared notes
- Owner can remove collaborators at any time

## Implementation Details

### Files Created/Modified

1. **lib/core/services/deep_link_service.dart**
   - Service for generating share links
   - Creates deep links with note IDs

2. **lib/core/services/deep_link_handler.dart**
   - Handles incoming deep links
   - Parses URLs and extracts note IDs

3. **lib/presentation/screens/notes/share_note_dialog.dart**
   - Updated to use the correct domain: `collabnotes.hostspica.com`
   - Shows share link and allows adding collaborators
   - Provides "Share via..." button to share through system share sheet

4. **lib/data/repositories/notes_repository.dart**
   - Added `fetchSharedNote()` method
   - Added `acceptCollaborationInvite()` method
   - Handles fetching and caching shared notes

5. **lib/presentation/bloc/notes/notes_bloc.dart**
   - Added `NotesFetchSharedNoteRequested` event
   - Added `NotesAcceptCollaborationRequested` event
   - Handlers for fetching and accepting shared notes

6. **android/app/src/main/AndroidManifest.xml**
   - Configured deep link handling for Android
   - Added intent filters for `collabnotes.hostspica.com`

## How to Use

### Sharing a Note

1. Open a note in the editor
2. Tap the share icon in the app bar
3. In the share dialog:
   - **Add Collaborator**: Enter email address and tap "Add"
   - **Share Link**: Copy the link or tap "Share via..." to share through other apps
4. Send the link to collaborators

### Accepting a Shared Note

1. Receive a share link (e.g., `https://collabnotes.hostspica.com/note/abc123`)
2. Click the link on your device
3. If CollabNotes is installed:
   - App opens automatically
   - Dialog asks to join collaboration
   - Tap "Open" to accept
4. Note is added to your notes list
5. You can now view and edit the shared note

## Technical Flow

```
User shares note
    ↓
Generate share link: https://collabnotes.hostspica.com/note/{noteId}
    ↓
Recipient clicks link
    ↓
Deep link handler catches the URL
    ↓
Extract noteId from URL
    ↓
Show collaboration dialog
    ↓
User accepts → NotesAcceptCollaborationRequested event
    ↓
Repository fetches note from Firestore
    ↓
Add user's email to collaborators array
    ↓
Save note locally
    ↓
Navigate to note editor
```

## Security

- Only authenticated users can share and collaborate
- Notes must have `isSyncEnabled = true` to be shared
- Access control:
  - Owner can add/remove collaborators
  - Collaborators can only access notes they're invited to
  - Private notes cannot be shared

## Dependencies

- **app_links**: ^6.4.1 - Handles deep linking on Android/iOS
- **share_plus**: ^10.1.2 - System share sheet integration
- **firebase_auth**: For user authentication
- **cloud_firestore**: For real-time note syncing

## Configuration

### Android
Deep linking is configured in `AndroidManifest.xml`:
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" />
    <data android:host="collabnotes.hostspica.com" />
    <data android:pathPrefix="/note" />
</intent-filter>
```

### iOS
For iOS, you'll need to configure Associated Domains in Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to "Signing & Capabilities"
4. Add "Associated Domains" capability
5. Add domain: `applinks:collabnotes.hostspica.com`

### Web Server
For deep linking to work properly, you need to host an `apple-app-site-association` file at:
`https://collabnotes.hostspica.com/.well-known/apple-app-site-association`

And an `assetlinks.json` file at:
`https://collabnotes.hostspica.com/.well-known/assetlinks.json`

## Testing

### Test Deep Links

**Android (ADB):**
```bash
adb shell am start -W -a android.intent.action.VIEW -d "https://collabnotes.hostspica.com/note/test123" com.hostspica.collabnotes
```

**iOS (Simulator):**
```bash
xcrun simctl openurl booted "https://collabnotes.hostspica.com/note/test123"
```

### Test Collaboration

1. Create a note on Device A
2. Share the note
3. Open the share link on Device B
4. Accept collaboration on Device B
5. Edit the note on Device B
6. Verify changes appear on Device A

## Web Integration

When users click share links in a browser, they need a landing page. See `WEB_INTEGRATION_GUIDE.md` for complete setup instructions.

**Quick Setup:**
1. Upload `web_integration/note-redirect.html` (or `note.php`) to your web server
2. Configure server to route `/note/*` requests to the landing page
3. Upload `.well-known/assetlinks.json` for Android
4. Upload `.well-known/apple-app-site-association` for iOS
5. Update SHA-256 fingerprint in `assetlinks.json`

The landing page will:
- Auto-detect mobile devices
- Try to open the app automatically
- Show "Download App" button if app is not installed
- Provide a smooth user experience

## Future Enhancements

- [ ] Real-time presence indicators (show who's currently viewing)
- [ ] Collaborative cursor positions
- [ ] Comment threads on specific sections
- [ ] Permission levels (view-only, edit, admin)
- [ ] Share expiration dates
- [ ] Revoke access to specific collaborators
- [ ] Activity log showing who made what changes
