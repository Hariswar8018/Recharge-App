import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../widgets/background_container.dart';
import 'payment_checkout_screen.dart';

class ProviderSelectionScreen extends StatefulWidget {
  final String serviceType; // e.g. "Prepaid", "Electricity", "DTH", etc.
  const ProviderSelectionScreen({super.key, required this.serviceType});

  @override
  State<ProviderSelectionScreen> createState() => _ProviderSelectionScreenState();
}

class _ProviderSelectionScreenState extends State<ProviderSelectionScreen> {
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedProvider;
  int _selectedProviderId = 1;

  final Map<String, List<Map<String, dynamic>>> _providersMap = {
    "Prepaid": [
      {"name": "Airtel Prepaid", "id": 1, "logo": "A", "color": Colors.red},
      {"name": "Jio Prepaid", "id": 2, "logo": "J", "color": Colors.blue},
      {"name": "Vi Prepaid", "id": 3, "logo": "V", "color": Colors.purple},
      {"name": "BSNL Prepaid", "id": 4, "logo": "B", "color": Colors.orange},
    ],
    "Electricity": [
      {"name": "State Electricity", "id": 10, "logo": "SE", "color": Colors.amber},
      {"name": "Adani Power", "id": 11, "logo": "AP", "color": Colors.yellow.shade800},
      {"name": "Tata Power", "id": 12, "logo": "TP", "color": Colors.teal},
    ],
    "DTH": [
      {"name": "Tata Play", "id": 20, "logo": "TP", "color": Colors.pink},
      {"name": "Dish TV", "id": 21, "logo": "DT", "color": Colors.redAccent},
      {"name": "Airtel Digital TV", "id": 22, "logo": "AD", "color": Colors.red},
    ],
    "FastTag": [
      {"name": "NHAI FastTag", "id": 30, "logo": "NH", "color": Colors.blueAccent},
      {"name": "SBI FastTag", "id": 31, "logo": "SB", "color": Colors.indigo},
      {"name": "ICICI FastTag", "id": 32, "logo": "IC", "color": Colors.orangeAccent},
    ]
  };

  @override
  void dispose() {
    _numberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showReceiptBottomSheet() {
    if (!_formKey.currentState!.validate() || _selectedProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select provider and fill all fields")),
      );
      return;
    }

    final number = _numberController.text.trim();
    final amount = _amountController.text.trim();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recharge Confirmation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue),
            ),
            const SizedBox(height: 4),
            const Text("Please review transaction details before proceeding to payment."),
            const Divider(height: 30, color: AppTheme.cardLightBlue),
            _buildReceiptRow("Service", widget.serviceType),
            _buildReceiptRow("Operator", _selectedProvider!),
            _buildReceiptRow("Customer Number/ID", number),
            _buildReceiptRow("Amount", "₹ $amount"),
            const Divider(height: 30, color: AppTheme.cardLightBlue),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentCheckoutScreen(
                        serviceType: widget.serviceType,
                        providerName: _selectedProvider!,
                        providerId: _selectedProviderId,
                        number: number,
                        amount: double.parse(amount),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Confirm & Proceed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textGray, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(val, style: const TextStyle(color: AppTheme.textDarkBlue, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _providersMap[widget.serviceType] ?? [
      {"name": "Other Provider 1", "id": 90},
      {"name": "Other Provider 2", "id": 91},
    ];

    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("${widget.serviceType} Recharge", style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Operator / Provider", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue)),
              const SizedBox(height: 12),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemBuilder: (context, index) {
                  final providerName = list[index]["name"] as String;
                  final providerId = list[index]["id"] as int;
                  final isSelected = _selectedProvider == providerName;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedProvider = providerName;
                        _selectedProviderId = providerId;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryBlue.withOpacity(0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.cardLightBlue,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: list[index]["color"] as Color? ?? Colors.grey,
                            child: Text(
                              list[index]["logo"] as String? ?? providerName.substring(0, 1),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              providerName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: isSelected ? AppTheme.primaryBlue : AppTheme.textDarkBlue,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Customer Details", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue)),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _numberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: widget.serviceType == "Electricity" ? "CA Number" : "Mobile / Customer Number",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.person_pin),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? "Please fill this field" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Recharge Amount (₹)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.currency_rupee),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? "Please enter amount" : null,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _showReceiptBottomSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Proceed to Recharge", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
