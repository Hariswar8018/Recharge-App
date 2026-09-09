import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';

class DirectTeamScreen extends StatefulWidget {
  const DirectTeamScreen({super.key});

  @override
  State<DirectTeamScreen> createState() => _DirectTeamScreenState();
}

class _DirectTeamScreenState extends State<DirectTeamScreen> {
  bool _isLoading = true;
  List<dynamic> _directMembers = [];

  @override
  void initState() {
    super.initState();
    _loadDirectTeam();
  }

  Future<void> _loadDirectTeam() async {
    final teamList = await ApiService.getTeam();
    setState(() {
      _directMembers = teamList;
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Direct Team Members",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0A369D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0A369D)))
          : Column(
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A369D),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Direct Members: ${_directMembers.length}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Level-1 Direct Referrals Only",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Members List
                Expanded(
                  child: _directMembers.isEmpty
                      ? const Center(
                          child: Text(
                            "No direct members found in your team.",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _directMembers.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final member = _directMembers[index];
                            final rawId = member['id']?.toString() ?? '${index + 1}';
                            final userFormattedId = "SRM${rawId.padLeft(6, '0')}";
                            final rawName = member['fullName'] ?? member['name'] ?? 'Member';
                            final firstName = _getFirstNameMax15(rawName);
                            final mobile = member['mobileNumber'] ?? member['mobile'] ?? 'N/A';
                            final status = (member['status'] ?? 'ACTIVE').toString().toUpperCase();
                            final isActive = status == 'ACTIVE';
                            final rawIncome = member['main_wallet_balance'] ?? member['income'] ?? '0.00';
                            final incomeVal = double.tryParse(rawIncome.toString()) ?? 0.0;
                            final createdAt = member['createdAt']?.toString().substring(0, 10) ?? member['created_at']?.toString() ?? 'N/A';

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                    child: Icon(
                                      Icons.person,
                                      color: isActive ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              firstName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "($userFormattedId)",
                                              style: const TextStyle(
                                                color: Color(0xFF0052CC),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone_android, size: 13, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              mobile,
                                              style: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(Icons.account_balance_wallet, size: 13, color: Color(0xFF16A34A)),
                                            const SizedBox(width: 4),
                                            Text(
                                              "₹ ${incomeVal.toStringAsFixed(2)}",
                                              style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Joined: $createdAt",
                                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isActive ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                                      ),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: isActive ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
