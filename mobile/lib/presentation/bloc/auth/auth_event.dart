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

  const RequestOtp(this.phoneNumber);
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
