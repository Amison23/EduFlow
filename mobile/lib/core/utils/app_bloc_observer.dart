import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/log_service.dart';

class GlobalBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    LogService().logError(
      level: 'error',
      message: 'Bloc Error in ${bloc.runtimeType}: $error',
      stackTrace: stackTrace.toString(),
      context: {
        'bloc': bloc.runtimeType.toString(),
      },
    );
  }
}
