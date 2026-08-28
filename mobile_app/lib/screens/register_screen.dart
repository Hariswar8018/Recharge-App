import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/social_footer.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _sponsorController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
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
      email: _emailController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      password: _passwordController.text,
      sponsorId: _sponsorController.text.trim(),
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
                       children: [
                         const Icon(
                           Icons.add_circle_outline,
                           color: Color(0xFF0C3C8F),
                           size: 20,
                         ),
                         const SizedBox(width: 6),
                         const Text(
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
                             child: Stack(
                               children: [
                                 Image.asset(
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
                               ],
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

                          // Email
                          _buildLabel("Email Address"),
                          _buildTextField(
                            controller: _emailController,
                            hint: "Enter Email Address",
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || v.isEmpty) ? "Please enter email" : null,
                          ),
                          const SizedBox(height: 12),

                          // Mobile Number
                          _buildLabel("Mobile Number"),
                          _buildTextField(
                            controller: _mobileController,
                            hint: "Enter Mobile Number",
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (v) => (v == null || v.isEmpty) ? "Please enter mobile number" : null,
                          ),
                          const SizedBox(height: 12),

                          // Sponsor ID
                          _buildLabel("Sponsor ID"),
                          _buildTextField(
                            controller: _sponsorController,
                            hint: "Enter Sponsor ID",
                            icon: Icons.group,
                            validator: (v) => (v == null || v.trim().isEmpty) ? "Sponsor ID is mandatory" : null,
                          ),
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
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0052CC),
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
                                        const Expanded(
                                          child: Center(
                                            child: Text(
                                              "Register",
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
                                        )
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
                        const SizedBox(width: 12),
                        Expanded(
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
