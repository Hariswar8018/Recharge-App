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
    double w = MediaQuery.of(context).size.width;
      double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: w,height: h,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/splash.png"),
          fit: BoxFit.cover)
        ),
      ),
    );
  }
}
