import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';

class WalletDetailsScreen extends StatefulWidget {
  const WalletDetailsScreen({super.key});

  @override
  State<WalletDetailsScreen> createState() => _WalletDetailsScreenState();
}

class _WalletDetailsScreenState extends State<WalletDetailsScreen> {
  double _mainBalance = 6700.0;
  double _fundBalance = 1200.0;
  int _teamCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final response = await ApiService.getProfile();
    final teamRes = await ApiService.getTeam();
    if (response['success']) {
      final user = response['user'];
      setState(() {
        _mainBalance = double.tryParse(user['main_wallet_balance']?.toString() ?? "6700.0") ?? 6700.0;
        _fundBalance = double.tryParse(user['fund_wallet_balance']?.toString() ?? "1200.0") ?? 1200.0;
        _teamCount = teamRes.length;
        _isLoading = false;
      });
    } else {
      setState(() {
        _teamCount = teamRes.length;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("My Wallets", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/withdrawal').then((_) => _loadWalletData()),
                      icon: const Icon(Icons.account_balance, color: Colors.white),
                      label: const Text("CASHOUT TO BANK / UPI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

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
                        _buildMetricRow(Icons.people_outline, "Current Team Size", "$_teamCount Members"),
                        const Divider(color: AppTheme.cardLightBlue),
                        _buildMetricRow(Icons.cached, "Current Active Cycle", "Cycle 1 (126 Max)"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

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

                  _buildPreviewRow("Direct Income", "₹300.00", "28 Aug 2026", true),
                  const SizedBox(height: 10),
                  _buildPreviewRow("Fund Deposit", "₹1,200.00", "28 Aug 2026", true),
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
              isIncome ? Icons.south_rounded : Icons.north_rounded,
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
            "${isIncome ? '+' : '-'}$amt",
            style: TextStyle(fontWeight: FontWeight.w900, color: isIncome ? Colors.green : Colors.red, fontSize: 13),
          )
        ],
      ),
    );
  }
}
