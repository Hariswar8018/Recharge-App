import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/background_container.dart';
import '../widgets/brand_logo.dart';

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
                "Create an Account",
                style: TextStyle(
                  color: AppTheme.textDarkBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Join us today! Please fill in the details to get started.",
                style: TextStyle(
                  color: AppTheme.textGray,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Form Container
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
                  border: Border.all(color: AppTheme.cardLightBlue),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      // Password
                      _buildLabel("Password"),
                      _buildPasswordField(
                        controller: _passwordController,
                        hint: "Enter Password",
                        obscure: _obscurePassword,
                        onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: 12),

                      // Confirm Password
                      _buildLabel("Confirm Password"),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        hint: "Confirm Password",
                        obscure: _obscureConfirmPassword,
                        onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
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
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLoading ? "Registering..." : "Register",
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
                      ),
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

              // Back to Login Button
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
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                          children: [
                            TextSpan(text: "Already have an account? "),
                            TextSpan(text: "Login", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                          ],
                        ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.cardLightBlue, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 18),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.cardLightBlue, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.lock, color: AppTheme.primaryBlue, size: 18),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Please enter password" : null,
    );
  }
}
