import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

/// Remote data source for analytics
class AnalyticsRemote {
  final ApiClient _apiClient = ApiClient();

  /// Track an onboarding event
  Future<void> trackOnboardingEvent({
    required String sessionId,
    required String step,
    String? selectionType,
    String? selectionValue,
  }) async {
    try {
      await _apiClient.post(
        ApiConstants.trackOnboarding,
        data: {
          'sessionId': sessionId,
          'step': step,
          if (selectionType != null) 'selectionType': selectionType,
          if (selectionValue != null) 'selectionValue': selectionValue,
        },
      );
    } catch (e) {
      // Analytics failures should not block user experience
    }
  }
}
