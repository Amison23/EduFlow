import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';

/// Remote data source for authentication
class AuthRemote {
  final ApiClient _apiClient = ApiClient();

  /// Request OTP for a phone number
  Future<Map<String, dynamic>> requestOtp(String phoneNumber) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'phone': phoneNumber,
        },
      );
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to request OTP', originalError: e);
    }
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        data: {
          'phone': phoneNumber,
          'otp': otp,
        },
      );
      
      // Set auth token on successful verification
      final token = response.data['token'] as String?;
      if (token != null) {
        _apiClient.setAuthToken(token);
      }
      
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to verify OTP', originalError: e);
    }
  }

  /// Resend OTP
  Future<Map<String, dynamic>> resendOtp(String phoneNumber) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resendOtp,
        data: {
          'phone': phoneNumber,
        },
      );
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to resend OTP', originalError: e);
    }
  }

  /// Update learner profile
  Future<Map<String, dynamic>> updateProfile({
    required String learnerId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.auth}/profile/$learnerId',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to update profile', originalError: e);
    }
  }

  /// Logout
  Future<void> logout(String token) async {
    try {
      _apiClient.setAuthToken(token);
      await _apiClient.post('${ApiConstants.auth}/logout');
    } catch (e) {
      // Ignore logout errors
    } finally {
      _apiClient.clearAuthToken();
    }
  }

  /// Set auth token
  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  /// Clear auth token
  void clearAuthToken() {
    _apiClient.clearAuthToken();
  }
}
