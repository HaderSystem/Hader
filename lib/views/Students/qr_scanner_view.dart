import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  final _supabase = Supabase.instance.client;
  bool _scanned = false;
  bool _isLoading = false;
  Timer? _scannerTimeoutTimer;

  @override
  void initState() {
    super.initState();

    // ⏲️ مؤقت إغلاق تلقائي بعد 20 ثانية
    _scannerTimeoutTimer = Timer(Duration(seconds: 20), () {
      if (!_scanned) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⏱️ انتهى الوقت المسموح للمسح')),
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _scannerTimeoutTimer?.cancel();
    super.dispose();
  }

  void _handleScan(String code) async {
    if (_scanned) return;
    _scanned = true;
    _scannerTimeoutTimer?.cancel(); // أوقف المؤقت لو تم المسح

    final lectureId = code.trim();
    final studentId = _supabase.auth.currentUser?.id;

    if (lectureId.isNotEmpty && studentId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final existing = await _supabase
            .from('attendance')
            .select()
            .eq('lecture_id', lectureId)
            .eq('student_id', studentId);

        if (existing.isNotEmpty) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم تسجيل حضورك مسبقًا")),
          );
          Navigator.pop(context);
          return;
        }

        await _supabase.from('attendance').insert({
          'lecture_id': lectureId,
          'student_id': studentId,
          'status': 'present',
        });

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تسجيل الحضور بنجاح ✅")),
        );
        Navigator.pop(context);
      } catch (e) {
        setState(() => _isLoading = false);
        print('خطأ أثناء التسجيل: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("حدث خطأ أثناء تسجيل الحضور ❌")),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: Stack(
        children: [
          MobileScanner(
            key: UniqueKey(),
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              final code = barcode.rawValue;
              if (code != null) {
                _handleScan(code);
              }
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
