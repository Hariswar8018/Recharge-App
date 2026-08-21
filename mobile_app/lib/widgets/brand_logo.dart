import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class BrandLogo extends StatelessWidget {
  final double scale;

  const BrandLogo({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo Icon
          Container(
            width: 48 * scale,
            height: 48 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryBlue, width: 3.5 * scale),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "S",
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 22 * scale,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Text(
                      "R",
                      style: TextStyle(
                        color: AppTheme.secondaryRed,
                        fontWeight: FontWeight.w900,
                        fontSize: 16 * scale,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Logo Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "SR DIGITAL SEVA",
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: 18 * scale,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "KENDRAM",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10 * scale,
                    letterSpacing: 4.0,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
