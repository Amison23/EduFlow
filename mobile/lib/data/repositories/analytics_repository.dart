import 'package:uuid/uuid.dart';
import '../remote/analytics_remote.dart';
import '../local/hive_boxes.dart';
import '../repositories/outbox_repository.dart';
import '../../core/constants/api_constants.dart';

/// Repository for handling analytics
class AnalyticsRepository {
  final AnalyticsRemote _analyticsRemote;
  final OutboxRepository _outboxRepository;
  final Uuid _uuid = const Uuid();

  AnalyticsRepository({
    required AnalyticsRemote analyticsRemote,
    required OutboxRepository outboxRepository,
  })  : _analyticsRemote = analyticsRemote,
        _outboxRepository = outboxRepository;

  /// Get or create a session ID for onboarding
  String getOnboardingSessionId() {
    String? sessionId = HiveBoxes.settings.get('onboarding_session_id');
    if (sessionId == null) {
      sessionId = _uuid.v4();
      HiveBoxes.settings.put('onboarding_session_id', sessionId);
    }
    return sessionId;
  }

  /// Track onboarding step
  Future<void> trackOnboardingStep({
    required String step,
    String? selectionType,
    String? selectionValue,
  }) async {
    final sessionId = getOnboardingSessionId();
    final eventData = {
      'session_id': sessionId,
      'step': step,
      if (selectionType != null) 'selection_type': selectionType,
      if (selectionValue != null) 'selection_value': selectionValue,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      await _analyticsRemote.trackOnboardingEvent(
        sessionId: sessionId,
        step: step,
        selectionType: selectionType,
        selectionValue: selectionValue,
      );
    } catch (_) {
      // On failure, enqueue to outbox for later sync
      await _outboxRepository.enqueueRequest(
        url: ApiConstants.trackOnboarding,
        method: 'POST',
        body: eventData as Map<String, dynamic>,
      );
    }
  }
}
