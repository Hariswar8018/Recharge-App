import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

// --- TRANSACTION MODEL ---
class TransactionModel {
  final String id;
  final String type;
  final String amount;
  final String date;
  final bool isIncome;
  final String status;
  final String reference;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.isIncome,
    this.status = "Success",
    this.reference = "TXN827182749",
  });
}

// --- TRANSACTION RECEIPT SCREEN ---
class TransactionReceiptScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionReceiptScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(
        title: const Text("Transaction Receipt", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Badge
                CircleAvatar(
                  radius: 30,
                  backgroundColor: transaction.status == "Success" ? Colors.green.shade50 : Colors.red.shade50,
                  child: Icon(
                    transaction.status == "Success" ? Icons.check_circle : Icons.error,
                    color: transaction.status == "Success" ? Colors.green : Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Payment Successful", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue)),
                const SizedBox(height: 8),
                Text(
                  transaction.amount,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: 24),
                const Divider(color: AppTheme.cardLightBlue, height: 1),
                const SizedBox(height: 20),

                // Receipt Fields Table
                _buildReceiptRow("Transaction ID", transaction.reference),
                _buildReceiptRow("Service/Type", transaction.type),
                _buildReceiptRow("Date & Time", transaction.date),
                _buildReceiptRow("Flow", transaction.isIncome ? "Wallet Credit (+)" : "Wallet Debit (-)"),
                _buildReceiptRow("Status", transaction.status),

                const SizedBox(height: 24),
                const Divider(color: AppTheme.cardLightBlue, height: 1),
                const SizedBox(height: 24),

                // Print or Share Button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Receipt saved to gallery")),
                          );
                        },
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: const Text("Download", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppTheme.textDarkBlue, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

// --- TRANSACTION HISTORY SCREEN ---
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final List<TransactionModel> _allTransactions = [
    TransactionModel(id: "1", type: "Cashout Withdrawal", amount: "₹12,600.00", date: "2026-08-22 12:30 PM", isIncome: false, reference: "TXN55283920"),
    TransactionModel(id: "2", type: "Affiliate Payout (Level 1)", amount: "₹300.00", date: "2026-08-22 10:15 AM", isIncome: true, reference: "TXN10294829"),
    TransactionModel(id: "3", type: "Mobile Prepaid Recharge", amount: "₹299.00", date: "2026-08-21 04:45 PM", isIncome: false, reference: "TXN99281729"),
    TransactionModel(id: "4", type: "DTH Subscription Topup", amount: "₹450.00", date: "2026-08-20 02:15 PM", isIncome: false, reference: "TXN33827182"),
    TransactionModel(id: "5", type: "FastTag Recharge", amount: "₹500.00", date: "2026-08-20 11:00 AM", isIncome: false, reference: "TXN28173921"),
    TransactionModel(id: "6", type: "Deposit Request", amount: "₹1,200.00", date: "2026-08-19 09:30 AM", isIncome: true, reference: "TXN77362810"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(
        title: const Text("All Transactions", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _allTransactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final tx = _allTransactions[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransactionReceiptScreen(transaction: tx)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardLightBlue),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: tx.isIncome ? Colors.green.shade50 : Colors.red.shade50,
                    child: Icon(
                      tx.isIncome ? Icons.call_received : Icons.call_made,
                      color: tx.isIncome ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx.type, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(tx.date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(
                    (tx.isIncome ? "+" : "-") + tx.amount,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: tx.isIncome ? Colors.green : Colors.red,
                      fontSize: 13,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- WALLET DETAILS SCREEN ---
class WalletDetailsScreen extends StatefulWidget {
  const WalletDetailsScreen({super.key});

  @override
  State<WalletDetailsScreen> createState() => _WalletDetailsScreenState();
}

class _WalletDetailsScreenState extends State<WalletDetailsScreen> {
  double _mainBalance = 6700.0;
  double _fundBalance = 1200.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final response = await ApiService.getProfile();
    if (response['success']) {
      final user = response['user'];
      setState(() {
        _mainBalance = double.tryParse(user['main_wallet_balance']?.toString() ?? "6700.0") ?? 6700.0;
        _fundBalance = double.tryParse(user['fund_wallet_balance']?.toString() ?? "1200.0") ?? 1200.0;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(
        title: const Text("My Wallets", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dual Wallet Cards
                  Row(
                    children: [
                      // Main Wallet
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppTheme.blueGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("MAIN WALLET", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text("₹${_mainBalance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Fund Wallet
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.cardLightBlue),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("FUND WALLET", style: TextStyle(color: AppTheme.textDarkBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text("₹${_fundBalance.toStringAsFixed(2)}", style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Wallet metrics (Team Size, Min Balance rule)
                  const Text("Wallet Conditions & Rules", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue, fontSize: 14)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardLightBlue),
                    ),
                    child: Column(
                      children: [
                        _buildMetricRow(Icons.rule, "Min. Balance Limit", "₹0.00 (No lock-in)"),
                        const Divider(color: AppTheme.cardLightBlue),
                        _buildMetricRow(Icons.people_outline, "Current Team Size", "99 Members"),
                        const Divider(color: AppTheme.cardLightBlue),
                        _buildMetricRow(Icons.cached, "Current Active Cycle", "Cycle 1 (126 Max)"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Transaction Preview list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Recent Transactions", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue, fontSize: 14)),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/transaction-history');
                        },
                        child: const Text("See More", style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Preview rows
                  _buildPreviewRow("Deposit Request", "₹1,200.00", "2026-08-22", true),
                  const SizedBox(height: 10),
                  _buildPreviewRow("Affiliate Commission", "₹300.00", "2026-08-22", true),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricRow(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
        Text(val, style: const TextStyle(color: AppTheme.textDarkBlue, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildPreviewRow(String label, String amt, String date, bool isIncome) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardLightBlue),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isIncome ? Colors.green.shade50 : Colors.red.shade50,
            child: Icon(
              isIncome ? Icons.call_received : Icons.call_made,
              color: isIncome ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue, fontSize: 13)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(
            (isIncome ? "+" : "-") + amt,
            style: TextStyle(fontWeight: FontWeight.w900, color: isIncome ? Colors.green : Colors.red, fontSize: 13),
          )
        ],
      ),
    );
  }
}
