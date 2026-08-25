import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class ProcessingDialog extends StatefulWidget {
  final String message;
  const ProcessingDialog({super.key, required this.message});

  @override
  State<ProcessingDialog> createState() => _ProcessingDialogState();
}

class _ProcessingDialogState extends State<ProcessingDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDarkBlue),
            ),
            const SizedBox(height: 12),
            const Text(
              "Please wait while we process your request securely. Do not close the app or navigate away.",
              style: TextStyle(color: AppTheme.textGray, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _animation.value,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${(_animation.value * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                ),
                const Text("Securing transaction...", style: TextStyle(fontSize: 11, color: AppTheme.textGray)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

Future<void> showProcessingDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ProcessingDialog(message: message),
  );
}
