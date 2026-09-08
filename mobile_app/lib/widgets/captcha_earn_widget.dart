import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CaptchaEarnWidget extends StatefulWidget {
  final Function(double earnedAmount) onEarn;

  const CaptchaEarnWidget({super.key, required this.onEarn});

  @override
  State<CaptchaEarnWidget> createState() => _CaptchaEarnWidgetState();
}

class _CaptchaEarnWidgetState extends State<CaptchaEarnWidget> {
  final TextEditingController _captchaController = TextEditingController();
  
  String _currentCaptcha = "";
  int _timeLeft = 30;
  Timer? _timer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _generateNewCaptcha();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _captchaController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 1) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        _generateNewCaptcha();
      }
    });
  }

  void _generateNewCaptcha() {
    const chars = r'23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz@#$';
    final random = math.Random();
    final buffer = StringBuffer();
    for (int i = 0; i < 6; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    setState(() {
      _currentCaptcha = buffer.toString();
      _captchaController.clear();
    });
    _startTimer();
  }

  Future<void> _handleSubmit() async {
    final input = _captchaController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the captcha shown above."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (input.toLowerCase() != _currentCaptcha.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect captcha code! Try again."),
          backgroundColor: Colors.red,
        ),
      );
      _captchaController.clear();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await ApiService.submitCaptchaEarnings(earnedAmount: 0.01);
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    widget.onEarn(0.01);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Success! ₹ 0.01 added to your balance.", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Color(0xFF16A34A),
        duration: Duration(seconds: 2),
      ),
    );

    _generateNewCaptcha();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Title
          Center(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
                children: [
                  TextSpan(
                    text: "Solve Captcha & ",
                    style: TextStyle(color: Color(0xFF0F172A)),
                  ),
                  TextSpan(
                    text: "Earn Money",
                    style: TextStyle(color: Color(0xFF0052CC)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Captcha Box & Refresh Button Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      // Visual Captcha Canvas
                      Expanded(
                        child: CustomPaint(
                          size: const Size(double.infinity, 72),
                          painter: _CaptchaPainter(text: _currentCaptcha),
                        ),
                      ),

                      // Divider
                      Container(
                        width: 1,
                        height: 48,
                        color: const Color(0xFFE2E8F0),
                      ),

                      // Time Left Column
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Time Left",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${_timeLeft}s",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0052CC),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Refresh Button
              InkWell(
                onTap: _generateNewCaptcha,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 48,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Icon(
                    Icons.sync_rounded,
                    color: Color(0xFF0052CC),
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Captcha Input Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextField(
              controller: _captchaController,
              autocorrect: false,
              enableSuggestions: false,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Color(0xFF0F172A),
              ),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_outline_rounded, color: Color(0xFF475569), size: 20),
                hintText: "Enter Captcha",
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0,
                  color: Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Submit & Earn Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052CC),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Submit & Earn ₹ 0.01",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Captcha Text with noise lines and background dots
class _CaptchaPainter extends CustomPainter {
  final String text;

  _CaptchaPainter({required this.text});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(text.hashCode);

    // Draw background noise dots
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final colors = [
      Colors.blue.shade300,
      Colors.red.shade300,
      Colors.green.shade300,
      Colors.purple.shade300,
      Colors.orange.shade300,
    ];

    for (int i = 0; i < 40; i++) {
      dotPaint.color = colors[random.nextInt(colors.length)].withOpacity(0.5);
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        1.5,
        dotPaint,
      );
    }

    // Draw strikethrough noise lines
    final linePaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      linePaint.color = colors[random.nextInt(colors.length)].withOpacity(0.7);
      canvas.drawLine(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        linePaint,
      );
    }

    // Draw styled captcha text characters
    if (text.isEmpty) return;
    final double charWidth = (size.width - 20) / text.length;

    final textColors = [
      const Color(0xFF0F172A), // Dark slate
      const Color(0xFFDC2626), // Red
      const Color(0xFF16A34A), // Green
      const Color(0xFF7C3AED), // Purple
      const Color(0xFFD97706), // Amber
      const Color(0xFF0284C7), // Sky Blue
    ];

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final charColor = textColors[random.nextInt(textColors.length)];
      final fontSize = 20.0 + random.nextDouble() * 6.0;

      final textSpan = TextSpan(
        text: char,
        style: TextStyle(
          color: charColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          fontFamily: 'Inter',
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final x = 10.0 + i * charWidth + random.nextDouble() * 4 - 2;
      final y = (size.height - textPainter.height) / 2 + random.nextDouble() * 6 - 3;

      canvas.save();
      // Slight angle rotation for noise effect
      final angle = (random.nextDouble() - 0.5) * 0.3;
      canvas.translate(x + textPainter.width / 2, y + textPainter.height / 2);
      canvas.rotate(angle);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CaptchaPainter oldDelegate) {
    return oldDelegate.text != text;
  }
}
