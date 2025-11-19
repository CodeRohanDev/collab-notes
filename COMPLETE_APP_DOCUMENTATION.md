# CollabNotes - Complete App Documentation

## 📱 App Overview

**CollabNotes** is a modern, feature-rich note-taking application built with Flutter that combines the simplicity of local storage with the power of cloud synchronization. It offers a seamless experience for both guest users and authenticated users.

### Key Highlights
- **Offline-First Architecture**: Works perfectly without internet
- **Flexible Sync**: Choose which notes to sync to cloud
- **Rich Text Editing**: Full-featured text formatting
- **Guest Mode**: Start using immediately without sign-in
- **Collaboration**: Share notes and add comments
- **Modern UI**: Beautiful Material Design with gradients

---

## 🎯 Core Features

### 1. Authentication System

#### Guest Mode
- **Instant Access**: No sign-up required
- **Persistent Storage**: Notes saved locally with Hive
- **Unique Guest ID**: Automatically generated and persisted
- **Seamless Migration**: Guest notes preserved when signing in

#### Google Sign-In
- **One-Tap Login**: Quick authentication with Google
- **Data Migration**: Automatic transfer of guest notes
- **Cloud Sync**: Access notes across devices
- **Secure**: Firebase Authentication

### 2. Note Management

#### Rich Text Editor
- **Formatting Options**:
  - Bold, Italic, Underline, Strikethrough
  - Bullet lists, Numbered lists, Checklists
  - Code blocks, Inline code
  - Links
  - Undo/Redo
- **Click-to-Type**: Tap anywhere in editor to start typing
- **Word Count**: Real-time character and word counter
- **Auto-Save**: Changes saved automatically on exit

#### Note Organization
- **Pin Notes**: Keep important notes at the top
- **Archive**: Hide notes without deleting
- **Favorites**: Mark notes for quick access
- **Color Coding**: 13 color options for visual organization
- **Tags**: Add multiple tags for categorization
- **Search**: Find notes by title, content, or tags

#### Sync Options
- **Selective Sync**: Choose which notes to sync to cloud
- **Local-Only**: Keep sensitive notes on device
- **Cloud Sync**: Access from any device
- **Visual Indicators**:
  - 🔵 Cloud badge - Synced to cloud
  - 📱 Local badge - Device only
  - 🔄 Syncing badge - Currently syncing

### 3. Collaboration Features

#### Note Sharing
- **Share by Email**: Add collaborators via email
- **Real-time Updates**: Changes sync instantly
- **Access Control**: Owner can manage collaborators

#### Comments System
- **Threaded Comments**: Discuss notes with collaborators
- **Real-time**: Comments appear instantly
- **User Attribution**: See who commented and when

### 4. User Interface

#### Home Screen
- **Grid/List View**: Toggle between layouts
- **Quick Stats**: Total notes and today's activity
- **Search Bar**: Fast note discovery
- **Floating Action Button**: Quick note creation

#### Note Cards
- **Preview**: See title, content snippet, and tags
- **Status Indicators**: Pin, favorite, sync status
- **Quick Actions**: Long-press for options menu
- **Color Borders**: Visual organization

#### Bottom Sheets
- **Note Options**:
  - Color picker (13 colors)
  - Tag management
  - Pin/Unpin
  - Archive/Unarchive
  - Sync toggle
  - Delete
- **Smooth Animations**: Polished user experience

---

## 🏗️ Technical Architecture

### Technology Stack

#### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: BLoC (Business Logic Component)
- **UI Components**: Material Design 3

#### Backend & Storage
- **Local Database**: Hive (NoSQL)
- **Cloud Backend**: Firebase
  - Authentication
  - Firestore (Database)
  - Cloud Storage
- **Rich Text**: flutter_quill

#### Key Dependencies
```yaml
dependencies:
  flutter_bloc: ^8.1.6
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  google_sign_in: ^6.2.1
  flutter_quill: ^10.8.6
  iconsax: ^0.0.8
  equatable: ^2.0.5
  uuid: ^4.5.1
```

### Architecture Pattern

#### Clean Architecture Layers

```
lib/
├── core/                    # Core utilities
│   ├── constants/          # App constants
│   ├── services/           # Shared services
│   └── theme/              # App theming
├── data/                   # Data layer
│   ├── models/            # Data models
│   └── repositories/      # Data repositories
└── presentation/          # Presentation layer
    ├── bloc/             # Business logic
    ├── screens/          # UI screens
    └── widgets/          # Reusable widgets
```

#### BLoC Pattern
- **Separation of Concerns**: UI separated from business logic
- **Reactive**: Stream-based state management
- **Testable**: Easy to unit test
- **Predictable**: Clear state transitions

