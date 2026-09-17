import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upi_uri/qr_widget.dart';
import '../../services/api_service.dart';
import '../../widgets/processing_dialog.dart';

class FundRequestScreen extends StatefulWidget {
  const FundRequestScreen({super.key});

  @override
  State<FundRequestScreen> createState() => _FundRequestScreenState();
}

class _FundRequestScreenState extends State<FundRequestScreen> {
  final _amountController = TextEditingController(text: "1200");
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
    _amountController.dispose();
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

    final amtVal = double.tryParse(_amountController.text.trim()) ?? 1200.0;
    if (amtVal < 1200.0 || amtVal > 12000.0 || (amtVal % 1200.0 != 0)) {
      setState(() {
        _error = "Deposit amount must be between ₹1,200 and ₹12,000 in multiples of ₹1,200";
      });
      return;
    }

    final utrVal = _utrController.text.trim();
    if (utrVal.length != 12) {
      setState(() {
        _error = "UTR number must be exactly 12 digits";
      });
      return;
    }

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
                                payeeName: "SR Digital Seva Kendram",
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

                      // Amount Input Card
                      Builder(
                        builder: (context) {
                          final String text = _amountController.text.trim();
                          final double? amt = double.tryParse(text);
                          final bool isTouched = text.isNotEmpty;
                          final bool isValidAmt = amt != null && amt >= 1200 && amt <= 12000 && (amt % 1200 == 0);
                          final bool isLessThanMin = amt != null && amt < 1200;
                          final bool isMoreThanMax = amt != null && amt > 12000;
                          final bool isNotMultiple = amt != null && amt >= 1200 && amt <= 12000 && (amt % 1200 != 0);

                          Color borderColor = const Color(0xFFCBD5E1);
                          Widget? suffixIcon;
                          String? statusMsg;
                          Color statusColor = const Color(0xFF16A34A);

                          if (isTouched) {
                            if (isValidAmt) {
                              borderColor = const Color(0xFF16A34A);
                              suffixIcon = const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 22),
                              );
                              statusMsg = "Valid amount (Multiple of ₹1200)";
                              statusColor = const Color(0xFF16A34A);
                            } else if (isLessThanMin) {
                              borderColor = const Color(0xFFDC2626);
                              suffixIcon = const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
                              );
                              statusMsg = "Minimum amount is ₹1200";
                              statusColor = const Color(0xFFDC2626);
                            } else if (isMoreThanMax) {
                              borderColor = const Color(0xFFDC2626);
                              suffixIcon = const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
                              );
                              statusMsg = "Maximum amount is ₹12000";
                              statusColor = const Color(0xFFDC2626);
                            } else if (isNotMultiple) {
                              borderColor = const Color(0xFFDC2626);
                              suffixIcon = const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
                              );
                              statusMsg = "Amount must be in multiples of ₹1200 (₹1200 - ₹12000 only)";
                              statusColor = const Color(0xFFDC2626);
                            }
                          }

                          return Container(
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
                                  "Deposit Amount (₹)",
                                  style: TextStyle(
                                    color: Color(0xFF1565C0),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isTouched && !isValidAmt ? const Color(0xFFFEF2F2) : (isValidAmt ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderColor, width: isTouched ? 1.8 : 1.0),
                                  ),
                                  child: TextFormField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF1565C0)),
                                      suffixIcon: suffixIcon,
                                      hintText: "Enter Amount",
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                  ),
                                ),
                                if (statusMsg != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isValidAmt ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isValidAmt ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isValidAmt ? Icons.check_circle_rounded : Icons.error_rounded,
                                          color: statusColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            statusMsg,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                // Quick Amount Chips (Multiples of 1200)
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  alignment: WrapAlignment.center,
                                  children: [1200, 2400, 3600, 4800, 6000, 12000].map((amtVal) {
                                    return ChoiceChip(
                                      label: Text("₹$amtVal", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      selected: _amountController.text == amtVal.toString(),
                                      selectedColor: const Color(0xFF1565C0),
                                      labelStyle: TextStyle(
                                        color: _amountController.text == amtVal.toString() ? Colors.white : const Color(0xFF1565C0),
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() {
                                            _amountController.text = amtVal.toString();
                                          });
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // 3. Enter UTR Number Card
                      Builder(
                        builder: (context) {
                          final String utrText = _utrController.text.trim();
                          final bool isTouched = utrText.isNotEmpty;
                          final bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(utrText);
                          final bool isLessThan12 = utrText.length < 12;
                          final bool isMoreThan12 = utrText.length > 12;
                          final bool isAlreadyUsed = _requests.any((r) => r['utr_number']?.toString().trim() == utrText);
                          final bool isValidUtr = isTouched && isNumeric && utrText.length == 12 && !isAlreadyUsed;

                          Color borderColor = const Color(0xFFE2E8F0);
                          Widget? suffixIcon = IconButton(
                            icon: const Icon(Icons.content_paste_rounded, color: Color(0xFF7E22CE), size: 20),
                            onPressed: _pasteFromClipboard,
                          );
                          String? utrStatusMsg;
                          Color utrStatusColor = const Color(0xFF16A34A);

                          if (isTouched) {
                            if (isValidUtr) {
                              borderColor = const Color(0xFF16A34A);
                              suffixIcon = const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 22),
                              );
                              utrStatusMsg = "Valid 12 digit UTR number";
                              utrStatusColor = const Color(0xFF16A34A);
                            } else if (!isNumeric) {
                              borderColor = const Color(0xFFDC2626);
                              suffixIcon = const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
                              );
                              utrStatusMsg = "Please enter only numbers (0-9)";
                              utrStatusColor = const Color(0xFFDC2626);
                            } else if (isAlreadyUsed) {
                              borderColor = const Color(0xFFDC2626);
                              suffixIcon = const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
                              );
                              utrStatusMsg = "This UTR number has already been used. Please enter a different UTR number.";
                              utrStatusColor = const Color(0xFFDC2626);
                            } else if (isLessThan12) {
                              borderColor = const Color(0xFFDC2626);
                              suffixIcon = const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
                              );
                              utrStatusMsg = "Please enter 12 digit UTR number";
                              utrStatusColor = const Color(0xFFDC2626);
                            } else if (isMoreThan12) {
                              borderColor = const Color(0xFFDC2626);
                              suffixIcon = const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
                              );
                              utrStatusMsg = "Please enter only 12 digit UTR number";
                              utrStatusColor = const Color(0xFFDC2626);
                            }
                          }

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF5FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: utrStatusMsg != null && !isValidUtr ? const Color(0xFFFCA5A5) : const Color(0xFFE9D5FF)),
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
                                Container(
                                  decoration: BoxDecoration(
                                    color: isTouched && !isValidUtr ? const Color(0xFFFEF2F2) : (isValidUtr ? const Color(0xFFF0FDF4) : Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderColor, width: isTouched ? 1.8 : 1.0),
                                  ),
                                  child: TextFormField(
                                    controller: _utrController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 12,
                                    decoration: InputDecoration(
                                      hintText: "Enter 12 Digit UTR Number",
                                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                      border: InputBorder.none,
                                      suffixIcon: suffixIcon,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      counterText: "",
                                    ),
                                    style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B), fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (utrStatusMsg != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isValidUtr ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isValidUtr ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isValidUtr ? Icons.check_circle_rounded : Icons.error_rounded,
                                          color: utrStatusColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            utrStatusMsg,
                                            style: TextStyle(
                                              color: utrStatusColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
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
                            _buildInstructionBullet(Icons.monetization_on_outlined, "Deposit amount must be ₹1200 to ₹12000 in multiples of ₹1200."),
                            _buildInstructionBullet(Icons.access_time_rounded, "UTR number must be exactly 12 digits."),
                            _buildInstructionBullet(Icons.highlight_off_rounded, "Already used UTR number will not be allowed."),
                            _buildInstructionBullet(Icons.thumb_up_alt_outlined, "Funds will be added to your wallet after Admin approval."),
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
