# 🔧 Quick Integration Guide - Real-Time Collaboration

## What Was Implemented

I've created all the necessary files for real-time collaboration:

✅ **Models** - Presence data structure  
✅ **Services** - Real-time sync logic  
✅ **BLoC** - State management  
✅ **Widgets** - UI components  
✅ **Security** - Firestore rules  

---

## What You Need to Do

### Step 1: Deploy Firestore Rules (2 min)

```bash
firebase deploy --only firestore:rules
```

This adds support for the `/presence` subcollection.

---

### Step 2: Add CollaborationBloc to Main (5 min)

Open `lib/main.dart` and add the CollaborationBloc provider.

**Find this section:**
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (context) => AuthBloc(...),
    ),
    // Add here
  ],
)
```

**Add this:**
```dart
BlocProvider(
  create: (context) => CollaborationBloc(
    collaborationService: RealtimeCollaborationService(),
  ),
),
```

**Full import needed:**
```dart
import 'presentation/bloc/collaboration/collaboration_bloc.dart';
import 'core/services/realtime_collaboration_service.dart';
```

---

### Step 3: Update Rich Note Editor (15 min)

Open `lib/presentation/screens/notes/rich_note_editor_screen.dart`

#### 3.1: Add Imports

Add at the top:
```dart
import '../../bloc/collaboration/collaboration_bloc.dart';
import '../../widgets/presence_avatars.dart';
```

#### 3.2: Start Collaboration in initState

Add to `initState()`:
```dart
@override
void initState() {
  super.initState();
  
  // Existing code...
  _titleController = TextEditingController(text: widget.note?.title ?? '');
  // ... rest of existing code
  
  // NEW: Start collaboration if editing existing note
  if (widget.note != null && widget.note!.collaborators.isNotEmpty) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollaborationBloc>().add(
        CollaborationStartWatching(noteId: widget.note!.id),
      );
    });
    
    _setupCollaborationListeners();
  }
}
```

#### 3.3: Add Collaboration Listeners

Add this new method:
```dart
void _setupCollaborationListeners() {
  // Listen to remote changes
  context.read<CollaborationBloc>().stream.listen((state) {
    if (state is CollaborationWatching && state.remoteContent != null) {
      // Only update if content is different
      final currentContent = jsonEncode(_quillController.document.toDelta().toJson());
      if (currentContent != state.remoteContent) {
        _updateEditorFromRemote(state.remoteContent!);
      }
    }
  });
  
  // Send local changes (debounced)
  _quillController.addListener(() {
    if (widget.note != null && widget.note!.collaborators.isNotEmpty) {
      context.read<CollaborationBloc>().add(
        CollaborationSendChanges(
          content: jsonEncode(_quillController.document.toDelta().toJson()),
          title: _titleController.text,
        ),
      );
    }
  });
  
  // Track cursor position
  _quillController.addListener(() {
    if (widget.note != null && widget.note!.collaborators.isNotEmpty) {
      final selection = _quillController.selection;
      context.read<CollaborationBloc>().add(
        CollaborationUpdateCursor(
          cursorPosition: selection.baseOffset,
          selectionStart: selection.start,
          selectionEnd: selection.end,
        ),
      );
    }
  });
}

