import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/social_footer.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isCheckingEmail = false;
  bool? _isEmailValid; // null = untouched, true = green, false = red
  String? _emailStatusMessage;
  String _lastCheckedEmail = "";
  Map<String, dynamic> _visibilitySettings = {};

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _loadVisibility();
  }

  Future<void> _loadVisibility() async {
    final v = await ApiService.getVisibility();
    if (mounted) {
      setState(() {
        _visibilitySettings = v;
      });
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    final text = _emailController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _isCheckingEmail = false;
        _isEmailValid = null;
        _emailStatusMessage = null;
        _lastCheckedEmail = "";
      });
      return;
    }

    // Validate email format basic check
    final bool isEmailFormat = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text);
    if (!isEmailFormat) {
      setState(() {
        _isCheckingEmail = false;
        _isEmailValid = false;
        _emailStatusMessage = "Email ID not found. Please enter a registered email ID.";
        _lastCheckedEmail = "";
      });
      return;
    }

    if (_lastCheckedEmail != text) {
      _verifyEmailRegistration(text);
    }
  }

  Future<void> _verifyEmailRegistration(String email) async {
    setState(() {
      _isCheckingEmail = true;
      _lastCheckedEmail = email;
    });

    final res = await ApiService.checkEmail(email);

    if (_emailController.text.trim() != email) return;

    setState(() {
      _isCheckingEmail = false;
      if (res['registered'] == true) {
        _isEmailValid = true;
        _emailStatusMessage = null; // Will show green message after Send Password
      } else {
        _isEmailValid = false;
        _emailStatusMessage = res['message'] ?? "Email ID not found. Please enter a registered email ID.";
      }
    });
  }

  OutlineInputBorder _getEmailBorder() {
    Color color = const Color(0xFFE2E8F0);
    if (_isEmailValid == true) {
      color = const Color(0xFF10B981);
    } else if (_isEmailValid == false) {
      color = const Color(0xFFEF4444);
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: _isEmailValid != null ? 1.5 : 1.0,
      ),
    );
  }

  Widget? _buildEmailSuffixIcon() {
    if (_isCheckingEmail) {
      return const UnconstrainedBox(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.primaryBlue,
          ),
        ),
      );
    }
    if (_isEmailValid == true) {
      return const Icon(
        Icons.check_circle,
        color: Color(0xFF10B981),
        size: 22,
      );
    }
    if (_isEmailValid == false) {
      return const Icon(
        Icons.cancel,
        color: Color(0xFFEF4444),
        size: 22,
      );
    }
    return null;
  }

  Future<void> _handleSendPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _isEmailValid == false) {
      setState(() {
        _isEmailValid = false;
        _emailStatusMessage = "Email ID not found. Please enter a registered email ID.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final res = await ApiService.forgotPassword(email);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (res['success'] || res['registered'] == true) {
        _isEmailValid = true;
        _emailStatusMessage = res['message'] ?? "Password has been sent to your registered email ID.";
      } else {
        _isEmailValid = false;
        _emailStatusMessage = res['error'] ?? "Email ID not found. Please enter a registered email ID.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.fill),
          ),

          // Form Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SR Logo at Top
                    Image.asset(
                      'assets/sr_logo.png',
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          "SR DIGITAL SEVA",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryBlue,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 7),

                    // Title
                    const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xFF0C3C8F),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Your password will be sent to your registered Email ID",
                      style: TextStyle(
                        color: AppTheme.textGray,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    if (_visibilitySettings['sec_otp_visibility'] == 'Hide' || _visibilitySettings['sec_otp_enabled'] == false || (_visibilitySettings['sec_otp_notice'] != null && _visibilitySettings['sec_otp_notice'].toString().isNotEmpty)) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: (_visibilitySettings['sec_otp_visibility'] == 'Hide' || _visibilitySettings['sec_otp_enabled'] == false) ? Colors.red.shade50 : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: (_visibilitySettings['sec_otp_visibility'] == 'Hide' || _visibilitySettings['sec_otp_enabled'] == false) ? Colors.red.shade200 : Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              (_visibilitySettings['sec_otp_visibility'] == 'Hide' || _visibilitySettings['sec_otp_enabled'] == false) ? Icons.lock : Icons.info,
                              color: (_visibilitySettings['sec_otp_visibility'] == 'Hide' || _visibilitySettings['sec_otp_enabled'] == false) ? Colors.red : AppTheme.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                (_visibilitySettings['sec_otp_visibility'] == 'Hide' || _visibilitySettings['sec_otp_enabled'] == false)
                                    ? (_visibilitySettings['sec_otp_notice']?.toString().isNotEmpty == true ? _visibilitySettings['sec_otp_notice'] : "Password Reset / OTP functionality is currently disabled or hidden by administrator.")
                                    : _visibilitySettings['sec_otp_notice'],
                                style: TextStyle(
                                  color: (_visibilitySettings['sec_otp_visibility'] == 'Hide' || _visibilitySettings['sec_otp_enabled'] == false) ? Colors.red.shade800 : AppTheme.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Card Form Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Forget Icon inside the card (centered)
                          Center(
                            child: Image.asset(
                              'assets/forget.png',
                              width: 130,
                              height: 130,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.lock_reset,
                                    size: 50,
                                    color: AppTheme.primaryBlue,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 5),

                          const Text(
                            "Enter your registered Email ID and we will send your password directly to your inbox.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textGray,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email field label
                          const Text(
                            "Email Address",
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: "Enter Registered Email Address",
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.email,
                                  color: AppTheme.primaryBlue,
                                  size: 16,
                                ),
                              ),
                              suffixIcon: _buildEmailSuffixIcon(),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              border: _getEmailBorder(),
                              enabledBorder: _getEmailBorder(),
                              focusedBorder: _getEmailBorder(),
                              errorStyle: const TextStyle(height: 0, fontSize: 0),
                            ),
                          ),
                          if (_emailStatusMessage != null && _emailStatusMessage!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isEmailValid == true
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isEmailValid == true
                                      ? const Color(0xFFA7F3D0)
                                      : const Color(0xFFFECACA),
                                ),
                              ),
                              child: Text(
                                _emailStatusMessage!,
                                style: TextStyle(
                                  color: _isEmailValid == true
                                      ? const Color(0xFF047857)
                                      : const Color(0xFFDC2626),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),

                          // Send Password button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSendPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0052CC),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Expanded(
                                          child: Center(
                                            child: Text(
                                              "Send Password",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.chevron_right,
                                            color: AppTheme.primaryBlue,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    // OR Divider
                    Row(
                      children: const [
                        Expanded(
                          child: Divider(
                            color: AppTheme.primaryBlue,
                            thickness: 0.5,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppTheme.primaryBlue,
                            thickness: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Back to Login Button
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.chevron_left,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                            const Spacer(),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Back to Login",
                                    style: TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 36),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Support and Join Global Team Buttons
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final uri = Uri.parse("https://wa.me/919988494936");
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Image.asset("assets/support.png", width: 30),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          "Support",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: AppTheme.textDarkBlue,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          "We're here to help",
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final uri = Uri.parse("https://whatsapp.com/channel/0029Vajp33CLSmbYgWt2lZ19");
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Image.asset("assets/team.png", width: 30),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          "Join Global Team",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AppTheme.textDarkBlue,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          "Grow with us",
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const SocialFooter(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
