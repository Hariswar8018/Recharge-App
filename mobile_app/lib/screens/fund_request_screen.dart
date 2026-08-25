import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upi_uri/qr_widget.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/processing_dialog.dart';

class FundRequestScreen extends StatefulWidget {
  const FundRequestScreen({super.key});

  @override
  State<FundRequestScreen> createState() => _FundRequestScreenState();
}

class _FundRequestScreenState extends State<FundRequestScreen> {
  final _amountController = TextEditingController();
  final _utrController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _message = "";
  String _error = "";
  List<dynamic> _requests = [];
  String _currentAmount = "";
  bool _isUtrExact = false;

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
    _utrController.removeListener(_onUtrChanged);
    _amountController.dispose();
    _utrController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    setState(() {
      _currentAmount = _amountController.text.trim();
    });
  }

  void _onUtrChanged() {
    setState(() {
      _isUtrExact = _utrController.text.trim().length == 12;
    });
  }

  void _setQuickAmount(String amt) {
    _amountController.text = amt;
    setState(() {
      _currentAmount = amt;
    });
  }

  Future<void> _loadRequestHistory() async {
    final list = await ApiService.getFundRequests();
    setState(() {
      _requests = list;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final amtVal = double.tryParse(_currentAmount);
    if (amtVal == null || amtVal < 1200 || amtVal > 12000) {
      setState(() {
        _error = "Amount must be between ₹1,200 and ₹12,000";
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
        _amountController.clear();
        _utrController.clear();
        _currentAmount = "";
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
    String payeeVpa = "vp110064@okaxis";
    String qrAmount = _currentAmount.isNotEmpty ? _currentAmount : "1200";

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Add Money", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Select Amount Card
              _buildCardSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("1. Select Amount", Icons.currency_rupee),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter Amount",
                        prefixIcon: const Icon(Icons.currency_rupee, color: AppTheme.primaryBlue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? "Please enter amount" : null,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Minimum: ₹1200", style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
                        Text("Maximum: ₹12000", style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Quick amount grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: ["1200", "2000", "3000", "5000", "8000", "12000"].map((val) {
                        return OutlinedButton(
                          onPressed: () => _setQuickAmount(val),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text("₹$val", style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Payment Method Card
              _buildCardSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("2. Payment Method", Icons.grid_view_rounded),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: UPI QR
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: UpiQrCode(
                            payeeVpa: payeeVpa,
                            payeeName: "EarnFarm",
                            amount: qrAmount,
                            txnRef: "TXN${DateTime.now().millisecondsSinceEpoch}",
                            size: 100,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text("Scan & Pay", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                              const SizedBox(height: 6),
                              const Text("Scan QR Code using any UPI App", style: TextStyle(color: AppTheme.textDarkBlue, fontWeight: FontWeight.bold, fontSize: 10)),
                              const SizedBox(height: 6),
                              const Text("----------------- OR -----------------", style: TextStyle(color: AppTheme.textGray, fontSize: 9)),
                              const SizedBox(height: 6),
                              const Text("UPI ID", style: TextStyle(color: AppTheme.textGray, fontSize: 9)),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.cardLightBlue),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(payeeVpa, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue), overflow: TextOverflow.ellipsis),
                                    ),
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: payeeVpa));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("UPI ID copied to clipboard")),
                                        );
                                      },
                                      child: const Icon(Icons.copy, size: 14, color: AppTheme.primaryBlue),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Enter UTR Card
              _buildCardSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("3. Enter UTR Number", Icons.receipt_long),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _utrController,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      decoration: InputDecoration(
                        hintText: "Enter 12 Digit UTR Number",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        counterText: "",
                      ),
                      validator: (value) => (value == null || value.length != 12) ? "Please enter 12-digit UTR" : null,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Please enter exact 12 digits UTR number.", style: TextStyle(color: AppTheme.textGray, fontSize: 10)),
                        Row(
                          children: [
                            Icon(
                              _isUtrExact ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: _isUtrExact ? Colors.green : Colors.grey,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text("Exactly 12 digits", style: TextStyle(color: _isUtrExact ? Colors.green : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Instructions Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info, color: AppTheme.primaryBlue, size: 18),
                        SizedBox(width: 6),
                        Text("Important Instructions", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionBullet("Minimum Add Money: ₹1200"),
                    _buildInstructionBullet("Maximum Add Money: ₹12000"),
                    _buildInstructionBullet("Only 12 Digit UTR number is allowed."),
                    _buildInstructionBullet("Funds will be added to your wallet after Admin approval."),
                    _buildInstructionBullet("It may take some time for approval."),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_message.isNotEmpty) ...[
                Text(_message, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
              ],
              if (_error.isNotEmpty) ...[
                Text(_error, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleSubmit,
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  label: Text(_isLoading ? "SUBMITTING..." : "SUBMIT", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Your request will be sent to admin for approval.\nOnce approved, amount will be added to your wallet.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textGray, fontSize: 10, height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Request History section
              const Text("Your Request History", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue)),
              const SizedBox(height: 8),
              _requests.isEmpty
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No request history found", style: TextStyle(color: AppTheme.textGray))))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final item = _requests[index];
                        final status = item['status'] as String;
                        Color statusColor = Colors.orange;
                        if (status == 'APPROVED') statusColor = Colors.green;
                        if (status == 'REJECTED') statusColor = Colors.red;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppTheme.cardLightBlue),
                          ),
                          child: ListTile(
                            title: Text(
                              "₹ ${(item['amount'] is num ? item['amount'] : double.tryParse(item['amount'].toString()) ?? 0.0).toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue),
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
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardLightBlue),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppTheme.primaryBlue,
          child: Icon(icon, color: Colors.white, size: 12),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDarkBlue)),
      ],
    );
  }

  Widget _buildInstructionBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(color: AppTheme.textDarkBlue, fontSize: 11, height: 1.3))),
        ],
      ),
    );
  }
}
