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
  final String _payeeVpa = "vp110064@okaxis";
  bool _isCheckingUtr = false;
  final Map<String, bool> _utrCache = {};

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _utrController.addListener(_onUtrChanged);
    _loadRequestHistory();
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _utrController.removeListener(_onUtrChanged);
    _utrController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    setState(() {});
  }

  void _onUtrChanged() async {
    final text = _utrController.text.trim();
    if (text.length == 12 && RegExp(r'^[0-9]{12}$').hasMatch(text)) {
      if (!_utrCache.containsKey(text)) {
        setState(() {
          _isCheckingUtr = true;
        });
        final exists = await ApiService.checkUtrExists(text);
        if (mounted && _utrController.text.trim() == text) {
          setState(() {
            _utrCache[text] = exists;
            _isCheckingUtr = false;
          });
        }
      } else {
        setState(() {});
      }
    } else {
      setState(() {});
    }
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
        _message = "";
      });
      return;
    }

    // Check if UTR is already used in local history
    final bool isAlreadyUsedLocally = _requests.any((r) => r['utr']?.toString().trim() == utrVal);
    if (isAlreadyUsedLocally) {
      setState(() {
        _error = "UTR Number Already Used";
        _message = "";
      });
      return;
    }

    // Check system-wide UTR existence
    final bool existsSystemWide = await ApiService.checkUtrExists(utrVal);
    if (!mounted) return;
    if (existsSystemWide) {
      setState(() {
        _error = "UTR Number Already Used";
        _message = "";
      });
      return;
    }

    showProcessingDialog(context, "Verifying Deposit / UTR Details...");
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _message = "";
      _error = "";
    });

    try {
      final result = await ApiService.submitFundRequest(amtVal, utrVal);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        _isLoading = false;
      });

    if (result['success']) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Transaction Success !",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
          content: const Text(
            "We will verify your Transaction and get back to you in a Hour.",
            style: TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      setState(() {
        _error = result['error'] ?? "Failed to submit request";
        _message = "";
      });
    }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          _isLoading = false;
          _error = "Error: $e";
        });
      }
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
                              statusMsg = "Valid deposit amount (Multiple of ₹1,200)";
                              statusColor = const Color(0xFF16A34A);
                            } else if (isLessThanMin) {
                              borderColor = const Color(0xFFDC2626);
                              suffixIcon = const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
                              );
                              statusMsg = "Minimum amount is ₹1,200";
                              statusColor = const Color(0xFFDC2626);
                            } else if (isMoreThanMax) {
                              borderColor = const Color(0xFFDC2626);
                              suffixIcon = const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
                              );
                              statusMsg = "Maximum amount is ₹12,000";
                              statusColor = const Color(0xFFDC2626);
                            } else if (isNotMultiple) {
                              borderColor = const Color(0xFFDC2626);
                              suffixIcon = const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
                              );
                              statusMsg = "Amount must be in multiples of ₹1,200 (e.g. ₹1,200, ₹2,400, ₹3,600...)";
                              statusColor = const Color(0xFFDC2626);
                            }
                          } else {
                            statusMsg = "Minimum: ₹1,200 | Maximum: ₹12,000 (Multiples of ₹1,200)";
                            statusColor = const Color(0xFF1565C0);
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
                                      color: isTouched ? (isValidAmt ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2)) : const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isTouched ? (isValidAmt ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5)) : const Color(0xFF90CAF9)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isTouched ? (isValidAmt ? Icons.check_circle_rounded : Icons.error_rounded) : Icons.info_outline_rounded,
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
                          final bool isAlreadyUsed = _requests.any((r) => r['utr']?.toString().trim() == utrText) || (_utrCache[utrText] == true);
                          final bool isValidUtr = isTouched && isNumeric && utrText.length == 12 && !isAlreadyUsed && !_isCheckingUtr;

                          Color borderColor = const Color(0xFFE2E8F0);
                          Widget? suffixIcon = IconButton(
                            icon: const Icon(Icons.content_paste_rounded, color: Color(0xFF7E22CE), size: 20),
                            onPressed: _pasteFromClipboard,
                          );
                          String? utrStatusMsg;
                          Color utrStatusColor = const Color(0xFF16A34A);

                          if (isTouched) {
                            if (_isCheckingUtr) {
                              utrStatusMsg = "Checking UTR availability...";
                              utrStatusColor = const Color(0xFF1565C0);
                              borderColor = const Color(0xFF1565C0);
                            } else if (isValidUtr) {
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
                              utrStatusMsg = "Duplicate UTR Number Admitted";
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
                      Builder(
                        builder: (context) {
                          final String amtText = _amountController.text.trim();
                          final double? amt = double.tryParse(amtText);
                          final bool isValidAmt = amt != null && amt >= 1200 && amt <= 12000 && (amt % 1200 == 0);

                          final String utrText = _utrController.text.trim();
                          final bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(utrText);
                          final bool isAlreadyUsed = _requests.any((r) => r['utr']?.toString().trim() == utrText) || (_utrCache[utrText] == true);
                          final bool isValidUtr = utrText.length == 12 && isNumeric && !isAlreadyUsed && !_isCheckingUtr;

                          final bool canSubmit = !_isLoading && isValidAmt && isValidUtr;

                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: canSubmit ? _handleSubmit : null,
                              icon: Icon(
                                Icons.near_me_rounded,
                                color: canSubmit ? Colors.white : const Color(0xFF64748B),
                                size: 20,
                              ),
                              label: Text(
                                _isLoading ? "SUBMITTING..." : "SUBMIT",
                                style: TextStyle(
                                  color: canSubmit ? Colors.white : const Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canSubmit ? const Color(0xFF0D47A1) : const Color(0xFFCBD5E1),
                                disabledBackgroundColor: const Color(0xFFCBD5E1),
                                disabledForegroundColor: const Color(0xFF64748B),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: canSubmit ? 2 : 0,
                              ),
                            ),
                          );
                        },
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
