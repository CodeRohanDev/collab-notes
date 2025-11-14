import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
import 'core/theme/app_theme.dart';

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
    print('Error opening notes box, deleting old data: $e');
    // Delete the corrupted box
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

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

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
            child: const HomeScreen(),
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
