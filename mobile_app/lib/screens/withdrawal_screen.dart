import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/processing_dialog.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _amountController = TextEditingController();
  final _paymentDetailsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  double _mainBalance = 0.0;
  String _message = "";
  String _error = "";
  List<dynamic> _cashoutHistory = [];
  String _currentAmount = "";
  String _paymentMethod = "UPI"; // "UPI" or "BANK"

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _loadBalanceAndHistory();
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _paymentDetailsController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    setState(() {
      _currentAmount = _amountController.text.trim();
    });
  }

  void _setQuickAmount(String amt) {
    _amountController.text = amt;
    setState(() {
      _currentAmount = amt;
    });
  }

  Future<void> _loadBalanceAndHistory() async {
    // Load profile to get latest main balance
    final profileRes = await ApiService.getProfile();
    double balance = 0.0;
    if (profileRes['success']) {
      final user = profileRes['user'];
      balance = double.tryParse(user['main_wallet_balance']?.toString() ?? "0.0") ?? 0.0;
    }

    // Load transactions and filter by "Cashout" to get history
    final txns = await ApiService.getTransactions();
    final cashouts = txns.where((tx) => tx['type'] == 'Cashout').toList();

    setState(() {
      _mainBalance = balance;
      _cashoutHistory = cashouts;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final amtVal = double.tryParse(_currentAmount);
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

    await showProcessingDialog(context, "Processing Cashout Request...");
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _message = "";
      _error = "";
    });

    final result = await ApiService.submitWithdrawal(amtVal);
    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      setState(() {
        _message = "Cashout request processed successfully!";
        _amountController.clear();
        _paymentDetailsController.clear();
        _currentAmount = "";
      });
      await _loadBalanceAndHistory();
    } else {
      setState(() {
        _error = result['error'] ?? "Withdrawal request failed";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Cashout / Withdraw", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              // Wallet Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: AppTheme.blueGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("MAIN WALLET BALANCE", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Text("₹ ${_mainBalance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),

              // 1. Select Amount Card
              _buildCardSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("1. Enter Withdrawal Amount", Icons.currency_rupee),
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
                    const Text("Minimum Cashout: ₹500", style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
                    const SizedBox(height: 12),
                    // Quick amount selection
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: ["500", "1000", "2000", "5000"].map((val) {
                        return OutlinedButton(
                          onPressed: () => _setQuickAmount(val),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text("₹$val", style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 11)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Select Payment Method Card
              _buildCardSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("2. Choose Transfer Method", Icons.account_balance),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text("UPI Transfer", style: TextStyle(fontWeight: FontWeight.bold))),
                            selected: _paymentMethod == "UPI",
                            selectedColor: AppTheme.primaryBlue.withOpacity(0.12),
                            checkmarkColor: AppTheme.primaryBlue,
                            labelStyle: TextStyle(color: _paymentMethod == "UPI" ? AppTheme.primaryBlue : Colors.grey),
                            onSelected: (val) {
                              if (val) setState(() => _paymentMethod = "UPI");
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text("Bank Account", style: TextStyle(fontWeight: FontWeight.bold))),
                            selected: _paymentMethod == "BANK",
                            selectedColor: AppTheme.primaryBlue.withOpacity(0.12),
                            checkmarkColor: AppTheme.primaryBlue,
                            labelStyle: TextStyle(color: _paymentMethod == "BANK" ? AppTheme.primaryBlue : Colors.grey),
                            onSelected: (val) {
                              if (val) setState(() => _paymentMethod = "BANK");
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _paymentDetailsController,
                      decoration: InputDecoration(
                        labelText: _paymentMethod == "UPI" ? "Enter UPI ID" : "Account Number + IFSC Code",
                        hintText: _paymentMethod == "UPI" ? "username@upi" : "Acc: 123456789, IFSC: SBIN0001234",
                        prefixIcon: Icon(_paymentMethod == "UPI" ? Icons.payment : Icons.account_box, color: AppTheme.primaryBlue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? "Payment destination details are required" : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Instructions Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info, color: AppTheme.secondaryRed, size: 18),
                        SizedBox(width: 6),
                        Text("Important Instructions", style: TextStyle(color: AppTheme.secondaryRed, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionBullet("Minimum Cashout Amount: ₹500"),
                    _buildInstructionBullet("A standard 15% processing fee applies to all cashouts."),
                    _buildInstructionBullet("Funds will be instantly transferred to your selected UPI/Bank account."),
                    _buildInstructionBullet("Please double check your payment details before confirming."),
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
                  label: Text(_isLoading ? "PROCESSING..." : "CONFIRM CASHOUT", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Request History section
              const Text("Your Withdrawal History", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue)),
              const SizedBox(height: 8),
              _cashoutHistory.isEmpty
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No cashout history found", style: TextStyle(color: AppTheme.textGray))))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cashoutHistory.length,
                      itemBuilder: (context, index) {
                        final item = _cashoutHistory[index];
                        final amount = item['amount'] as String? ?? '₹0.00';
                        final date = item['date'] as String? ?? '';
                        final id = item['id']?.toString() ?? '';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppTheme.cardLightBlue),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.red.shade50,
                              child: const Icon(
                                Icons.call_made,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              amount,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue),
                            ),
                            subtitle: Text("Ref ID: SRTXN${id.padLeft(8, '0')}\n$date", style: const TextStyle(fontSize: 10)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "SUCCESS",
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 9),
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
          const Text("• ", style: TextStyle(color: AppTheme.secondaryRed, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(color: AppTheme.textDarkBlue, fontSize: 11, height: 1.3))),
        ],
      ),
    );
  }
}
