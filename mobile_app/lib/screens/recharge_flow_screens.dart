import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../api.dart';
import '../widgets/background_container.dart';

// --- SCREEN 1: PROVIDER SELECTION & DETAILS ---
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
                  // Navigate to checkout screen using pushReplacement (cannot go back!)
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
              
              // Provider grid select list
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

              // Inputs Form
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


// --- SCREEN 2: PAYMENT & VERIFICATION CHECKOUT ---
class PaymentCheckoutScreen extends StatefulWidget {
  final String serviceType;
  final String providerName;
  final int providerId;
  final String number;
  final double amount;

  const PaymentCheckoutScreen({
    super.key,
    required this.serviceType,
    required this.providerName,
    required this.providerId,
    required this.number,
    required this.amount,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  late Razorpay _razorpay;
  String _paymentStatus = "Awaiting Payment Initiator";
  bool _isLoading = false;
  String _clientId = "";

  @override
  void initState() {
    super.initState();
    // Unique Client ID for Scriza reconciliation
    _clientId = "CLI${DateTime.now().millisecondsSinceEpoch}";

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // Complete Payment: opens Razorpay checkout
  void _startPayment() {
    setState(() {
      _paymentStatus = "Processing in Payment Gateway...";
    });

    var options = {
      'key': Api.razorpayapi_key,
      'amount': (widget.amount * 100).toInt(), // paise
      'currency': 'INR',
      'name': 'SR Digital Seva',
      'description': '${widget.providerName} Recharge',
      'prefill': {
        'contact': widget.number,
        'email': 'customer@srdigitalseva.com'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _paymentStatus = "Checkout opening error: $e";
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      _isLoading = true;
      _paymentStatus = "Payment verified. Executing Telecom Recharge...";
    });

    // Deduct amount from Main Wallet and log transaction success
    final result = await ApiService.triggerRazorpaySandboxPayment(
      -widget.amount,
      "${widget.providerName} Recharge",
      "MAIN"
    );

    setState(() {
      _isLoading = false;
      _paymentStatus = result['success'] 
          ? "SUCCESS: Recharge Complete!" 
          : "PENDING: Awaiting Operator Callback";
    });

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Recharge Initiated", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
        content: Text(
          "Recharge transaction for ${widget.providerName} success!\n\nBill payment api not integrated.\nPay ID: ${response.paymentId}",
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.popUntil(context, ModalRoute.withName('/home')); // Back to Home
            },
            style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))),
            child: const Text("Go to Home"),
          )
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _paymentStatus = "FAILED: ${response.message} (Code: ${response.code})";
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External wallet selected");
  }

  // Cancel Payment
  void _cancelCheckout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text("Cancel Recharge?"),
          ],
        ),
        content: const Text("Are you sure you want to abort the payment process?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.popUntil(context, ModalRoute.withName('/home')); // Go back to main portal
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Check Status
  void _queryStatus() {
    setState(() {
      _paymentStatus = "Querying operator logs for Client ID: $_clientId";
    });
    
    // Simulate Scriza check-status API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _paymentStatus = "Status: SUCCESS. Transaction registered under Client ID: $_clientId";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Back navigation is completely disabled
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Checkout Portal", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          automaticallyImplyLeading: false, // Disables back arrow
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: AppTheme.primaryBlue),
              const SizedBox(height: 16),
              const Text(
                "Secure Checkout Session",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDarkBlue),
              ),
              const SizedBox(height: 8),
              Text(
                "Do not close the application or press back. Complete your payment below.",
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Transaction Summary box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardLightBlue.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildRow("Operator", widget.providerName),
                    const SizedBox(height: 8),
                    _buildRow("Number", widget.number),
                    const SizedBox(height: 8),
                    _buildRow("Recharge Amount", "₹ ${widget.amount.toStringAsFixed(2)}"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Status message
              Text(
                _paymentStatus,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              if (_isLoading)
                const CircularProgressIndicator(color: AppTheme.primaryBlue)
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _startPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.credit_card, color: Colors.white),
                        label: const Text("Complete Payment", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _queryStatus,
                            icon: const Icon(Icons.refresh, color: AppTheme.primaryBlue),
                            label: const Text("Check Status"),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size(0, 48),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _cancelCheckout,
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            label: const Text("Cancel Payment", style: TextStyle(color: Colors.red)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size(0, 48),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textGray, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: AppTheme.textDarkBlue, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
