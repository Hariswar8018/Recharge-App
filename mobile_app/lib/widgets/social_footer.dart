import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class SocialFooter extends StatelessWidget {
  const SocialFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            // Left gradient line (fades from transparent to solid blue)
            Expanded(
              child: Container(
                height: 2, // Thicker in center
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF0052CC).withOpacity(0.5),
                      const Color(0xFF0052CC),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Follow Us",
                style: TextStyle(
                  color: Color(0xFF0052CC),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            // Right gradient line (fades from solid blue to transparent)
            Expanded(
              child: Container(
                height: 2, // Thicker in center
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0052CC),
                      const Color(0xFF0052CC).withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Social Icons Image Row
        Center(
          child: Image.asset(
            "assets/logos/bottom.png",
            width: MediaQuery.of(context).size.width / 2,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
