part of 'auth_bloc.dart';

/// Base class for auth events
abstract class AuthEvent {
  const AuthEvent();
}

/// Check if user is already authenticated
class CheckAuthStatus extends AuthEvent {}

/// Request OTP for phone number
class RequestOtp extends AuthEvent {
  final String phoneNumber;
  final String? name;

  const RequestOtp(this.phoneNumber, {this.name});
}

/// Request OTP for login (existing user)
class LoginRequested extends AuthEvent {
  final String phoneNumber;
  const LoginRequested(this.phoneNumber);
}

/// Verify OTP
class VerifyOtp extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const VerifyOtp({required this.phoneNumber, required this.otp});
}

/// Resend OTP
class ResendOtp extends AuthEvent {
  final String phoneNumber;

  const ResendOtp(this.phoneNumber);
}

/// Update learner profile
class UpdateProfile extends AuthEvent {
  final Map<String, dynamic> data;

  const UpdateProfile(this.data);
}

/// Logout
class Logout extends AuthEvent {}

/// Complete onboarding
class CompleteOnboarding extends AuthEvent {}

/// Mark language as selected during onboarding
class SetAppLanguage extends AuthEvent {
  const SetAppLanguage();
}
