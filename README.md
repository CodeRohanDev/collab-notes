# CollabNotes - Offline-First Collaborative Notes App

A Flutter-based notes application with offline-first architecture, real-time collaboration, and Google authentication.

## Features Implemented

### Core Features
- ✅ Offline-first note editing with local storage (Hive)
- ✅ Google Sign-In authentication
- ✅ Auto-sync to Firestore when online
- ✅ Create, read, update, and delete notes
- ✅ Sync status indicators
- ✅ Clean architecture with BLoC pattern

### Architecture
- **State Management**: flutter_bloc
- **Local Storage**: Hive (NoSQL database)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Connectivity**: Real-time network status monitoring

## Getting Started

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Firebase project configured
- Android Studio / VS Code

### Installation

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants
│   └── utils/              # Utilities (connectivity service)
├── data/
│   ├── models/             # Data models (Note, User)
│   └── repositories/       # Data repositories
├── presentation/
│   ├── bloc/               # BLoC state management
│   │   ├── auth/           # Authentication BLoC
│   │   └── notes/          # Notes BLoC
│   └── screens/            # UI screens
│       ├── auth/           # Login screen
│       ├── home/           # Home screen
│       └── notes/          # Note editor
├── firebase_options.dart   # Firebase configuration
└── main.dart               # App entry point
```

## How It Works

### Offline-First Architecture
1. All notes are saved locally first using Hive
2. Notes are marked with sync status (pending/completed/failed)
3. When online, pending notes automatically sync to Firestore
4. Real-time listeners update local storage with cloud changes

### Authentication Flow
1. User signs in with Google
2. User profile saved to Firestore
3. Notes are associated with user ID
4. Automatic session management

## Next Steps

To implement the full feature set from docs.md:

1. **Real-time Collaboration**
   - Add Firestore listeners for shared notes
   - Implement live cursors
   - Add comment threads

2. **Rich Text Editor**
   - Integrate flutter_quill for formatting
   - Add image/media support

3. **Workspaces**
   - Create workspace model
   - Implement sharing functionality

4. **AI Features** (Future)
   - AI summaries
   - Note generation
   - Quiz creation

## Firebase Setup

Make sure your Firebase project has:
- Authentication enabled (Google provider)
- Firestore database created
- Storage bucket configured
- Security rules properly set

## License

This project is private and not licensed for public use.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
