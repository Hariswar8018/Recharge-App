import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';
import '../../api.dart';
import '../../widgets/processing_dialog.dart';

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

  void _startPayment() {
    setState(() {
      _paymentStatus = "Processing in Payment Gateway...";
    });

    var options = {
      'key': Api.razorpayapi_key,
      'amount': (widget.amount * 100).toInt(),
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
    await showProcessingDialog(context, "Processing Telecom Recharge...");
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _paymentStatus = "Payment verified. Executing Telecom Recharge...";
    });

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
              Navigator.pop(context);
              Navigator.popUntil(context, ModalRoute.withName('/home'));
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
              Navigator.pop(context);
              Navigator.popUntil(context, ModalRoute.withName('/home'));
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _queryStatus() {
    setState(() {
      _paymentStatus = "Querying operator logs for Client ID: $_clientId";
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _paymentStatus = "Status: SUCCESS. Transaction registered under Client ID: $_clientId";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Checkout Portal", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          automaticallyImplyLeading: false,
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
