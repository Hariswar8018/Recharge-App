import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';

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
