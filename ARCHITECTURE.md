# CollabNotes Architecture

## Overview

CollabNotes follows a clean architecture pattern with clear separation of concerns, using BLoC for state management and an offline-first approach for data persistence.

## Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Screens, Widgets, BLoC)          │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│     (Business Logic, Use Cases)         │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│           Data Layer                    │
│  (Repositories, Models, Data Sources)   │
└─────────────────────────────────────────┘
                  ↓
┌──────────────────┬──────────────────────┐
│  Local Storage   │   Remote Storage     │
│     (Hive)       │    (Firebase)        │
└──────────────────┴──────────────────────┘
```

## Layer Details

### 1. Presentation Layer

**Location**: `lib/presentation/`

**Components**:
- **Screens**: UI pages (Login, Home, Note Editor)
- **BLoC**: State management (AuthBloc, NotesBloc)
- **Widgets**: Reusable UI components

**Responsibilities**:
- Display data to users
- Handle user interactions
- Emit events to BLoC
- React to state changes

**Key Files**:
```
presentation/
├── bloc/
│   ├── auth/
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   └── notes/
│       ├── notes_bloc.dart
│       ├── notes_event.dart
│       └── notes_state.dart
└── screens/
    ├── auth/login_screen.dart
    ├── home/home_screen.dart
    └── notes/note_editor_screen.dart
```

### 2. Data Layer

**Location**: `lib/data/`

**Components**:
- **Models**: Data structures (NoteModel, UserModel)
- **Repositories**: Data access abstraction
- **Data Sources**: Local (Hive) and Remote (Firebase)

**Responsibilities**:
- Manage data persistence
- Handle sync logic
- Abstract data sources from business logic

**Key Files**:
```
data/
├── models/
│   ├── note_model.dart
│   ├── note_model.g.dart (generated)
│   ├── user_model.dart
│   └── user_model.g.dart (generated)
└── repositories/
    ├── auth_repository.dart
    └── notes_repository.dart
```

### 3. Core Layer

**Location**: `lib/core/`

**Components**:
- **Constants**: App-wide constants
- **Utils**: Utility classes and helpers

**Key Files**:
```
core/
├── constants/
│   └── app_constants.dart
└── utils/
    └── connectivity_service.dart
```

## Data Flow

### Creating a Note (Offline-First)

```
User Action (Tap Create)
        ↓
NotesCreateRequested Event
        ↓
NotesBloc processes event
        ↓
Create NoteModel with syncStatus='pending'
        ↓
NotesRepository.saveNoteLocally()
        ↓
Save to Hive (Local Storage)
        ↓
Emit NotesLoaded State
        ↓
UI Updates
        ↓
NotesSyncRequested Event (automatic)
        ↓
NotesRepository.syncNoteToCloud()
        ↓
Upload to Firestore
        ↓
Update syncStatus='completed'
        ↓
Save updated note to Hive
        ↓
Emit NotesLoaded State
        ↓
UI Updates (sync indicator removed)
```

### Authentication Flow

```
User Action (Tap Google Sign-In)
        ↓
AuthSignInWithGoogleRequested Event
        ↓
AuthBloc emits AuthLoading
        ↓
AuthRepository.signInWithGoogle()
        ↓
Google Sign-In SDK
        ↓
Firebase Authentication
        ↓
Create/Update User in Firestore
        ↓
Return UserModel
        ↓
AuthBloc emits AuthAuthenticated
        ↓
UI navigates to HomeScreen
        ↓
NotesBloc initialized with userId
        ↓
Load notes from local storage
```

## State Management (BLoC Pattern)

### Why BLoC?

- **Separation of Concerns**: Business logic separated from UI
- **Testability**: Easy to test business logic independently
- **Predictability**: Clear state transitions
- **Scalability**: Easy to add new features

### BLoC Flow

```
UI Widget
   ↓ (user action)
Event
   ↓
BLoC
   ↓ (processes event)
State
   ↓
