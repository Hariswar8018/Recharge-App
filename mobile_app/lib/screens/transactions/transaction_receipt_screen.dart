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
    final String status = widget.transaction.status;
    final String cleanAmount = widget.transaction.amount.replaceAll(RegExp(r'[+\-₹\s]'), '');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Transaction Receipt", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                key: _boundaryKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0052CC), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row with Brand & Contact
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/sr_logo.png', height: 42, fit: BoxFit.contain),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("📞 9988494936", style: TextStyle(fontSize: 10, color: Color(0xFF334155))),
                              Text("✉️ info@srdigitalseva.com", style: TextStyle(fontSize: 9, color: Color(0xFF334155))),
                              Text("📍 Warangal, TS - 506005", style: TextStyle(fontSize: 9, color: Color(0xFF334155))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Service Invoice Title Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052CC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "SERVICE INVOICE",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.5),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Details Cards Grid
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("INVOICE & TRANSACTION DETAILS", style: TextStyle(color: Color(0xFF0052CC), fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 6),
                            _buildReceiptRow("Invoice No.", "SR/2026-27/${widget.transaction.reference}"),
                            _buildReceiptRow("Service/Type", widget.transaction.type),
                            _buildReceiptRow("Payment Mode", widget.transaction.descLine1.isNotEmpty ? widget.transaction.descLine1 : "UPI"),
                            _buildReceiptRow("UTR / Ref No.", widget.transaction.reference),
                            _buildReceiptRow("Payment Date", DateFormatter.formatToIST(widget.transaction.date)),
                            _buildReceiptRow("Status", status.toUpperCase()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Items Table Container
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF0052CC)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              color: const Color(0xFF0052CC),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: const Row(
                                children: [
                                  Text("S.No.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                  SizedBox(width: 12),
                                  Expanded(child: Text("DESCRIPTION OF SERVICE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                                  Text("AMOUNT (₹)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.transaction.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                                        const SizedBox(height: 2),
                                        const Text("(Application form filling, document verification, online submission)", style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                  Text("₹$cleanAmount", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Subtotal & Grand Total Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052CC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Grand Total", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text("₹$cleanAmount", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Footer Terms & Seal Signature
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Terms & Conditions :", style: TextStyle(color: Color(0xFF0052CC), fontWeight: FontWeight.bold, fontSize: 10)),
                                SizedBox(height: 2),
                                Text("1. Computer generated invoice.", style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                Text("2. Services non-refundable once processed.", style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                Text("3. All disputes subject to Warangal Jurisdiction.", style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                SizedBox(height: 8),
                                Text("Thank You! For Your Business", style: TextStyle(fontSize: 14, color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 24.0),
                            child: Text("Authorised Signatory", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0052CC))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _captureAndSave,
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  label: const Text("Download Receipt", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
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

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
