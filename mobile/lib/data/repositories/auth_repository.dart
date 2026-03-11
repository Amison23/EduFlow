import '../../core/errors/failures.dart';
import '../../core/utils/crypto.dart';
import '../local/database.dart';
import '../local/hive_boxes.dart';
import '../remote/auth_remote.dart';

/// Repository for authentication
class AuthRepository {
  final AppDatabase _localDatabase;
  final AuthRemote _authRemote;

  AuthRepository({
    required AppDatabase localDatabase,
    required AuthRemote authRemote,
  })  : _localDatabase = localDatabase,
        _authRemote = authRemote;

  /// Request OTP for phone number
  Future<({bool success, String? message})> requestOtp(String phoneNumber) async {
    try {
      // Hash phone number for privacy
      final phoneHash = CryptoUtils.hashPhoneNumber(phoneNumber);
      
      // Save phone hash locally
      await HiveBoxes.savePhoneHash(phoneHash);
      
      // Request OTP from server
      final response = await _authRemote.requestOtp(phoneNumber);
      
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
    try {
      await _authRemote.updateProfile(learnerId: learnerId, data: data);
      
      // Save displacement context
      if (data.containsKey('displacement')) {
        await HiveBoxes.setDisplacementContext(data['displacement']);
      }
      
      // Save preferred language
      if (data.containsKey('language')) {
        await HiveBoxes.setPreferredLanguage(data['language']);
      }
      
      return (success: true, failure: null);
    } catch (e) {
      return (success: false, failure: ServerFailure(e.toString()));
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
  Future<({bool hasSeenWelcome, bool hasSetContext})> getOnboardingStatus() async {
    final hasSeenWelcome = HiveBoxes.isOnboardingComplete() == false 
        ? false 
        : true;
    final context = HiveBoxes.getDisplacementContext();
    
    return (
      hasSeenWelcome: hasSeenWelcome || context != null,
      hasSetContext: context != null,
    );
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
