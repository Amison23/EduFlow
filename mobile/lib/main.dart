import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:eduflow/data/local/hive_boxes.dart';
import 'package:eduflow/data/local/database.dart';
import 'package:eduflow/data/remote/auth_remote.dart';
import 'package:eduflow/data/remote/lesson_remote.dart';
import 'package:eduflow/data/remote/progress_remote.dart';
import 'package:eduflow/data/remote/community_remote.dart';
import 'package:eduflow/data/remote/analytics_remote.dart';
import 'package:eduflow/data/repositories/auth_repository.dart';
import 'package:eduflow/data/repositories/lesson_repository.dart';
import 'package:eduflow/data/repositories/progress_repository.dart';
import 'package:eduflow/data/repositories/community_repository.dart';
import 'package:eduflow/data/repositories/analytics_repository.dart';
import 'package:eduflow/data/repositories/outbox_repository.dart';
import 'package:eduflow/services/sync_service.dart';
import 'package:eduflow/services/tflite_quiz_service.dart';
import 'package:eduflow/presentation/bloc/auth/auth_bloc.dart';
import 'package:eduflow/presentation/bloc/lesson/lesson_bloc.dart';
import 'package:eduflow/presentation/bloc/community/community_bloc.dart';
import 'package:eduflow/presentation/bloc/progress/progress_bloc.dart';
import 'package:eduflow/presentation/bloc/sync/sync_cubit.dart';
import 'package:eduflow/presentation/bloc/locale/locale_cubit.dart';
import 'package:eduflow/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: "assets/.env");
  
  // Initialize Hive
  await Hive.initFlutter();
  await HiveBoxes.init();
  
  // Initialize SQLite
  final database = AppDatabase();
  
  // Initialize TFLite service
  final tfliteQuizService = TfliteQuizService();
  await tfliteQuizService.init();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>.value(value: database),
        RepositoryProvider<TfliteQuizService>.value(value: tfliteQuizService),
        RepositoryProvider<OutboxRepository>(
          create: (context) => OutboxRepository(localDatabase: database),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            localDatabase: database,
            authRemote: AuthRemote(),
            outboxRepository: context.read<OutboxRepository>(),
          ),
        ),
        RepositoryProvider<LessonRepository>(
          create: (context) => LessonRepository(
            localDatabase: database,
            lessonRemote: LessonRemote(),
          ),
        ),
        RepositoryProvider<ProgressRepository>(
          create: (context) => ProgressRepository(
            localDatabase: database,
            progressRemote: ProgressRemote(),
          ),
        ),
        RepositoryProvider<CommunityRepository>(
          create: (context) => CommunityRepository(
            communityRemote: CommunityRemote(),
            localDatabase: database,
          ),
        ),
        RepositoryProvider<AnalyticsRepository>(
          create: (context) => AnalyticsRepository(
            analyticsRemote: AnalyticsRemote(),
            outboxRepository: context.read<OutboxRepository>(),
          ),
        ),
        RepositoryProvider<SyncService>(
          create: (context) => SyncService(
            progressRepository: context.read<ProgressRepository>(),
            outboxRepository: context.read<OutboxRepository>(),
            lessonRepository: context.read<LessonRepository>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(CheckAuthStatus()),
          ),
          BlocProvider<LessonBloc>(
            create: (context) => LessonBloc(
              lessonRepository: context.read<LessonRepository>(),
              progressRepository: context.read<ProgressRepository>(),
            ),
          ),
          BlocProvider<CommunityBloc>(
            create: (context) => CommunityBloc(
              communityRepository: context.read<CommunityRepository>(),
            ),
          ),
          BlocProvider<ProgressBloc>(
            create: (context) => ProgressBloc(
              progressRepository: context.read<ProgressRepository>(),
              quizService: context.read<TfliteQuizService>(),
            )..add(const LoadProgress()),
          ),
          BlocProvider<SyncCubit>(
            create: (context) => SyncCubit(
              syncService: context.read<SyncService>(),
              progressRepository: context.read<ProgressRepository>(),
            )..init(),
          ),
          BlocProvider<LocaleCubit>(
            create: (context) => LocaleCubit(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
        ],
        child: const EduFlowApp(),
      ),
    ),
  );
}
