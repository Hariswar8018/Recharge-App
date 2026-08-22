import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class FundRequestScreen extends StatefulWidget {
  const FundRequestScreen({super.key});

  @override
  State<FundRequestScreen> createState() => _FundRequestScreenState();
}

class _FundRequestScreenState extends State<FundRequestScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _message = "";
  String _error = "";
  List<dynamic> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequestHistory();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadRequestHistory() async {
    final list = await ApiService.getFundRequests();
    setState(() {
      _requests = list;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _message = "";
      _error = "";
    });

    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      setState(() {
        _isLoading = false;
        _error = "Invalid amount entered";
      });
      return;
    }

    final result = await ApiService.submitFundRequest(amount);
    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      setState(() {
        _message = "Your deposit request has been submitted for approval!";
        _amountController.clear();
      });
      _loadRequestHistory();
    } else {
      setState(() {
        _error = result['error'] ?? "Failed to submit request";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Fund Request", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Request Wallet Funding",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue),
            ),
            const SizedBox(height: 6),
            const Text(
              "Submit a request to deposit funds. Once the administrator approves the request, the amount will be credited to your Fund Wallet.",
              style: TextStyle(color: AppTheme.textGray, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Form Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardLightBlue),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter Deposit Amount (₹)",
                      style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "e.g. 5000",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardLightBlue)),
                        prefixIcon: const Icon(Icons.currency_rupee, color: AppTheme.primaryBlue),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? "Please enter amount" : null,
                    ),
                    const SizedBox(height: 16),

                    if (_message.isNotEmpty) ...[
                      Text(_message, style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                    ],
                    if (_error.isNotEmpty) ...[
                      Text(_error, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _isLoading ? "Submitting..." : "Submit Deposit Request",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // History Header
            const Text(
              "Your Request History",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue),
            ),
            const SizedBox(height: 12),

            // History List
            _requests.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No request history found", style: TextStyle(color: AppTheme.textGray))))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final item = _requests[index];
                      final status = item['status'] as String;
                      Color statusColor = Colors.orange;
                      if (status == 'APPROVED') statusColor = Colors.green;
                      if (status == 'REJECTED') statusColor = Colors.red;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppTheme.cardLightBlue),
                        ),
                        child: ListTile(
                          title: Text(
                            "₹ ${parseFloat(item['amount']).toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue),
                          ),
                          subtitle: Text(
                            item['createdAt'] != null 
                                ? DateTime.parse(item['createdAt']).toLocal().toString().substring(0, 16) 
                                : "",
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ),
                      );
                    },
                  )
          ],
        ),
      ),
    );
  }

  double parseFloat(dynamic amount) {
    if (amount == null) return 0.0;
    if (amount is num) return amount.toDouble();
    if (amount is String) return double.tryParse(amount) ?? 0.0;
    return 0.0;
  }
}
