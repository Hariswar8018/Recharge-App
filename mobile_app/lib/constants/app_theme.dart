import 'package:flutter/material.dart';
import '../api.dart';
class AppTheme {
  // Global background image asset string. 
  // The user can replace this empty string or mock asset path with their real background asset path later!
  static const String globalBackgroundImageAsset = "assets/logos/background.png";

  // API Config
  static const String apiBaseUrl = Api.apiBaseUrl; 
  static const String appToken = Api.appToken;

  // App Palette (Mirroring screenshots)
  static const Color primaryBlue = Color(0xFF0052CC);
  static const Color secondaryRed = Color(0xFFE01A22);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color cardLightBlue = Color(0xFFF1F5F9);
  static const Color textDarkBlue = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);

  // Gradient definitions (mirroring UI)
  static const Gradient blueGradient = RadialGradient(
    colors: [
      Color(0xFF0080FF), // B color (light blue)
      Color(0xFF0052CC), // A color (dark blue)
    ],
    center: Alignment.topCenter,
    radius: 1.3,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF0052CC), Color(0xFF003D99)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