### Data Flow

```
User Action → Event → BLoC → Repository → Data Source
                ↓
            State Update
                ↓
            UI Rebuild
```

#### Example: Creating a Note
1. User taps save button
2. `NotesCreateRequested` event dispatched
3. `NotesBloc` processes event
4. `NotesRepository` saves to Hive
5. `NotesLoaded` state emitted
6. UI updates with new note

### Storage Strategy

#### Local Storage (Hive)
- **Primary Storage**: All notes stored locally first
- **Fast Access**: In-memory caching
- **Offline Support**: Full functionality without internet
- **Type Adapters**: Custom serialization for models

#### Cloud Storage (Firestore)
- **Optional Sync**: Per-note sync control
- **Real-time**: Live updates for shared notes
- **Conflict Resolution**: Last-write-wins strategy
- **Security Rules**: Server-side validation

#### Sync Logic
```dart
// Notes are merged, not replaced
Cloud Notes + Local-Only Notes = All Notes
```

---

## 📊 Data Models

### NoteModel
```dart
class NoteModel {
  final String id;              // UUID
  final String title;           // Note title
  final String content;         // Quill JSON format
  final String ownerId;         // User ID
  final DateTime createdAt;     // Creation timestamp
  final DateTime updatedAt;     // Last modified
  final List<String> collaborators;  // Email list
  final List<String> tags;      // Tag list
  final bool isPrivate;         // Privacy flag
  final String? workspaceId;    // Future feature
  final String syncStatus;      // pending/completed/failed
  final bool isPinned;          // Pin status
  final bool isArchived;        // Archive status
  final String? color;          // Hex color code
  final List<String> attachments;  // Future feature
  final String? reminder;       // Future feature
  final bool isFavorite;        // Favorite status
  final String noteType;        // note/todo/checklist
  final List<Map> checklistItems;  // Checklist data
  final bool isSyncEnabled;     // Sync toggle
}
```

### UserModel
```dart
class UserModel {
  final String id;              // Firebase UID or Guest ID
  final String email;           // User email
  final String displayName;     // Display name
  final String? photoUrl;       // Profile picture
  final DateTime createdAt;     // Account creation
}
```

---

## 🔐 Security & Privacy

### Authentication
- **Firebase Auth**: Industry-standard security
- **OAuth 2.0**: Secure Google Sign-In
- **Guest Mode**: No personal data collected

### Data Protection
- **Local Encryption**: Hive supports encryption
- **HTTPS**: All network traffic encrypted
- **ProGuard**: Code obfuscation in release builds
- **No Tracking**: No analytics or tracking

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{noteId} {
      // Owner can read/write
      allow read, write: if request.auth != null && 
        resource.data.ownerId == request.auth.uid;
      
      // Collaborators can read/write
      allow read, write: if request.auth != null && 
        request.auth.token.email in resource.data.collaborators;
    }
  }
}
```

### Privacy Features
- **Local-Only Notes**: Never leave device
- **Selective Sync**: User controls what syncs
- **Guest Mode**: Anonymous usage
- **Data Deletion**: Complete removal on request

---

## 🎨 Design System

### Color Palette

#### Primary Colors
- **Primary**: `#6366F1` (Indigo)
- **Secondary**: `#8B5CF6` (Purple)
- **Accent**: `#EC4899` (Pink)

#### Semantic Colors
- **Success**: `#10B981` (Green)
- **Warning**: `#F59E0B` (Amber)
- **Error**: `#EF4444` (Red)
- **Info**: `#3B82F6` (Blue)

#### Note Colors (13 options)
- Red, Pink, Purple, Indigo, Blue
- Teal, Green, Yellow, Orange
- Brown, Gray, Grey, None

### Typography
- **Headlines**: Bold, 24-28px
- **Titles**: Semi-bold, 18-20px
- **Body**: Regular, 14-16px
- **Captions**: Regular, 12px

### Spacing System
- **XS**: 4px
- **SM**: 8px
- **MD**: 16px
- **LG**: 24px
- **XL**: 32px

### Components

#### Buttons
- **Primary**: Gradient background, white text
- **Secondary**: Outlined, colored text
- **Text**: No background, colored text

#### Cards
- **Elevation**: 2-4dp shadow
- **Radius**: 12-16px
- **Padding**: 16px

#### Bottom Sheets
- **Radius**: 24px top corners
- **Handle**: 40x4px gray bar
- **Padding**: 20px

---

## 🚀 Performance Optimizations

### App Performance
- **Lazy Loading**: Notes loaded on demand
- **Image Optimization**: Cached and compressed
- **Tree Shaking**: Unused code removed
- **Code Splitting**: Modular architecture

