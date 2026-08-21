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
  String _fullName = "User";
  double _walletBalance = 6700.00; // Screenshot value as default
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
        _fullName = user['fullName'] ?? "User";
        _walletBalance = (user['walletBalance'] as num?)?.toDouble() ?? 0.0;
        _status = user['status'] ?? "ACTIVE";
        _isLoading = false;
      });
    } else {
      // Use defaults if backend not running/configured
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleLogout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
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
              onTap: () => Navigator.pop(context),
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
            // Mini logo icon
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
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Marquee Alert Bar
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

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Wallet & User Status Row
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
                              // Wallet Details
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Your Wallet Balance", style: TextStyle(color: AppTheme.textGray, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text(
                                    "₹ ${_walletBalance.toStringAsFixed(2)}",
                                    style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 22, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                              // Vertical Divider
                              Container(width: 1.5, height: 40, color: AppTheme.cardLightBlue),
                              // Status details
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("User Status", style: TextStyle(color: AppTheme.textGray, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _status,
                                      style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action cards row: Add Money, Subscribe, Cashout
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(Icons.account_balance_wallet, "Add Money"),
                              Container(width: 1, height: 24, color: Colors.white24),
                              _buildActionButton(Icons.stars, "Subscribe"),
                              Container(width: 1, height: 24, color: Colors.white24),
                              _buildActionButton(Icons.call_made, "Cashout"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Grid Menu Section
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                          children: [
                            _buildGridItem(Icons.phone_android, "Prepaid", Colors.blue),
                            _buildGridItem(Icons.electric_bolt, "Electricity", Colors.orange),
                            _buildGridItem(Icons.settings_input_hdmi, "DTH", Colors.purple),
                            _buildGridItem(Icons.directions_car, "FastTag", Colors.teal),
                            _buildGridItem(Icons.security, "Insurance", Colors.indigo),
                            _buildGridItem(Icons.water_drop, "Water Bill", Colors.lightBlue),
                            _buildGridItem(Icons.receipt, "Postpaid", Colors.brown),
                            _buildGridItem(Icons.apps, "More", Colors.grey),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Transaction History section
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
                            // Recent Txn 1
                            _buildTransactionRow(
                              icon: Icons.call_made,
                              type: "Cashout",
                              amount: "₹12,600.00",
                              date: "2026-08-21 12:30 PM",
                              isIncome: false,
                            ),
                            const Divider(color: AppTheme.cardLightBlue, height: 1),
                            // Recent Txn 2
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
                  ),
                ],
              ),
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

  Widget _buildGridItem(IconData icon, String label, Color color) {
    return Column(
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
}
