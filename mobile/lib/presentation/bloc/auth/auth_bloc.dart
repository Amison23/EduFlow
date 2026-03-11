import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC for authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RequestOtp>(_onRequestOtp);
    on<VerifyOtp>(_onVerifyOtp);
    on<ResendOtp>(_onResendOtp);
    on<UpdateProfile>(_onUpdateProfile);
    on<Logout>(_onLogout);
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _authRepository.checkAuthStatus();
    
    if (result.isAuthenticated) {
      final onboardingStatus = await _authRepository.getOnboardingStatus();
      
      emit(AuthAuthenticated(
        token: result.token!,
        learnerId: result.learnerId,
        hasSeenWelcome: onboardingStatus.hasSeenWelcome,
        hasSetDisplacementContext: onboardingStatus.hasSetContext,
      ));
    } else {
      emit(const AuthUnauthenticated(hasSeenWelcome: false));
    }
  }

  Future<void> _onRequestOtp(
    RequestOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _authRepository.requestOtp(event.phoneNumber);
    
    if (result.success) {
      emit(OtpSent(phoneNumber: event.phoneNumber));
    } else {
      emit(AuthError(result.message ?? 'Failed to send OTP'));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _authRepository.verifyOtp(
      phoneNumber: event.phoneNumber,
      otp: event.otp,
    );
    
    if (result.success && result.token != null) {
      final onboardingStatus = await _authRepository.getOnboardingStatus();
      
      emit(AuthAuthenticated(
        token: result.token!,
        learnerId: result.learnerId,
        hasSeenWelcome: onboardingStatus.hasSeenWelcome,
        hasSetDisplacementContext: onboardingStatus.hasSetContext,
      ));
    } else {
      emit(AuthError(result.failure?.message ?? 'Invalid OTP'));
    }
  }

  Future<void> _onResendOtp(
    ResendOtp event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.resendOtp(event.phoneNumber);
    
    if (result.success) {
      emit(OtpSent(phoneNumber: event.phoneNumber));
    } else {
      emit(AuthError(result.message ?? 'Failed to resend OTP'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;
    
    final result = await _authRepository.updateProfile(
      learnerId: currentState.learnerId ?? '',
      data: event.data,
    );
    
    if (result.success) {
      emit(currentState.copyWith(
        hasSetDisplacementContext: event.data.containsKey('displacement'),
      ));
    } else {
      emit(AuthError(result.failure?.message ?? 'Failed to update profile'));
    }
  }

  Future<void> _onLogout(
    Logout event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated(hasSeenWelcome: true));
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.completeOnboarding();
    
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(currentState.copyWith(hasSeenWelcome: true));
    }
  }
}
