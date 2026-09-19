import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';
import 'bank_verify_screen.dart';

class SecurityDetailsScreen extends StatefulWidget {
  const SecurityDetailsScreen({super.key});

  @override
  State<SecurityDetailsScreen> createState() => _SecurityDetailsScreenState();
}

class _SecurityDetailsScreenState extends State<SecurityDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter new password";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters long";
    }
    final weakPasswords = ["123456", "12345678", "123456789", "1234567890", "password", "qwerty", "abcdef"];
    if (weakPasswords.contains(value.toLowerCase()) || RegExp(r'^(\d)\1+$').hasMatch(value)) {
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
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;

    setState(() => _isLoading = true);

    final result = await ApiService.changePassword(
      oldPassword: oldPass,
      newPassword: newPass,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? "Previous password is incorrect. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Password & Security", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryBlue, width: 3),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.fingerprint, size: 56, color: AppTheme.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Previous / Old Password
              TextFormField(
                controller: _oldPasswordController,
                obscureText: _obscureOld,
                decoration: InputDecoration(
                  labelText: "Previous Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureOld ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please enter your previous password";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: "New Password",
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: _validateNewPassword,
              ),
              const SizedBox(height: 6),

              // Password Policy Instructions Box
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Password Rules: Min 8 chars, 1 Uppercase (A-Z), 1 Lowercase (a-z), 1 Number (0-9), 1 Special Char (@, #, \$, %). Simple passwords like 123456 are forbidden.",
                  style: TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.3),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.lock_clock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please confirm your new password";
                  }
                  if (val != _newPasswordController.text) {
                    return "Confirm Password does not match New Password";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _isLoading ? "Updating Password..." : "Update Password",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(height: 32),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: AppTheme.primaryBlue, size: 24),
                  ),
                  title: const Text("Bank Account Verify", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: const Text("Verify and lock your bank details via ₹1 Penny Drop", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BankVerifyScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
