import 'package:flutter/material.dart';
import 'package:flutter_application_2/views/Students/face_recognition_view.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_application_2/views/students/qr_scanner_view.dart';

class ChooseVerificationMethodView extends StatefulWidget {
  final String userId;
  const ChooseVerificationMethodView({super.key, required this.userId});

  @override
  State<ChooseVerificationMethodView> createState() => _ChooseVerificationMethodViewState();
}

class _ChooseVerificationMethodViewState extends State<ChooseVerificationMethodView> {
  final LocalAuthentication auth = LocalAuthentication();

  // ✅ التحقق بالبصمة فقط
  Future<void> _verifyWithFingerprint() async {
    final canCheck = await auth.canCheckBiometrics;
    final available = await auth.getAvailableBiometrics();

    if (!canCheck || !available.contains(BiometricType.fingerprint)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("جهازك لا يدعم بصمة الإصبع")),
      );
      return;
    }

    final success = await auth.authenticate(
      localizedReason: 'يرجى التحقق ببصمة الإصبع',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const QRScannerView()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل التحقق ببصمة الإصبع")),
      );
    }
  }

  // ✅ التحقق بالوجه مباشرة (نروح على صفحة مخصصة)
  void _verifyWithFace() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FaceRecognitionView(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("اختر وسيلة التحقق")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "يرجى اختيار طريقة التحقق",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _verifyWithFace,
              icon: const Icon(Icons.face),
              label: const Text("التحقق ببصمة الوجه"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _verifyWithFingerprint,
              icon: const Icon(Icons.fingerprint),
              label: const Text("التحقق ببصمة الإصبع"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
