import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/user_portal_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/verify_code_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/explore_services_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_phone_screen.dart';
import 'screens/verification_success_screen.dart';
import 'screens/identity_verification_screen.dart';
import 'screens/enter_nin_screen.dart';
import 'screens/enter_bvn_screen.dart';
import 'screens/enter_passport_screen.dart';
import 'screens/enter_drivers_license_screen.dart';
import 'screens/create_password_screen.dart';
import 'screens/existing_policy_question_screen.dart';
import 'screens/get_covered_screen.dart';
import 'screens/enter_policy_details_screen.dart';
import 'screens/agent_dashboard_screen.dart';
import 'screens/select_client_type_screen.dart';
import 'utils/app_theme.dart';
import 'providers/onboarding_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/policy_provider.dart';
import 'providers/agent_policy_provider.dart';
import 'services/inactivity_service.dart';
import 'widgets/app_update_gate.dart';

void main() {
  runZoned(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      debugPrint = (String? message, {int? wrapWidth}) {};

      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
      );

      runApp(MyApp());
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {},
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => PolicyProvider()),
        ChangeNotifierProvider(create: (_) => AgentPolicyProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Rex Insurance',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            // Lock text scaling to 1.0 so UI sizes don't change with device font settings
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.1),
                ),
                child: InactivityService(
                  timeout: const Duration(minutes: 3),
                  navigatorKey: _navigatorKey,
                  child: AppUpdateGate(child: child!),
                ),
              );
            },
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/user-portal': (context) => const UserPortalScreen(),
              '/login': (context) => const LoginScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/explore-services': (context) => const ExploreServicesScreen(),
              '/signup': (context) => const SignupScreen(),
              '/verification-success': (context) =>
                  const VerificationSuccessScreen(),
              '/identity-verification': (context) =>
                  const IdentityVerificationScreen(),
              '/enter-nin': (context) => const EnterNinScreen(),
              '/enter-bvn': (context) => const EnterBvnScreen(),
              '/enter-passport': (context) => const EnterPassportScreen(),
              '/enter-drivers-license': (context) =>
                  const EnterDriversLicenseScreen(),
              '/create-password': (context) => const CreatePasswordScreen(),
              '/existing-policy-question': (context) =>
                  const ExistingPolicyQuestionScreen(),
              '/get-covered': (context) => const GetCoveredScreen(),
              '/enter-policy-details': (context) =>
                  const EnterPolicyDetailsScreen(),
              '/agent-dashboard': (context) => const AgentDashboardScreen(),
              '/select-client-type': (context) =>
                  const SelectClientTypeScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/verify-code') {
                final email = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => VerifyCodeScreen(email: email),
                );
              }
              if (settings.name == '/reset-password') {
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (context) => ResetPasswordScreen(
                    email: args?['email']?.toString() ?? '',
                    otp: args?['otp']?.toString() ?? '',
                  ),
                );
              }
              if (settings.name == '/verify-phone') {
                final email = settings.arguments?.toString() ?? '';
                return MaterialPageRoute(
                  builder: (context) => VerifyPhoneScreen(email: email),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