UI Widget (rebuilds)
```

### Example: Notes BLoC

**Events**:
- `NotesLoadRequested`: Load all notes
- `NotesCreateRequested`: Create new note
- `NotesUpdateRequested`: Update existing note
- `NotesDeleteRequested`: Delete note
- `NotesSyncRequested`: Sync pending notes

**States**:
- `NotesInitial`: Initial state
- `NotesLoading`: Loading notes
- `NotesLoaded`: Notes loaded successfully
- `NotesError`: Error occurred

## Offline-First Strategy

### Local Storage (Hive)

**Why Hive?**
- Fast (pure Dart, no native dependencies)
- Lightweight
- Type-safe with code generation
- Works on all platforms

**Data Models**:
```dart
@HiveType(typeId: 0)
class NoteModel {
  @HiveField(0) final String id;
  @HiveField(1) final String title;
  @HiveField(2) final String content;
  @HiveField(10) final String syncStatus;
  // ... other fields
}
```

### Sync Mechanism

**Sync Status Values**:
- `pending`: Note needs to be synced
- `completed`: Note is synced
- `failed`: Sync failed (will retry)

**Sync Process**:
1. Save all changes locally first
2. Mark note as `pending`
3. When online, sync to Firestore
4. Update status to `completed`
5. If sync fails, mark as `failed` and retry later

### Conflict Resolution (Future Enhancement)

**Strategies**:
- **Last Write Wins**: Simple, current implementation
- **Operational Transform**: For real-time collaboration
- **CRDTs**: For complex merging scenarios

## Firebase Integration

### Firestore Structure

```
users/
  {userId}/
    - email
    - displayName
    - photoUrl
    - createdAt

notes/
  {noteId}/
    - id
    - title
    - content
    - ownerId
    - collaborators[]
    - tags[]
    - isPrivate
    - workspaceId
    - createdAt
    - updatedAt
    
    revisions/
      {revisionId}/
        - content
        - timestamp
        - userId
    
    comments/
      {commentId}/
        - text
        - authorId
        - createdAt

workspaces/
  {workspaceId}/
    - name
    - members[]
    - createdAt
```

### Security Rules

**Principle**: Users can only access their own notes or notes shared with them

**Key Rules**:
- Read: Owner or collaborator
- Create: Authenticated users
- Update: Owner or collaborator
- Delete: Owner only

## Connectivity Handling

**ConnectivityService**:
- Monitors network status
- Broadcasts connectivity changes
- Used by repositories to trigger sync

**Flow**:
```
Network Status Change
        ↓
ConnectivityService detects
        ↓
Broadcast to listeners
        ↓
NotesRepository receives update
        ↓
If online: Trigger sync
        ↓
Sync all pending notes
```

## Testing Strategy (Future)

### Unit Tests
- BLoC logic
- Repository methods
- Model serialization

### Widget Tests
- Screen rendering
- User interactions
- State changes

### Integration Tests
- End-to-end flows
- Offline/online transitions
- Sync mechanisms

## Performance Considerations

### Optimizations
- Lazy loading of notes
- Pagination for large datasets
- Debouncing text input
- Efficient Hive queries
- Firestore query optimization

### Memory Management
- Dispose controllers properly
- Close streams
- Clear caches when needed

## Security

### Local Storage
- Hive data encrypted (future enhancement)
- Secure key storage

### Firebase
- Authentication required for all operations
- Security rules enforce access control
- HTTPS for all communications

## Scalability

### Current Limitations
- All notes loaded at once
- No pagination
- Simple conflict resolution

### Future Enhancements
- Pagination and lazy loading
- Advanced conflict resolution
- Caching strategies
- Background sync
- Push notifications

## Dependencies

### Core
- `flutter_bloc`: State management
- `hive`: Local storage
- `equatable`: Value equality

### Firebase
- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `firebase_storage`: File storage
- `google_sign_in`: Google authentication

### Utilities
- `connectivity_plus`: Network monitoring
- `uuid`: Unique ID generation
- `intl`: Internationalization

## Development Workflow

1. **Feature Development**
   - Create/update models
   - Implement repository methods
   - Create BLoC events/states
   - Build UI screens
   - Test functionality

2. **Code Generation**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Testing**
   - Unit tests for BLoC
   - Widget tests for UI
   - Integration tests for flows

4. **Deployment**
   - Update Firebase rules
   - Build and release

## Future Architecture Improvements

1. **Use Cases Layer**
   - Add explicit use case classes
   - Better separation of business logic

2. **Dependency Injection**
   - Use get_it or injectable
   - Better testability

3. **Error Handling**
   - Centralized error handling
   - User-friendly error messages

4. **Logging**
   - Structured logging
   - Analytics integration

5. **Caching**
   - Multi-level caching
   - Cache invalidation strategies
