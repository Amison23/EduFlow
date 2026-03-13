import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';

/// Remote data source for authentication
class AuthRemote {
  final ApiClient _apiClient = ApiClient();

  /// Request OTP for a phone number
  Future<Map<String, dynamic>> requestOtp(String phoneNumber, {String? name}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'phone': phoneNumber,
          if (name != null) 'name': name,
        },
      );
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      String? fallbackUrl;
      int? status;
      if (e is DioException) {
        fallbackUrl = e.requestOptions.uri.toString();
        status = e.response?.statusCode;
      }
      throw NetworkException(
        'Failed to request OTP', 
        originalError: e,
        url: fallbackUrl ?? ApiConstants.baseUrl + ApiConstants.register,
        statusCode: status,
      );
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

  /// Get supported languages
  Future<List<Map<String, dynamic>>> getLanguages() async {
    try {
      final response = await _apiClient.get(ApiConstants.languages);
      return (response.data as List).cast<Map<String, dynamic>>();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch languages', originalError: e);
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
