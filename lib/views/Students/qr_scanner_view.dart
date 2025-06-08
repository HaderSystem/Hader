import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

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

    _scannerTimeoutTimer = Timer(const Duration(seconds: 20), () {
      if (!_scanned && mounted) {
        _showError("scan_timeout_msg".tr());
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
    _scannerTimeoutTimer?.cancel();

    print("📦 Scanned QR Code Raw Value: $code");

    final parts = code.split('-');
    if (parts.length < 2) {
      _showError("رمز غير صالح");
      return;
    }

    final lectureId = parts.sublist(0, parts.length - 1).join('-');
    final studentId = _supabase.auth.currentUser?.id;

    print("🧠 Parsed lectureId: $lectureId");
    print("👤 Current studentId: $studentId");

    if (lectureId.isNotEmpty && studentId != null) {
      setState(() => _isLoading = true);

      try {
        final existing = await _supabase
            .from('attendance')
            .select()
            .eq('lecture_id', lectureId)
            .eq('student_id', studentId);

        if (existing.isNotEmpty) {
          _showError("already_marked".tr());
          return;
        }

        final lecture = await _supabase
            .from('lectures')
            .select('course_id')
            .eq('id', lectureId)
            .maybeSingle();

        if (lecture == null) {
          _showError("المحاضرة غير موجودة");
          return;
        }

        final courseId = lecture['course_id'];

        final enrolled = await _supabase
            .from('student_courses')
            .select()
            .eq('student_id', studentId)
            .eq('course_id', courseId);

        if (enrolled.isEmpty) {
          _showError("أنت غير مسجل في هذا الكورس");
          return;
        }

        await _supabase.from('attendance').insert({
          'lecture_id': lectureId,
          'student_id': studentId,
          'status': 'present',
        });

        _showSuccess("attendance_success".tr());
      } catch (e, stack) {
        print('❌ Error during attendance insert: $e');
        print('🧱 StackTrace: $stack');
        _showError("attendance_error".tr());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(message)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(message)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("scan_title".tr()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            key: UniqueKey(),
            fit: BoxFit.cover,
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
              color: Colors.black.withOpacity(0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
