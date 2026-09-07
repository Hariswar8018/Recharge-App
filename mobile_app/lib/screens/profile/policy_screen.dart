import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InternalPolicyScreen extends StatelessWidget {
  final String title;
  final String content;

  const InternalPolicyScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: Color(0xFF0D47A1), size: 24),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),
            Text(
              content,
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper to launch WhatsApp Support directly
Future<void> launchWhatsAppSupport(BuildContext context) async {
  const String phone = "919988494936";
  const String message = "Hello Support, I need assistance with my SR Digital Seva account.";
  final Uri waUrl = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");

  try {
    if (await canLaunchUrl(waUrl)) {
      await launchUrl(waUrl, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch WhatsApp. Contact: +91 9988494936")),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening WhatsApp: $e")),
      );
    }
  }
}
