import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/gold_loan_screen.dart';
import 'screens/apply_loan_screen.dart';
import 'screens/emi_calculator_screen.dart';
import 'screens/loan_status_screen.dart';
import 'screens/digital_gold_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/branches_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const IMuthootApp());
}

class IMuthootApp extends StatelessWidget {
  const IMuthootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iMuthoot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/otp': (_) => const OtpScreen(),
        '/home': (_) => const MainNavigation(),
        '/gold-loan': (_) => const GoldLoanScreen(),
        '/apply-loan': (_) => const ApplyLoanScreen(),
        '/pay-emi': (_) => const LoanStatusScreen(),
        '/loan-status': (_) => const LoanStatusScreen(),
        '/emi-calculator': (_) => const EmiCalculatorScreen(),
        '/digital-gold': (_) => const DigitalGoldScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/branches': (_) => const BranchesScreen(),
      },
    );
  }
}
