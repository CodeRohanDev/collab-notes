# Guest Mode & Onboarding Guide

## 🎉 New Features Added

### 1. Splash Screen
- Beautiful animated splash screen on app launch
- Shows app logo and name with smooth animations
- 2-second display duration

### 2. Onboarding Flow
- 4-screen onboarding experience for first-time users
- Explains key features:
  - Create notes anywhere
  - Works offline
  - Sync across devices
  - Collaborate in real-time
- Skip button to jump directly to app
- Smooth page indicators
- Only shows once (stored in preferences)

### 3. Guest Mode
- **Start using immediately** without signing in
- All notes saved locally on device
- Full offline functionality
- No cloud sync in guest mode
- Persistent guest session

### 4. Sign In Later
- Guest users can sign in anytime
- Banner notification in guest mode
- Menu option to sign in
- Automatic data migration when signing in

## 🔄 User Flow

### First Time User
```
App Launch
    ↓
Splash Screen (2s)
    ↓
Onboarding (4 screens)
    ↓
Welcome Screen
    ↓
Choose: Sign In OR Continue as Guest
    ↓
Home Screen
```

### Returning User
```
App Launch
    ↓
Splash Screen (2s)
    ↓
Home Screen (auto-login or guest mode)
```

## 📱 Guest Mode Features

### What Works in Guest Mode
✅ Create notes
✅ Edit notes
✅ Delete notes
✅ Offline storage
✅ Full app functionality
✅ Fast and private

### What Doesn't Work in Guest Mode
❌ Cloud sync
❌ Cross-device access
❌ Collaboration
❌ Backup to cloud

## 🔐 Sign In Benefits

When a guest user signs in:
1. **Data Migration**: All guest notes automatically transferred
2. **Cloud Sync**: Notes backed up to Firestore
3. **Cross-Device**: Access notes on any device
4. **Collaboration**: Share notes with others
5. **Backup**: Never lose your notes

## 💾 Data Migration Process

When guest signs in with Google:
```
1. User taps "Sign In" in guest mode
2. Google authentication completes
3. System detects guest notes exist
4. All guest notes migrated to user account
5. Notes synced to Firestore
6. Guest data cleared
7. User now has full account
```

## 🎨 UI Indicators

### Guest Mode Banner
- Orange banner at top of home screen
- Shows "Guest mode: Sign in to sync your notes"
- Quick "Sign In" button
- Dismissible after sign-in

### Menu Options
**Guest Mode:**
- ☁️ Sign in to Sync
- 🚪 Logout

**Signed In:**
- 🔄 Sync
- 🚪 Logout

### Sync Status
- **Guest Mode**: No sync indicators (local only)
- **Signed In**: Orange sync icon for pending notes

## 🛠️ Technical Implementation

### New Files Created
```
lib/presentation/screens/
├── splash/
│   └── splash_screen.dart          # Animated splash screen
├── onboarding/
│   └── onboarding_screen.dart      # Onboarding flow
└── auth/
    └── welcome_screen.dart         # Sign in or guest choice

lib/core/
├── constants/
│   └── onboarding_data.dart        # Onboarding content
└── services/
    └── preferences_service.dart     # User preferences storage
```

### Updated Files
```
lib/main.dart                        # Added splash & onboarding logic
lib/presentation/bloc/auth/
├── auth_bloc.dart                   # Guest mode support
├── auth_event.dart                  # Guest events
└── auth_state.dart                  # Guest state
lib/presentation/screens/home/
└── home_screen.dart                 # Guest mode UI
lib/data/repositories/
└── notes_repository.dart            # Data migration
```

### New Dependencies
```yaml
shared_preferences: ^2.3.5          # Store preferences
smooth_page_indicator: ^1.2.0+3     # Onboarding indicators
```

## 🧪 Testing Guest Mode

### Test Scenario 1: New Guest User
1. Launch app (first time)
2. See splash screen
3. Go through onboarding
4. Tap "Continue as Guest"
5. Create notes
6. Close and reopen app
7. Notes should persist

### Test Scenario 2: Guest to Signed In
1. Start as guest
2. Create 3-5 notes
3. Tap "Sign In" button
4. Complete Google sign-in
5. Verify all notes still visible
6. Check Firestore - notes should be synced
7. Close app and reopen
8. Should auto-login (no longer guest)

### Test Scenario 3: Skip Onboarding
1. Fresh install
2. See splash screen
3. Tap "Skip" on onboarding
4. Should go to welcome screen
5. Onboarding won't show again

## 🔧 Configuration

### Reset Onboarding
To show onboarding again (for testing):
```dart
// In preferences_service.dart or manually
await _prefs.remove('onboarding_complete');
```

### Clear Guest Data
```dart
await preferencesService.clearGuestData();
```

### Check Guest Status
```dart
bool isGuest = preferencesService.isGuestMode;
String? guestId = preferencesService.guestUserId;
```

## 📊 User Preferences Stored

```
SharedPreferences Keys:
- onboarding_complete: bool    # Has user seen onboarding?
- guest_mode: bool             # Is user in guest mode?
- guest_user_id: String        # Guest user's unique ID
```

## 🎯 Best Practices

### For Users
1. **Try guest mode first** - No commitment needed
2. **Sign in when ready** - Your notes will be safe
3. **Don't worry about data loss** - Migration is automatic

### For Developers
1. **Always check guest status** before cloud operations
2. **Handle migration gracefully** - Show progress if needed
3. **Test both modes** - Guest and authenticated
4. **Clear guest data** after successful migration

## 🚀 Future Enhancements

### Planned Features
- [ ] Migration progress indicator
- [ ] Guest mode limitations dialog
- [ ] Prompt to sign in after X notes
- [ ] Export guest notes before sign-in
- [ ] Guest mode analytics
- [ ] Custom onboarding based on user type

## 📝 Code Examples

### Check if User is Guest
```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthAuthenticated && state.isGuest) {
      // Show guest-specific UI
    }
  },
)
```

### Trigger Sign In from Guest Mode
```dart
context.read<AuthBloc>().add(AuthSignInWithGoogleRequested());
```

### Continue as Guest
```dart
context.read<AuthBloc>().add(AuthContinueAsGuestRequested());
```

## ✅ Verification Checklist

- [x] Splash screen displays correctly
- [x] Onboarding shows on first launch
- [x] Onboarding can be skipped
- [x] Guest mode works offline
- [x] Guest notes persist
- [x] Sign-in option visible in guest mode
- [x] Data migration works
- [x] No data loss during migration
- [x] Guest banner shows correctly
- [x] Sync disabled in guest mode

## 🎉 Summary

Your app now supports:
- ✅ Beautiful splash screen
- ✅ Informative onboarding
- ✅ Instant guest access
- ✅ Sign in anytime
- ✅ Automatic data migration
- ✅ Seamless user experience

Users can start using the app immediately without any barriers, and upgrade to full features when they're ready!
