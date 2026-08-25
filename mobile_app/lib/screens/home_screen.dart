import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_me/share_me.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/background_container.dart';
import '../widgets/processing_dialog.dart';
import 'recharge_flow_screens.dart';
import 'wallet_history_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _fullName = "Rajesh Reddy";
  double _mainWalletBalance = 0.00;
  double _fundWalletBalance = 0.00;
  String _status = "ACTIVE";
  bool _isLoading = true;
  int _membersCount = 0;
  String _activeCycleId = "";
  List<dynamic> _cyclesHistory = [];
  int _userId = 0;
  String _referralLink = "";
  String _email = "";
  String _mobileNumber = "";
  String _createdAt = "2026-08-25";
  List<dynamic> _teamMembers = [];
  List<dynamic> _transactions = [];
  bool _isNetworkConnected = true;
  Timer? _healthCheckTimer;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _healthCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final response = await ApiService.getProfile();
    if (response['success']) {
      final user = response['user'];
      final cycles = await ApiService.getCyclesHistory();
      final team = await ApiService.getTeam();
      final txns = await ApiService.getTransactions();

      dynamic activeCycle;
      try {
        activeCycle = cycles.firstWhere(
          (c) => c['status'] == 'ACTIVE',
          orElse: () => null,
        );
      } catch (_) {
        activeCycle = null;
      }

      setState(() {
        _fullName = user['fullName'] ?? "Rajesh Reddy";
        _userId = user['id'] ?? 0;
        _email = user['email'] ?? "";
        _mobileNumber = user['mobileNumber'] ?? "";
        _createdAt = user['createdAt'] != null
            ? DateTime.parse(
                user['createdAt'],
              ).toLocal().toString().substring(0, 10)
            : "2026-08-25";
        _mainWalletBalance = parseDouble(user['main_wallet_balance']) ?? 0.00;
        _fundWalletBalance = parseDouble(user['fund_wallet_balance']) ?? 0.00;
        _status = user['status'] ?? "ACTIVE";
        _cyclesHistory = cycles;
        _teamMembers = team;
        _transactions = txns;
        if (activeCycle != null) {
          _activeCycleId = activeCycle['cycle_id'] ?? "";
          _membersCount = activeCycle['members_count'] ?? 0;
        } else {
          _activeCycleId = "";
          _membersCount = 0;
        }
        _referralLink = "https://earnfarm.com/join?ref=EARNFARMX7AQ96SD$_userId";
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

  void _handleShareReferral() async {
    if (_referralLink.isEmpty) return;
    final String shareMessage = 
      "Join EarnFarm Today!\n\n"
      "Register on EarnFarm using my Sponsor ID: EARNFARMX7AQ96SD$_userId\n\n"
      "Referral Link:\n$_referralLink\n\n"
      "Download the App:\nhttps://play.google.com/store/apps/details?id=com.app.earnfarm\n\n"
      "Start earning affiliate commissions, global cycle rewards, and much more! Join our network today.";
    try {
      await ShareMe.system(
        title: 'Join EarnFarm Today!',
        url: _referralLink,
        description: shareMessage,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sharing referral link: $e")),
      );
    }
  }

  Future<void> _handleActivateCycle() async {
    await showProcessingDialog(context, "Activating ID / Subscription...");
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final res = await ApiService.activateCycle();
    setState(() {
      _isLoading = false;
    });
    if (res['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cycle activated successfully! ID: ${res['cycleId']}"),
        ),
      );
      _loadUserProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? "Failed to activate cycle")),
      );
    }
  }

  void _handleLogout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // --- URL LAUNCHER HELPER ---
  Future<void> _openWebUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $urlString');
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  // --- SETTINGS DIALOGS ---

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        title: Row(
          children: const [
            Icon(Icons.notifications_active, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text(
              "Notification Preference",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          "Would you like to enable push notifications for transactions?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      useSafeArea: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: Drawer(
          elevation: 16,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // Professional Drawer Header
                UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.blueGradient,
                  ),
                  accountName: Text(
                    _fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  accountEmail: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Colors.greenAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Status: $_status",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  currentAccountPicture: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: AppTheme.primaryBlue,
                        size: 44,
                      ),
                    ),
                  ),
                ),

                // Drawer Menu Options
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildDrawerItem(Icons.home_outlined, "Home Portal", () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 0);
                      }),
                      _buildDrawerItem(
                        Icons.business_center_outlined,
                        "Business Hub",
                        () {
                          Navigator.pop(context);
                          setState(() => _currentIndex = 1);
                        },
                      ),
                      _buildDrawerItem(
                        Icons.group_outlined,
                        "Team Network",
                        () {
                          Navigator.pop(context);
                          setState(() => _currentIndex = 2);
                        },
                      ),
                      _buildDrawerItem(Icons.person_outline, "My Profile", () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 3);
                      }),
                      const Divider(
                        color: AppTheme.cardLightBlue,
                        thickness: 1.5,
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildDrawerItem(
                        Icons.help_outline,
                        "About Seva Kendram",
                        () {
                          Navigator.pop(context);
                          _openWebUrl("https://srdigitalseva.com");
                        },
                      ),
                      _buildDrawerItem(
                        Icons.support_agent_outlined,
                        "Customer Support",
                        () {
                          Navigator.pop(context);
                          _openWebUrl("https://srdigitalseva.com/contact");
                        },
                      ),
                    ],
                  ),
                ),

                // Sign Out at Bottom
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      "Sign Out",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: false,
          titleSpacing: 0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Center(
                  child: Text(
                    "S",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "SR DIGITAL SEVA",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    "K E N D R A M",
                    style: TextStyle(
                      color: AppTheme.secondaryRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 7,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {},
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBlue),
              )
            : Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Container(
                      width: double.infinity,
                      color: Colors.white.withOpacity(0.9),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.volume_up,
                            color: AppTheme.primaryBlue,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: MarqueeWidget(
                              animationDuration: Duration(seconds: 12),
                              child: Text(
                                "Welcome to Affiliate Marketing | Grow your income with Smart Digital Services          ",
                                style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(child: _buildTabContent()),
                  ),
                ],
              ),
        // Premium Floating Curved Navigation Bar
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppTheme.primaryBlue,
              unselectedItemColor: Colors.grey.shade400,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business_center),
                  label: "Business",
                ),
                BottomNavigationBarItem(icon: Icon(Icons.group), label: "Team"),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppTheme.textDarkBlue,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildTabContent() {
    if (_activeCycleId.isEmpty) {
      if (_currentIndex == 0 || _currentIndex == 2) {
        return _buildSubscriptionActivationView();
      }
    }
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

  Widget _buildSubscriptionActivationView() {
    String formattedId = "SRD${_userId.toString().padLeft(8, '0')}";
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardLightBlue),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 32),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "SR DIGITAL SEVA",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        Text(
                          "KENDRAM",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Fund Wallet Balance",
                      style: TextStyle(fontSize: 10, color: AppTheme.textGray),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "₹ ${_fundWalletBalance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Select Plan
          _buildStepHeader("1. Select Plan", Icons.workspace_premium),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryBlue, width: 1.5),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Basic Plan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textDarkBlue,
                        ),
                      ),
                      Text(
                        "ID Activation Plan",
                        style: TextStyle(
                          color: AppTheme.textGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      "₹1200",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    Text(
                      "One Time",
                      style: TextStyle(color: AppTheme.textGray, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Enter ID to Activate
          _buildStepHeader("2. Enter ID to Activate", Icons.person_outline),
          TextFormField(
            initialValue: formattedId,
            readOnly: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person, color: AppTheme.primaryBlue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.cardLightBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.cardLightBlue),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. User Details
          _buildStepHeader("3. User Details", Icons.assignment_outlined),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardLightBlue),
            ),
            child: Column(
              children: [
                _buildDetailRow("ID", formattedId),
                _buildDetailRow("Name", _fullName),
                _buildDetailRow("Mobile Number", _mobileNumber),
                _buildDetailRow("Email", _email),
                _buildDetailRow("Joining Date", _createdAt),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "User Verified Successfully\nAll details are correct.",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Amount Pay
          _buildStepHeader("4. Amount Pay", Icons.payment),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardLightBlue),
            ),
            child: Column(
              children: [
                _buildPayRow("Plan Amount", "₹1200.00"),
                const Divider(),
                _buildPayRow("Total Amount", "₹1200.00", isBold: true),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/fund-request',
                    ).then((_) => _loadUserProfile());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cardLightBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              color: AppTheme.primaryBlue,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Available in Fund Wallet: ₹${_fundWalletBalance.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDarkBlue,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppTheme.textGray,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleActivateCycle,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isLoading ? "ACTIVATING..." : "SUBSCRIBE NOW - ₹1200",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 18),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.textDarkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textGray, fontSize: 12),
          ),
          Text(
            val,
            style: const TextStyle(
              color: AppTheme.textDarkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayRow(String label, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppTheme.textDarkBlue : AppTheme.textGray,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            color: AppTheme.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: isBold ? 15 : 13,
          ),
        ),
      ],
    );
  }

  // --- TAB 0: HOME VIEW ---
  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Separate Wallets Displays (Main Wallet & Fund Wallet)
          // Separate Wallets Displays (Main Wallet & Fund Wallet)
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/wallet-details',
              ).then((_) => _loadUserProfile());
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
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
                        const Text(
                          "Main/Income Wallet",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹ ${_mainWalletBalance.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 40,
                    color: AppTheme.cardLightBlue,
                  ),
                  const SizedBox(width: 12),
                  // Fund Wallet Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Fund Wallet",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹ ${_fundWalletBalance.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Add Money",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
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
              _buildServiceGridItem(
                Icons.phone_android,
                "Prepaid",
                Colors.blue,
              ),
              _buildServiceGridItem(
                Icons.electric_bolt,
                "Electricity",
                Colors.orange,
              ),
              _buildServiceGridItem(
                Icons.settings_input_hdmi,
                "DTH",
                Colors.purple,
              ),
              _buildServiceGridItem(
                Icons.directions_car,
                "FastTag",
                Colors.teal,
              ),
              _buildServiceGridItem(Icons.security, "Insurance", Colors.indigo),
              _buildServiceGridItem(
                Icons.local_fire_department,
                "Gas Cylinder",
                Colors.red,
              ),
              _buildServiceGridItem(Icons.play_arrow, "Google Play", Colors.green),
              _buildServiceGridItem(Icons.credit_card, "Credit Card", Colors.amber),
            ],
          ),

          const SizedBox(height: 24),

          // Transaction History List
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Transaction History",
                        style: TextStyle(
                          color: AppTheme.textDarkBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/transaction-history');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "See More",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _transactions.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "No transactions recorded yet",
                          style: TextStyle(color: AppTheme.textGray, fontSize: 12),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transactions.length > 5 ? 5 : _transactions.length,
                      separatorBuilder: (context, index) => const Divider(color: AppTheme.cardLightBlue, height: 1),
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        final type = tx['type'] as String? ?? 'Transaction';
                        final amount = tx['amount'] as String? ?? '₹0.00';
                        final date = tx['date'] as String? ?? '';
                        
                        final typeLower = type.toLowerCase();
                        final bool isIncome = !typeLower.contains('debit') && 
                                              !typeLower.contains('cashout') && 
                                              !typeLower.contains('withdrawal');

                        return _buildTransactionRow(
                          icon: isIncome ? Icons.call_received : Icons.call_made,
                          type: type,
                          amount: amount,
                          date: date,
                          isIncome: isIncome,
                        );
                      },
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
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGridItem(IconData icon, String label, Color color) {
    String? assetPath;
    switch (label.toLowerCase()) {
      case "prepaid":
        assetPath = "assets/logos/phone_recharge.jpg";
        break;
      case "electricity":
        assetPath = "assets/logos/electrcity.jpg";
        break;
      case "dth":
        assetPath = "assets/logos/dth.jpg";
        break;
      case "fasttag":
        assetPath = "assets/logos/fast_track.jpg";
        break;
      case "insurance":
        assetPath = "assets/logos/insurance.jpg";
        break;
      case "google play":
        assetPath = "assets/logos/google_play.jpg";
        break;
      case "credit card":
        assetPath = "assets/logos/credit_card.jpg";
        break;
      case "gas cylinder":
      case "cylinder":
        assetPath = "assets/logos/cylinder.jpg";
        break;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderSelectionScreen(serviceType: label),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: assetPath != null ? const EdgeInsets.all(4) : const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: assetPath != null
                ? ClipOval(
                    child: Image.asset(
                      assetPath,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textDarkBlue,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionReceiptScreen(
              transaction: TransactionModel(
                id: "mock_id",
                type: type,
                amount: amount,
                date: date,
                isIncome: isIncome,
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isIncome
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isIncome ? Colors.green : Colors.red,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.textDarkBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
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
      ),
    );
  }

  // --- TAB 1: BUSINESS VIEW ---
  Widget _buildBusinessTab() {
    double progressVal = _activeCycleId.isNotEmpty
        ? (_membersCount / 126.0)
        : 0.0;
    String progressPercent = _activeCycleId.isNotEmpty
        ? "${(_membersCount * 100 / 126).toStringAsFixed(0)}%"
        : "0%";

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
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
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
                        const Text(
                          "INCOME GROWTH",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _activeCycleId.isNotEmpty
                              ? "Active Cycle: $_activeCycleId"
                              : "No Active Cycle",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹ ${(_mainWalletBalance).toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.trending_up,
                      color: Colors.white38,
                      size: 60,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Members completed: $_membersCount of 126",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressVal,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "0%",
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    Text(
                      progressPercent,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "100%",
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_activeCycleId.isEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleActivateCycle,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.flash_on),
              label: const Text(
                "ACTIVATE NEW CYCLE (₹1,200)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],

          const SizedBox(height: 20),

          Builder(
            builder: (context) {
              double globalIncome = 0;
              if (_activeCycleId.isNotEmpty) {
                if (_membersCount >= 2) globalIncome += 200;
                if (_membersCount >= 6) globalIncome += 400;
                if (_membersCount >= 14) globalIncome += 800;
                if (_membersCount >= 30) globalIncome += 1600;
                if (_membersCount >= 62) globalIncome += 3200;
                if (_membersCount >= 126) globalIncome += 6400;
              }
              double affiliateIncome = _activeCycleId.isNotEmpty
                  ? (_teamMembers.length * 300.0)
                  : 0.0;
              double totalIncome = _activeCycleId.isNotEmpty
                  ? _mainWalletBalance
                  : 0.00;
              double todayIncome = 0.00;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.35,
                children: [
                  _buildBusinessStatCard(
                    "TODAY INCOME",
                    "₹ ${todayIncome.toStringAsFixed(2)}",
                    Icons.trending_up,
                    Colors.blue,
                  ),
                  _buildBusinessStatCard(
                    "TOTAL INCOME",
                    "₹ ${totalIncome.toStringAsFixed(2)}",
                    Icons.account_balance_wallet,
                    Colors.teal,
                  ),
                  _buildBusinessStatCard(
                    "GLOBAL INCOME",
                    "₹ ${globalIncome.toStringAsFixed(2)}",
                    Icons.language,
                    Colors.indigo,
                  ),
                  _buildBusinessStatCard(
                    "AFFILIATE INCOME",
                    "₹ ${affiliateIncome.toStringAsFixed(2)}",
                    Icons.people,
                    Colors.purple,
                  ),
                ],
              );
            },
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
                const Icon(
                  Icons.card_giftcard,
                  color: AppTheme.primaryBlue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Refer App ₹300.00",
                        style: TextStyle(
                          color: AppTheme.textDarkBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Each Referral",
                        style: TextStyle(
                          color: AppTheme.textGray,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _handleShareReferral,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        "INVITE NOW",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessStatCard(
    String label,
    String amount,
    IconData icon,
    Color color,
  ) {
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
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textGray,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              color: AppTheme.textDarkBlue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: TEAM VIEW ---
  Widget _buildTeamTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Affiliate Referral Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardLightBlue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "YOUR REFERRAL PROGRAM",
                  style: TextStyle(
                    color: AppTheme.textDarkBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardLightBlue.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _referralLink.isNotEmpty
                              ? _referralLink
                              : "Loading referral Link...",
                          style: const TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      onPressed: () {
                        if (_referralLink.isNotEmpty) {
                          Clipboard.setData(ClipboardData(text: _referralLink));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Referral link copied to clipboard",
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      onPressed: _handleShareReferral,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.blueGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
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
                        const Text(
                          "TEAM GROWTH",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Current Team",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$_membersCount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.hub_outlined,
                      color: Colors.white38,
                      size: 54,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "TARGET : 126",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _membersCount / 126.0,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "0%",
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    Text(
                      "${(_membersCount * 100 / 126).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "100%",
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "YOUR AFFILIATE NETWORK",
            style: TextStyle(
              color: AppTheme.textDarkBlue,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          _teamMembers.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardLightBlue),
                  ),
                  child: const Center(
                    child: Text(
                      "No affiliates have joined using your referral link yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textGray,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _teamMembers.length,
                  itemBuilder: (context, index) {
                    final member = _teamMembers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.cardLightBlue),
                      ),
                      child: ListTile(
                        tileColor: Colors.white,
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue.withOpacity(
                            0.1,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        title: Text(
                          member['fullName'] ?? 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDarkBlue,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          "ID: SRD${member['id'].toString().padLeft(8, '0')}\nJoined: ${member['createdAt'] != null ? member['createdAt'].toString().substring(0, 10) : ''}",
                          style: const TextStyle(fontSize: 10, height: 1.4),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (member['status'] == 'ACTIVE'
                                        ? Colors.green
                                        : Colors.orange)
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            member['status'] ?? 'PENDING',
                            style: TextStyle(
                              color: member['status'] == 'ACTIVE'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    level,
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              team,
              style: const TextStyle(
                color: AppTheme.textDarkBlue,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              income,
              style: const TextStyle(
                color: AppTheme.textDarkBlue,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              total,
              style: const TextStyle(
                color: AppTheme.textDarkBlue,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
              textAlign: TextAlign.right,
            ),
          ),
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
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.primaryBlue,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "ID : EARNFARMX7AQ96SD$_userId",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Active Member",
                                  style: TextStyle(
                                    color: AppTheme.primaryBlue,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.verified_user,
                      color: Colors.white.withOpacity(0.12),
                      size: 54,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProfileSubMetric(
                        "Main Balance",
                        "₹ ${_mainWalletBalance.toStringAsFixed(2)}",
                        Icons.account_balance_wallet,
                        onTap: () => Navigator.pushNamed(context, '/wallet-details').then((_) => _loadUserProfile()),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: AppTheme.cardLightBlue,
                      ),
                      _buildProfileSubMetric(
                        "Team Size",
                        "${_teamMembers.length}",
                        Icons.group,
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: AppTheme.cardLightBlue,
                      ),
                      _buildProfileSubMetric(
                        "Fund Balance",
                        "₹ ${_fundWalletBalance.toStringAsFixed(2)}",
                        Icons.wallet_giftcard,
                        onTap: () => Navigator.pushNamed(context, '/wallet-details').then((_) => _loadUserProfile()),
                      ),
                    ],
                  ),
                ),
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
                _buildProfileMenuOption(
                  Icons.person,
                  "Manage Profile",
                  "Update your personal details",
                  onTap: () {
                    Navigator.pushNamed(context, '/profile-details').then((
                      val,
                    ) {
                      if (val != null) {
                        setState(() {
                          _fullName = val as String;
                        });
                      }
                    });
                  },
                ),
                _buildProfileMenuOption(
                  Icons.security,
                  "Password & Security",
                  "Change password and secure your account",
                  onTap: () {
                    Navigator.pushNamed(context, '/security-details');
                  },
                ),
                _buildProfileMenuOption(
                  Icons.notifications_active,
                  "Notifications",
                  "Manage your notification preferences",
                  onTap: _showNotificationsDialog,
                ),
                _buildProfileMenuOption(
                  Icons.share,
                  "Refer & Earn",
                  "Share app with friends and earn ₹300.00",
                  onTap: _handleShareReferral,
                ),
                _buildProfileMenuOption(
                  Icons.info,
                  "About Us",
                  "Know more about SR Digital Seva Kendram",
                  onTap: () => _openWebUrl("https://srdigitalseva.com"),
                ),
                _buildProfileMenuOption(
                  Icons.help_center,
                  "Support",
                  "Help & support center",
                  onTap: () => _openWebUrl("https://srdigitalseva.com/contact"),
                ),
                _buildProfileMenuOption(
                  Icons.power_settings_new,
                  "Log out",
                  "Sign out from your account",
                  isLogout: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileSubMetric(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 18),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textGray,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuOption(
    IconData icon,
    String title,
    String subtitle, {
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout
              ? Colors.red.withOpacity(0.08)
              : AppTheme.primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isLogout ? Colors.red : AppTheme.primaryBlue,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : AppTheme.textDarkBlue,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textGray, fontSize: 10),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      onTap: onTap ?? (isLogout ? _handleLogout : () {}),
    );
  }
}

class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final Duration backDuration;

  const MarqueeWidget({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 10000),
    this.backDuration = const Duration(milliseconds: 800),
  });

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scroll());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll() async {
    while (_scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (_scrollController.hasClients) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        if (maxExtent > 0) {
          await _scrollController.animateTo(
            maxExtent,
            duration: widget.animationDuration,
            curve: Curves.linear,
          );
          await Future.delayed(const Duration(milliseconds: 1000));
          if (_scrollController.hasClients) {
            await _scrollController.animateTo(
              0.0,
              duration: widget.backDuration,
              curve: Curves.easeOut,
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: widget.child,
    );
  }
}
