import '../../core/errors/failures.dart';
import '../../core/utils/crypto.dart';
import '../local/database.dart';
import '../local/hive_boxes.dart';
import '../remote/auth_remote.dart';
import '../repositories/outbox_repository.dart';
import '../../core/constants/api_constants.dart';

/// Repository for authentication
class AuthRepository {
  final AppDatabase _localDatabase;
  final AuthRemote _authRemote;
  final OutboxRepository _outboxRepository;

  AuthRepository({
    required AppDatabase localDatabase,
    required AuthRemote authRemote,
    required OutboxRepository outboxRepository,
  })  : _localDatabase = localDatabase,
        _authRemote = authRemote,
        _outboxRepository = outboxRepository;

  /// Request OTP for phone number
  Future<({bool success, String? message})> requestOtp(String phoneNumber, {String? name}) async {
    try {
      // Hash phone number for privacy
      final phoneHash = CryptoUtils.hashPhoneNumber(phoneNumber);
      
      // Save phone hash locally
      await HiveBoxes.savePhoneHash(phoneHash);
      
      // Request OTP from server
      final response = await _authRemote.requestOtp(phoneNumber, name: name);
      
      return (success: true, message: response['message'] as String?);
    } catch (e) {
      return (success: false, message: e.toString());
    }
  }

  /// Request OTP for login
  Future<({bool success, String? message})> login(String phoneNumber) async {
    try {
      final phoneHash = CryptoUtils.hashPhoneNumber(phoneNumber);
      await HiveBoxes.savePhoneHash(phoneHash);
      final response = await _authRemote.login(phoneNumber);
      return (success: true, message: response['message'] as String?);
    } catch (e) {
      return (success: false, message: e.toString());
    }
  }

  /// Verify OTP and authenticate
  Future<({bool success, Failure? failure, String? token, String? learnerId})> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await _authRemote.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      
      final token = response['token'] as String?;
      final learnerId = response['learner_id'] as String?;
      
      if (token != null) {
        // Save auth data
        await HiveBoxes.saveToken(token);
        if (learnerId != null) {
          await HiveBoxes.saveLearnerId(learnerId);
        }
        _authRemote.setAuthToken(token);
      }
      
      return (success: true, failure: null, token: token, learnerId: learnerId);
    } catch (e) {
      final failure = ServerFailure(e.toString());
      return (success: false, failure: failure, token: null, learnerId: null);
    }
  }

  /// Resend OTP
  Future<({bool success, String? message})> resendOtp(String phoneNumber) async {
    try {
      final response = await _authRemote.resendOtp(phoneNumber);
      return (success: true, message: response['message'] as String?);
    } catch (e) {
      return (success: false, message: e.toString());
    }
  }

  /// Update learner profile
  Future<({bool success, Failure? failure})> updateProfile({
    required String learnerId,
    required Map<String, dynamic> data,
  }) async {
    // Update Hive first (source of truth for UI)
    if (data.containsKey('displacement')) {
      await HiveBoxes.setDisplacementContext(data['displacement']);
    }
    if (data.containsKey('language')) {
      await HiveBoxes.setPreferredLanguage(data['language']);
    }

    try {
      await _authRemote.updateProfile(learnerId: learnerId, data: data);
      return (success: true, failure: null);
    } catch (e) {
      // Queue for background sync if failed
      await _outboxRepository.enqueueRequest(
        url: '${ApiConstants.auth}/profile/$learnerId',
        method: 'PUT',
        body: data,
      );
      return (success: true, failure: null); // Return success as it's queued
    }
  }

  /// Sync preferred language to backend
  Future<void> syncPreferredLanguage(String languageCode) async {
    final learnerId = HiveBoxes.getLearnerId();
    if (learnerId == null) return;

    final data = {'preferred_language': languageCode};
    
    try {
      await _authRemote.updateProfile(
        learnerId: learnerId,
        data: data,
      );
    } catch (_) {
      await _outboxRepository.enqueueRequest(
        url: '${ApiConstants.auth}/profile/$learnerId',
        method: 'PUT',
        body: data,
      );
    }
  }

  /// Check if user is authenticated
  Future<({bool isAuthenticated, String? token, String? learnerId})> checkAuthStatus() async {
    final token = HiveBoxes.getToken();
    final learnerId = HiveBoxes.getLearnerId();
    
    if (token != null) {
      _authRemote.setAuthToken(token);
      return (isAuthenticated: true, token: token, learnerId: learnerId);
    }
    
    return (isAuthenticated: false, token: null, learnerId: null);
  }

  /// Get onboarding status
  Future<({bool hasSelectedLanguage, bool hasSeenWelcome, bool hasSetContext})> getOnboardingStatus() async {
    final hasSelectedLanguage = HiveBoxes.settings.containsKey('preferred_language');
    
    final hasSeenWelcome = HiveBoxes.isOnboardingComplete() == false 
        ? false 
        : true;
    final context = HiveBoxes.getDisplacementContext();
    
    return (
      hasSelectedLanguage: hasSelectedLanguage,
      hasSeenWelcome: hasSeenWelcome || context != null,
      hasSetContext: context != null,
    );
  }

  /// Get dynamic supported languages from backend
  Future<List<Map<String, dynamic>>> getSupportedLanguages() async {
    try {
      return await _authRemote.getLanguages();
    } catch (_) {
      // Return empty list on failure or handle as needed
      return [];
    }
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    await HiveBoxes.setOnboardingComplete(true);
  }

  /// Logout
  Future<void> logout() async {
    final token = HiveBoxes.getToken();
    if (token != null) {
      await _authRemote.logout(token);
    }
    
    // Clear local data
    await HiveBoxes.session.clear();
    await _localDatabase.clearAll();
  }
}
