import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upi_uri/qr_widget.dart';
import '../services/api_service.dart';
import '../widgets/processing_dialog.dart';

class FundRequestScreen extends StatefulWidget {
  const FundRequestScreen({super.key});

  @override
  State<FundRequestScreen> createState() => _FundRequestScreenState();
}

class _FundRequestScreenState extends State<FundRequestScreen> {
  final _utrController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _message = "";
  String _error = "";
  List<dynamic> _requests = [];
  bool _isUtrExact = false;
  final String _payeeVpa = "vp110064@okaxis";

  @override
  void initState() {
    super.initState();
    _utrController.addListener(_onUtrChanged);
    _loadRequestHistory();
  }

  @override
  void dispose() {
    _utrController.removeListener(_onUtrChanged);
    _utrController.dispose();
    super.dispose();
  }

  void _onUtrChanged() {
    setState(() {
      _isUtrExact = _utrController.text.trim().length == 12;
    });
  }

  Future<void> _loadRequestHistory() async {
    final list = await ApiService.getFundRequests();
    setState(() {
      _requests = list;
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      final cleanText = data.text!.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanText.length <= 12) {
        _utrController.text = cleanText;
      } else {
        _utrController.text = cleanText.substring(0, 12);
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final utrVal = _utrController.text.trim();
    if (utrVal.length != 12) {
      setState(() {
        _error = "UTR number must be exactly 12 digits";
      });
      return;
    }

    // Default amount 1200 for standard fund deposit request
    const double amtVal = 1200.0;

    await showProcessingDialog(context, "Verifying Deposit / UTR Details...");
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _message = "";
      _error = "";
    });

    final result = await ApiService.submitFundRequest(amtVal, utrVal);
    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      setState(() {
        _message = "Your deposit request has been submitted for approval!";
        _utrController.clear();
      });
      _loadRequestHistory();
    } else {
      setState(() {
        _error = result['error'] ?? "Failed to submit request";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Blue Header with 3D Wallet Illustration
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
                          "Add Money",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Add funds to your wallet",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 3D Wallet Badge Illustration
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
                          Icons.add,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 1. Scan & Pay Card Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            // Scan & Pay Pill Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Scan & Pay",
                                style: TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Scan QR Code using any UPI App",
                              style: TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // QR Code Centered Container
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.05),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: UpiQrCode(
                                payeeVpa: _payeeVpa,
                                payeeName: "EarnFarm",
                                amount: "1200",
                                txnRef: "TXN${DateTime.now().millisecondsSinceEpoch}",
                                size: 180,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Divider Row
                            const Row(
                              children: [
                                Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text("OR", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                Expanded(child: Divider(color: Color(0xFFCBD5E1))),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // UPI Logo Text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.account_balance, color: Color(0xFF1565C0), size: 18),
                                const SizedBox(width: 6),
                                const Text(
                                  "UPI",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1565C0),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    "✓",
                                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. UPI ID Box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.person_outline_rounded, color: Color(0xFF1565C0), size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "UPI ID",
                                    style: TextStyle(
                                      color: Color(0xFF1565C0),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _payeeVpa,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: const Icon(Icons.copy_rounded, color: Color(0xFF1565C0), size: 18),
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _payeeVpa));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("UPI ID copied to clipboard!")),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3. Enter UTR Number Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E8FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF7E22CE), size: 20),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Enter UTR Number",
                                  style: TextStyle(
                                    color: Color(0xFF7E22CE),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _utrController,
                              keyboardType: TextInputType.number,
                              maxLength: 12,
                              decoration: InputDecoration(
                                hintText: "Enter 12 Digit UTR Number",
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF7E22CE), width: 1.5),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.content_paste_rounded, color: Color(0xFF7E22CE), size: 20),
                                  onPressed: _pasteFromClipboard,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                counterText: "",
                              ),
                              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                              validator: (value) => (value == null || value.length != 12) ? "Please enter 12-digit UTR" : null,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Please enter exact 12 digits UTR number.",
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                ),
                                Text(
                                  "Exactly 12 digits",
                                  style: TextStyle(
                                    color: _isUtrExact ? const Color(0xFF22C55E) : const Color(0xFF7E22CE),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 4. Important Instructions Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFEF08A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFDE68A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.info_outline_rounded, color: Color(0xFFB45309), size: 16),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Important Instructions",
                                  style: TextStyle(
                                    color: Color(0xFFB45309),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInstructionBullet(Icons.monetization_on_outlined, "Minimum Add Money: ₹1200"),
                            _buildInstructionBullet(Icons.monetization_on_outlined, "Maximum Add Money: ₹12000"),
                            _buildInstructionBullet(Icons.access_time_rounded, "Only 12 Digit UTR number is allowed."),
                            _buildInstructionBullet(Icons.thumb_up_alt_outlined, "Funds will be added to your wallet after Admin approval."),
                            _buildInstructionBullet(Icons.access_time_rounded, "It may take some time for approval."),
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

                      // 5. Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleSubmit,
                          icon: const Icon(Icons.near_me_rounded, color: Colors.white, size: 20),
                          label: Text(
                            _isLoading ? "SUBMITTING..." : "SUBMIT",
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
                      const SizedBox(height: 24),

                      // Request History Section
                      if (_requests.isNotEmpty) ...[
                        const Row(
                          children: [
                            Text(
                              "Your Request History",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            final item = _requests[index];
                            final status = item['status'] as String;
                            Color statusColor = const Color(0xFFEF6C00);
                            if (status == 'APPROVED') statusColor = const Color(0xFF2E7D32);
                            if (status == 'REJECTED') statusColor = const Color(0xFFC62828);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: statusColor.withOpacity(0.1),
                                  child: Icon(
                                    Icons.account_balance_wallet,
                                    color: statusColor,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  "₹ ${(item['amount'] is num ? item['amount'] : double.tryParse(item['amount'].toString()) ?? 0.0).toStringAsFixed(2)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                                subtitle: Text("UTR: ${item['utr'] ?? ''}\n${item['createdAt'] != null ? DateTime.parse(item['createdAt']).toLocal().toString().substring(0, 16) : ''}", style: const TextStyle(fontSize: 10)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 9),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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

  Widget _buildInstructionBullet(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFD97706), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF78350F),
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
