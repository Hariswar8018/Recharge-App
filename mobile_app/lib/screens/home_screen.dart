import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _fullName = "Rajesh Reddy";
  double _mainWalletBalance = 6700.00;
  double _fundWalletBalance = 0.00;
  String _status = "ACTIVE";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final response = await ApiService.getProfile();
    if (response['success']) {
      final user = response['user'];
      setState(() {
        _fullName = user['fullName'] ?? "Rajesh Reddy";
        _mainWalletBalance = parseDouble(user['main_wallet_balance']) ?? 6700.00;
        _fundWalletBalance = parseDouble(user['fund_wallet_balance']) ?? 0.00;
        _status = user['status'] ?? "ACTIVE";
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double? parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  void _handleLogout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Simulated Razorpay Sandbox checkout for bill recharges
  void _triggerServicePayment(String serviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.payment, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text("Razorpay Sandbox", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Simulate payment for $serviceName recharge."),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Text("Test API Key: rzp_test_dummy", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange)),
            ),
            const SizedBox(height: 12),
            const Text("Amount: ₹ 100.00", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              // Perform a simulated sandbox payment decrementing ₹100 from Main Wallet
              await ApiService.triggerRazorpaySandboxPayment(-100.0, "$serviceName Recharge", "MAIN");
              await _loadUserProfile();
              
              setState(() => _isLoading = false);
              
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text("Payment Success", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: const Text(
                    "Recharge payment of ₹100.00 completed successfully via Razorpay Sandbox.\n\nBill payment api not integrated.",
                    style: TextStyle(height: 1.4),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              );
            },
            child: const Text("Simulate Pay"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.primaryBlue),
              accountName: Text(_fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: const Text(""),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppTheme.primaryBlue, size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: AppTheme.primaryBlue),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_center, color: AppTheme.primaryBlue),
              title: const Text("Business"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: AppTheme.primaryBlue),
              title: const Text("Team"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppTheme.primaryBlue),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryBlue, width: 2),
              ),
              child: const Center(
                child: Text("S", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(width: 6),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("SR DIGITAL SEVA", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 13)),
                Text("K E N D R A M", style: TextStyle(color: AppTheme.secondaryRed, fontWeight: FontWeight.bold, fontSize: 7, letterSpacing: 0.5)),
              ],
            )
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: AppTheme.primaryBlue),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              )
            ],
          )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  color: AppTheme.cardLightBlue.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_up, color: AppTheme.primaryBlue, size: 16),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            "Welcome to Affiliate Marketing | Grow your income with Smart Digital Services",
                            style: TextStyle(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildTabContent(),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.business_center), label: "Business"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Team"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildBusinessTab();
      case 2:
        return _buildTeamTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  // --- TAB 0: HOME VIEW ---
  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Separate Wallets Displays (Main Wallet & Fund Wallet)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
              border: Border.all(color: AppTheme.cardLightBlue),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Main Wallet Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Main/Income Wallet", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        "₹ ${_mainWalletBalance.toStringAsFixed(2)}",
                        style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                Container(width: 1.5, height: 40, color: AppTheme.cardLightBlue),
                const SizedBox(width: 12),
                // Fund Wallet Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Fund Wallet", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        "₹ ${_fundWalletBalance.toStringAsFixed(2)}",
                        style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Actions Row: Add Money, Subscribe, Cashout
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/fund-request'),
                  child: Row(
                    children: const [
                      Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text("Add Money", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildActionButton(Icons.stars, "Subscribe"),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildActionButton(Icons.call_made, "Cashout"),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Services Grid (Prepaid, Electricity, etc.)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              _buildServiceGridItem(Icons.phone_android, "Prepaid", Colors.blue),
              _buildServiceGridItem(Icons.electric_bolt, "Electricity", Colors.orange),
              _buildServiceGridItem(Icons.settings_input_hdmi, "DTH", Colors.purple),
              _buildServiceGridItem(Icons.directions_car, "FastTag", Colors.teal),
              _buildServiceGridItem(Icons.security, "Insurance", Colors.indigo),
              _buildServiceGridItem(Icons.water_drop, "Water Bill", Colors.lightBlue),
              _buildServiceGridItem(Icons.receipt, "Postpaid", Colors.brown),
              _buildServiceGridItem(Icons.apps, "More", Colors.grey),
            ],
          ),

          const SizedBox(height: 24),

          // Transaction History List
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 4, height: 16, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  const Text(
                    "Transaction History",
                    style: TextStyle(color: AppTheme.textDarkBlue, fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTransactionRow(
                icon: Icons.call_made,
                type: "Cashout",
                amount: "₹12,600.00",
                date: "2026-08-21 12:30 PM",
                isIncome: false,
              ),
              const Divider(color: AppTheme.cardLightBlue, height: 1),
              _buildTransactionRow(
                icon: Icons.call_received,
                type: "Affiliate Income",
                amount: "₹300.00",
                date: "2026-08-21 10:15 AM",
                isIncome: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildServiceGridItem(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () => _triggerServicePayment(label),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textDarkBlue, fontWeight: FontWeight.w600, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow({
    required IconData icon,
    required String type,
    required String amount,
    required String date,
    required bool isIncome,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isIncome ? Colors.green : Colors.red, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDarkBlue)),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isIncome ? Colors.green : AppTheme.textDarkBlue,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
        ],
      ),
    );
  }

  // --- TAB 1: BUSINESS VIEW ---
  Widget _buildBusinessTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.blueGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("INCOME GROWTH", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        const Text("You've earned", style: TextStyle(color: Colors.white, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text(
                          "₹ 0.00",
                          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const Icon(Icons.trending_up, color: Colors.white38, size: 60),
                  ],
                ),
                const SizedBox(height: 12),
                const Text("Of ₹ 12,600", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.0,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("0%", style: TextStyle(color: Colors.white70, fontSize: 10)),
                    Text("100%", style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.35,
            children: [
              _buildBusinessStatCard("TODAY INCOME", "₹ 300.00", Icons.trending_up, Colors.blue),
              _buildBusinessStatCard("TOTAL INCOME", "₹ 6,700.00", Icons.account_balance_wallet, Colors.teal),
              _buildBusinessStatCard("GLOBAL INCOME", "₹ 6,400.00", Icons.language, Colors.indigo),
              _buildBusinessStatCard("AFFILIATE INCOME", "₹ 300.00", Icons.people, Colors.purple),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardLightBlue),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard, color: AppTheme.primaryBlue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Refer App Earn ₹ 300.00",
                        style: TextStyle(color: AppTheme.textDarkBlue, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Each Referral",
                        style: TextStyle(color: AppTheme.textGray, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: Row(
                    children: const [
                      Text("INVITE NOW", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 12),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBusinessStatCard(String label, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardLightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppTheme.textGray, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(color: AppTheme.textDarkBlue, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  // --- TAB 2: TEAM VIEW ---
  Widget _buildTeamTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.blueGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("TEAM GROWTH", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        SizedBox(height: 8),
                        Text("Current Team", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Text("99", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const Icon(Icons.hub_outlined, color: Colors.white38, size: 54),
                  ],
                ),
                const SizedBox(height: 12),
                const Text("TARGET : 126", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 99 / 126,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("0%", style: TextStyle(color: Colors.white70, fontSize: 10)),
                    Text("100%", style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardLightBlue),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  ),
                  child: Row(
                    children: const [
                      Expanded(child: Text("Level", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(child: Text("Team", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                      Expanded(child: Text("Income", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                      Expanded(child: Text("Total", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.right)),
                    ],
                  ),
                ),

                _buildTeamRow("1", "2", "₹ 100", "₹ 200"),
                _buildTeamRow("2", "4", "₹ 100", "₹ 400"),
                _buildTeamRow("3", "8", "₹ 100", "₹ 800"),
                _buildTeamRow("4", "16", "₹ 100", "₹ 1,600"),
                _buildTeamRow("5", "32", "₹ 100", "₹ 3,200"),
                _buildTeamRow("6", "64", "₹ 100", "₹ 6,400"),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                    border: const Border(top: BorderSide(color: AppTheme.cardLightBlue, width: 1.5)),
                  ),
                  child: Row(
                    children: const [
                      Expanded(child: Text("Total", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 12))),
                      Expanded(child: Text("126", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 12), textAlign: TextAlign.center)),
                      Expanded(child: Text("₹ 600", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 12), textAlign: TextAlign.center)),
                      Expanded(child: Text("₹ 12,600", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 12), textAlign: TextAlign.right)),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTeamRow(String level, String team, String income, String total) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.cardLightBlue)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    level,
                    style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: Text(team, style: const TextStyle(color: AppTheme.textDarkBlue, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
          Expanded(child: Text(income, style: const TextStyle(color: AppTheme.textDarkBlue, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
          Expanded(child: Text(total, style: const TextStyle(color: AppTheme.textDarkBlue, fontWeight: FontWeight.w800, fontSize: 12), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // --- TAB 3: PROFILE VIEW ---
  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.blueGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.person, color: AppTheme.primaryBlue, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fullName,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "ID : 7989293968",
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.check_circle, color: Colors.green, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  "Active Member",
                                  style: TextStyle(color: AppTheme.primaryBlue, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Icon(Icons.verified_user, color: Colors.white.withOpacity(0.12), size: 54),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProfileSubMetric("Main Balance", "₹ ${_mainWalletBalance.toStringAsFixed(2)}", Icons.account_balance_wallet),
                      Container(width: 1, height: 36, color: AppTheme.cardLightBlue),
                      _buildProfileSubMetric("Team Size", "99", Icons.group),
                      Container(width: 1, height: 36, color: AppTheme.cardLightBlue),
                      _buildProfileSubMetric("Fund Balance", "₹ ${_fundWalletBalance.toStringAsFixed(2)}", Icons.wallet_giftcard),
                    ],
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardLightBlue),
            ),
            child: Column(
              children: [
                _buildProfileMenuOption(Icons.person, "Manage Profile", "Update your personal details"),
                _buildProfileMenuOption(Icons.security, "Password & Security", "Change password and secure your account"),
                _buildProfileMenuOption(Icons.notifications_active, "Notifications", "Manage your notification preferences"),
                _buildProfileMenuOption(Icons.info, "About Us", "Know more about SR Digital Seva Kendram"),
                _buildProfileMenuOption(Icons.help_center, "Support", "Help & support center"),
                _buildProfileMenuOption(Icons.power_settings_new, "Log out", "Sign out from your account", isLogout: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileSubMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 18),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppTheme.textGray, fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildProfileMenuOption(IconData icon, String title, String subtitle, {bool isLogout = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withOpacity(0.08) : AppTheme.primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isLogout ? Colors.red : AppTheme.primaryBlue, size: 20),
      ),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : AppTheme.textDarkBlue, fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      onTap: isLogout ? _handleLogout : () {},
    );
  }
}
