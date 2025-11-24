import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
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
import 'utils/app_theme.dart';
import 'providers/onboarding_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Rex Insurance',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/user-portal': (context) => const UserPortalScreen(),
              '/login': (context) => const LoginScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/reset-password': (context) => const ResetPasswordScreen(),
              '/explore-services': (context) => const ExploreServicesScreen(),
              '/signup': (context) => const SignupScreen(),
              '/verification-success': (context) => const VerificationSuccessScreen(),
              '/identity-verification': (context) => const IdentityVerificationScreen(),
              '/enter-nin': (context) => const EnterNinScreen(),
              '/enter-bvn': (context) => const EnterBvnScreen(),
              '/enter-passport': (context) => const EnterPassportScreen(),
              '/enter-drivers-license': (context) => const EnterDriversLicenseScreen(),
              '/create-password': (context) => const CreatePasswordScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/verify-code') {
                final email = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => VerifyCodeScreen(email: email),
                );
              }
              if (settings.name == '/verify-phone') {
                final email = settings.arguments as String;
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
