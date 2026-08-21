import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/background_container.dart';
import '../widgets/brand_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = "";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await ApiService.login(email: email, password: password);

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
      backgroundColor: Colors.white,
      body: BackgroundContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Brand Logo
              const BrandLogo(scale: 0.95),
              const SizedBox(height: 20),

              // Title
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  color: AppTheme.textDarkBlue,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Login to continue to your account",
                style: TextStyle(
                  color: AppTheme.textGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Login Form Card
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
                      // Email label and field
                      const Text(
                        "Email Address",
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
                            decoration: BoxDecoration(
                              color: AppTheme.cardLightBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.email, color: AppTheme.primaryBlue, size: 18),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.cardLightBlue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.cardLightBlue),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? "Please enter email" : null,
                      ),
                      const SizedBox(height: 16),

                      // Password label and field
                      const Text(
                        "Password",
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.cardLightBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.lock, color: AppTheme.primaryBlue, size: 18),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.cardLightBlue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.cardLightBlue),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? "Please enter password" : null,
                      ),

                      // Forgot password aligned right
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                      if (_errorMessage.isNotEmpty) ...[
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Login button with inline chevron
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLoading ? "Logging in..." : "Login",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
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
              ),

              const SizedBox(height: 16),
              // OR Divider
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

              // Create Account Button
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
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
                          style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                          children: [
                            TextSpan(text: "New here? "),
                            TextSpan(
                              text: "Create an Account",
                              style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 36), // Balanced spacing
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Support and Join Global Team Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.cardLightBlue),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.headset_mic, color: AppTheme.primaryBlue, size: 28),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Support", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDarkBlue)),
                                Text("We're here to help", style: TextStyle(fontSize: 10, color: Colors.grey)),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.cardLightBlue),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.people, color: AppTheme.primaryBlue, size: 28),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Join Global Team", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDarkBlue)),
                                Text("Grow with us", style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              // Follow Us
              const Text(
                "Follow Us",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
              ),
              const SizedBox(height: 12),
              // Social icons row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(Icons.telegram, AppTheme.primaryBlue),
                  _buildSocialIcon(Icons.play_circle_fill, Colors.red),
                  _buildSocialIcon(Icons.video_camera_front, Colors.blue),
                  _buildSocialIcon(Icons.camera_alt, Colors.pink),
                  _buildSocialIcon(Icons.chat, Colors.green),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.cardLightBlue,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
