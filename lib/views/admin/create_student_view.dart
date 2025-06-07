import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

class CreateStudentView extends StatefulWidget {
  const CreateStudentView({Key? key}) : super(key: key);

  @override
  State<CreateStudentView> createState() => _CreateStudentViewState();
}

class _CreateStudentViewState extends State<CreateStudentView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  File? _faceImage;
  bool _loading = false;
  String? _createdStudentId;
  String? _createdPassword;

  Future<void> _pickFaceImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _faceImage = File(picked.path);
      });
    }
  }

  Future<void> _createStudent() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final role = 'student';

    if (email.isEmpty || name.isEmpty || _faceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('fill_required_fields'))),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final uri = Uri.parse('https://student-api-sgwe.onrender.com/create_student_server');
      final request = http.MultipartRequest('POST', uri);

      request.fields['email'] = email;
      request.fields['name'] = name;
      request.fields['role'] = role;

      request.files.add(await http.MultipartFile.fromPath(
        'face_image',
        _faceImage!.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _createdStudentId = data['studentId'].toString();
          _createdPassword = data['password'].toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('student_created_success'))),
        );
      } else {
        debugPrint('Error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('student_creation_failed'))),
        );
      }
    } catch (e) {
      debugPrint('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('server_error'))),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _toggleLanguage() {
    final current = context.locale;
    final newLocale = current.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    context.setLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('create_student_account')),
        backgroundColor: const Color(0xFF002D62),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: tr('change_language'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: tr('student_name'),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: tr('student_email'),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _pickFaceImage,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(tr('capture_face_image')),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      if (_faceImage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_faceImage!, height: 200),
                          ),
                        ),
                      const SizedBox(height: 10),
                      _loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _createStudent,
                                icon: const Icon(Icons.person_add),
                                label: Text(tr('create_account')),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),
                      if (_createdStudentId != null && _createdPassword != null)
                        Card(
                          color: Colors.blue.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(top: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr('new_student_info'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('${tr('student_id')}: $_createdStudentId'),
                                Text('${tr('password')}: $_createdPassword'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



/* import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

class CreateStudentView extends StatefulWidget {
  const CreateStudentView({Key? key}) : super(key: key);

  @override
  State<CreateStudentView> createState() => _CreateStudentViewState();
}

class _CreateStudentViewState extends State<CreateStudentView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  File? _faceImage;
  bool _loading = false;
  String? _createdStudentId;
  String? _createdPassword;

  Future<void> _pickFaceImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _faceImage = File(picked.path);
      });
    }
  }

  Future<void> _createStudent() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final role = 'student';

    if (email.isEmpty || name.isEmpty || _faceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('fill_required_fields'))),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      //final uri = Uri.parse('https://student-api-sgwe.onrender.com/create_student_server');
     
     final uri = Uri.parse('https://student-api-sgwe.onrender.com/create_student_server');
      final request = http.MultipartRequest('POST', uri);

      request.fields['email'] = email;
      request.fields['name'] = name;
      request.fields['role'] = role;

      request.files.add(await http.MultipartFile.fromPath(
        'face_image',
        _faceImage!.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _createdStudentId = data['studentId'].toString();
          _createdPassword = data['password'].toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('student_created_success'))),
        );
      } else {
        debugPrint('Error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('student_creation_failed'))),
        );
      }
    } catch (e) {
      debugPrint('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('server_error'))),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _toggleLanguage() {
    final current = context.locale;
    final newLocale = current.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    context.setLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('create_student_account')),
        backgroundColor: const Color(0xFF002D62),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: tr('change_language'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: tr('student_name'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: tr('student_email'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickFaceImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(tr('capture_face_image')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_faceImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_faceImage!, height: 200),
                  ),
                ),
              const SizedBox(height: 10),
              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _createStudent,
                        icon: const Icon(Icons.person_add),
                        label: Text(tr('create_account')),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              if (_createdStudentId != null && _createdPassword != null)
                Card(
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(top: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('new_student_info'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text('${tr('student_id')}: $_createdStudentId'),
                        Text('${tr('password')}: $_createdPassword'),
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