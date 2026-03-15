import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eduflow/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/ui_utils.dart';
import '../../bloc/auth/auth_bloc.dart';

/// Phone authentication screen
class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoginMode = false;
  String? _phoneNumber;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.phoneLogin),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Hide loading overlay if previously shown
          if (state is! AuthLoading) {
            // Check if dialog is actually showing before popping
            // A better way is state tracking but this is a common quick fix
          }

          if (state is AuthLoading) {
            UiUtils.showLoadingOverlay(context);
          } else if (state is OtpSent) {
            UiUtils.hideLoadingOverlay(context);
            UiUtils.showSuccessSnackBar(context, l10n.codeSent);
            setState(() {
              _isOtpSent = true;
              _phoneNumber = state.phoneNumber;
            });
          } else if (state is AuthError) {
            UiUtils.hideLoadingOverlay(context);
            UiUtils.showErrorSnackBar(context, state.message);
          } else if (state is AuthAuthenticated) {
            UiUtils.hideLoadingOverlay(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isOtpSent) ...[
                Text(
                  l10n.enterPhoneNumber,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.verificationCodeDesc,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name (Optional)',
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumberLabel,
                    hintText: l10n.phoneNumberHint,
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _sendOtp,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(_isLoginMode ? 'Login' : l10n.sendCode),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                      });
                    },
                    child: Text(_isLoginMode 
                      ? l10n.dontHaveAccount 
                      : l10n.alreadyHaveAccount),
                  ),
                ),
              ] else ...[
                Text(
                  l10n.enterCode,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.sentCodeTo(_phoneNumber ?? ''),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: l10n.verificationCodeLabel,
                    hintText: '000000',
                    prefixIcon: const Icon(Icons.lock),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyOtp,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(l10n.verify),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _resendOtp,
                    child: Text(l10n.resendCode),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isOtpSent = false;
                        _otpController.clear();
                      });
                    },
                    child: Text(l10n.changePhoneNumber),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterPhone)),
      );
      return;
    }
    
    if (_isLoginMode) {
      context.read<AuthBloc>().add(LoginRequested(phone));
    } else {
      context.read<AuthBloc>().add(RequestOtp(phone, name: name.isNotEmpty ? name : null));
    }
  }

  void _verifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterOtp)),
      );
      return;
    }
    
    context.read<AuthBloc>().add(VerifyOtp(
      phoneNumber: _phoneNumber!,
      otp: otp,
    ));
  }

  void _resendOtp() {
    if (_phoneNumber != null) {
      context.read<AuthBloc>().add(ResendOtp(_phoneNumber!));
    }
  }
}
