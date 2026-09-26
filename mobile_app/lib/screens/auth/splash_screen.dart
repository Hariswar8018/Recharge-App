import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isOffline = false;
  bool _isChecking = true;
  String _errorMessage = '';

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
    final startTime = DateTime.now();

    if (mounted) {
      setState(() {
        _isChecking = true;
        _isOffline = false;
        _errorMessage = '';
      });
    }

    bool healthy = false;
    String errText = '';

    try {
      await ApiService.getWorkingBaseUrl(forceCheck: true);
      final cleanBase = ApiService.baseUrl.replaceAll(RegExp(r'/+$'), '');
      final url = Uri.parse('$cleanBase/api/health');

      final response = await http.get(
        url,
        headers: {'x-app-token': ApiService.appToken},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        healthy = true;
      } else {
        errText = "Server Error (${response.statusCode}): Could not connect to API.";
      }
    } catch (e) {
      errText = "Connection Error: Unable to connect to server. Please check your internet connection or try again.";
    }

    if (!healthy) {
      if (!mounted) return;
      setState(() {
        _isChecking = false;
        _isOffline = true;
        _errorMessage = errText.isNotEmpty
            ? errText
            : "Unable to connect to API server. Please check your internet connection.";
      });
      return; // AVOID NAVIGATION WHEN OFFLINE OR UNHEALTHY
    }

    try {
      await ApiService.getVisibility(forceRefresh: true);
    } catch (_) {}

    if (!mounted) return;

    final elapsedTime = DateTime.now().difference(startTime);
    final remainingDelay = const Duration(seconds: 3) - elapsedTime;
    if (remainingDelay > Duration.zero) {
      await Future.delayed(remainingDelay);
    }

    if (!mounted) return;

    setState(() {
      _isChecking = false;
      _isOffline = false;
    });

    final token = await ApiService.getToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
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
      body: Stack(
        children: [
          Container(
            width: w,
            height: h,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/logos/spalsh.gif"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (_isChecking)
            Positioned(
              left: 0,
              right: 0,
              bottom: 60,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3.0,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Connecting to server...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black54,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isOffline)
            Positioned(
              left: 20,
              right: 20,
              bottom: 50,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.redAccent.shade100,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Connection Error",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToNextScreen,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Color(0xFFDC2626),
                        ),
                        label: const Text(
                          "Retry Connection",
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
