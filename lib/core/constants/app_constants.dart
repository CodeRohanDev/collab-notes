class AppConstants {
  static const String appName = 'CollabNotes';
  static const String hiveBoxNotes = 'notes_box';
  static const String hiveBoxUser = 'user_box';
  static const String hiveBoxSync = 'sync_box';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String notesCollection = 'notes';
  static const String workspacesCollection = 'workspaces';
  
  // Sync Status
  static const String syncPending = 'pending';
  static const String syncCompleted = 'completed';
  static const String syncFailed = 'failed';
}
