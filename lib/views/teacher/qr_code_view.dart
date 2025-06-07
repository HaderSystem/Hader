import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/views/teacher/attendance_list_view.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeView extends StatefulWidget {
  final String lectureId;
  const QRCodeView({super.key, required this.lectureId});

  @override
  State<QRCodeView> createState() => _QRCodeViewState();
}

class _QRCodeViewState extends State<QRCodeView> {
  late String qrData;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateQR();
    _timer = Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      _updateQR();
    });
  }

  void _updateQR() {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 5000;
    setState(() {
      qrData = "${widget.lectureId}-$timestamp";
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecture QR Code"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Scan this QR code to record attendance",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 250.0,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AttendanceListView(lectureId: widget.lectureId),
                    ),
                  );
                },
                child: const Text("View Attendance List"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
