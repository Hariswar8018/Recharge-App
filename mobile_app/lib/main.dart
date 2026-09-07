import 'package:flutter/material.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/navigation/home_screen.dart';
import 'screens/transactions/fund_request_screen.dart';
import 'screens/profile/profile_details_screen.dart';
import 'screens/profile/security_details_screen.dart';
import 'screens/transactions/wallet_details_screen.dart';
import 'screens/transactions/transaction_history_screen.dart';
import 'screens/transactions/withdrawal_screen.dart';
import 'screens/recharge/id_subscription_screen.dart';
import 'constants/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SR Digital Seva Kendram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryBlue,
          primary: AppTheme.primaryBlue,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/fund-request': (context) => const FundRequestScreen(),
        '/withdrawal': (context) => const WithdrawalScreen(),
        '/profile-details': (context) => const ProfileDetailsScreen(),
        '/security-details': (context) => const SecurityDetailsScreen(),
        '/wallet-details': (context) => const WalletDetailsScreen(),
        '/transaction-history': (context) => const TransactionHistoryScreen(),
        '/id-subscription': (context) => const IdSubscriptionScreen(),
      },
    );
  }
}
