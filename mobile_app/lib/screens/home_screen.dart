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
        _referralLink =
            "https://earnfarm.com/join?ref=EARNFARMX7AQ96SD$_userId";
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

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Exit App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to exit EarnFarm?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Yes",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmationDialog(context);
        if (shouldPop == true) {
          SystemNavigator.pop();
        }
      },
      child: BackgroundContainer(
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
                        _buildDrawerItem(
                          Icons.home_outlined,
                          "Home Portal",
                          () {
                            Navigator.pop(context);
                            setState(() => _currentIndex = 0);
                          },
                        ),
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
                        _buildDrawerItem(
                          Icons.person_outline,
                          "My Profile",
                          () {
                            Navigator.pop(context);
                            setState(() => _currentIndex = 3);
                          },
                        ),
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
            leading: Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0052CC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            centerTitle: true,
            title: Image.asset(
              'assets/sr_logo.png',
              height: 38,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Text(
                "SR DIGITAL SEVA",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: Color(0xFF0052CC),
                    size: 24,
                  ),
                  onPressed: () {},
                ),
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
            padding: const EdgeInsets.symmetric(vertical: 4),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomNavItem(0, Icons.home_outlined, Icons.home, "Home"),
                _buildCustomNavItem(1, Icons.business_center_outlined, Icons.business_center, "Business"),
                _buildCustomNavItem(2, Icons.group_outlined, Icons.group, "Team"),
                _buildCustomNavItem(3, Icons.person_outlined, Icons.person, "Profile"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavItem(int index, IconData outlineIcon, IconData solidIcon, String label) {
    final bool isActive = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: isActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0052CC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(solidIcon, color: Colors.white, size: 20),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(outlineIcon, color: const Color(0xFF0052CC), size: 20),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF0052CC),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),)
        ;
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

  void _navigateToSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("ID Activation"),
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: _buildSubscriptionActivationView(),
        ),
      ),
    ).then((_) => _loadUserProfile());
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Wallet Balance & User Status Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Your Wallet Balance
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/icons_logo/wallet.png",
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Your Balance",
                              style: TextStyle(
                                color: AppTheme.textGray,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "₹ ${_mainWalletBalance.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Color(0xFF0052CC),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                const SizedBox(width: 12),
                // User Status
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/icons_logo/user.png",
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "User Status",
                              style: TextStyle(
                                color: AppTheme.textGray,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _activeCycleId.isNotEmpty ? "ACTIVE" : "PENDING",
                              style: TextStyle(
                                color: _activeCycleId.isNotEmpty
                                    ? const Color(0xFF0052CC)
                                    : Colors.orange,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
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
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/fund-request',
                  ).then((_) => _loadUserProfile()),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/icons_logo/wallet_home.png",
                        width: 26,
                        height: 26,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Add Money",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 24, color: Colors.white24),
                InkWell(
                  onTap: _navigateToSubscription,
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/icons_logo/subscribe.png",
                        width: 26,
                        height: 26,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Subscribe",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 24, color: Colors.white24),
                InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/withdrawal',
                  ).then((_) => _loadUserProfile()),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/icons_logo/cashout.png",
                        width: 26,
                        height: 26,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Cashout",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Services Divided Grid Card (Prepaid, Electricity, DTH, FastTag, Insurance, Water Bill, Postpaid, More)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
           // padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                // Row 1: Prepaid, Electricity, DTH, FastTag
                Row(
                  children: [
                    Expanded(
                      child: _buildServiceGridItem(
                        Icons.phone_android,
                        "Prepaid",
                        const Color(0xFF0052CC),
                      ),
                    ),
                    Container(
                      width: 0.5,
                      height: 75,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFFE2E8F0).withOpacity(0.4),
                            const Color(0xFFE2E8F0),
                            const Color(0xFFE2E8F0).withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildServiceGridItem(
                        Icons.lightbulb_outline,
                        "Electricity",
                        const Color(0xFF0052CC),
                      ),
                    ),
                    Container(
                      width: 0.5,
                      height: 75,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFFE2E8F0).withOpacity(0.4),
                            const Color(0xFFE2E8F0),
                            const Color(0xFFE2E8F0).withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildServiceGridItem(
                        Icons.satellite_alt_outlined,
                        "DTH",
                        const Color(0xFF0052CC),
                      ),
                    ),
                    Container(
                      width: 0.5,
                      height: 75,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFFE2E8F0).withOpacity(0.4),
                            const Color(0xFFE2E8F0),
                            const Color(0xFFE2E8F0).withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildServiceGridItem(
                        Icons.directions_car,
                        "FastTag",
                        const Color(0xFF0052CC),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFFE2E8F0).withOpacity(0.4),
                        const Color(0xFFE2E8F0),
                        const Color(0xFFE2E8F0).withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Row 2: Insurance, Water Bill, Postpaid, More
                Row(
                  children: [
                    Expanded(
                      child: _buildServiceGridItem(
                        Icons.shield_outlined,
                        "Insurance",
                        const Color(0xFF0052CC),
                      ),
                    ),
                    Container(
                      width: 0.5,
                      height: 75,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFFE2E8F0).withOpacity(0.4),
                            const Color(0xFFE2E8F0),
                            const Color(0xFFE2E8F0).withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildServiceGridItem(
                        Icons.water_drop_outlined,
                        "Water Bill",
                        const Color(0xFF0052CC),
                      ),
                    ),
                    Container(
                      width: 0.5,
                      height: 75,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFFE2E8F0).withOpacity(0.4),
                            const Color(0xFFE2E8F0),
                            const Color(0xFFE2E8F0).withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildServiceGridItem(
                        Icons.description_outlined,
                        "Postpaid",
                        const Color(0xFF0052CC),
                      ),
                    ),
                    Container(
                      width: 0.5,
                      height: 75,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFFE2E8F0).withOpacity(0.4),
                            const Color(0xFFE2E8F0),
                            const Color(0xFFE2E8F0).withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildServiceGridItem(
                        Icons.apps,
                        "More",
                        const Color(0xFF0052CC),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                          style: TextStyle(
                            color: AppTheme.textGray,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transactions.length > 5
                          ? 5
                          : _transactions.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: AppTheme.cardLightBlue,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        final type = tx['type'] as String? ?? 'Transaction';
                        final amount = tx['amount'] as String? ?? '₹0.00';
                        final date = tx['date'] as String? ?? '';

                        final typeLower = type.toLowerCase();
                        final bool isIncome =
                            !typeLower.contains('debit') &&
                            !typeLower.contains('cashout') &&
                            !typeLower.contains('withdrawal');

                        return _buildTransactionRow(
                          icon: isIncome
                              ? Icons.call_received
                              : Icons.call_made,
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
        assetPath = "assets/logos/reccharge.png";
        break;
      case "electricity":
        assetPath = "assets/logos/electricity.png";
        break;
      case "dth":
        assetPath = "assets/logos/dth.png";
        break;
      case "fasttag":
        assetPath = "assets/logos/fasttag.png";
        break;
      case "insurance":
        assetPath = "assets/logos/insurance.png";
        break;
      case "water bill":
        assetPath = "assets/logos/water.png";
        break;
      case "postpaid":
        assetPath = "assets/logos/postpaid.png";
        break;
      case "more":
        assetPath = "assets/logos/more.png";
        break;
    }

    return InkWell(
      onTap: () {
        if (_activeCycleId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please activate your ID to access services."),
            ),
          );
          _navigateToSubscription();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderSelectionScreen(serviceType: label),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: assetPath != null
                    ? Image.asset(
                        assetPath,
                        width: 34,
                        height: 34,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          icon,
                          color: const Color(0xFF0052CC),
                          size: 28,
                        ),
                      )
                    : Icon(icon, color: const Color(0xFF0052CC), size: 28),
              ),
            ),
            const SizedBox(height: 6),
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
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/business_page.png',
                color: Colors.white,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(icon, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppTheme.textDarkBlue,
                ),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: Color(0xFF0052CC),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFF0052CC), size: 18),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: BUSINESS VIEW ---
  Widget _buildBusinessTab() {
    double totalEarned = _mainWalletBalance;
    double progressVal = (_membersCount / 126.0).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Income Growth Card
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Business Page Icon on the Left
                    Image.asset(
                      'assets/business_page.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.trending_up,
                        color: Colors.white38,
                        size: 70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Vertical White Divider
                    Container(width: 1, height: 95, color: Colors.white24),
                    const SizedBox(width: 16),
                    // Text Details on the Right
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "INCOME GROWTH",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "You've earned",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            "₹ ${totalEarned.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Of ₹ 12,600",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Custom slider-style progress indicator inside right column
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double maxWidth = constraints.maxWidth;
                              final double thumbPosition =
                                  maxWidth * progressVal;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "0%",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 9,
                                        ),
                                      ),
                                      Text(
                                        "100%",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Stack(
                                    alignment: Alignment.centerLeft,
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Track
                                      Container(
                                        width: maxWidth,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.white24,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      // Active Track
                                      Container(
                                        width: thumbPosition,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      // Thumb circle dot
                                      Positioned(
                                        left: (thumbPosition - 6).clamp(
                                          0.0,
                                          maxWidth - 12,
                                        ),
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),



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

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    // Row 1: Today Income & Total Income
                    Row(
                      children: [
                        Expanded(
                          child: _buildBusinessStatItem(
                            "TODAY INCOME",
                            "₹ ${todayIncome.toStringAsFixed(2)}",
                            Icons.trending_up,
                          ),
                        ),
                        Container(
                          width: 0.5,
                          height: 90,
                          color: const Color(0xFFE2E8F0),
                        ),
                        Expanded(
                          child: _buildBusinessStatItem(
                            "TOTAL INCOME",
                            "₹ ${totalIncome.toStringAsFixed(2)}",
                            Icons.account_balance_wallet,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 0.5,
                      color: const Color(0xFFE2E8F0),
                    ),
                    // Row 2: Global Income & Affiliate Income
                    Row(
                      children: [
                        Expanded(
                          child: _buildBusinessStatItem(
                            "GLOBAL INCOME",
                            "₹ ${globalIncome.toStringAsFixed(2)}",
                            Icons.language,
                          ),
                        ),
                        Container(
                          width: 0.5,
                          height: 90,
                          color: const Color(0xFFE2E8F0),
                        ),
                        Expanded(
                          child: _buildBusinessStatItem(
                            "AFFILIATE INCOME",
                            "₹ ${affiliateIncome.toStringAsFixed(2)}",
                            Icons.people,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Refer invitation Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    "assets/icons_logo/refer.png",
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Refer App Earn ₹ 300.00",
                        style: TextStyle(
                          color: AppTheme.textDarkBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Each Referral",
                        style: TextStyle(
                          color: AppTheme.textDarkBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: _handleShareReferral,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0052CC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "INVITE NOW",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.chevron_right,
                              color: Color(0xFF0052CC),
                              size: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessStatItem(
    String label,
    String amount,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0052CC), size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textGray,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Color(0xFF0052CC),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: TEAM VIEW ---
  Widget _buildLevelRow({
    required String level,
    required String team,
    required String income,
    required String total,
    required Color bgColor,
    bool isHeader = false,
    bool isFooter = false,
  }) {
    final TextStyle textStyle = TextStyle(
      fontSize: 12,
      fontWeight: (isHeader || isFooter) ? FontWeight.bold : FontWeight.w600,
      color: isHeader
          ? Colors.white
          : (isFooter ? const Color(0xFF0C3C8F) : AppTheme.textDarkBlue),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: isHeader
            ? const BorderRadius.vertical(top: Radius.circular(16))
            : (isFooter
                  ? const BorderRadius.vertical(bottom: Radius.circular(16))
                  : null),
      ),
      child: Row(
        children: [
          // Level
          Expanded(
            flex: 2,
            child: isHeader || isFooter
                ? Text(level, style: textStyle, textAlign: TextAlign.center)
                : Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          level,
                          style: const TextStyle(
                            color: Color(0xFF0052CC),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          // Team
          Expanded(
            flex: 2,
            child: Text(team, style: textStyle, textAlign: TextAlign.center),
          ),
          // Income
          Expanded(
            flex: 3,
            child: Text(income, style: textStyle, textAlign: TextAlign.center),
          ),
          // Total
          Expanded(
            flex: 3,
            child: Text(total, style: textStyle, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Growth Card
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Team Network Icon on the Left
                    Image.asset(
                      'assets/teams.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.hub_outlined,
                        color: Colors.white38,
                        size: 70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Vertical White Divider
                    Container(width: 1, height: 95, color: Colors.white24),
                    const SizedBox(width: 16),
                    // Text & Progress details on the Right
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "TEAM GROWTH",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Current Team",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            "$_membersCount",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "TARGET : 126",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Custom slider-style progress indicator inside right column
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double maxWidth = constraints.maxWidth;
                              final double progress = (_membersCount / 126.0)
                                  .clamp(0.0, 1.0);
                              final double thumbPosition = maxWidth * progress;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "0%",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 9,
                                        ),
                                      ),
                                      Text(
                                        "100%",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Stack(
                                    alignment: Alignment.centerLeft,
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Track
                                      Container(
                                        width: maxWidth,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.white24,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      // Active Track
                                      Container(
                                        width: thumbPosition,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      // Thumb circle dot
                                      Positioned(
                                        left: (thumbPosition - 6).clamp(
                                          0.0,
                                          maxWidth - 12,
                                        ),
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Levels Matrix Table Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                _buildLevelRow(
                  level: "Level",
                  team: "Team",
                  income: "Income",
                  total: "Total",
                  bgColor: AppTheme.primaryBlue,
                  isHeader: true,
                ),
                // Rows 1 to 6
                _buildLevelRow(
                  level: "1",
                  team: "2",
                  income: "₹ 100",
                  total: "₹ 200",
                  bgColor: Colors.white,
                ),
                _buildLevelRow(
                  level: "2",
                  team: "4",
                  income: "₹ 100",
                  total: "₹ 400",
                  bgColor: const Color(0xFFF8FAFC),
                ),
                _buildLevelRow(
                  level: "3",
                  team: "8",
                  income: "₹ 100",
                  total: "₹ 800",
                  bgColor: Colors.white,
                ),
                _buildLevelRow(
                  level: "4",
                  team: "16",
                  income: "₹ 100",
                  total: "₹ 1,600",
                  bgColor: const Color(0xFFF8FAFC),
                ),
                _buildLevelRow(
                  level: "5",
                  team: "32",
                  income: "₹ 100",
                  total: "₹ 3,200",
                  bgColor: Colors.white,
                ),
                _buildLevelRow(
                  level: "6",
                  team: "64",
                  income: "₹ 100",
                  total: "₹ 6,400",
                  bgColor: const Color(0xFFF8FAFC),
                ),
                // Footer
                _buildLevelRow(
                  level: "Total",
                  team: "126",
                  income: "₹ 600",
                  total: "₹ 12,600",
                  bgColor: const Color(0xFFEFF6FF),
                  isFooter: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "YOUR REFERRAL NETWORK",
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
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Text(
                      "No affiliates have joined using your referral link yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textGray, fontSize: 12),
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
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
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
          const SizedBox(height: 20),
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
    double globalIncome = 0;
    if (_activeCycleId.isNotEmpty) {
      if (_membersCount >= 2) globalIncome += 200;
      if (_membersCount >= 6) globalIncome += 400;
      if (_membersCount >= 14) globalIncome += 800;
      if (_membersCount >= 30) globalIncome += 1600;
      if (_membersCount >= 62) globalIncome += 3200;
      if (_membersCount >= 126) globalIncome += 6400;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(16),
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
                    // Circular bordered user avatar
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Vertical White Divider
                    Container(width: 1, height: 68, color: Colors.white24),
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
                            "ID : $_mobileNumber",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Active Member Badge
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
                                  Icons.verified,
                                  color: Color(0xFF0052CC),
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Active Member",
                                  style: TextStyle(
                                    color: Color(0xFF0052CC),
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
                      size: 58,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // White 3-Column Submetrics Row inside Header Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Total Income
                      Expanded(
                        child: _buildProfileSubMetric(
                          "Total Income",
                          "₹ ${_mainWalletBalance.toStringAsFixed(2)}",
                          Icons.account_balance_wallet_outlined,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/wallet-details',
                          ).then((_) => _loadUserProfile()),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: const Color(0xFFE2E8F0),
                      ),
                      // Team Size
                      Expanded(
                        child: _buildProfileSubMetric(
                          "Team Size",
                          "$_membersCount",
                          Icons.group_outlined,
                          onTap: () => setState(() => _currentIndex = 2),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: const Color(0xFFE2E8F0),
                      ),
                      // Global Income
                      Expanded(
                        child: _buildProfileSubMetric(
                          "Global Income",
                          "₹ ${globalIncome.toStringAsFixed(2)}",
                          Icons.bar_chart_outlined,
                          onTap: () => setState(() => _currentIndex = 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Menu Options List Box
          Container(
            padding:EdgeInsets.symmetric(
              vertical:10
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  Icons.shield,
                  "Password & Security",
                  "Secure your account",
                  onTap: () {
                    Navigator.pushNamed(context, '/security-details');
                  },
                ),
                _buildProfileMenuOption(
                  Icons.notifications,
                  "Notifications",
                  "Manage your notification preferences",
                  onTap: _showNotificationsDialog,
                ),
                _buildProfileMenuOption(
                  Icons.info,
                  "About Us",
                  "Know more about SR Digital Seva Kendram",
                  onTap: () => _openWebUrl("https://srdigitalseva.com"),
                ),
                _buildProfileMenuOption(
                  Icons.support_agent,
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

  Widget _buildProfileSubMetric(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0052CC), size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textGray,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0052CC),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0052CC), size: 20),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textDarkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textGray, fontSize: 10),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF0052CC),
        size: 22,
      ),
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
