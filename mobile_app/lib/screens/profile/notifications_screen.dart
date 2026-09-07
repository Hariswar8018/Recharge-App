import 'package:flutter/material.dart';
import '../../services/api_service.dart';

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
