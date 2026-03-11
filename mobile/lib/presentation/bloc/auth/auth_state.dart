part of 'auth_bloc.dart';

/// Base class for auth states
abstract class AuthState {
  const AuthState();
}

/// Initial state
class AuthInitial extends AuthState {}

/// Loading state
class AuthLoading extends AuthState {}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  final bool hasSeenWelcome;

  const AuthUnauthenticated({required this.hasSeenWelcome});
}

/// OTP sent, waiting for verification
class OtpSent extends AuthState {
  final String phoneNumber;

  const OtpSent({required this.phoneNumber});
}

/// Authenticated state
class AuthAuthenticated extends AuthState {
  final String token;
  final String? learnerId;
  final bool hasSeenWelcome;
  final bool hasSetDisplacementContext;

  const AuthAuthenticated({
    required this.token,
    this.learnerId,
    required this.hasSeenWelcome,
    required this.hasSetDisplacementContext,
  });

  AuthAuthenticated copyWith({
    String? token,
    String? learnerId,
    bool? hasSeenWelcome,
    bool? hasSetDisplacementContext,
  }) {
    return AuthAuthenticated(
      token: token ?? this.token,
      learnerId: learnerId ?? this.learnerId,
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
      hasSetDisplacementContext: hasSetDisplacementContext ?? this.hasSetDisplacementContext,
    );
  }
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}
