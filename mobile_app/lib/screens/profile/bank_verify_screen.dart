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
  Map<String, dynamic> _visibilitySettings = {};

  @override
  void initState() {
    super.initState();
    _bankNameController.addListener(_onFieldChanged);
    _ifscController.addListener(_onFieldChanged);
    _checkVerificationStatus();
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _bankNameController.removeListener(_onFieldChanged);
    _ifscController.removeListener(_onFieldChanged);
    _bankNameController.dispose();
    _holderNameController.dispose();
    _accountNoController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _checkVerificationStatus() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getProfile();
    final v = await ApiService.getVisibility();
    setState(() => _isLoading = false);

    if (mounted) {
      setState(() {
        _visibilitySettings = v;
      });
    }

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
    final bankName = _bankNameController.text.trim();
    final holderName = _holderNameController.text.trim();
    final accountNo = _accountNoController.text.trim();
    final ifsc = _ifscController.text.trim();

    if (bankName.toLowerCase().contains('icici') || ifsc.toLowerCase().startsWith('icic')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ICICI payout unavailable. Use another bank"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    showProcessingDialog(context, "Verifying Bank Account...");
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await ApiService.verifyBankAccount(
        bankName: bankName,
        accountHolder: holderName,
        accountNo: accountNo,
        ifsc: ifsc,
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      setState(() {
        _isLoading = false;
      });

    if (res['success'] == true) {
      setState(() {
        _isVerified = true;
        if (res['nameAtBank'] != null && res['nameAtBank'].toString().isNotEmpty) {
          _holderNameController.text = res['nameAtBank'];
        }
        if (res['bankName'] != null && res['bankName'].toString().isNotEmpty) {
          _bankNameController.text = res['bankName'];
        }
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
            res['message'] ?? "Bank Account verification successful! Your bank account details have been verified and locked securely.",
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
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: onChanged,
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
    final String bankNameInput = _bankNameController.text.trim().toLowerCase();
    final String ifscInput = _ifscController.text.trim().toLowerCase();
    final bool isIciciError = bankNameInput.contains("icici") || ifscInput.startsWith("icic");

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
                                ? "Details are locked for secure payouts."
                                : "Submit details to verify your bank account.",
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
                      onChanged: (val) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Please enter Bank Name";
                        }
                        if (v.trim().toLowerCase().contains("icici")) {
                          return "ICICI payout unavailable. Use another bank";
                        }
                        return null;
                      },
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
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Please enter Account Number";
                        }
                        final cleanAcc = v.trim();
                        if (!RegExp(r'^\d+$').hasMatch(cleanAcc)) {
                          return "Account Number must contain digits only";
                        }
                        if (cleanAcc.length < 9 || cleanAcc.length > 18) {
                          return "Account Number must be 9 to 18 digits long";
                        }
                        return null;
                      },
                    ),
                    _buildField(
                      label: "IFSC Code",
                      controller: _ifscController,
                      icon: Icons.code_rounded,
                      enabled: !_isVerified,
                      onChanged: (val) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Please enter IFSC Code";
                        }
                        final cleanIfsc = v.trim().toUpperCase();
                        if (cleanIfsc.startsWith("ICIC")) {
                          return "ICICI payout unavailable. Use another bank";
                        }
                        if (cleanIfsc.length != 11) {
                          return "IFSC Code must be exactly 11 characters long";
                        }
                        final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
                        if (!ifscRegex.hasMatch(cleanIfsc)) {
                          return "Invalid IFSC format (e.g. SBIN0001234: 4 letters, 0, 6 branch digits/letters)";
                        }
                        return null;
                      },
                    ),

                    if (isIciciError && !_isVerified) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "ICICI payout unavailable. Use another bank",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    const SizedBox(height: 10),

                    if (!_isVerified)
                      Builder(
                        builder: (context) {
                          final String vis = (_visibilitySettings['sec_bank_verification_visibility'] ?? 'Show').toString();
                          final bool enabled = _visibilitySettings['sec_bank_verification_enabled'] != false && _visibilitySettings['sec_bank_verification_enabled_bool'] != 'false';
                          final String ruleMode = (_visibilitySettings['sec_bank_verification_rule_mode'] ?? '').toString();
                          final bool isBankDisabled = vis == 'Hide' || !enabled || ruleMode.contains('Disabled') || ruleMode.contains('Maintenance');
                          final bool isBtnDisabled = _isLoading || isIciciError || isBankDisabled;
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: isBtnDisabled ? null : _handlePennyDropVerify,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (isIciciError || isBankDisabled) ? Colors.grey : const Color(0xFF0A369D),
                                    disabledBackgroundColor: Colors.grey.shade400,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.verified_user_rounded, color: Colors.white),
                                  label: Text(
                                    isBankDisabled ? "Verification Disabled" : "Verify & Save Bank Account",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              ),
                              if (isBankDisabled) ...[
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
                                          _visibilitySettings['sec_bank_verification_notice']?.toString().isNotEmpty == true
                                              ? _visibilitySettings['sec_bank_verification_notice']
                                              : "Bank Account Verification service is currently disabled by Administrator.",
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
