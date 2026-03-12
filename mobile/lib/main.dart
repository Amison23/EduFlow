import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'data/local/database.dart';
import 'data/remote/auth_remote.dart';
import 'data/remote/lesson_remote.dart';
import 'data/remote/progress_remote.dart';
import 'data/remote/community_remote.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/lesson_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/community_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/lesson/lesson_bloc.dart';
import 'presentation/bloc/community/community_bloc.dart';
import 'services/sync_service.dart';
import 'presentation/bloc/progress/progress_bloc.dart';
import 'presentation/bloc/sync/sync_cubit.dart';
import 'presentation/bloc/locale/locale_cubit.dart';
import 'services/tflite_quiz_service.dart';
import 'services/log_service.dart';
import 'core/utils/app_bloc_observer.dart';
import 'presentation/screens/error/error_screen.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup Logging Service
  final logService = LogService();
  
  // Capture Flutter errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logService.logError(
      message: details.exceptionAsString(),
      stackTrace: details.stack.toString(),
      level: 'error',
      context: {'library': 'flutter'},
    );
  };

  // Capture platform errors (async/main errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    logService.logFatal(error, stack);
    return true; // Error was handled
  };

  // Set Bloc observer
  Bloc.observer = GlobalBlocObserver();
  
  // Custom Error Widget for UI crashes
  ErrorWidget.builder = (details) {
    return ErrorScreen(
      error: details.exception,
      onRetry: () {
        // Simple restart by clearing state and reloading main
        // In a real app, you might use Phoenix or similar
        main(); 
      },
    );
  };
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize local database
  final database = AppDatabase();
  await database.database;
  
  // Initialize API clients
  final authRemote = AuthRemote();
  final lessonRemote = LessonRemote();
  final progressRemote = ProgressRemote();
  final communityRemote = CommunityRemote();
  
  // Initialize repositories
  final authRepository = AuthRepository(
    localDatabase: database,
    authRemote: authRemote,
  );
  final lessonRepository = LessonRepository(
    localDatabase: database,
    lessonRemote: lessonRemote,
  );
  final progressRepository = ProgressRepository(
    localDatabase: database,
    progressRemote: progressRemote,
  );
  final communityRepository = CommunityRepository(
    communityRemote: communityRemote,
  );
  
  final tfliteQuizService = TfliteQuizService();
  await tfliteQuizService.init();
  
  // Initialize sync service
  final syncService = SyncService(
    progressRepository: progressRepository,
  );
  
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<LessonRepository>.value(value: lessonRepository),
        RepositoryProvider<ProgressRepository>.value(value: progressRepository),
        RepositoryProvider<CommunityRepository>.value(value: communityRepository),
        RepositoryProvider<SyncService>.value(value: syncService),
        RepositoryProvider<TfliteQuizService>.value(value: tfliteQuizService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: authRepository,
            )..add(CheckAuthStatus()),
          ),
          BlocProvider<LessonBloc>(
            create: (context) => LessonBloc(
              lessonRepository: lessonRepository,
            ),
          ),
          BlocProvider<CommunityBloc>(
            create: (context) => CommunityBloc(
              communityRepository: communityRepository,
            )..add(const LoadStudyGroups()),
          ),
          BlocProvider<ProgressBloc>(
            create: (context) => ProgressBloc(
              progressRepository: progressRepository,
              quizService: tfliteQuizService,
            )..add(const LoadProgress()),
          ),
          BlocProvider<SyncCubit>(
            create: (context) => SyncCubit(
              syncService: syncService,
              progressRepository: progressRepository,
            ),
          ),
          BlocProvider<LocaleCubit>(
            create: (context) => LocaleCubit(
              authRepository: authRepository,
            ),
          ),
        ],
        child: const EduFlowApp(),
      ),
    ),
  );
}
