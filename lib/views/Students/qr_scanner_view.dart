import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_auth/local_auth.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  final _supabase = Supabase.instance.client;
  final LocalAuthentication auth = LocalAuthentication();
  bool _scanned = false;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _chooseBiometricMethod();
  }

  Future<void> _chooseBiometricMethod() async {
    final canCheck = await auth.canCheckBiometrics;
    final available = await auth.getAvailableBiometrics();

    if (!canCheck || available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("جهازك لا يدعم التحقق البيومتري")),
      );
      Navigator.pop(context);
      return;
    }

    if (available.length == 1) {
      _authenticate("الرجاء التحقق عبر ${_getLabel(available.first)}");
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: available.map((type) {
                return ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: Text("التحقق عبر ${_getLabel(type)}"),
                  onTap: () {
                    Navigator.pop(context);
                    _authenticate("الرجاء التحقق عبر ${_getLabel(type)}");
                  },
                );
              }).toList(),
            ),
          );
        },
      );
    }
  }

  String _getLabel(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return "بصمة الإصبع";
      case BiometricType.face:
        return "الوجه";
      case BiometricType.iris:
        return "العين";
      default:
        return "التحقق";
    }
  }

  Future<void> _authenticate(String message) async {
    final success = await auth.authenticate(
      localizedReason: message,
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (success) {
      setState(() {
        _authenticated = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل التحقق البيومتري")),
      );
      Navigator.pop(context);
    }
  }

  void _handleScan(String code) async {
    if (_scanned) return;
    _scanned = true;

    final lectureId = code;
    final studentId = _supabase.auth.currentUser?.id;

    if (lectureId.isNotEmpty && studentId != null) {
      final existing = await _supabase
          .from('attendance')
          .select()
          .eq('lecture_id', lectureId)
          .eq('student_id', studentId);

      if (existing.isNotEmpty) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تسجيل الحضور بنجاح")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: MobileScanner(
        key: UniqueKey(),
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          final code = barcode.rawValue;
          if (code != null) {
            _handleScan(code);
          }
        },
      ),
    );
  }
}
