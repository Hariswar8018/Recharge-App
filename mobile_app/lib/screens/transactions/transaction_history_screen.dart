import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../services/api_service.dart';
import 'transaction_receipt_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = true;

  String _searchQuery = "";
  String _selectedFilter = "All";
  DateTimeRange? _selectedDateRange;

  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = [
    "All",
    "Credit",
    "Debit",
    "Pending",
    "Success",
    "Failed",
    "Refunded"
  ];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final list = await ApiService.getTransactions();
    if (list.isNotEmpty) {
      setState(() {
        _allTransactions = list.map((item) {
          final type = item['type'] as String? ?? 'Transaction';
          final amount = item['amount'] as String? ?? '0.00';
          final date = item['date'] as String? ?? '';
          final status = item['status'] as String? ?? 'Success';
          final id = item['id']?.toString() ?? '';

          final typeLower = type.toLowerCase();
          final bool isIncome = !typeLower.contains('debit') &&
              !typeLower.contains('cashout') &&
              !typeLower.contains('withdrawal') &&
              !typeLower.contains('recharge') &&
              !typeLower.contains('bill') &&
              !typeLower.contains('activation') &&
              !typeLower.contains('top-up');

          String cleanAmt = amount.replaceAll(RegExp(r'[+\-₹\s]'), '');
          String refStr = id.startsWith('SR92728') ? id : "SR92728$id";

          return TransactionModel(
            id: id,
            title: type,
            type: type,
            descLine1: item['wallet_type'] != null ? "Wallet: ${item['wallet_type']}" : "Processed via Wallet",
            descLine2: item['description']?.toString() ?? "Transaction processed successfully",
            amount: cleanAmt,
            date: date.isNotEmpty ? date : "28 Aug 2026, 12:15 AM",
            isIncome: isIncome,
            status: status,
            reference: refStr,
          );
        }).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _allTransactions = List.from(sampleTransactionsList);
        _isLoading = false;
      });
    }
  }

  List<TransactionModel> get _filteredTransactions {
    return _allTransactions.where((tx) {
      if (_selectedFilter == "Credit" && !tx.isIncome) return false;
      if (_selectedFilter == "Debit" && tx.isIncome) return false;
      if (_selectedFilter == "Pending" && tx.status.toLowerCase() != "pending") return false;
      if (_selectedFilter == "Success" && tx.status.toLowerCase() != "success") return false;
      if (_selectedFilter == "Failed" && tx.status.toLowerCase() != "failed") return false;
      if (_selectedFilter == "Refunded" && tx.status.toLowerCase() != "refunded") return false;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = tx.title.toLowerCase().contains(query);
        final matchDesc1 = tx.descLine1.toLowerCase().contains(query);
        final matchDesc2 = tx.descLine2.toLowerCase().contains(query);
        final matchRef = tx.reference.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc1 && !matchDesc2 && !matchRef) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTransactions;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A369D), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Transaction History",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "All your transactions in one place",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                        ),
                        onPressed: _pickDateRange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search by Transaction ID, Mobile, UTR...",
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1565C0)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.tune_rounded, color: Color(0xFF1565C0)),
                          onPressed: () {},
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 50,
              color: Colors.white,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filterOptions[index];
                  final isSelected = _selectedFilter == filter;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)))
                  : filtered.isEmpty
                      ? const Center(
                          child: Text("No transactions match your search criteria", style: TextStyle(color: Color(0xFF64748B))),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final tx = filtered[index];
                            return _buildTransactionCard(context, tx);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionModel tx) {
    IconData icon;
    Color avatarBg;
    Color iconColor;

    final typeLower = tx.title.toLowerCase();

    if (typeLower.contains('direct income')) {
      icon = Icons.person_add_rounded;
      avatarBg = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF2E7D32);
    } else if (typeLower.contains('single-leg')) {
      icon = Icons.hub_rounded;
      avatarBg = const Color(0xFFF3E8FF);
      iconColor = const Color(0xFF7E22CE);
    } else if (typeLower.contains('deposit')) {
      icon = Icons.account_balance_wallet_rounded;
      avatarBg = const Color(0xFFE3F2FD);
      iconColor = const Color(0xFF1565C0);
    } else if (typeLower.contains('activation')) {
      icon = Icons.badge_rounded;
      avatarBg = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFEF6C00);
    } else if (typeLower.contains('transfer')) {
      icon = Icons.send_rounded;
      avatarBg = const Color(0xFFE0F2FE);
      iconColor = const Color(0xFF0284C7);
    } else if (typeLower.contains('received')) {
      icon = Icons.south_west_rounded;
      avatarBg = const Color(0xFFDCFCE7);
      iconColor = const Color(0xFF16A34A);
    } else if (typeLower.contains('recharge')) {
      icon = Icons.smartphone_rounded;
      avatarBg = const Color(0xFFFFE4E6);
      iconColor = const Color(0xFFE11D48);
    } else if (typeLower.contains('bill')) {
      icon = Icons.flash_on_rounded;
      avatarBg = const Color(0xFFFEF9C3);
      iconColor = const Color(0xFFCA8A04);
    } else if (typeLower.contains('top-up')) {
      icon = Icons.sync_rounded;
      avatarBg = const Color(0xFFE0E7FF);
      iconColor = const Color(0xFF4F46E5);
    } else {
      icon = tx.isIncome ? Icons.south_rounded : Icons.north_rounded;
      avatarBg = tx.isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
      iconColor = tx.isIncome ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    }

    Color statusBg = const Color(0xFFE8F5E9);
    Color statusText = const Color(0xFF2E7D32);

    if (tx.status.toLowerCase() == 'pending') {
      statusBg = const Color(0xFFFFF3E0);
      statusText = const Color(0xFFEF6C00);
    } else if (tx.status.toLowerCase() == 'refunded') {
      statusBg = const Color(0xFFE3F2FD);
      statusText = const Color(0xFF1565C0);
    } else if (tx.status.toLowerCase() == 'failed') {
      statusBg = const Color(0xFFFFEBEE);
      statusText = const Color(0xFFC62828);
    }

    final String cleanAmount = tx.amount.replaceAll(RegExp(r'[+\-₹\s]'), '');
    String formattedRef = tx.reference;
    if (formattedRef.isEmpty) {
      formattedRef = tx.id;
    }
    if (!formattedRef.startsWith("SR92728")) {
      formattedRef = "SR92728$formattedRef";
    }

    final String dateStr = tx.date.isNotEmpty ? tx.date : "28 Aug 2026, 12:15 AM";
    final String dateAndTxnId = "$dateStr • TXN ID: $formattedRef";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionReceiptScreen(transaction: tx),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: avatarBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tx.descLine1,
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                     
                      const SizedBox(height: 3),
                      Text(
                        dateAndTxnId,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${tx.isIncome ? '+' : '-'} ₹$cleanAmount",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: tx.isIncome ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tx.status,
                        style: TextStyle(
                          color: statusText,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