void _updateEditorFromRemote(String remoteContent) {
  try {
    final doc = quill.Document.fromJson(jsonDecode(remoteContent));
    
    // Save current selection
    final selection = _quillController.selection;
    
    // Update document
    _quillController.document = doc;
    
    // Restore selection if possible
    if (selection.isValid) {
      _quillController.updateSelection(selection, quill.ChangeSource.silent);
    }
  } catch (e) {
    print('Error updating from remote: $e');
  }
}
```

#### 3.4: Stop Collaboration in dispose

Update `dispose()`:
```dart
@override
void dispose() {
  // NEW: Stop collaboration
  if (widget.note != null && widget.note!.collaborators.isNotEmpty) {
    context.read<CollaborationBloc>().add(CollaborationStopWatching());
  }
  
  // Existing code...
  _titleController.dispose();
  _quillController.dispose();
  _titleFocusNode.dispose();
  _editorFocusNode.dispose();
  super.dispose();
}
```

#### 3.5: Add Presence Avatars to AppBar

Find the `AppBar` widget and update the `title`:

**Replace:**
```dart
title: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      widget.note == null ? 'New Note' : 'Edit Note',
      style: const TextStyle(...),
    ),
    if (_hasChanges)
      Text('Unsaved changes', ...),
  ],
),
```

**With:**
```dart
title: Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.note == null ? 'New Note' : 'Edit Note',
            style: const TextStyle(...),
          ),
          if (_hasChanges)
            Text('Unsaved changes', ...),
        ],
      ),
    ),
    // NEW: Show active collaborators
    if (widget.note != null && widget.note!.collaborators.isNotEmpty)
      BlocBuilder<CollaborationBloc, CollaborationState>(
        builder: (context, state) {
          if (state is CollaborationWatching && state.activeUsers.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: PresenceAvatars(
                activeUsers: state.activeUsers,
                maxVisible: 3,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
  ],
),
```

---

### Step 4: Test (5 min)

1. **Open note on Device A**
2. **Share note with User B**
3. **Open same note on Device B**
4. **Type on Device A** → Should appear on Device B
5. **Check presence avatars** → Should see each other

---

## 🎯 Expected Behavior

### When Working:

✅ **Real-Time Sync:**
- Type on Device A
- Changes appear on Device B within 1-2 seconds

✅ **Presence Indicators:**
- Open note on multiple devices
- See avatars of active users in app bar

✅ **Auto-Save:**
- Changes sync automatically
- No manual save needed

✅ **Conflict Resolution:**
- Both users can type
- Last edit wins

---

## 🐛 Troubleshooting

### Changes Not Syncing:

**Check:**
1. Both users are logged in (not guest mode)
2. Note has `isSyncEnabled = true`
3. Users are added as collaborators
4. Internet connection is active
5. Firestore rules are deployed

**Debug:**
```dart
// Add this to see what's happening
print('Sending changes: $content');
print('Received remote: ${state.remoteContent}');
```

### Presence Not Showing:

**Check:**
1. Firestore rules deployed
2. User is authenticated
3. Note has collaborators
4. Heartbeat is running

**Debug:**
```dart
// Check if collaboration started
if (state is CollaborationWatching) {
  print('Watching note: ${state.noteId}');
  print('Active users: ${state.activeUsers.length}');
}
```

### App Crashes:

**Common Issues:**
1. Missing import statements
2. BLoC not provided in widget tree
3. Null safety issues

**Fix:**
- Check all imports are added
- Verify CollaborationBloc is in MultiBlocProvider
- Add null checks where needed

---

## 📊 Performance Tips

### 1. Only Enable for Shared Notes:

```dart
// Only start collaboration if note has collaborators
if (widget.note != null && widget.note!.collaborators.isNotEmpty) {
  // Start collaboration
}
```

### 2. Debouncing is Built-In:

The CollaborationBloc already debounces updates (500ms), so you don't need to add extra debouncing.

### 3. Clean Up Properly:

Always call `CollaborationStopWatching()` in dispose to:
- Stop heartbeat timer
- Cancel stream subscriptions
- Mark user as inactive

---

## 🎨 Customization

### Change Debounce Time:

In `collaboration_bloc.dart`, find:
```dart
Timer(const Duration(milliseconds: 500), () {
```

Change to your preferred delay (e.g., 1000ms for 1 second).

### Change Heartbeat Interval:

In `realtime_collaboration_service.dart`, find:
```dart
Timer.periodic(const Duration(seconds: 5), (_) {
```

Change to your preferred interval.

### Change Active User Timeout:

In `realtime_collaboration_service.dart`, find:
```dart
final diff = DateTime.now().difference(presence.lastSeen);
return diff.inSeconds < 30;
```

Change `30` to your preferred timeout in seconds.

---

## ✅ Checklist

- [ ] Firestore rules deployed
- [ ] CollaborationBloc added to main.dart
- [ ] Imports added to rich_note_editor_screen.dart
- [ ] initState updated with collaboration start
- [ ] Collaboration listeners added
- [ ] dispose updated with collaboration stop
- [ ] Presence avatars added to AppBar
- [ ] Tested on two devices
- [ ] Changes sync in real-time
- [ ] Presence indicators show

---

## 🚀 You're Done!

Your app now has:
- ✅ Real-time content sync
- ✅ Presence indicators
- ✅ Cursor tracking (basic)
- ✅ Automatic conflict resolution

**Total integration time: ~25 minutes**

---

## 📚 More Info

- **Full Documentation:** `REALTIME_COLLABORATION.md`
- **Architecture Details:** See "Architecture" section in REALTIME_COLLABORATION.md
- **Future Enhancements:** See "Future Enhancements" section

---

**Happy Collaborating! 🎉**
