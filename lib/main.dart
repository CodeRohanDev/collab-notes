import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'data/models/note_model.dart';
import 'data/models/user_model.dart';
import 'data/models/workspace_model.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/notes_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/notes/notes_bloc.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/welcome_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'core/constants/app_constants.dart';
import 'core/services/preferences_service.dart';
import 'core/services/deep_link_handler.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/notes/rich_note_editor_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(WorkspaceModelAdapter());

  // Try to open the box, if it fails due to schema changes, delete and recreate
  Box<NoteModel>? notesBox;
  try {
    notesBox = await Hive.openBox<NoteModel>(AppConstants.hiveBoxNotes);
  } catch (e) {
    // Delete the corrupted box if there's an error
    await Hive.deleteBoxFromDisk(AppConstants.hiveBoxNotes);
    // Open a fresh box
    notesBox = await Hive.openBox<NoteModel>(AppConstants.hiveBoxNotes);
  }

  final preferencesService = await PreferencesService.getInstance();

  runApp(MyApp(
    notesBox: notesBox,
    preferencesService: preferencesService,
  ));
}

class MyApp extends StatefulWidget {
  final Box<NoteModel> notesBox;
  final PreferencesService preferencesService;

  const MyApp({
    super.key,
    required this.notesBox,
    required this.preferencesService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  void _checkOnboarding() {
    _showOnboarding = !widget.preferencesService.isOnboardingComplete;
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  void _onOnboardingComplete() {
    widget.preferencesService.setOnboardingComplete();
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(
          create: (context) => NotesRepository(notesBox: widget.notesBox),
        ),
        RepositoryProvider.value(value: widget.preferencesService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              preferencesService: context.read<PreferencesService>(),
            )..add(AuthCheckRequested()),
          ),
        ],
        child: MaterialApp(
          title: 'CollabNotes',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [
            FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: FlutterQuillLocalizations.supportedLocales,
          home: _showSplash
              ? SplashScreen(onInitComplete: _onSplashComplete)
              : _showOnboarding
                  ? OnboardingScreen(
                      onComplete: _onOnboardingComplete,
                      onSkip: _onOnboardingComplete,
                    )
                  : const AppNavigator(),
        ),
      ),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final _deepLinkHandler = DeepLinkHandler();
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _deepLinkHandler.init(
      onNoteLink: (noteId) {
        _handleNoteDeepLink(noteId);
      },
    );
  }

  void _handleNoteDeepLink(String noteId) {
    // Wait a bit to ensure the app is fully initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      final context = _navigatorKey.currentContext;
      if (context == null) return;

      // Get the note from repository
      final notesRepository = context.read<NotesRepository>();
      final note = notesRepository.getNoteById(noteId);

      if (note != null) {
        // Note exists locally, open it
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RichNoteEditorScreen(note: note),
          ),
        );
      } else {
        // Note doesn't exist locally, show a dialog to add as collaborator
        _showCollaborationDialog(context, noteId);
      }
    });
  }

  void _showCollaborationDialog(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Join Collaboration'),
        content: const Text(
          'You\'ve been invited to collaborate on a note. Would you like to access it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Accept collaboration and fetch the note
                final notesBloc = context.read<NotesBloc>();
                notesBloc.add(NotesAcceptCollaborationRequested(noteId: noteId));
                
                // Wait for the note to be fetched
                await Future.delayed(const Duration(seconds: 2));
                
                if (!context.mounted) return;
                
                // Close loading dialog
                Navigator.pop(context);
                
                // Get the note from repository
                final notesRepository = context.read<NotesRepository>();
                final note = notesRepository.getNoteById(noteId);
                
                if (note != null) {
                  // Navigate to the note
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RichNoteEditorScreen(note: note),
                    ),
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Successfully joined collaboration!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to load note'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                
                // Close loading dialog
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return BlocProvider(
            create: (context) => NotesBloc(
              notesRepository: context.read<NotesRepository>(),
              userId: state.user.id,
            ),
            child: Navigator(
              key: _navigatorKey,
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                );
              },
            ),
          );
        }
        return WelcomeScreen(
          onContinueAsGuest: () {
            context.read<AuthBloc>().add(AuthContinueAsGuestRequested());
          },
        );
      },
    );
  }
}
