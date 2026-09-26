import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/social_footer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _sponsorController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _errorMessage = "";
  String _successMessage = "";

  // Email Validation States
  bool _isCheckingEmail = false;
  bool? _isEmailValid; // null = untouched, true = green, false = red
  String? _emailStatusMessage;
  String _lastCheckedEmail = "";

  // Mobile Validation States
  bool _isCheckingMobile = false;
  bool? _isMobileValid; // null = untouched, true = green, false = red
  String? _mobileStatusMessage;
  String _lastCheckedMobile = "";

  // Sponsor Validation States
  bool _isCheckingSponsor = false;
  bool? _isSponsorValid; // null = untouched, true = green, false = red
  String? _sponsorStatusMessage;
  String _lastCheckedSponsor = "";
  Map<String, dynamic> _visibilitySettings = {};

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _mobileController.addListener(_onMobileChanged);
    _sponsorController.addListener(_onSponsorChanged);
    _checkClipboardForSponsorLink();
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

  void _checkClipboardForSponsorLink() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData != null && clipboardData.text != null) {
        final text = clipboardData.text!.trim();
        final extracted = _extractSponsorCode(text);
        if (extracted.isNotEmpty && _sponsorController.text.isEmpty) {
          if (mounted) {
            setState(() {
              _sponsorController.text = text;
            });
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _mobileController.removeListener(_onMobileChanged);
    _sponsorController.removeListener(_onSponsorChanged);
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _sponsorController.dispose();
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

    final bool isEmailFormat = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text);
    if (!isEmailFormat) {
      setState(() {
        _isCheckingEmail = false;
        _isEmailValid = false;
        _emailStatusMessage = "Enter valid email address";
        _lastCheckedEmail = "";
      });
      return;
    }

    if (_lastCheckedEmail != text) {
      _verifyEmailAvailable(text);
    }
  }

  Future<void> _verifyEmailAvailable(String email) async {
    setState(() {
      _isCheckingEmail = true;
      _lastCheckedEmail = email;
    });

    final res = await ApiService.checkEmailAvailable(email);

    if (_emailController.text.trim() != email) return;

    setState(() {
      _isCheckingEmail = false;
      if (res['valid'] == true) {
        _isEmailValid = true;
        _emailStatusMessage = "Valid Email (Available)";
      } else {
        _isEmailValid = false;
        _emailStatusMessage = res['message'] ?? "Email Already Registered";
      }
    });
  }

  void _onMobileChanged() {
    final text = _mobileController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _isCheckingMobile = false;
        _isMobileValid = null;
        _mobileStatusMessage = null;
        _lastCheckedMobile = "";
      });
      return;
    }

    if (text.length < 10) {
      setState(() {
        _isCheckingMobile = false;
        _isMobileValid = false;
        _mobileStatusMessage = "Enter 10 digit mobile number";
        _lastCheckedMobile = "";
      });
      return;
    }

    if (text.length == 10) {
      if (_lastCheckedMobile == text && !_isCheckingMobile) return;
      _verifyMobileAvailable(text);
    }
  }

  Future<void> _verifyMobileAvailable(String number) async {
    setState(() {
      _isCheckingMobile = true;
      _lastCheckedMobile = number;
    });

    final res = await ApiService.checkMobileAvailable(number);

    if (_mobileController.text.trim() != number) return;

    setState(() {
      _isCheckingMobile = false;
      if (res['valid'] == true) {
        _isMobileValid = true;
        _mobileStatusMessage = "Valid (Can Register)";
      } else {
        _isMobileValid = false;
        if (res['registered'] == true) {
          _mobileStatusMessage = "Already Registered";
        } else {
          _mobileStatusMessage = res['message'] ?? "Invalid mobile number";
        }
      }
    });
  }

  String _extractSponsorCode(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return "";

    if (trimmed.contains("://") || trimmed.contains("ref=") || trimmed.contains("sponsor=") || trimmed.contains("id=") || trimmed.startsWith("www.")) {
      try {
        String urlStr = trimmed;
        if (!urlStr.startsWith("http://") && !urlStr.startsWith("https://")) {
          urlStr = "https://$urlStr";
        }
        final uri = Uri.parse(urlStr);

        if (uri.queryParameters.containsKey('ref') && uri.queryParameters['ref']!.isNotEmpty) {
          return uri.queryParameters['ref']!.trim();
        }
        if (uri.queryParameters.containsKey('sponsor') && uri.queryParameters['sponsor']!.isNotEmpty) {
          return uri.queryParameters['sponsor']!.trim();
        }
        if (uri.queryParameters.containsKey('id') && uri.queryParameters['id']!.isNotEmpty) {
          return uri.queryParameters['id']!.trim();
        }
        if (uri.queryParameters.containsKey('sponsor_id') && uri.queryParameters['sponsor_id']!.isNotEmpty) {
          return uri.queryParameters['sponsor_id']!.trim();
        }

        if (uri.pathSegments.isNotEmpty) {
          final last = uri.pathSegments.last.trim();
          if (last.isNotEmpty && last != "join" && last != "register" && last != "ref") {
            return last;
          }
        }
      } catch (_) {}

      final match = RegExp(r'(?:ref|sponsor|id|sponsor_id)=([A-Za-z0-9_]+)', caseSensitive: false).firstMatch(trimmed);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }

    return trimmed;
  }

  void _onSponsorChanged() {
    final rawText = _sponsorController.text.trim();
    if (rawText.isEmpty) {
      setState(() {
        _isCheckingSponsor = false;
        _isSponsorValid = null;
        _sponsorStatusMessage = null;
        _lastCheckedSponsor = "";
      });
      return;
    }

    final sponsorCode = _extractSponsorCode(rawText);

    if (RegExp(r'^\d+$').hasMatch(sponsorCode)) {
      if (sponsorCode.length < 10) {
        setState(() {
          _isCheckingSponsor = false;
          _isSponsorValid = false;
          _sponsorStatusMessage = "Sponsor Phone / ID must be 10 digits";
          _lastCheckedSponsor = "";
        });
        return;
      }
    }

    if (_lastCheckedSponsor == sponsorCode && !_isCheckingSponsor) return;
    _verifySponsorId(sponsorCode);
  }

  Future<void> _verifySponsorId(String sponsorId) async {
    setState(() {
      _isCheckingSponsor = true;
      _lastCheckedSponsor = sponsorId;
    });

    final res = await ApiService.checkSponsor(sponsorId);

    if (_extractSponsorCode(_sponsorController.text.trim()) != sponsorId) return;

    setState(() {
      _isCheckingSponsor = false;
      if (res['valid'] == true) {
        _isSponsorValid = true;
        _sponsorStatusMessage = res['name'] ?? "Valid Sponsor ID";
      } else {
        _isSponsorValid = false;
        _sponsorStatusMessage = res['error'] ?? "User Not Found";
      }
    });
  }

  OutlineInputBorder _getFieldBorder(bool? isValid) {
    Color color = const Color(0xFFE2E8F0);
    if (isValid == true) {
      color = const Color(0xFF10B981);
    } else if (isValid == false) {
      color = const Color(0xFFEF4444);
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: isValid != null ? 1.5 : 1.0,
      ),
    );
  }

  Widget? _buildSuffixIcon(bool isChecking, bool? isValid) {
    if (isChecking) {
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
    if (isValid == true) {
      return const Icon(
        Icons.check_circle,
        color: Color(0xFF10B981),
        size: 22,
      );
    }
    if (isValid == false) {
      return const Icon(
        Icons.cancel,
        color: Color(0xFFEF4444),
        size: 22,
      );
    }
    return null;
  }

  Future<void> _handleRegister() async {
    final emailText = _emailController.text.trim();
    if (emailText.isEmpty || _isEmailValid != true) {
      setState(() {
        _isEmailValid = false;
        _emailStatusMessage = _emailStatusMessage ?? "Enter valid email address";
      });
      return;
    }

    final mobileText = _mobileController.text.trim();
    if (mobileText.length < 10 || _isMobileValid != true) {
      setState(() {
        _isMobileValid = false;
        _mobileStatusMessage = _mobileStatusMessage ?? "Enter 10 digit mobile number";
      });
      return;
    }

    final rawSponsorText = _sponsorController.text.trim();
    final sponsorCode = _extractSponsorCode(rawSponsorText);
    if (rawSponsorText.isNotEmpty && _isSponsorValid != true) {
      setState(() {
        _isSponsorValid = false;
        _sponsorStatusMessage = _sponsorStatusMessage ?? "User Not Found";
      });
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Passwords do not match";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
      _successMessage = "";
    });

    final result = await ApiService.register(
      fullName: _nameController.text.trim(),
      email: emailText,
      mobileNumber: mobileText,
      password: _passwordController.text,
      sponsorId: sponsorCode.isNotEmpty ? sponsorCode : rawSponsorText,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      setState(() {
        _successMessage = "Account created successfully! Redirecting to login...";
      });
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        _errorMessage = result['error'] ?? "Registration failed";
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

                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF0C3C8F),
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Create an Account",
                          style: TextStyle(
                            color: Color(0xFF0C3C8F),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Join us today! Please fill in the details to get started.",
                      style: TextStyle(
                        color: AppTheme.textGray,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    if (_visibilitySettings['sec_registration_visibility'] == 'Hide' || _visibilitySettings['sec_registration_enabled'] == false || (_visibilitySettings['sec_registration_notice'] != null && _visibilitySettings['sec_registration_notice'].toString().isNotEmpty)) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: (_visibilitySettings['sec_registration_visibility'] == 'Hide' || _visibilitySettings['sec_registration_enabled'] == false) ? Colors.red.shade50 : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: (_visibilitySettings['sec_registration_visibility'] == 'Hide' || _visibilitySettings['sec_registration_enabled'] == false) ? Colors.red.shade200 : Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              (_visibilitySettings['sec_registration_visibility'] == 'Hide' || _visibilitySettings['sec_registration_enabled'] == false) ? Icons.lock : Icons.info,
                              color: (_visibilitySettings['sec_registration_visibility'] == 'Hide' || _visibilitySettings['sec_registration_enabled'] == false) ? Colors.red : AppTheme.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                (_visibilitySettings['sec_registration_visibility'] == 'Hide' || _visibilitySettings['sec_registration_enabled'] == false)
                                    ? (_visibilitySettings['sec_registration_notice']?.toString().isNotEmpty == true ? _visibilitySettings['sec_registration_notice'] : "Registration functionality is currently disabled or hidden by administrator.")
                                    : _visibilitySettings['sec_registration_notice'],
                                style: TextStyle(
                                  color: (_visibilitySettings['sec_registration_visibility'] == 'Hide' || _visibilitySettings['sec_registration_enabled'] == false) ? Colors.red.shade800 : AppTheme.primaryBlue,
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
                          )
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Icon inside the card (centered with + overlay)
                          Center(
                            child: Image.asset(
                              'assets/icons_logo/regitser_icon.png',
                              width: 110,
                              height: 110,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person, size: 45, color: AppTheme.primaryBlue),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Full Name
                          _buildLabel("Full Name"),
                          _buildTextField(
                            controller: _nameController,
                            hint: "Enter Full Name",
                            icon: Icons.person,
                            validator: (v) => (v == null || v.isEmpty) ? "Please enter full name" : null,
                          ),
                          const SizedBox(height: 12),

                          // Email Address
                          _buildLabel("Email Address"),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: "Enter Email Address",
                              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.email, color: AppTheme.primaryBlue, size: 16),
                              ),
                              suffixIcon: _buildSuffixIcon(_isCheckingEmail, _isEmailValid),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              border: _getFieldBorder(_isEmailValid),
                              enabledBorder: _getFieldBorder(_isEmailValid),
                              focusedBorder: _getFieldBorder(_isEmailValid),
                              errorStyle: const TextStyle(height: 0, fontSize: 0),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return "";
                              if (_isEmailValid != true) return "";
                              return null;
                            },
                          ),
                          if (_emailStatusMessage != null && _emailStatusMessage!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _emailStatusMessage!,
                              style: TextStyle(
                                color: _isEmailValid == true
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),

                          // Mobile Number (This will be your User ID / Login ID)
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(text: "Mobile Number "),
                                TextSpan(
                                  text: "(This will be your User ID / Login ID)",
                                  style: TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
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
                              hintText: "Enter Mobile Number",
                              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.phone, color: AppTheme.primaryBlue, size: 16),
                              ),
                              suffixIcon: _buildSuffixIcon(_isCheckingMobile, _isMobileValid),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              border: _getFieldBorder(_isMobileValid),
                              enabledBorder: _getFieldBorder(_isMobileValid),
                              focusedBorder: _getFieldBorder(_isMobileValid),
                              errorStyle: const TextStyle(height: 0, fontSize: 0),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return "";
                              if (value.trim().length < 10) return "";
                              if (_isMobileValid != true) return "";
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
                          const SizedBox(height: 12),

                          // Sponsor ID
                          _buildLabel("Sponsor ID"),
                          TextFormField(
                            controller: _sponsorController,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: "Enter 10 Digit Phone Number or Sponsor ID",
                              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.group, color: AppTheme.primaryBlue, size: 16),
                              ),
                              suffixIcon: _buildSuffixIcon(_isCheckingSponsor, _isSponsorValid),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              border: _getFieldBorder(_isSponsorValid),
                              enabledBorder: _getFieldBorder(_isSponsorValid),
                              focusedBorder: _getFieldBorder(_isSponsorValid),
                              errorStyle: const TextStyle(height: 0, fontSize: 0),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? "" : null,
                          ),
                          if (_sponsorStatusMessage != null && _sponsorStatusMessage!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _sponsorStatusMessage!,
                              style: TextStyle(
                                color: _isSponsorValid == true
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),

                          // Password
                          _buildLabel("Password"),
                          _buildPasswordField(
                            controller: _passwordController,
                            hint: "Enter Password",
                            obscure: _obscurePassword,
                            onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter password";
                              }
                              if (value.length < 8) {
                                return "Password must be at least 8 characters long";
                              }
                              final weak = ["123456", "12345678", "123456789", "1234567890", "password", "qwerty", "abcdef"];
                              if (weak.contains(value.toLowerCase()) || RegExp(r'^(\d)\1+$').hasMatch(value)) {
                                return "Simple passwords like 123456 are not allowed";
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
                          const SizedBox(height: 12),

                          // Confirm Password
                          _buildLabel("Confirm Password"),
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            hint: "Confirm Password",
                            obscure: _obscureConfirmPassword,
                            onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please confirm password";
                              }
                              if (value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          if (_errorMessage.isNotEmpty) ...[
                            Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                          ],
                          if (_successMessage.isNotEmpty) ...[
                            Text(_successMessage, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                          ],

                          // Register Button
                          Builder(
                            builder: (context) {
                              final bool isRegDisabled = _visibilitySettings['sec_registration_visibility'] == 'Hide' || _visibilitySettings['sec_registration_enabled'] == false;
                              return Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: (_isLoading || isRegDisabled) ? null : _handleRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isRegDisabled ? Colors.grey : const Color(0xFF0052CC),
                                        disabledBackgroundColor: Colors.grey.shade400,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      isRegDisabled ? "Registration Disabled" : "Register",
                                                      style: const TextStyle(
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
                                                )
                                              ],
                                            ),
                                    ),
                                  ),
                                  if (isRegDisabled) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFFCA5A5)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.block_rounded, color: Colors.red, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _visibilitySettings['sec_registration_notice']?.toString().isNotEmpty == true
                                                  ? _visibilitySettings['sec_registration_notice']
                                                  : "Registration is currently disabled by Administrator.",
                                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }
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
                            const Icon(Icons.chevron_left, color: AppTheme.primaryBlue, size: 20),
                            const Spacer(),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                                children: [
                                  TextSpan(text: "Already have an account? "),
                                  TextSpan(
                                    text: "Login",
                                    style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
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
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Image.asset("assets/support.png", width: 30),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text("Support", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDarkBlue)),
                                        SizedBox(height: 2),
                                        Text("We're here to help", style: TextStyle(fontSize: 9, color: Colors.grey)),
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
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Image.asset("assets/team.png", width: 30),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text("Join Global Team", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textDarkBlue)),
                                        SizedBox(height: 2),
                                        Text("Grow with us", style: TextStyle(fontSize: 9, color: Colors.grey)),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 13),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 16),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.lock, color: AppTheme.primaryBlue, size: 16),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 18),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      validator: validator ?? (v) => (v == null || v.isEmpty) ? "Please enter password" : null,
    );
  }
}

