/* import 'package:flutter/material.dart';
import 'package:flutter_application_2/controllers/fingerprint_controller.dart';

class FingerprintAuthPage extends StatefulWidget {
  @override
  _FingerprintAuthPageState createState() => _FingerprintAuthPageState();
}

class _FingerprintAuthPageState extends State<FingerprintAuthPage> {
  final FingerprintController _controller = FingerprintController();
  String? hashedId;

  Future<void> handleFingerprintAuthentication() async {
    // يمكن لاحقاً استبدال هذا بمعرّف ديناميكي
    String studentId = "152992";

    String? result = await _controller.authenticateAndHash(studentId);

    if (result != null) {
      setState(() {
        hashedId = result;
      });
      // يمكنك إرسال الهاش إلى قاعدة البيانات هنا
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل التحقق ببصمة الإصبع.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق ببصمة الإصبع'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: handleFingerprintAuthentication,
                icon: const Icon(Icons.fingerprint),
                label: const Text('تحقق وتوليد الهاش'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              if (hashedId != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: theme.cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '📦 Hashed ID:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          hashedId!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
 */