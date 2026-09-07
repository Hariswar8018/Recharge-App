import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import '../../models/transaction_model.dart';

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
    final bool isIncome = widget.transaction.isIncome;
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RepaintBoundary(
                key: _boundaryKey,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: status.toLowerCase() == "pending"
                            ? const Color(0xFFFFF3E0)
                            : (status.toLowerCase() == "failed"
                                ? const Color(0xFFFFEBEE)
                                : (isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD))),
                        child: Icon(
                          status.toLowerCase() == "pending"
                              ? Icons.access_time_filled
                              : (status.toLowerCase() == "failed"
                                  ? Icons.error_outline
                                  : (isIncome ? Icons.south_rounded : Icons.north_rounded)),
                          color: status.toLowerCase() == "pending"
                              ? const Color(0xFFEF6C00)
                              : (status.toLowerCase() == "failed"
                                  ? const Color(0xFFC62828)
                                  : (isIncome ? const Color(0xFF2E7D32) : const Color(0xFF1565C0))),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.transaction.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${isIncome ? '+' : '-'} ₹$cleanAmount",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: isIncome ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFE2E8F0), height: 1),
                      const SizedBox(height: 16),

                      _buildReceiptRow("Transaction ID", widget.transaction.reference),
                      _buildReceiptRow("Service/Type", widget.transaction.type),
                      _buildReceiptRow("Details", widget.transaction.descLine1),
                      if (widget.transaction.descLine2.isNotEmpty)
                        _buildReceiptRow("Note", widget.transaction.descLine2),
                      _buildReceiptRow("Date & Time", widget.transaction.date),
                      _buildReceiptRow(
                        "Flow Direction",
                        isIncome ? "Credit (Incoming)" : "Debit (Outgoing)",
                      ),
                      _buildReceiptRow("Status", status),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

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
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
