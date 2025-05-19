import 'package:flutter/material.dart';
import 'package:flutter_application_2/controllers/fingerprint_controller.dart';

class FingerprintAuthPage extends StatefulWidget {
  @override
  _FingerprintAuthPageState createState() => _FingerprintAuthPageState();
}

class _FingerprintAuthPageState extends State<FingerprintAuthPage> {
  final FingerprintController _controller = FingerprintController();
  String? hashedId;

  Future<void> handleFingerprintAuthentication() async {
    // ملاحظة: عادي هون تحطي رقم الطالب بشكل ديناميكي
    String studentId = "152992";

    String? result = await _controller.authenticateAndHash(studentId);

    if (result != null) {
      setState(() {
        hashedId = result;
      });
      // هنا ممكن ترفعي الهاش عالداتابيس إذا حابة
    } else {
      // فشل التحقق
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fingerprint authentication failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fingerprint Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: handleFingerprintAuthentication,
              child: Text('Authenticate & Generate Hash'),
            ),
            SizedBox(height: 20),
            if (hashedId != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Hashed ID:\n$hashedId',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
