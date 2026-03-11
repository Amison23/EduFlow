import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/onboarding/welcome_screen.dart';
import 'presentation/screens/onboarding/displacement_context_screen.dart';
import 'presentation/screens/onboarding/phone_auth_screen.dart';
import 'presentation/widgets/offline_banner.dart';

class EduFlowApp extends StatelessWidget {
  const EduFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return const AuthNavigator();
        },
      ),
    );
  }
}

class AuthNavigator extends StatelessWidget {
  const AuthNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthUnauthenticated) {
          // Check which step of onboarding they're on
          if (state.hasSeenWelcome == false) {
            return const WelcomeScreen();
          } else if (state.hasSetDisplacementContext == false) {
            return const DisplacementContextScreen();
          } else {
            return const PhoneAuthScreen();
          }
        }

        if (state is AuthAuthenticated) {
          return const HomeScreenWrapper();
        }

        if (state is AuthError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(CheckAuthStatus());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return const WelcomeScreen();
      },
    );
  }
}

class HomeScreenWrapper extends StatelessWidget {
  const HomeScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const OfflineBanner(
      child: HomeScreen(),
    );
  }
}
