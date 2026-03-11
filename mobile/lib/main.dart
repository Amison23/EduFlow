import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'data/local/database.dart';
import 'data/remote/auth_remote.dart';
import 'data/remote/lesson_remote.dart';
import 'data/remote/progress_remote.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/lesson_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/lesson/lesson_bloc.dart';
import 'presentation/bloc/sync/sync_cubit.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize local database
  final database = Database();
  await database.init();
  
  // Initialize API clients
  final authRemote = AuthRemote();
  final lessonRemote = LessonRemote();
  final progressRemote = ProgressRemote();
  
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
        RepositoryProvider<SyncService>.value(value: syncService),
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
          BlocProvider<SyncCubit>(
            create: (context) => SyncCubit(
              syncService: syncService,
              progressRepository: progressRepository,
            ),
          ),
        ],
        child: const EduFlowApp(),
      ),
    ),
  );
}
