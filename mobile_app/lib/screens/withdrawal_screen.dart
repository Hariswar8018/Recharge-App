import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/processing_dialog.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _amountController = TextEditingController(text: "1000");
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  double _mainBalance = 1200.0;
  String _message = "";
  String _error = "";
  String _selectedMethod = "UPI"; // "UPI" or "BANK"

  String _userUpiId = "raju@ybl";
  String _bankName = "State Bank of India";
  String _accountNo = "XXXXXX4567";

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _loadBalanceAndProfile();
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    setState(() {});
  }

  void _setMaxAmount() {
    _amountController.text = _mainBalance.toInt().toString();
    setState(() {});
  }

  Future<void> _loadBalanceAndProfile() async {
    final profileRes = await ApiService.getProfile();
    if (profileRes['success']) {
      final user = profileRes['user'];
      final balance = double.tryParse(user['main_wallet_balance']?.toString() ?? "1200.0") ?? 1200.0;
      final mobile = user['mobileNumber'] ?? "7989293968";
      setState(() {
        _mainBalance = balance;
        _userUpiId = user['upi_id'] ?? "$mobile@ybl";
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final amtVal = double.tryParse(_amountController.text.trim());
    if (amtVal == null || amtVal < 500) {
      setState(() {
        _error = "Minimum withdrawal amount is ₹500";
      });
      return;
    }

    if (amtVal > _mainBalance) {
      setState(() {
        _error = "Insufficient balance in Main Wallet";
      });
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _error = "Please enter your login password";
      });
      return;
    }

    await showProcessingDialog(context, "Processing Cashout Request...");
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _message = "";
      _error = "";
    });

    final result = await ApiService.submitCashout(
      amount: amtVal,
      paymentMethod: _selectedMethod,
      details: _selectedMethod == "UPI" ? _userUpiId : "$_bankName - $_accountNo",
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      setState(() {
        _message = "Your cashout request of ₹${amtVal.toStringAsFixed(2)} has been submitted successfully!";
        _passwordController.clear();
      });
      _loadBalanceAndProfile();
    } else {
      setState(() {
        _error = result['error'] ?? "Failed to submit cashout request";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double amtVal = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final double processingFee = amtVal * 0.15; // 15% Fee
    final double youWillReceive = amtVal - processingFee > 0 ? amtVal - processingFee : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Blue Header with 3D Wallet Badge
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A369D), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cash Out",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Withdraw your money",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 3D Wallet Badge Illustration with Upward Arrow
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Color(0xFFFFD54F),
                          size: 34,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 1. Available Balance Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D47A1),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D47A1).withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Color(0xFF0D47A1),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Available Balance",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹${_mainBalance.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white.withOpacity(0.2),
                              size: 40,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. Enter Amount Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  "Enter Amount",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "Minimum: ₹500",
                                  style: TextStyle(
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Text(
                                    "₹",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                hintText: "Enter amount",
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              validator: (val) {
                                if (val == null || val.isEmpty) return "Please enter amount";
                                final parsed = double.tryParse(val);
                                if (parsed == null || parsed < 500) return "Minimum withdrawal is ₹500";
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Enter amount to withdraw",
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                ),
                                InkWell(
                                  onTap: _setMaxAmount,
                                  child: const Text(
                                    "Max",
                                    style: TextStyle(
                                      color: Color(0xFF1565C0),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Select Method Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Select Method",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Option 1: UPI
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedMethod = "UPI";
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _selectedMethod == "UPI" ? const Color(0xFFEFF6FF) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedMethod == "UPI" ? const Color(0xFF1565C0) : const Color(0xFFE2E8F0),
                                    width: _selectedMethod == "UPI" ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFCBD5E1)),
                                      ),
                                      child: const Text(
                                        "UPI",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF1565C0),
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "UPI ${_selectedMethod == 'UPI' ? '(Selected)' : ''}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _userUpiId,
                                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_selectedMethod == "UPI") ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          "Selected",
                                          style: TextStyle(
                                            color: Color(0xFF2E7D32),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Icon(
                                      _selectedMethod == "UPI" ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                      color: _selectedMethod == "UPI" ? const Color(0xFF1565C0) : const Color(0xFF94A3B8),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Option 2: Bank Account
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedMethod = "BANK";
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _selectedMethod == "BANK" ? const Color(0xFFEFF6FF) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedMethod == "BANK" ? const Color(0xFF1565C0) : const Color(0xFFE2E8F0),
                                    width: _selectedMethod == "BANK" ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.account_balance, color: Color(0xFF1565C0), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Bank Account",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "$_bankName • $_accountNo",
                                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      _selectedMethod == "BANK" ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                      color: _selectedMethod == "BANK" ? const Color(0xFF1565C0) : const Color(0xFF94A3B8),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. Summary Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Summary",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildSummaryRow("Withdrawal Amount", "₹${amtVal.toStringAsFixed(2)}", isBold: true),
                            _buildSummaryRow("Processing Fee (15%)", "- ₹${processingFee.toStringAsFixed(2)}", textColor: const Color(0xFFDC2626)),
                            const Divider(color: Color(0xFFE2E8F0), height: 20),
                            _buildSummaryRow("You Will Receive", "₹${youWillReceive.toStringAsFixed(2)}", isBold: true, isLarge: true, textColor: const Color(0xFF22C55E)),
                            const SizedBox(height: 14),

                            // Light blue Info Box
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Icon(Icons.info_outline_rounded, color: Color(0xFF1565C0), size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "15% processing fee will be deducted from the withdrawal amount. Requests are usually processed within 24 hours.",
                                      style: TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontSize: 11,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. Login Password Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Login Password",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
                                hintText: "Enter your login password",
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: const Color(0xFF64748B),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/forgot-password');
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_message.isNotEmpty) ...[
                        Text(_message, style: const TextStyle(color: Color(0xFF22C55E), fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                      ],
                      if (_error.isNotEmpty) ...[
                        Text(_error, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                      ],

                      // 6. Submit Button & Security Footer
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleSubmit,
                          icon: const Icon(Icons.near_me_rounded, color: Colors.white, size: 20),
                          label: Text(
                            _isLoading ? "PROCESSING..." : "REQUEST CASHOUT",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.shield_outlined, color: Color(0xFF94A3B8), size: 14),
                          SizedBox(width: 6),
                          Text(
                            "Your transaction is 100% secure",
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String val, {
    bool isBold = false,
    bool isLarge = false,
    Color textColor = const Color(0xFF1E293B),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? const Color(0xFF1E293B) : const Color(0xFF64748B),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isLarge ? 14 : 13,
            ),
          ),
          Text(
            val,
            style: TextStyle(
              color: textColor,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              fontSize: isLarge ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
