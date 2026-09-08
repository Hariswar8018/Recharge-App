import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/processing_dialog.dart';

class BankVerifyScreen extends StatefulWidget {
  const BankVerifyScreen({super.key});

  @override
  State<BankVerifyScreen> createState() => _BankVerifyScreenState();
}

class _BankVerifyScreenState extends State<BankVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _accountNoController = TextEditingController();
  final _ifscController = TextEditingController();

  bool _isVerified = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _holderNameController.dispose();
    _accountNoController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _checkVerificationStatus() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getProfile();
    setState(() => _isLoading = false);

    if (res['success'] == true && res['user'] != null) {
      final user = res['user'];
      final isVerified = user['bank_verified'] == 1 || user['bank_verified'] == true;
      setState(() {
        _isVerified = isVerified;
        if (user['bank_name'] != null && user['bank_name'].toString().isNotEmpty) {
          _bankNameController.text = user['bank_name'];
        }
        if (user['account_holder'] != null && user['account_holder'].toString().isNotEmpty) {
          _holderNameController.text = user['account_holder'];
        }
        if (user['account_no'] != null && user['account_no'].toString().isNotEmpty) {
          _accountNoController.text = user['account_no'];
        }
        if (user['ifsc'] != null && user['ifsc'].toString().isNotEmpty) {
          _ifscController.text = user['ifsc'];
        }
      });
    }
  }

  Future<void> _handlePennyDropVerify() async {
    if (!_formKey.currentState!.validate()) return;

    final bankName = _bankNameController.text.trim();
    final holderName = _holderNameController.text.trim();
    final accountNo = _accountNoController.text.trim();
    final ifsc = _ifscController.text.trim();

    await showProcessingDialog(context, "Initiating ₹1 Penny Drop Verification...");
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final res = await ApiService.verifyBankAccount(
      bankName: bankName,
      accountHolder: holderName,
      accountNo: accountNo,
      ifsc: ifsc,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (res['success'] == true) {
      setState(() {
        _isVerified = true;
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text("Verification Success", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            res['message'] ?? "₹1 Penny Drop verification successful! Your bank account details have been verified and locked securely.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A369D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['error'] ?? "Bank account verification failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: enabled ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: enabled ? const Color(0xFF0A369D) : Colors.grey),
            suffixIcon: !enabled ? const Icon(Icons.lock_rounded, color: Colors.green, size: 18) : null,
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          validator: validator,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Bank Account Verification",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0A369D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isVerified ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isVerified ? const Color(0xFF86EFAC) : const Color(0xFFFCD34D),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isVerified ? Icons.verified_rounded : Icons.pending_rounded,
                      color: _isVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isVerified ? "Bank Account Verified ✓" : "Verification Required",
                            style: TextStyle(
                              color: _isVerified ? const Color(0xFF15803D) : const Color(0xFFB45309),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isVerified
                                ? "Details are locked for secure payouts via ₹1 Penny Drop."
                                : "Submit details to verify via ₹1 Penny Drop.",
                            style: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Form Container
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildField(
                      label: "Bank Name",
                      controller: _bankNameController,
                      icon: Icons.account_balance_rounded,
                      enabled: !_isVerified,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter Bank Name" : null,
                    ),
                    _buildField(
                      label: "Account Holder Name",
                      controller: _holderNameController,
                      icon: Icons.person_outline_rounded,
                      enabled: !_isVerified,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter Account Holder Name" : null,
                    ),
                    _buildField(
                      label: "Account Number",
                      controller: _accountNoController,
                      icon: Icons.numbers_rounded,
                      enabled: !_isVerified,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter Account Number" : null,
                    ),
                    _buildField(
                      label: "IFSC Code",
                      controller: _ifscController,
                      icon: Icons.code_rounded,
                      enabled: !_isVerified,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter IFSC Code" : null,
                    ),

                    const SizedBox(height: 10),

                    if (!_isVerified)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handlePennyDropVerify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A369D),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.verified_user_rounded, color: Colors.white),
                          label: const Text(
                            "Verify & Save (₹1 Penny Drop)",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_rounded, color: Colors.grey, size: 16),
                            SizedBox(width: 6),
                            Text(
                              "Editing disabled for verified accounts",
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