### Build Optimizations
- **ProGuard**: Code shrinking and obfuscation
- **R8**: Advanced optimization
- **APK Size**: ~57MB (includes all features)
- **Startup Time**: < 3 seconds

### Database Performance
- **Indexing**: Fast queries with Hive
- **Caching**: In-memory cache for frequent access
- **Batch Operations**: Efficient bulk updates
- **Pagination**: Future feature for large datasets

---

## 📱 Platform Support

### Android
- **Minimum SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: 34 (Android 14)
- **Architecture**: ARM, ARM64, x86_64
- **Size**: 57.5 MB (release APK)

### Future Platforms
- **iOS**: Planned
- **Web**: Planned
- **Desktop**: Possible with Flutter

---

## 🔄 App Lifecycle

### First Launch
1. Splash screen (2 seconds)
2. Onboarding (skippable)
3. Welcome screen
4. Choose: Guest Mode or Sign In

### Guest User Flow
1. Tap "Continue as Guest"
2. Generate unique guest ID
3. Save to SharedPreferences
4. Navigate to Home Screen
5. Create notes (stored locally)

### Sign-In Flow
1. Tap "Sign in with Google"
2. Google OAuth flow
3. Firebase authentication
4. Migrate guest notes (if any)
5. Enable cloud sync
6. Navigate to Home Screen

### Note Creation Flow
1. Tap FAB (Floating Action Button)
2. Open Rich Editor
3. Enter title and content
4. Format text (optional)
5. Tap back or save button
6. Auto-save to local storage
7. Sync to cloud (if enabled)

### Sync Flow
1. User enables sync for note
2. Note marked as `syncPending`
3. Upload to Firestore
4. Update sync status to `completed`
5. Show "Cloud" badge on note

---

## 🧪 Testing Strategy

### Unit Tests
- BLoC logic testing
- Repository testing
- Model serialization
- Utility functions

### Widget Tests
- UI component testing
- User interaction testing
- State management testing

### Integration Tests
- End-to-end flows
- Authentication testing
- Sync testing
- Offline scenarios

### Manual Testing Checklist
- [ ] Guest mode works
- [ ] Google Sign-In works
- [ ] Note CRUD operations
- [ ] Rich text formatting
- [ ] Sync toggle
- [ ] Offline functionality
- [ ] Search functionality
- [ ] Archive/Pin/Favorite
- [ ] Color and tags
- [ ] Comments system

---

## 🐛 Known Limitations

### Current Limitations
1. **Single Device for Guests**: Guest notes don't sync
2. **No Image Support**: Text-only notes
3. **No Voice Notes**: Future feature
4. **No Folders**: Flat structure with tags
5. **No Export**: Can't export to PDF/Word

### Future Enhancements
- [ ] Image attachments
- [ ] Voice notes
- [ ] Folder organization
- [ ] Export to PDF/Word
- [ ] Dark mode
- [ ] Widgets
- [ ] Reminders
- [ ] Templates
- [ ] Handwriting support
- [ ] OCR for images

---

## 📈 Analytics & Monitoring

### Firebase Analytics (Optional)
- User engagement metrics
- Feature usage tracking
- Crash reporting
- Performance monitoring

### Crashlytics
- Real-time crash reporting
- Stack traces
- User impact analysis
- Version tracking

---

## 🔧 Configuration Files

### pubspec.yaml
```yaml
name: collabnotes
description: A collaborative note-taking app
version: 1.0.0+1

environment:
  sdk: '>=3.5.4 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5
  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  # UI
  flutter_quill: ^10.8.6
  iconsax: ^0.0.8
  # Utilities
  uuid: ^4.5.1
  intl: ^0.19.0
```

### AndroidManifest.xml
```xml
<manifest>
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
  
  <application
    android:label="CollabNotes"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
    <!-- Activities -->
  </application>
</manifest>
```

---

## 📚 API Reference

### NotesBloc Events

```dart
// Load all notes
NotesLoadRequested()

// Create new note
NotesCreateRequested(title, content)

// Update existing note
NotesUpdateRequested(noteId, title, content)

// Delete note
NotesDeleteRequested(noteId)

// Toggle pin
NotesTogglePinRequested(noteId)

// Toggle archive
NotesToggleArchiveRequested(noteId)

// Toggle favorite
NotesToggleFavoriteRequested(noteId)

// Update color
NotesUpdateColorRequested(noteId, color)

// Add tag
NotesAddTagRequested(noteId, tag)

// Remove tag
NotesRemoveTagRequested(noteId, tag)

// Toggle sync
NotesToggleSyncRequested(noteId, enableSync)

// Start realtime sync
NotesStartRealtimeSync()

// Stop realtime sync
NotesStopRealtimeSync()
```

