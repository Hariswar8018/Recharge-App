import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../widgets/background_container.dart';
import '../widgets/brand_logo.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _message = "";

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _message = "";
    });

    final email = _emailController.text.trim();
    final res = await ApiService.forgotPassword(email);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (res['success']) {
        _message = res['message'] ?? "Temporary password sent successfully!";
      } else {
        _message = "Error: ${res['error'] ?? 'Reset failed'}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BackgroundContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const BrandLogo(scale: 0.95),
              const SizedBox(height: 20),

              const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: AppTheme.textDarkBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "No worries! Let's reset your password",
                style: TextStyle(color: AppTheme.textGray, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),

              // Forgot password card containing OTP envelope art
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                  border: Border.all(color: AppTheme.cardLightBlue),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Envelope Art
                      _buildEnvelopeArt(),
                      const SizedBox(height: 16),

                      const Text(
                        "Enter your registered Email ID and we will send you a OTP to reset your password.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textGray, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "Email Address",
                          style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Enter Registered Email Address",
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppTheme.cardLightBlue, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.email, color: AppTheme.primaryBlue, size: 18),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? "Please enter email" : null,
                      ),
                      const SizedBox(height: 20),

                      if (_message.isNotEmpty) ...[
                        Text(_message, style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                      ],

                      // Send OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLoading ? "Sending..." : "Send OTP",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.chevron_right, color: AppTheme.primaryBlue, size: 16),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
                ],
              ),
              const SizedBox(height: 16),

              // Back to Login Link Box
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppTheme.cardLightBlue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.chevron_left, color: AppTheme.primaryBlue, size: 20),
                      const Spacer(),
                      const Text(
                        "Back to Login",
                        style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnvelopeArt() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.cardLightBlue.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Open Envelope Icon
            const Icon(Icons.drafts, color: AppTheme.primaryBlue, size: 68),
            // Lock overlay
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                child: const Icon(Icons.lock, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
