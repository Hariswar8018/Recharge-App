import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/processing_dialog.dart';

class IdSubscriptionScreen extends StatefulWidget {
  const IdSubscriptionScreen({super.key});

  @override
  State<IdSubscriptionScreen> createState() => _IdSubscriptionScreenState();
}

class _IdSubscriptionScreenState extends State<IdSubscriptionScreen> {
  final TextEditingController _mobileController = TextEditingController(text: "7989293968");
  
  double _fundWalletBalance = 1200.0;
  String _userName = "Raju Reddy";
  String _userMobile = "7989293968";
  String _userEmail = "srdigitalseva99@gmail.com";
  String _joiningDate = "28-08-2025";
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _lookupUserName = "Raju Reddy";

  @override
  void initState() {
    super.initState();
    _mobileController.addListener(_onMobileChanged);
    _loadUserData();
  }

  void _onMobileChanged() {
    final text = _mobileController.text.trim();
    if (text.length == 10) {
      setState(() {
        _lookupUserName = text == _userMobile ? _userName : "Raju Reddy";
      });
    } else {
      if (_lookupUserName.isNotEmpty) {
        setState(() {
          _lookupUserName = "";
        });
      }
    }
  }

  @override
  void dispose() {
    _mobileController.removeListener(_onMobileChanged);
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final response = await ApiService.getProfile();
    if (response['success'] == true) {
      final user = response['user'];
      setState(() {
        _fundWalletBalance = double.tryParse(user['fund_wallet_balance']?.toString() ?? "1200.0") ?? 1200.0;
        _userName = user['name']?.toString() ?? "Raju Reddy";
        _userMobile = user['mobile']?.toString() ?? "7989293968";
        _userEmail = user['email']?.toString() ?? "srdigitalseva99@gmail.com";
        if (user['created_at'] != null) {
          try {
            final dt = DateTime.parse(user['created_at'].toString());
            _joiningDate = "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
          } catch (_) {}
        }
        if (_mobileController.text.isEmpty) {
          _mobileController.text = _userMobile;
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSubscribe() async {
    final mobile = _mobileController.text.trim();
    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10-digit mobile number."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_fundWalletBalance < 1200.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Insufficient Fund Wallet balance! Please add funds."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    showProcessingDialog(context, "Activating Subscription...");

    final res = await ApiService.activateUser(mobile: mobile);
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (res['success'] == true) {
      setState(() {
        _fundWalletBalance -= 1200.0;
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text("Subscription Active", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text("ID $mobile activated successfully for ₹1200.00!"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A369D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? "Activation failed. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A369D),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "ID Subscription",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Subscribe to your ID",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge icon
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.badge_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // White Content Sheet
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A369D)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Fund Wallet Balance Card
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2FE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Color(0xFF0284C7),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Text(
                                      "Fund Wallet Balance",
                                      style: TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "₹${_fundWalletBalance.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFF0A369D),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // 2. Enter Mobile Number Section
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0A369D),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.phone_rounded, color: Colors.white, size: 14),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Enter Mobile Number",
                                  style: TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: TextField(
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.phone_outlined, color: Color(0xFF64748B), size: 20),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                            if (_lookupUserName.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF86EFAC)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "User Name: $_lookupUserName",
                                        style: const TextStyle(
                                          color: Color(0xFF15803D),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF16A34A),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        "OK",
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            const Text(
                              "Enter the mobile number (ID) you want to subscribe.",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 3. User Details Section
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0A369D),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 14),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "User Details",
                                  style: TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                children: [
                                  _buildUserDetailRow(
                                    icon: Icons.badge_outlined,
                                    label: "ID Number",
                                    value: _userMobile,
                                  ),
                                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                  _buildUserDetailRow(
                                    icon: Icons.person_outline,
                                    label: "Name",
                                    value: _userName,
                                  ),
                                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                  _buildUserDetailRow(
                                    icon: Icons.phone_outlined,
                                    label: "Mobile Number",
                                    value: _userMobile,
                                  ),
                                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                  _buildUserDetailRow(
                                    icon: Icons.email_outlined,
                                    label: "Email ID",
                                    value: _userEmail,
                                  ),
                                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                  _buildUserDetailRow(
                                    icon: Icons.calendar_today_outlined,
                                    label: "Joining Date",
                                    value: _joiningDate,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 4. Amount to Pay Section
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0A369D),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.currency_rupee_rounded, color: Colors.white, size: 14),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Amount to Pay",
                                  style: TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Subscription Amount",
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "₹1200.00",
                                      style: TextStyle(
                                        color: Color(0xFF0A369D),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 5. Important Instructions Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.info_rounded, color: Color(0xFFD97706), size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        "Important Instructions",
                                        style: TextStyle(
                                          color: Color(0xFFD97706),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInstructionItem(Icons.info_outline, "Subscription amount is non-refundable."),
                                  const SizedBox(height: 8),
                                  _buildInstructionItem(Icons.help_outline_rounded, "Ensure the mobile number is correct."),
                                  const SizedBox(height: 8),
                                  _buildInstructionItem(Icons.account_balance_wallet_outlined, "Your ID will be activated after successful payment."),
                                  const SizedBox(height: 8),
                                  _buildInstructionItem(Icons.access_time_rounded, "Contact support for any issues."),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Bottom Subscribe Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _handleSubscribe,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0A369D),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.card_membership_rounded, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "SUBSCRIBE NOW",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
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

  Widget _buildUserDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0A369D), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFD97706), size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF78350F),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
