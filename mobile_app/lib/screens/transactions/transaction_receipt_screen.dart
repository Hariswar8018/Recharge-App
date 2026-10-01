import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import '../../models/transaction_model.dart';
import '../../utils/date_formatter.dart';

class TransactionReceiptScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionReceiptScreen({super.key, required this.transaction});

  @override
  State<TransactionReceiptScreen> createState() => _TransactionReceiptScreenState();
}

class _TransactionReceiptScreenState extends State<TransactionReceiptScreen> {
  final GlobalKey _boundaryKey = GlobalKey();

  Future<void> _captureAndSave() async {
    try {
      final boundary = _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        await ImageGallerySaver().saveImage(pngBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Receipt saved to gallery successfully!")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving receipt: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String rawStatus = widget.transaction.status.toUpperCase();
    final bool isSuccess = rawStatus == 'SUCCESS' || rawStatus == 'APPROVED';
    final bool isPending = rawStatus == 'PENDING';
    final String cleanAmount = widget.transaction.amount.replaceAll(RegExp(r'[+\-₹?\s]|Rs\.?|INR', caseSensitive: false), '').trim();
    final bool isDebit = widget.transaction.isDebit || widget.transaction.amount.contains('-') || widget.transaction.type.toLowerCase().contains('debit') || widget.transaction.type.toLowerCase().contains('withdrawal') || widget.transaction.type.toLowerCase().contains('cashout');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          "Transaction Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0052CC),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            tooltip: "Save Receipt",
            onPressed: _captureAndSave,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                key: _boundaryKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LOGO BRAND HEADER
                      Center(
                        child: Image.asset(
                          'assets/sr_logo.png',
                          height: 52,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // STATUS BANNER (GREEN / AMBER / RED)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSuccess
                              ? const Color(0xFFE6F4EA)
                              : (isPending ? const Color(0xFFFEF3C7) : const Color(0xFFFFEBEE)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSuccess
                                ? const Color(0xFFA7F3D0)
                                : (isPending ? const Color(0xFFFDE68A) : const Color(0xFFFECDD3)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isSuccess
                                    ? const Color(0xFF16A34A)
                                    : (isPending ? const Color(0xFFD97706) : const Color(0xFFDC2626)),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSuccess
                                    ? Icons.check
                                    : (isPending ? Icons.access_time_rounded : Icons.close),
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSuccess ? "Success" : (isPending ? "Pending" : "Failed"),
                                    style: TextStyle(
                                      color: isSuccess
                                          ? const Color(0xFF15803D)
                                          : (isPending ? const Color(0xFFB45309) : const Color(0xFFB91C1C)),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isSuccess
                                        ? "Transaction completed successfully"
                                        : (isPending ? "Transaction is under verification" : "Transaction rejected / failed"),
                                    style: TextStyle(
                                      color: isSuccess
                                          ? const Color(0xFF166534)
                                          : (isPending ? const Color(0xFF92400E) : const Color(0xFF991B1B)),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ITEM 1: TRANSACTION TYPE
                      _buildDetailRow(
                        icon: Icons.article_outlined,
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: const Color(0xFF2563EB),
                        label: "Transaction Type",
                        value: widget.transaction.type.isNotEmpty
                            ? widget.transaction.type
                            : "General Transaction",
                      ),
                      _buildDivider(),

                      // ITEM 2: AMOUNT
                      _buildDetailRow(
                        icon: Icons.currency_rupee,
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: const Color(0xFF2563EB),
                        label: "Amount",
                        valueWidget: Text(
                          "₹$cleanAmount",
                          style: TextStyle(
                            color: isDebit ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _buildDivider(),

                      // ITEM 3: DATE & TIME
                      _buildDetailRow(
                        icon: Icons.calendar_month_outlined,
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: const Color(0xFF2563EB),
                        label: "Date & Time",
                        value: DateFormatter.formatToIST(widget.transaction.date),
                      ),
                      _buildDivider(),

                      // ITEM 4: TRANSACTION ID
                      _buildDetailRow(
                        icon: Icons.badge_outlined,
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: const Color(0xFF2563EB),
                        label: "Transaction ID",
                        value: widget.transaction.reference.isNotEmpty
                            ? widget.transaction.reference
                            : "SR${widget.transaction.id}",
                      ),
                      _buildDivider(),

                      // ITEM 5: WALLET
                      _buildDetailRow(
                        icon: Icons.account_balance_wallet_outlined,
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: const Color(0xFF2563EB),
                        label: "Wallet",
                        value: "${(widget.transaction.walletType.isNotEmpty ? widget.transaction.walletType : 'Main').toLowerCase() == 'fund' ? 'Fund' : 'Main'} Wallet",
                      ),
                      _buildDivider(),

                      // ITEM 6: CREDIT / DEBIT
                      _buildDetailRow(
                        icon: isDebit ? Icons.arrow_downward : Icons.arrow_upward,
                        iconBg: isDebit ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                        iconColor: isDebit ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                        label: "Credit / Debit",
                        valueWidget: Text(
                          isDebit ? "Debit (Deducted)" : "Credit (Received)",
                          style: TextStyle(
                            color: isDebit ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      _buildDivider(),

                      // ITEM 7: STATUS
                      _buildDetailRow(
                        icon: isSuccess
                            ? Icons.check_circle
                            : (isPending ? Icons.access_time_filled : Icons.cancel),
                        iconBg: isSuccess
                            ? const Color(0xFFDCFCE7)
                            : (isPending ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2)),
                        iconColor: isSuccess
                            ? const Color(0xFF16A34A)
                            : (isPending ? const Color(0xFFD97706) : const Color(0xFFDC2626)),
                        label: "Status",
                        valueWidget: Text(
                          isSuccess ? "Success" : (isPending ? "Pending" : "Failed"),
                          style: TextStyle(
                            color: isSuccess
                                ? const Color(0xFF16A34A)
                                : (isPending ? const Color(0xFFD97706) : const Color(0xFFDC2626)),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // BACK BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  label: const Text(
                    "Back",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Spacer(),
          if (valueWidget != null)
            valueWidget
          else
            Flexible(
              child: Text(
                value ?? "",
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 16, color: Color(0xFFE2E8F0), thickness: 1);
  }
}
