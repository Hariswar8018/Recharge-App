import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/background_container.dart';
import '../widgets/brand_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isOffline = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    setState(() {
      _isChecking = true;
      _isOffline = false;
    });

    final url = Uri.parse(ApiService.baseUrl).resolve('api/health');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode != 200) {
        throw Exception("Server offline");
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _isOffline = true;
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isChecking = false;
      _isOffline = false;
    });

    final token = await ApiService.getToken();
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              
              // Logo
              const BrandLogo(scale: 1.2),

              // Animated Loader / Offline visual
              if (_isOffline)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      color: AppTheme.secondaryRed,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "You are Offline",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDarkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Cannot connect to the server.\nPlease check your internet connection.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGray,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _navigateToNextScreen,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        "Try Again",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryBlue.withOpacity(0.2),
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryBlue,
                              width: 4,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "SR",
                              style: TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w900,
                                fontSize: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Welcome!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Simple dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryBlue.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
