import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;

  const BackgroundContainer({
    super.key,
    required this.child,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    // If the user pasted an asset path, show the asset image.
    if (AppTheme.globalBackgroundImageAsset.isNotEmpty) {
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppTheme.globalBackgroundImageAsset),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      );
    }

    // Otherwise, generate a premium blue curved background styling mathematically using Container/ClipPath
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Top Left Blue Curve
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopCurveClipper(),
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0052CC), Color(0xFF0080FF)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            ),
          ),
          // Bottom Right Blue Curve
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomCurveClipper(),
              child: Container(
                height: 140,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0080FF), Color(0xFF0052CC)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            ),
          ),
          useSafeArea 
              ? SafeArea(child: child) 
              : child,
        ],
      ),
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.6,
      size.height - 50,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height - 80,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 80);
    path.quadraticBezierTo(
      size.width * 0.35,
      20,
      size.width * 0.7,
      50,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      60,
      size.width,
      0,
    );
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
