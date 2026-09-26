import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import '../../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _isOffline = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initVideoAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initVideoAndNavigate() async {
    if (mounted) {
      setState(() {
        _isOffline = false;
        _errorMessage = '';
      });
    }

    // 1. Initialize 8-second Splash Video with zero volume (no audio)
    _controller = VideoPlayerController.asset('assets/video_spalsh.mp4');
    try {
      await _controller.initialize();
      _controller.setVolume(0.0); // Silent video playback
      _controller.setLooping(false);
      _controller.play();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      // Fallback if video fails to initialize
      _isVideoInitialized = false;
    }

    final startTime = DateTime.now();
    bool healthy = false;
    String errText = '';

    // 2. Perform API health check in background while video plays
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

    // 3. Handle offline / health failure state (NO navigation, show red error container)
    if (!healthy) {
      if (!mounted) return;
      setState(() {
        _isOffline = true;
        _errorMessage = errText.isNotEmpty
            ? errText
            : "Unable to connect to API server. Please check your internet connection.";
      });
      return;
    }

    try {
      await ApiService.getVisibility(forceRefresh: true);
    } catch (_) {}

    // 4. Wait for 3 seconds splash screen duration before navigation
    const targetSplashDuration = Duration(seconds: 3);
    final elapsedTime = DateTime.now().difference(startTime);
    final remainingDelay = targetSplashDuration - elapsedTime;
    if (remainingDelay > Duration.zero) {
      await Future.delayed(remainingDelay);
    }

    if (!mounted) return;

    // 5. Navigate to Home or Login
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fullscreen Video Player (cover fit, no letterboxing)
          if (_isVideoInitialized && _controller.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          else
            const SizedBox.expand(
              child: ColoredBox(color: Colors.black),
            ),

          // ONLY SHOW RED CONTAINER IF NO INTERNET OR API CANNOT CONNECT
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
                        onPressed: () {
                          if (_isVideoInitialized) {
                            _controller.seekTo(Duration.zero);
                            _controller.play();
                          }
                          _initVideoAndNavigate();
                        },
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
