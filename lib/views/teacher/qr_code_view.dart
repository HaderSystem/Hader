import 'package:flutter/material.dart';
import 'package:flutter_application_2/views/teacher/attendance_list_view.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeView extends StatelessWidget {
  final String lectureId;

  const QRCodeView({super.key, required this.lectureId});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lecture QR Code")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Scan this to record attendance"),
            const SizedBox(height: 20),
            QrImageView(
              data: lectureId,
              version: QrVersions.auto,
              size: 250.0,
            ),
            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceListView(lectureId: lectureId),
      ),
    );
  },
  child: const Text("View Attendance List"),
)

          ],
        ),
      ),
    );
  }
}
