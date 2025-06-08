//this page for face recognition for students to ensure that they are themselves
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:easy_localization/easy_localization.dart';

class FaceRecognitionView extends StatefulWidget {
  final String userId;
  const FaceRecognitionView({super.key, required this.userId});

  @override
  State<FaceRecognitionView> createState() => _FaceRecognitionViewState();
}

class _FaceRecognitionViewState extends State<FaceRecognitionView> {
  final supabase = Supabase.instance.client;
  File? _storedFace;
  bool _loading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _startFullFaceFlow();
  }

  Future<File> _compressFile(File file) async {
    final targetPath =
        '${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 50,
    );
    return result != null ? File(result.path) : file;
  }

  Future<void> _startFullFaceFlow() async {
    setState(() {
      _loading = true;
      _statusMessage = tr('loading_face');
    });

    try {
      await _downloadStoredFace();

      if (mounted) {
        setState(() => _statusMessage = tr('capture_face'));
      }

      final captured = await _autoCaptureFace();
      if (captured == null) return;

      setState(() => _statusMessage = tr('comparing_faces'));
      await _compareFaces(captured);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _downloadStoredFace() async {
    final userId = widget.userId.trim();

    final result = await supabase
        .from('students')
        .select('faces')
        .eq('id', userId)
        .maybeSingle();

    if (result == null || result['faces'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('no_face_found'))),
      );
      throw Exception("No stored face");
    }

    final response = await http.get(Uri.parse(result['faces']));
    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/stored.jpg');
      await file.writeAsBytes(response.bodyBytes);
      _storedFace = file;
    } else {
      throw Exception("Image download failed");
    }
  }

  Future<File?> _autoCaptureFace() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return null;
    return await _compressFile(File(pickedFile.path));
  }

  Future<void> _compareFaces(File capturedFace) async {
    if (_storedFace == null) return;

    final compressedStored = await _compressFile(_storedFace!);
    final uri = Uri.parse('https://api-us.faceplusplus.com/facepp/v3/compare');

    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = 'FJhvE1OSyc3G6jIKAt7GKEtH0Y5-VVIf'
      ..fields['api_secret'] = 'V9OroBbeLKesOY-DH7q2Eekn1rf6VB8C'
      ..files.add(await http.MultipartFile.fromPath('image_file1', compressedStored.path,
          contentType: MediaType('image', 'jpeg')))
      ..files.add(await http.MultipartFile.fromPath('image_file2', capturedFace.path,
          contentType: MediaType('image', 'jpeg')));

    try {
      final streamedResponse = await request.send();
      final response =
          await http.Response.fromStream(streamedResponse).timeout(const Duration(seconds: 2));

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data.containsKey('confidence')) {
        final confidence = data['confidence'];
        final threshold = data['thresholds']['1e-5'];

        if (confidence >= threshold) {
          Navigator.pushReplacementNamed(context, '/qr-scanner');
        } else {
          _showFaceMismatchDialog(confidence);
        }
      } else {
        _showMessage(tr('face_verification_failed'));
      }
    } on TimeoutException {
      _showMessage(tr('verification_timeout'));
    } catch (e) {
      debugPrint('❌ Error: $e');
      _showMessage(tr('error_verifying_face'));
    }
  }

  void _showFaceMismatchDialog(double confidence) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr('face_not_match')),
        content: Text('${tr('similarity')}: ${confidence.toStringAsFixed(2)}%\n${tr('try_again')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('ok')),
          )
        ],
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('face_verification'))),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _loading
                  ? isWide
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(width: 24),
                            if (_statusMessage != null)
                              Expanded(
                                child: Text(
                                  _statusMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 24),
                            if (_statusMessage != null)
                              Text(
                                _statusMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                          ],
                        )
                  : Text(
                      tr('no_matching'),
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          );
        },
      ),
    );
  }
}


