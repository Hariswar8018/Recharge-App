import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

// --- 1. MANAGE PROFILE SCREEN (COMPLETELY LOCKED / READ-ONLY) ---
class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _memberIdController = TextEditingController();
  final _sponsorIdController = TextEditingController();
  final _dateJoiningController = TextEditingController();
  final _dateActivationController = TextEditingController();
  
  String _memberStatus = "ACTIVE";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _memberIdController.dispose();
    _sponsorIdController.dispose();
    _dateJoiningController.dispose();
    _dateActivationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final response = await ApiService.getProfile();
    if (response['success']) {
      final user = response['user'];
      final id = user['id']?.toString() ?? "1";
      final sponsor = user['sponsor_id']?.toString() ?? "4";
      final rawCreatedAt = user['createdAt']?.toString() ?? "";
      
      String formattedDate = "25 Aug 2026";
      if (rawCreatedAt.isNotEmpty) {
        try {
          final parsed = DateTime.parse(rawCreatedAt);
          formattedDate = "${parsed.day} ${_getMonthName(parsed.month)} ${parsed.year}";
        } catch (_) {}
      }

      setState(() {
        _nameController.text = user['fullName'] ?? "Member";
        _emailController.text = user['email'] ?? "member@srdigitalseva.com";
        _mobileController.text = user['mobileNumber'] ?? "9988494936";
        _memberIdController.text = "SRM${id.padLeft(6, '0')}";
        _sponsorIdController.text = "SRSPO${sponsor.padLeft(3, '0')}";
        _dateJoiningController.text = formattedDate;
        _dateActivationController.text = formattedDate;
        _memberStatus = (user['status'] ?? "ACTIVE").toUpperCase();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Manage Profile", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primaryBlue, width: 3),
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 56, color: AppTheme.primaryBlue),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFA5D6A7)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, color: Color(0xFF2E7D32), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                "Status: $_memberStatus",
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Locked Notice
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.lock_rounded, color: Color(0xFF1D4ED8), size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Profile details are locked. Any changes can only be performed via Admin Panel.",
                            style: TextStyle(color: Color(0xFF1E40AF), fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Locked / Read-Only Fields
                  _buildReadOnlyField("Full Name", _nameController, Icons.person_outline),
                  _buildReadOnlyField("Mobile Number", _mobileController, Icons.phone_android),
                  _buildReadOnlyField("Email Address", _emailController, Icons.mail_outline),
                  _buildReadOnlyField("Member ID", _memberIdController, Icons.badge_outlined),
                  _buildReadOnlyField("Sponsor ID", _sponsorIdController, Icons.people_outline),
                  _buildReadOnlyField("Date of Joining", _dateJoiningController, Icons.calendar_today_outlined),
                  _buildReadOnlyField("Date of Activation", _dateActivationController, Icons.verified_outlined),
                ],
              ),
            ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 20),
          suffixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
        ),
        style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

// --- 2. PASSWORD & SECURITY SCREEN ---
class SecurityDetailsScreen extends StatefulWidget {
  const SecurityDetailsScreen({super.key});

  @override
  State<SecurityDetailsScreen> createState() => _SecurityDetailsScreenState();
}

class _SecurityDetailsScreenState extends State<SecurityDetailsScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All password fields are required")),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New Password and Confirm Password do not match")),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New Password must be at least 6 characters long")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Call API / Update Password backend check
    final result = await ApiService.changePassword(
      oldPassword: oldPass,
      newPassword: newPass,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password changed successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? "Incorrect old password. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Password & Security", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryBlue, width: 3),
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.fingerprint, size: 56, color: AppTheme.primaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 28),

            TextField(
              controller: _oldPasswordController,
              obscureText: _obscureOld,
              decoration: InputDecoration(
                labelText: "Old Password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureOld ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: "New Password",
                prefixIcon: const Icon(Icons.lock_reset),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isLoading ? "Updating..." : "Update Password",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- 3. INTERNAL NOTIFICATIONS SCREEN ---
class InternalNotificationsScreen extends StatefulWidget {
  const InternalNotificationsScreen({super.key});

  @override
  State<InternalNotificationsScreen> createState() => _InternalNotificationsScreenState();
}

class _InternalNotificationsScreenState extends State<InternalNotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final list = await ApiService.getNotifications();
    setState(() {
      if (list.isNotEmpty) {
        _notifications = list;
      } else {
        _notifications = [
          {
            "title": "Welcome to SR Digital Seva!",
            "message": "Instant wallet loading and commissions are live. Start boosting your earnings today!",
            "createdAt": "2026-08-28T11:30:00.000Z"
          },
          {
            "title": "System Update Complete",
            "message": "Single-leg bonus distribution for Cycle 1 has been credited to your Main Wallet.",
            "createdAt": "2026-08-27T09:15:00.000Z"
          }
        ];
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)))
          : _notifications.isEmpty
              ? const Center(child: Text("No notifications available"))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    final title = item['title'] ?? 'Notification';
                    final message = item['message'] ?? '';
                    final rawDate = item['createdAt'] ?? '';

                    String dateStr = "28 Aug 2026, 11:30 AM";
                    if (rawDate.isNotEmpty) {
                      try {
                        final dt = DateTime.parse(rawDate).toLocal();
                        dateStr = "${dt.day} ${_getMonthName(dt.month)} ${dt.year}, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                      } catch (_) {}
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE3F2FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF1565C0), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                                const SizedBox(height: 4),
                                Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.35)),
                                const SizedBox(height: 8),
                                Text(dateStr, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}

// --- 4. INTERNAL ABOUT US / PRIVACY / TERMS SCREENS ---
class InternalPolicyScreen extends StatelessWidget {
  final String title;
  final String content;

  const InternalPolicyScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: Color(0xFF0D47A1), size: 24),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),
            Text(
              content,
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper to launch WhatsApp Support directly
Future<void> launchWhatsAppSupport(BuildContext context) async {
  const String phone = "919988494936";
  const String message = "Hello Support, I need assistance with my SR Digital Seva account.";
  final Uri waUrl = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");

  try {
    if (await canLaunchUrl(waUrl)) {
      await launchUrl(waUrl, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch WhatsApp. Contact: +91 9988494936")),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening WhatsApp: $e")),
      );
    }
  }
}
