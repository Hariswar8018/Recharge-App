import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_me/share_me.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/background_container.dart';
import '../../widgets/processing_dialog.dart';
import '../../widgets/captcha_earn_widget.dart';
import '../../widgets/marquee_widget.dart';
import '../../models/transaction_model.dart';
import '../recharge/id_subscription_screen.dart';
import '../transactions/transaction_receipt_screen.dart';
import '../profile/profile_details_screen.dart';
import '../profile/security_details_screen.dart';
import '../profile/notifications_screen.dart';
import '../profile/policy_screen.dart';
import '../profile/direct_team_screen.dart';
import '../profile/bank_verify_screen.dart';

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
  Timer? _healthCheckTimer;
  Map<String, dynamic> _visibilitySettings = {};

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

  String _getFirstNameMax15(String fullName) {
    if (fullName.isEmpty) return 'Member';
    final parts = fullName.trim().split(' ');
    String firstName = parts[0];
    if (firstName.length > 15) {
      firstName = firstName.substring(0, 15);
    }
    return firstName;
  }

  Future<void> _loadUserProfile() async {
    final response = await ApiService.getProfile();
    final user = response['user'] ?? {};
    final cycles = await ApiService.getCyclesHistory();
    final team = await ApiService.getTeam();
    final txns = await ApiService.getTransactions();
    final visibility = await ApiService.getVisibility();

    dynamic activeCycle;
    try {
      activeCycle = cycles.firstWhere(
        (c) => c['status'] == 'ACTIVE',
        orElse: () => null,
      );
    } catch (_) {
      activeCycle = null;
    }

    if (mounted) {
      setState(() {
        _visibilitySettings = visibility;
        _fullName = user['fullName'] ?? "Rajesh Reddy";
        _userId = user['id'] ?? 0;
        _email = user['email'] ?? "";
        _mobileNumber = user['mobileNumber'] ?? "";
        _createdAt = user['createdAt'] != null
            ? DateTime.parse(
                user['createdAt'],
              ).toLocal().toString().substring(0, 10)
            : "2026-08-25";

        final double fetchedBal = parseDouble(user['main_wallet_balance']) ?? 0.00;
        if (fetchedBal > _mainWalletBalance || _mainWalletBalance == 0.00) {
          _mainWalletBalance = fetchedBal;
        }

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
        _referralLink = "https://play.google.com/store/apps/details?id=com.app.earnfarm";
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
    String adminShareText = "";
    String adminPlayStoreLink = "";

    try {
      final info = await ApiService.getLandingInfo();
      final settings = info['settings'] is Map ? info['settings'] : {};
      adminShareText = (info['app_share_text'] ?? settings['app_share_text'] ?? settings['referral_text'] ?? "").toString().trim();
      adminPlayStoreLink = (info['playstore_link'] ?? settings['playstore_link'] ?? "").toString().trim();
    } catch (_) {}

    final String fallbackText = "Download our App to Earn Money from Scratch Cards";
    final String fallbackPlayStore = "https://play.google.com/store/apps/details?id=com.app.earnfarm";

    final String shareText = adminShareText.isNotEmpty ? adminShareText : fallbackText;
    final String playStoreUrl = adminPlayStoreLink.isNotEmpty ? adminPlayStoreLink : fallbackPlayStore;

    final String textToCopy = "$shareText\n\n$playStoreUrl";

    // 1. Copy text and PlayStore link to clipboard
    await Clipboard.setData(ClipboardData(text: textToCopy));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("App link copied to clipboard! Opening Play Store..."),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // 2. Redirect ONLY to Play Store
    final Uri playStoreUri = Uri.parse(playStoreUrl);
    final Uri marketUri = Uri.parse("market://details?id=com.app.earnfarm");
    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  Future<void> _handleActivateCycle() async {
    showProcessingDialog(context, "Activating ID / Subscription...");
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await ApiService.activateCycle();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
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
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  void _handleLogout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
        content: const Text("Are you sure you want to exit SR Digital Seva Kendram?"),
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
                          Icons.people_outline,
                          "Direct Team Members",
                          () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DirectTeamScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDrawerItem(
                          Icons.account_balance_outlined,
                          "Bank Account Verify",
                          () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BankVerifyScreen(),
                              ),
                            );
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
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            leadingWidth: 64,
            leading: Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Center(
                  child: InkWell(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0052CC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            centerTitle: true,
            title: Image.asset(
              'assets/sr_logo.png',
              height: 46,
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
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InternalNotificationsScreen(),
                      ),
                    );
                  },
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
                    SizedBox(height: 10),
                    SafeArea(
                      bottom: false,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 16,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(
                            0xFFEFF6FF,
                          ), // very light blue background
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/logos/announcmenet.png',
                              width: 13,
                              height: 13,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.volume_up,
                                    color: AppTheme.primaryBlue,
                                    size: 16,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MarqueeWidget(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 50),
                                  child: Text(
                                    "⚡ Welcome to SR Digital Seva    |    Grow your income with Smart Digital Services & Instant Micro Earnings! 🚀",
                                    style: const TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                _buildCustomNavItem(
                  1,
                  Icons.business_center_outlined,
                  Icons.business_center,
                  "Business",
                ),
                _buildCustomNavItem(
                  2,
                  Icons.group_outlined,
                  Icons.group,
                  "Team",
                ),
                _buildCustomNavItem(
                  3,
                  Icons.person_outlined,
                  Icons.person,
                  "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavItem(
    int index,
    IconData outlineIcon,
    IconData solidIcon,
    String label,
  ) {
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  void _navigateToSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IdSubscriptionScreen(),
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

  Widget _buildBlinkingTopUpCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.35, end: 1.0),
      duration: const Duration(milliseconds: 700),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const IdSubscriptionScreen()),
          ).then((_) => _loadUserProfile());
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "TOP-UP REQUIRED! (126 Members Reached)",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Tap here to Top-Up ID (₹1,200) & unlock next cycle income!",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionNoticeBanner(String noticeKey, String visKey) {
    final String notice = _visibilitySettings[noticeKey]?.toString() ?? '';
    final String vis = _visibilitySettings[visKey]?.toString() ?? 'Show';
    final bool isEnabled = _visibilitySettings[visKey.replaceAll('_visibility', '_enabled')] != false;

    if (vis == 'Hide' || !isEnabled) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock, color: Colors.red, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                notice.isNotEmpty ? notice : "This feature is currently disabled or hidden by admin.",
                style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (notice.isNotEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info, color: AppTheme.primaryBlue, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                notice,
                style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // --- TAB 0: HOME VIEW ---
  Widget _buildHomeTab() {
    final bool isTopUpRequired = _membersCount >= 126;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionNoticeBanner('sec_home_notice', 'sec_home_visibility'),
          if (isTopUpRequired) ...[
            _buildBlinkingTopUpCard(),
            const SizedBox(height: 12),
          ],
          // Wallet Balance & User Status Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
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
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/icons_logo/wallet.png",
                          width: 30,
                          height: 30,
                          fit: BoxFit.contain,
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
                          fit: BoxFit.contain,
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
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
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

          const SizedBox(height: 10),

          // Actions Row: Add Money, Subscribe, Cashout
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(9),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
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
                        width: 42,
                        height: 42,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(width: 1),
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
                        width: 42,
                        height: 42,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 1),
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
                        width: 42,
                        height: 42,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 1),
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
                SizedBox(width: 1),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // New Captcha Solve & Earn Section
          CaptchaEarnWidget(
            onEarn: (earnedAmount) async {
              setState(() {
                _mainWalletBalance += earnedAmount;
              });
              final updatedTxns = await ApiService.getTransactions();
              if (mounted) {
                setState(() {
                  _transactions = updatedTxns;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          // Refer invitation Card (Visible on Home Dashboard)
         

          /*
          // HIDDEN RECHARGE SECTION (Preserved as requested)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
          */

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
              Row(
                children: [
                  Container(width: 18, height: 3.5, color: AppTheme.primaryBlue),
                ],
              ),
              _transactions.isEmpty
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.history_toggle_off_rounded, color: Color(0xFF0A369D), size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "No Recent Transactions",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Your wallet earnings and captcha rewards will appear here.",
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transactions.isNotEmpty ? 1 : 0,
                      separatorBuilder: (context, index) => const Divider(
                        color: AppTheme.cardLightBlue,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        final type = tx['type'] as String? ?? 'Transaction';
                        final amount = tx['amount'] as String? ?? '₹0.00';
                        final rawDate = tx['date'] ?? tx['createdAt'] ?? '';
                        final date = DateFormatter.formatToIST(rawDate);

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

  // ignore: unused_element
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
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  "$label - Coming Soon",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0D47A1),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
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
                        width: 45,
                        height: 45,
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
                title: type,
                type: type,
                descLine1: type,
                descLine2: "Wallet Transaction",
                amount: amount,
                date: date,
                isIncome: isIncome,
                reference: "SR927281",
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
    double realGlobalIncome = 0.0;
    double realAffiliateIncome = 0.0;
    double todayIncome = 0.0;

    final String nowStr = DateTime.now().toLocal().toString().substring(0, 10);

    for (var tx in _transactions) {
      final String status = (tx['status'] ?? '').toString().toLowerCase();
      if (status == 'success' || status == 'approved' || status == 'completed') {
        final String type = (tx['type'] ?? '').toString();
        final double rawAmt = parseDouble(tx['amount']?.toString().replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

        final bool isGlobal = type.contains('Level') || type.contains('Global') || type.contains('Cycle');
        final bool isAffiliate = type.contains('Direct') || type.contains('Affiliate') || type.contains('Referral');

        if (isGlobal) {
          realGlobalIncome += rawAmt;
        } else if (isAffiliate) {
          realAffiliateIncome += rawAmt;
        }

        if (isGlobal || isAffiliate) {
          final String txDate = (tx['date'] ?? '').toString();
          if (txDate.contains(nowStr)) {
            todayIncome += rawAmt;
          }
        }
      }
    }

    double totalEarned = realGlobalIncome + realAffiliateIncome;
    double progressVal = (totalEarned / 12600.0).clamp(0.0, 1.0);
    final String percentDisplay = "${(progressVal * 100).toStringAsFixed(1)}%";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionNoticeBanner('sec_business_income_notice', 'sec_business_income_visibility'),
          // Income Growth Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 8,
              top: 20,
              bottom: 20,
              right: 15,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.blueGradient,
              borderRadius: BorderRadius.circular(15),
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
                    const SizedBox(width: 8),
                    // Vertical White Divider
                    Container(width: 1, height: 135, color: Colors.white24),
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
                                    children: [
                                      Text(
                                        percentDisplay,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
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
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                          child: _buildBusinessStatItem(
                            "TOTAL INCOME",
                            "₹ ${totalEarned.toStringAsFixed(2)}",
                            Icons.account_balance_wallet,
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
                    // Row 2: Global Income & Affiliate Income
                    Row(
                      children: [
                        Expanded(
                          child: _buildBusinessStatItem(
                            "GLOBAL INCOME",
                            "₹ ${realGlobalIncome.toStringAsFixed(2)}",
                            Icons.language,
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
                          child: _buildBusinessStatItem(
                            "AFFILIATE INCOME",
                            "₹ ${realAffiliateIncome.toStringAsFixed(2)}",
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
          _buildInviteCard(),
        ],
      ),
    );
  }

  Widget _buildInviteCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(1),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              "assets/icons_logo/refer.png",
              width: 45,
              height: 45,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Refer App Earn ₹ 300.00",
                  style: TextStyle(
                    color: AppTheme.textDarkBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Each Referral",
                  style: TextStyle(
                    color: AppTheme.textDarkBlue,
                    fontWeight: FontWeight.w500,
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
                borderRadius: BorderRadius.circular(9),
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
    );
  }

  Widget _buildBusinessStatItem(String label, String amount, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0052CC), size: 25),
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
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 1),
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
  Widget _buildStatusBadge(String status) {
    if (status == "Status") {
      return const Text(
        "Status",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      );
    }

    final String sUpper = status.toUpperCase();
    Color bgColor;
    Color textColor;
    IconData iconData;
    String displayLabel;

    if (sUpper.contains("COMPLET")) {
      displayLabel = "Completed";
      bgColor = const Color(0xFFDCFCE7); // Light green badge
      textColor = const Color(0xFF15803D); // Dark green text
      iconData = Icons.check_circle_rounded;
    } else if (sUpper.contains("PROGRESS") || sUpper.contains("PENDING")) {
      displayLabel = "In Progress";
      bgColor = const Color(0xFFFEF3C7); // Light orange badge
      textColor = const Color(0xFFB45309); // Dark orange text
      iconData = Icons.access_time_rounded;
    } else {
      displayLabel = "Locked";
      bgColor = const Color(0xFFF1F5F9); // Light gray badge
      textColor = const Color(0xFF64748B); // Dark gray text
      iconData = Icons.lock_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, color: textColor, size: 12),
          const SizedBox(width: 4),
          Text(
            displayLabel,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelRow({
    required String level,
    required String team,
    required String income,
    required String status,
    required Color bgColor,
    bool isHeader = false,
    bool isFirstRow = false,
    bool isLastRow = false,
  }) {
    final TextStyle textStyle = TextStyle(
      fontSize: 13,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.w700,
      color: isHeader ? Colors.white : const Color(0xFF1E293B),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: isHeader
            ? const BorderRadius.vertical(top: Radius.circular(15))
            : BorderRadius.only(
                bottomLeft: isLastRow ? const Radius.circular(15) : Radius.zero,
                bottomRight: isLastRow ? const Radius.circular(15) : Radius.zero,
              ),
        border: !isHeader && !isLastRow
            ? const Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))
            : null,
      ),
      child: Row(
        children: [
          // Level (Circle badge for data rows)
          Expanded(
            flex: 2,
            child: isHeader
                ? Text(level, style: textStyle, textAlign: TextAlign.center)
                : Center(
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          level,
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          // Team (Required level team count: 2, 4, 8, 16, 32, 64)
          Expanded(
            flex: 2,
            child: Text(team, style: textStyle, textAlign: TextAlign.center),
          ),
          // Income (Level release income: 200, 400, 800, 1600, 3200, 6400)
          Expanded(
            flex: 3,
            child: Text(income, style: textStyle, textAlign: TextAlign.center),
          ),
          // Status (Completed / In Progress / Locked)
          Expanded(
            flex: 3,
            child: Center(child: _buildStatusBadge(status)),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamTab() {
    final int realTeamCount = _teamMembers.length > _membersCount ? _teamMembers.length : _membersCount;
    final double progressRatio = (realTeamCount / 126.0).clamp(0.0, 1.0);
    final String percentDisplay = "${(progressRatio * 100).toStringAsFixed(1)}%";

    final List<Map<String, dynamic>> levelData = [
      {"level": "1", "team": "2", "income": "₹ 200.00", "cumTarget": 2},
      {"level": "2", "team": "4", "income": "₹ 400.00", "cumTarget": 6},
      {"level": "3", "team": "8", "income": "₹ 800.00", "cumTarget": 14},
      {"level": "4", "team": "16", "income": "₹ 1,600.00", "cumTarget": 30},
      {"level": "5", "team": "32", "income": "₹ 3,200.00", "cumTarget": 62},
      {"level": "6", "team": "64", "income": "₹ 6,400.00", "cumTarget": 126},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Growth Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 8,
              top: 20,
              bottom: 20,
              right: 15,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.blueGradient,
              borderRadius: BorderRadius.circular(15),
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
                      'assets/logos/user.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.hub_outlined,
                        color: Colors.white38,
                        size: 70,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Vertical White Divider
                    Container(width: 1, height: 135, color: Colors.white24),
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
                            "$realTeamCount",
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
                              final double thumbPosition = maxWidth * progressRatio;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        percentDisplay,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
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

          // Business Plan Level Table Card (Level, Team, Income, Status)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header Row (Joined at the top of the card)
                _buildLevelRow(
                  level: "Level",
                  team: "Team",
                  income: "Income",
                  status: "Status",
                  bgColor: AppTheme.primaryBlue,
                  isHeader: true,
                ),
                ...List.generate(levelData.length, (i) {
                  final item = levelData[i];
                  final int cumTarget = item['cumTarget'] as int;
                  final int prevCumTarget = i > 0 ? (levelData[i - 1]['cumTarget'] as int) : 0;

                  String statusStr;
                  if (realTeamCount >= cumTarget) {
                    statusStr = "Completed";
                  } else if (i == 0 || realTeamCount >= prevCumTarget) {
                    statusStr = "In Progress";
                  } else {
                    statusStr = "Locked";
                  }

                  return _buildLevelRow(
                    level: item['level'],
                    team: item['team'],
                    income: item['income'],
                    status: statusStr,
                    bgColor: i % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
                    isFirstRow: false,
                    isLastRow: i == levelData.length - 1,
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ignore: unused_element
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
    final int realTeamSize = _teamMembers.length > _membersCount ? _teamMembers.length : _membersCount;
    double globalIncome = 0.0;

    for (var tx in _transactions) {
      final String status = (tx['status'] ?? '').toString().toLowerCase();
      if (status == 'success' || status == 'approved' || status == 'completed') {
        final String type = (tx['type'] ?? '').toString();
        final double rawAmt = parseDouble(tx['amount']?.toString().replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
        if (type.contains('Level') || type.contains('Global') || type.contains('Cycle')) {
          globalIncome += rawAmt;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppTheme.blueGradient,
              borderRadius: BorderRadius.circular(10),
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
                        border: Border.all(color: Colors.white, width: 2.6),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Vertical White Divider
                    Container(width: 1, height: 68, color: Colors.white24),
                    const SizedBox(width: 8),
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
                                  Icons.gpp_good,
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

                const SizedBox(height: 12),

                // White 3-Column Submetrics Row inside Header Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 9,
                    horizontal: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Activation Cycle
                      Expanded(
                        child: _buildProfileSubMetric(
                          "Activation Cycle",
                          "Cycle 1",
                          Icons.autorenew_rounded,
                          onTap: () => _showActivationCycleModal(context),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 65,
                        color: const Color(0xFFE2E8F0),
                      ),
                      // Team Size
                      Expanded(
                        child: _buildProfileSubMetric(
                          "Team Size",
                          "$realTeamSize",
                          Icons.group_outlined,
                          onTap: null,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 65,
                        color: const Color(0xFFE2E8F0),
                      ),
                      // Global Income
                      Expanded(
                        child: _buildProfileSubMetric(
                          "Global Income",
                          "₹ ${globalIncome.toStringAsFixed(2)}",
                          Icons.bar_chart_outlined,
                          onTap: () => _showGlobalIncomeModal(context, globalIncome),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Menu Options List Box
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileMenuOption(
                  Icons.person,
                  "Manage Profile",
                  "View your locked personal details",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileDetailsScreen()),
                    );
                  },
                ),
                _buildProfileMenuDivider(),
                _buildProfileMenuOption(
                  Icons.gpp_good,
                  "Password & Security",
                  "Secure your account password",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SecurityDetailsScreen()),
                    );
                  },
                ),
                _buildProfileMenuDivider(),
                _buildProfileMenuOption(
                  Icons.account_balance_rounded,
                  "Bank Account Verify",
                  "Verify & lock bank details via ₹1 Penny Drop",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BankVerifyScreen()),
                    );
                  },
                ),
                _buildProfileMenuDivider(),
                _buildProfileMenuOption(
                  Icons.notifications,
                  "Notifications",
                  "View admin announcements & alerts",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InternalNotificationsScreen()),
                    );
                  },
                ),
                _buildProfileMenuDivider(),
                _buildProfileMenuOption(
                  Icons.info,
                  "About Us",
                  "Know more about SR Digital Seva Kendram",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InternalPolicyScreen(
                          title: "About Us",
                          content: "SR Digital Seva is a leading digital work platform dedicated exclusively to online CAPTCHA entry and micro-task solutions.\n\nOur mission is to provide an accessible, transparent, and user-friendly digital work platform. We connect users with digital task opportunities, allowing individuals to perform CAPTCHA work and earn rewards based on accuracy, quality, and completed performance standards.\n\nWe prioritize 100% data security, system transparency, and timely wallet distributions for all active users.",
                        ),
                      ),
                    );
                  },
                ),
                _buildProfileMenuDivider(),
                _buildProfileMenuOption(
                  Icons.privacy_tip_outlined,
                  "Privacy Policy",
                  "Our privacy practices & data policy",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InternalPolicyScreen(
                          title: "Privacy Policy",
                          content: "Welcome to SR Digital Seva. We value your privacy and are committed to protecting your personal data.\n\n1. Information We Collect\nWe collect personal identification details required for account creation and service delivery, including Name, Email Address, 10-digit Mobile Number, Bank details for verified payouts, and device metrics for security.\n\n2. How We Use Data\nWe utilize the collected information strictly for user authentication, account management, CAPTCHA work verification, payout processing, and securing platform integrity. We do not sell or share personal data with unauthorized third parties.\n\n3. Security\nWe implement bank-grade SSL encryption and secure data handling protocols to protect your information against unauthorized access, loss, or alteration.\n\n4. User Account & Data Protection\nUsers are responsible for maintaining account credential confidentiality. You may update your profile or request data review via SR Digital Seva support.",
                        ),
                      ),
                    );
                  },
                ),
                _buildProfileMenuDivider(),
                _buildProfileMenuOption(
                  Icons.article_outlined,
                  "Terms & Conditions",
                  "Rules & service agreement",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InternalPolicyScreen(
                          title: "Terms & Conditions",
                          content: "By creating an account and using the SR Digital Seva platform, you confirm that you have reviewed and agreed to the following Terms & Conditions:\n\n1. Agreement to Terms\nBy downloading, installing, or using the SR Digital Seva mobile application or web portal, you agree to be bound by these Terms & Conditions.\n\n2. Platform Scope\nSR Digital Seva operates exclusively as a CAPTCHA Work platform. All legacy service references (recharge, DTH, bill payments) are obsolete and disclaimed.\n\n3. User Account\nUsers must provide accurate information and keep account credentials confidential. One 10-digit mobile number is permitted per User ID. Users must not share, sell, transfer, or allow unauthorized persons to use their account.\n\n4. Work Requirements\nUsers must perform available CAPTCHA work themselves and follow required accuracy, quality, and performance standards. Work that is incomplete, rejected, invalid, or does not meet requirements will not qualify for earnings.\n\n5. Prohibited Activities\nFraudulent activity, manipulation, automated abuse, bot usage, unauthorized access, fake information, duplicate or misleading accounts, or any misuse of the platform is strictly prohibited. Violation of platform rules may result in immediate account restriction, suspension, or termination.\n\n6. Payments & Earnings\nWhere payments or earnings are applicable, they are subject to verification, eligibility, completed and accepted work, applicable platform rules, and required processing procedures.\n\n7. Platform Changes\nWork availability, requirements, features, procedures, and policies may be changed, suspended, or discontinued when reasonably required for operational, security, legal, regulatory, or business purposes.\n\n8. User Responsibility\nUsers are responsible for reading and understanding the Terms & Conditions, Privacy Policy, work requirements, and applicable guidelines before participating.\n\n9. No Employment Guarantee\nParticipation in the SR Digital Seva CAPTCHA Work platform does not by itself create an employment relationship or guarantee employment.\n\n10. Acceptance\nBy creating an account and using the platform, the user confirms that they have reviewed and agreed to all Terms & Conditions and Privacy Policy.",
                        ),
                      ),
                    );
                  },
                ),
                _buildProfileMenuDivider(),
                _buildProfileMenuOption(
                  Icons.support_agent,
                  "Support",
                  "Help & WhatsApp support center",
                  onTap: () => launchWhatsAppSupport(context),
                ),
                _buildProfileMenuDivider(),
                _buildProfileMenuOption(
                  Icons.power_settings_new,
                  "Log out",
                  "Sign out from your account",
                  isLogout: true,
                  onTap: _handleLogout,
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
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0052CC), size: 20),
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

  Widget _buildProfileMenuDivider() {
    return const FractionallySizedBox(
      widthFactor: 0.9,
      child: Divider(
        height: 1,
        thickness: 0.3,
        color: Color(0xFFE0EFFF), // very light blue
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      leading: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0052CC), size: 25),
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
            style: const TextStyle(color: AppTheme.textGray, fontSize: 9),
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

  void _showActivationCycleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Activation Cycle Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Current Cycle", style: TextStyle(fontWeight: FontWeight.w600)),
                  Text("Cycle 1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0052CC))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Cycle Status", style: TextStyle(fontWeight: FontWeight.w600)),
                  Text("Active", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF16A34A))),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showTeamSizeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Team Members Details (${_teamMembers.length})",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _teamMembers.isEmpty
                  ? const Center(child: Text("No direct team members joined yet.", style: TextStyle(color: Colors.grey)))
                  : ListView.separated(
                      itemCount: _teamMembers.length,
                      separatorBuilder: (c, i) => const Divider(),
                      itemBuilder: (c, index) {
                        final m = _teamMembers[index];
                        final rawId = m['id']?.toString() ?? '${index + 1}';
                        final userFormattedId = "SRM${rawId.padLeft(6, '0')}";
                        final firstName = _getFirstNameMax15(m['fullName'] ?? m['name'] ?? 'Member');
                        final status = (m['status'] ?? 'ACTIVE').toString().toUpperCase();
                        final isActive = status == 'ACTIVE';
                        final incomeVal = double.tryParse((m['main_wallet_balance'] ?? '0.0').toString()) ?? 0.0;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                            child: Icon(Icons.person, color: isActive ? const Color(0xFF16A34A) : const Color(0xFFEF4444)),
                          ),
                          title: Text("$firstName ($userFormattedId)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text("Mobile: ${m['mobileNumber'] ?? m['mobile'] ?? 'N/A'}\nIncome: ₹ ${incomeVal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 11)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(status, style: TextStyle(color: isActive ? const Color(0xFF15803D) : const Color(0xFFB91C1C), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGlobalIncomeModal(BuildContext context, double globalInc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Global Income Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.blueGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Current Global Income", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  Text("₹ ${globalInc.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text("Target: ₹12,600.00 (Current Progress: ${((globalInc / 12600.0) * 100).toStringAsFixed(1)}%)", style: const TextStyle(color: AppTheme.textGray, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
