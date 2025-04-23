import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class FaceVerificationView extends StatefulWidget {
  final String userId;
  const FaceVerificationView({super.key, required this.userId});

  @override
  State<FaceVerificationView> createState() => _FaceVerificationViewState();
}

class _FaceVerificationViewState extends State<FaceVerificationView> {
  final supabase = Supabase.instance.client;
  File? _capturedFace;
  File? _storedFace;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _downloadStoredFace();
  }

  Future<void> _downloadStoredFace() async {
    final url = await supabase.storage
        .from('faces')
        .createSignedUrl('${widget.userId}.jpg', 60);

    final response = await http.get(Uri.parse(url));
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/stored.jpg');
    await file.writeAsBytes(response.bodyBytes);

    setState(() {
      _storedFace = file;
      _loading = false;
    });
  }

  Future<void> _captureFace() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _capturedFace = File(picked.path);
      });
    }
  }

  Future<void> compareFacesWithFacePlusPlus() async {
    if (_capturedFace == null || _storedFace == null) return;

    final uri = Uri.parse('https://api-us.faceplusplus.com/facepp/v3/compare');

    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = 'FJhvE1OSyc3G6jIKAt7GKEtH0Y5-VVIf'
      ..fields['api_secret'] = 'V9OroBbeLKesOY-DH7q2Eekn1rf6VB8C'
      ..files.add(await http.MultipartFile.fromPath(
        'image_file1',
        _storedFace!.path,
        contentType: MediaType('image', 'jpeg'),
      ))
      ..files.add(await http.MultipartFile.fromPath(
        'image_file2',
        _capturedFace!.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    final response = await request.send();
    final result = await response.stream.bytesToString();
    final data = json.decode(result);

    if (response.statusCode == 200 && data.containsKey('confidence')) {
      final confidence = data['confidence'];
      final threshold = data['thresholds']['1e-3'];
      final match = confidence >= threshold;

      if (match) {
        // ✅ إذا تطابق الوجه → افتح QR Scanner
        Navigator.pushReplacementNamed(context, '/qr-scanner');
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("فشل التحقق"),
            content: Text("الوجه غير مطابق، الثقة: $confidence"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("رجوع"),
              )
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطأ أثناء الاتصال بخدمة Face++")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("التحقق من الوجه")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_storedFace != null)
              Image.file(_storedFace!, height: 150),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _captureFace,
              child: const Text("التقط صورة وجه جديدة"),
            ),
            const SizedBox(height: 12),
            if (_capturedFace != null)
              Image.file(_capturedFace!, height: 150),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: compareFacesWithFacePlusPlus,
              child: const Text("تحقق من التطابق باستخدام Face++"),
            ),
          ],
        ),
      ),
    );
  }
}
