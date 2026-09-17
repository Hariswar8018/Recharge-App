import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/social_footer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = "";

  // Mobile Validation States
  bool _isCheckingMobile = false;
  bool? _isMobileValid; // null = empty/unfilled, true = green valid, false = red invalid
  bool _isMobileRegistered = false;
  String? _mobileStatusMessage;
  String _lastCheckedNumber = "";

  @override
  void initState() {
    super.initState();
    _mobileController.addListener(_onMobileChanged);
  }

  @override
  void dispose() {
    _mobileController.removeListener(_onMobileChanged);
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onMobileChanged() {
    final text = _mobileController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _isCheckingMobile = false;
        _isMobileValid = null;
        _isMobileRegistered = false;
        _mobileStatusMessage = null;
        _lastCheckedNumber = "";
      });
      return;
    }

    if (text.length < 10) {
      setState(() {
        _isCheckingMobile = false;
        _isMobileValid = false;
        _isMobileRegistered = false;
        _mobileStatusMessage = "Enter 10 digit mobile number";
        _lastCheckedNumber = "";
      });
      return;
    }

    if (text.length == 10) {
      if (_lastCheckedNumber == text && !_isCheckingMobile) return;
      _checkMobileRegistration(text);
    }
  }

  Future<void> _checkMobileRegistration(String number) async {
    setState(() {
      _isCheckingMobile = true;
      _lastCheckedNumber = number;
    });

    final res = await ApiService.checkMobile(number);

    if (_mobileController.text.trim() != number) return;

    setState(() {
      _isCheckingMobile = false;
      if (res['registered'] == true) {
        _isMobileValid = true;
        _isMobileRegistered = true;
        _mobileStatusMessage = "Valid registered mobile number";
      } else {
        _isMobileValid = false;
        _isMobileRegistered = false;
        _mobileStatusMessage = res['message'] ??
            "This mobile number is not registered. Please use your registered mobile number.";
      }
    });
  }

  OutlineInputBorder _getMobileBorder() {
    Color color = const Color(0xFFE2E8F0);
    if (_isMobileValid == true) {
      color = const Color(0xFF10B981);
    } else if (_isMobileValid == false) {
      color = const Color(0xFFEF4444);
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: _isMobileValid != null ? 1.5 : 1.0,
      ),
    );
  }

  Widget? _buildMobileSuffixIcon() {
    if (_isCheckingMobile) {
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
    if (_isMobileValid == true) {
      return const Icon(
        Icons.check_circle,
        color: Color(0xFF10B981),
        size: 22,
      );
    }
    if (_isMobileValid == false) {
      return const Icon(
        Icons.cancel,
        color: Color(0xFFEF4444),
        size: 22,
      );
    }
    return null;
  }

  Future<void> _handleLogin() async {
    final mobileText = _mobileController.text.trim();
    if (mobileText.length < 10) {
      setState(() {
        _isMobileValid = false;
        _mobileStatusMessage = "Enter 10 digit mobile number";
      });
      return;
    }

    if (!_isMobileRegistered) {
      if (!_isCheckingMobile && mobileText.length == 10) {
        await _checkMobileRegistration(mobileText);
      }
      if (!_isMobileRegistered) {
        setState(() {
          _isMobileValid = false;
          _mobileStatusMessage = _mobileStatusMessage ??
              "This mobile number is not registered. Please use your registered mobile number.";
        });
        return;
      }
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final password = _passwordController.text;

    final result = await ApiService.login(email: mobileText, password: password);

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _errorMessage = result['error'] ?? "Login failed";
      });
    }
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

                    // Welcome Text (Outside the card)
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        color: Color(0xFF0C3C8F),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Login to continue to your account",
                      style: TextStyle(
                        color: AppTheme.textGray,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),

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
                          // User Icon inside the card (centered)
                          Center(
                            child: Image.asset(
                              'assets/user_icon.png',
                              width: 130,
                              height: 130,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppTheme.primaryBlue,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Registered Mobile field label
                          const Text(
                            "Registered Mobile",
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: "Enter Registered Mobile",
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
                                  Icons.phone,
                                  color: AppTheme.primaryBlue,
                                  size: 16,
                                ),
                              ),
                              suffixIcon: _buildMobileSuffixIcon(),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              border: _getMobileBorder(),
                              enabledBorder: _getMobileBorder(),
                              focusedBorder: _getMobileBorder(),
                              errorStyle: const TextStyle(height: 0, fontSize: 0),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "";
                              }
                              if (value.trim().length < 10) {
                                return "";
                              }
                              if (!_isMobileRegistered) {
                                return "";
                              }
                              return null;
                            },
                          ),
                          if (_mobileStatusMessage != null && _mobileStatusMessage!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _mobileStatusMessage!,
                              style: TextStyle(
                                color: _isMobileValid == true
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),

                          // Password field label
                          const Text(
                            "Password",
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: "Enter Password",
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
                                  Icons.lock,
                                  color: AppTheme.primaryBlue,
                                  size: 16,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter password";
                              }
                              if (value.length < 8) {
                                return "Password must be at least 8 characters";
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return "Password must contain at least one uppercase letter (A-Z)";
                              }
                              if (!RegExp(r'[a-z]').hasMatch(value)) {
                                return "Password must contain at least one lowercase letter (a-z)";
                              }
                              if (!RegExp(r'[0-9]').hasMatch(value)) {
                                return "Password must contain at least one number (0-9)";
                              }
                              if (!RegExp(r'[!@#\$&*~%]').hasMatch(value)) {
                                return "Password must contain at least one special character (@, #, \$, %, etc.)";
                              }
                              return null;
                            },
                          ),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot-password',
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                          if (_errorMessage.isNotEmpty) ...[
                            Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Expanded(
                                          child: Center(
                                            child: Text(
                                              "Login",
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
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
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
                            "OR",
                            style: TextStyle(
                              color: Color(0xFF0052CC),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
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
                    const SizedBox(height: 5),

                    // New here? Register card
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
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
                                  TextSpan(text: "New here? "),
                                  TextSpan(
                                    text: "Create an Account",
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

  // ignore: unused_element
  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

