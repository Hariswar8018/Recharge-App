import 'dart:async';
import 'dart:convert';
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
  final String _defaultPayeeVpa = "vp110064@okaxis";
  bool _isCheckingUtr = false;
  final Map<String, bool> _utrCache = {};
  Map<String, dynamic> _settings = {};
  Map<String, dynamic>? _fundStatus;
  bool _isLoadingStatus = false;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _amountController.text = "1200";
    _amountController.addListener(_onAmountChanged);
    _utrController.addListener(_onUtrChanged);
    _loadSettings();
    _fetchFundStatus(showLoading: true);
    _loadRequestHistory();

    // Auto-refresh status & history every 4 seconds so Admin approval is reflected instantly
    _statusTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        _fetchFundStatus(showLoading: false);
        _loadRequestHistory();
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _utrController.removeListener(_onUtrChanged);
    _utrController.dispose();
    super.dispose();
  }

  Future<void> _fetchFundStatus({bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _isLoadingStatus = true;
      });
    }
    final status = await ApiService.getFundStatus();
    if (mounted) {
      setState(() {
        _fundStatus = status;
        _isLoadingStatus = false;
      });
    }
  }

  Future<void> _loadSettings() async {
    try {
      final vis = await ApiService.getVisibility();
      final raw = (vis['raw_settings'] as Map<String, dynamic>?) ?? {};
      if (mounted) {
        setState(() {
          _settings = {...vis, ...raw};
          _amountController.text = "1200";
        });
      }
    } catch (_) {}
  }

  bool _boolSetting(String key, {bool defaultValue = true}) {
    if (!_settings.containsKey(key)) return defaultValue;
    final val = _settings[key];
    if (val == true || val == 'true' || val == 1 || val == '1' || val == 'Show' || val == 'Enable') return true;
    if (val == false || val == 'false' || val == 0 || val == '0' || val == 'Hide' || val == 'Disable') return false;
    return defaultValue;
  }

  String _stringSetting(String key, {String defaultValue = ''}) {
    final val = _settings[key];
    if (val == null) return defaultValue;
    return val.toString();
  }

  bool get isAddMoneyDisabled =>
      _stringSetting('add_money_section_visibility') == 'Hide' ||
      _stringSetting('add_money_enabled') == 'false' ||
      _stringSetting('add_money_enabled_bool') == 'false';

  bool get showQrCode => _boolSetting('status_upi_qr', defaultValue: true);
  String get customQrUrl => _stringSetting('upi_qr_url');

  bool get showUpiId => _boolSetting('status_upi_id', defaultValue: true);
  String get payeeVpa {
    final val = _stringSetting('upi_vpa_id', defaultValue: _defaultPayeeVpa).trim();
    return val.isNotEmpty ? val : _defaultPayeeVpa;
  }
  String get payeeName {
    final val = _stringSetting('upi_payee_name', defaultValue: "EarnFarm").trim();
    return val.isNotEmpty ? val : "EarnFarm";
  }

  bool get statusMinAddMoney => _boolSetting('status_min_add_money', defaultValue: true);
  double get minAddMoney => statusMinAddMoney
      ? (double.tryParse(_stringSetting('min_add_money', defaultValue: '1200')) ?? 1200.0)
      : 0.0;

  bool get statusMaxAddMoney => _boolSetting('status_max_add_money', defaultValue: true);
  double get maxAddMoney => statusMaxAddMoney
      ? (double.tryParse(_stringSetting('max_add_money', defaultValue: '12000')) ?? 12000.0)
      : 999999999.0;

  bool get showPresetButtons => _boolSetting('status_preset_amounts', defaultValue: true);
  List<String> get presetAmountsList {
    final raw = _stringSetting('preset_amounts', defaultValue: '100,500,1000,2000,5000');
    return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  bool get isUtrRequired => _boolSetting('status_utr_rule', defaultValue: true) && _stringSetting('utr_number_rule') != 'Disable (Optional)';

  bool get showInstructions => _boolSetting('status_add_instructions', defaultValue: true);
  String get instructionsText => _stringSetting('add_money_instructions');

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
    if (mounted) {
      setState(() {
        _requests = list;
      });
    }
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
    if (isAddMoneyDisabled) {
      setState(() {
        _error = "Add Money feature is currently disabled by Administrator.";
      });
      return;
    }

    final amtVal = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (statusMinAddMoney && amtVal < minAddMoney) {
      setState(() {
        _error = "Minimum deposit amount is ₹${minAddMoney.toStringAsFixed(0)}";
      });
      return;
    }
    if (statusMaxAddMoney && amtVal > maxAddMoney) {
      setState(() {
        _error = "Maximum deposit amount is ₹${maxAddMoney.toStringAsFixed(0)}";
      });
      return;
    }

    final utrVal = _utrController.text.trim();
    if (isUtrRequired) {
      if (utrVal.length != 12) {
        setState(() {
          _error = "UTR number must be exactly 12 digits";
          _message = "";
        });
        return;
      }

      final bool isAlreadyUsedLocally = _requests.any((r) => r['utr']?.toString().trim() == utrVal);
      if (isAlreadyUsedLocally) {
        setState(() {
          _error = "UTR Number Already Used";
          _message = "";
        });
        return;
      }

      final bool existsSystemWide = await ApiService.checkUtrExists(utrVal);
      if (!mounted) return;
      if (existsSystemWide) {
        setState(() {
          _error = "UTR Number Already Used";
          _message = "";
        });
        return;
      }
    }

    showProcessingDialog(context, "Verifying Deposit Details...");
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _message = "";
      _error = "";
    });

    try {
      final result = await ApiService.submitFundRequest(
        amtVal,
        utrVal.isNotEmpty ? utrVal : "NOUTR${DateTime.now().millisecondsSinceEpoch}",
      );
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        _utrController.clear();
        await _fetchFundStatus();
        await _loadRequestHistory();
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
              "We will verify your Transaction and get back to you within an hour.",
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

  Widget _buildQrDisplay() {
    final url = customQrUrl.trim();
    if (url.isNotEmpty) {
      try {
        if (url.startsWith('data:image')) {
          final base64Str = url.split(',').last;
          return Image.memory(
            base64Decode(base64Str),
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          );
        } else if (url.startsWith('http')) {
          return Image.network(
            url,
            width: 180,
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildFallbackQr(),
          );
        }
      } catch (_) {}
    }
    return _buildFallbackQr();
  }

  Widget _buildFallbackQr() {
    final amt = _amountController.text.trim();
    return UpiQrCode(
      payeeVpa: payeeVpa,
      payeeName: payeeName,
      amount: amt.isNotEmpty ? amt : minAddMoney.toStringAsFixed(0),
      txnRef: "TXN${DateTime.now().millisecondsSinceEpoch}",
      size: 180,
    );
  }

  Widget _buildPresetButtons() {
    return const SizedBox.shrink();
  }

  Widget _buildStatusBanner() {
    if (_isLoadingStatus) {
      return Container(
        margin: const EdgeInsets.only(bottom:14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: const [
            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text("Checking request status...", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          ],
        ),
      );
    }

    final status = (_fundStatus?['status'] as String?) ?? 'AVAILABLE';
    final message = (_fundStatus?['message'] as String?) ?? 'Next Request Available';

    Color bgColor;
    Color borderColor;
    Color textColor;
    Color titleColor;
    IconData icon;
    String title;

    switch (status) {
      case 'PENDING':
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFDE68A);
        textColor = const Color(0xFFD97706);
        titleColor = const Color(0xFFB45309);
        icon = Icons.hourglass_bottom_rounded;
        title = "STATUS: PENDING APPROVAL";
        break;
      case 'APPROVED_CYCLE_ACTIVE':
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFBBF7D0);
        textColor = const Color(0xFF16A34A);
        titleColor = const Color(0xFF15803D);
        icon = Icons.check_circle_rounded;
        title = "STATUS: APPROVED (CYCLE ACTIVE)";
        break;
      case 'REJECTED':
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFCA5A5);
        textColor = const Color(0xFFDC2626);
        titleColor = const Color(0xFFB91C1C);
        icon = Icons.cancel_rounded;
        title = "STATUS: REJECTED";
        break;
      case 'AVAILABLE':
      default:
        bgColor = const Color(0xFFF0F9FF);
        borderColor = const Color(0xFFBAE6FD);
        textColor = const Color(0xFF0284C7);
        titleColor = const Color(0xFF0369A1);
        icon = Icons.add_circle_outline_rounded;
        title = "STATUS: NEXT REQUEST AVAILABLE";
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom:14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestHistoryCard() {
    if (_requests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 18),
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
            children: const [
              Icon(Icons.history_rounded, color: Color(0xFF1565C0), size: 20),
              SizedBox(width: 8),
              Text(
                "Request History",
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _requests.length,
            separatorBuilder: (_, __) => const Divider(height: 16, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final req = _requests[index];
              final String statusStr = (req['status'] ?? 'pending').toString().toLowerCase();
              final String utr = req['utr'] ?? 'N/A';
              final String amt = (req['amount'] ?? 1200).toString().replaceAll(RegExp(r'[+\-₹?\s]|Rs\.?|INR', caseSensitive: false), '').trim();
              final String date = req['createdAt'] != null
                  ? req['createdAt'].toString().split('T').first
                  : 'Recent';

              Color badgeBg;
              Color badgeFg;
              String badgeText;

              if (statusStr == 'approved') {
                badgeBg = const Color(0xFFDCFCE7);
                badgeFg = const Color(0xFF15803D);
                badgeText = "APPROVED";
              } else if (statusStr == 'rejected') {
                badgeBg = const Color(0xFFFEE2E2);
                badgeFg = const Color(0xFFB91C1C);
                badgeText = "REJECTED";
              } else {
                badgeBg = const Color(0xFFFFFBEB);
                badgeFg = const Color(0xFFB45309);
                badgeText = "PENDING";
              }

              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹$amt",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "UTR: $utr",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeFg,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    if (!showInstructions) return const SizedBox.shrink();
    final text = instructionsText.trim().isNotEmpty
        ? instructionsText
        : "Deposit amount is fixed at ₹1,200.\nOnly 12 Digit UTR number is allowed.\nFunds will be added after Admin approval.";
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return Container(
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
          ...lines.map((line) => _buildInstructionBullet(Icons.check_circle_outline_rounded, line.trim())),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Blue Header
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
                        color: Colors.white.withValues(alpha: 0.18),
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
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
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

            if (isAddMoneyDisabled)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.block_rounded, color: Color(0xFFDC2626), size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Add Money service is currently disabled by Administrator.",
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),),
                // Scrollable Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 0. Fund Request Status Banner
                      _buildStatusBanner(),

                      // 1. UPI QR Code Card (Setting #1)
                      if (showQrCode) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
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
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.05),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: _buildQrDisplay(),
                              ),
                              const SizedBox(height: 16),
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
                      ],

                      // 2. UPI ID Box (Setting #2)
                      if (showUpiId) ...[
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
                                      payeeVpa,
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
                                  Clipboard.setData(ClipboardData(text: payeeVpa));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("UPI ID copied to clipboard!")),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // 3. Amount Display Card (Fixed ₹1,200)
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
                              children: [
                                const Text(
                                  "Deposit Amount (₹)",
                                  style: TextStyle(
                                    color: Color(0xFF1565C0),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFBFDBFE)),
                                  ),
                                  child: const Text(
                                    "FIXED",
                                    style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 10, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: TextFormField(
                                controller: _amountController,
                                readOnly: true,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.currency_rupee, color: Color(0xFF1565C0)),
                                  suffixIcon: Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF90CAF9)),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.info_outline_rounded, color: Color(0xFF1565C0), size: 16),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Deposit amount is fixed at ₹1,200",
                                      style: TextStyle(
                                        color: Color(0xFF1565C0),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 4. Enter UTR Number Card
                      Builder(
                        builder: (context) {
                          final bool canSubmitCycle = _fundStatus?['canSubmit'] ?? true;
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
                            onPressed: canSubmitCycle ? _pasteFromClipboard : null,
                          );
                          String? utrStatusMsg;
                          Color utrStatusColor = const Color(0xFF16A34A);

                          if (!canSubmitCycle) {
                            utrStatusMsg = "New request disabled during active cycle or pending request";
                            utrStatusColor = const Color(0xFFD97706);
                          } else if (isTouched) {
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
                              border: Border.all(color: utrStatusMsg != null && isTouched && !isValidUtr ? const Color(0xFFFCA5A5) : const Color(0xFFE9D5FF)),
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
                                      "Enter UTR Number *",
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
                                    color: !canSubmitCycle ? const Color(0xFFF1F5F9) : (isTouched && !isValidUtr ? const Color(0xFFFEF2F2) : (isValidUtr ? const Color(0xFFF0FDF4) : Colors.white)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderColor, width: isTouched ? 1.8 : 1.0),
                                  ),
                                  child: TextFormField(
                                    controller: _utrController,
                                    enabled: canSubmitCycle,
                                    keyboardType: TextInputType.number,
                                    maxLength: 12,
                                    decoration: InputDecoration(
                                      hintText: canSubmitCycle ? "Enter 12 Digit UTR Number" : "Request Disabled",
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
                                      color: isValidUtr ? const Color(0xFFF0FDF4) : (isTouched || !canSubmitCycle ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9)),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isValidUtr ? const Color(0xFF86EFAC) : (isTouched || !canSubmitCycle ? const Color(0xFFFCA5A5) : const Color(0xFFCBD5E1))),
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

                      // 5. Important Instructions Card (Setting #7)
                      _buildInstructionsCard(),
                      const SizedBox(height: 16),

                      if (_message.isNotEmpty) ...[
                        Text(_message, style: const TextStyle(color: Color(0xFF22C55E), fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                      ],
                      if (_error.isNotEmpty) ...[
                        Text(_error, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                      ],

                      // 6. Submit Button
                      Builder(
                        builder: (context) {
                          final bool canSubmitCycle = _fundStatus?['canSubmit'] ?? true;
                          final String statusStr = _fundStatus?['status'] ?? 'AVAILABLE';

                          final String amtText = _amountController.text.trim();
                          final double? amt = double.tryParse(amtText);
                          final bool isValidAmt = amt != null && amt == 1200;

                          final String utrText = _utrController.text.trim();
                          final bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(utrText);
                          final bool isAlreadyUsed = _requests.any((r) => r['utr']?.toString().trim() == utrText) || (_utrCache[utrText] == true);
                          final bool isValidUtr = utrText.length == 12 && isNumeric && !isAlreadyUsed && !_isCheckingUtr;

                          final bool canSubmit = !_isLoading && !isAddMoneyDisabled && isValidAmt && isValidUtr && canSubmitCycle;

                          String buttonText = "SUBMIT";
                          if (_isLoading) {
                            buttonText = "SUBMITTING...";
                          } else if (statusStr == 'PENDING') {
                            buttonText = "PENDING ADMIN APPROVAL";
                          } else if (statusStr == 'APPROVED_CYCLE_ACTIVE') {
                            buttonText = "ACTIVE CYCLE IN PROGRESS";
                          }

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
                                buttonText,
                                style: TextStyle(
                                  color: canSubmit ? Colors.white : const Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.0,
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
}