### NotesBloc States

```dart
// Initial state
NotesInitial()

// Loading state
NotesLoading()

// Success state with notes
NotesLoaded(notes: List<NoteModel>)

// Error state
NotesError(message: String)
```

### NotesRepository Methods

```dart
// Local operations
Future<void> saveNoteLocally(NoteModel note)
Future<void> deleteNoteLocally(String noteId)
List<NoteModel> getAllLocalNotes()
NoteModel? getNoteById(String noteId)

// Cloud operations
Future<void> syncNoteToCloud(NoteModel note)
Future<void> enableSyncForNote(String noteId)
Future<void> disableSyncForNote(String noteId)
Future<void> deleteNoteFromCloud(String noteId)

// Collaboration
Future<void> addCollaborator(String noteId, String email)
Future<void> removeCollaborator(String noteId, String email)

// Streams
Stream<List<NoteModel>> watchUserNotes(String userId)
Stream<List<NoteModel>> watchSharedNotes(String userId)
Stream<NoteModel?> watchNote(String noteId)
```

---

## 🎓 User Guide

### Getting Started

#### For New Users
1. **Download & Install**: Get from Play Store
2. **Choose Mode**: Guest or Sign In
3. **Create First Note**: Tap the + button
4. **Explore Features**: Try formatting, colors, tags

#### For Existing Users
1. **Sign In**: Use Google account
2. **Access Notes**: All synced notes appear
3. **Manage Sync**: Toggle per note
4. **Collaborate**: Share with others

### Tips & Tricks

#### Productivity
- **Pin Important Notes**: Keep them at top
- **Use Tags**: Organize by project/category
- **Color Code**: Visual organization
- **Search**: Find notes quickly

#### Collaboration
- **Share Notes**: Add collaborators by email
- **Add Comments**: Discuss with team
- **Real-time Updates**: See changes instantly

#### Privacy
- **Local-Only**: Disable sync for sensitive notes
- **Guest Mode**: No account needed
- **Selective Sync**: Choose what to sync

---

## 🛠️ Troubleshooting

### Common Issues

#### Notes Not Syncing
**Solution**: Check internet connection and sync toggle

#### Can't Sign In
**Solution**: Verify Google account and internet

#### Notes Disappeared
**Solution**: Check archived notes section

#### App Crashes
**Solution**: Clear cache, reinstall app

### Error Messages

#### "Sync Failed"
- Check internet connection
- Verify Firebase configuration
- Check Firestore rules

#### "Authentication Error"
- Verify Google Sign-In setup
- Check SHA-1 fingerprint in Firebase
- Ensure google-services.json is present

---

## 📞 Support & Contact

### Getting Help
- **Documentation**: This file
- **Issues**: GitHub Issues (if open source)
- **Email**: support@collabnotes.com (example)

### Contributing
- **Bug Reports**: Detailed description with steps
- **Feature Requests**: Clear use case and benefits
- **Pull Requests**: Follow coding standards

---

## 📄 License & Credits

### License
Copyright © 2024 CollabNotes
All rights reserved.

### Third-Party Libraries
- Flutter by Google
- Firebase by Google
- flutter_quill by singerdmx
- Hive by isar
- Iconsax by treasure-orb

### Acknowledgments
- Material Design by Google
- Flutter community
- Open source contributors

---

## 🗺️ Roadmap

### Version 1.1 (Q1 2025)
- [ ] Dark mode
- [ ] Image attachments
- [ ] Export to PDF
- [ ] Note templates

### Version 1.2 (Q2 2025)
- [ ] Voice notes
- [ ] Handwriting support
- [ ] Folder organization
- [ ] Widgets

### Version 2.0 (Q3 2025)
- [ ] iOS release
- [ ] Web version
- [ ] Desktop apps
- [ ] Advanced collaboration

---

## 📊 App Statistics

### Current Version: 1.0.0+1
- **Release Date**: November 2024
- **APK Size**: 57.5 MB
- **Minimum Android**: 5.0 (API 21)
- **Target Android**: 14 (API 34)
- **Languages**: English
- **Platforms**: Android

### Features Count
- **Total Features**: 25+
- **Authentication Methods**: 2 (Guest, Google)
- **Note Actions**: 10+ (Create, Edit, Delete, etc.)
- **Formatting Options**: 10+ (Bold, Italic, etc.)
- **Organization Tools**: 5 (Pin, Archive, Favorite, Color, Tags)

---

**Last Updated**: November 2024
**Version**: 1.0.0
**Status**: Production Ready ✅
