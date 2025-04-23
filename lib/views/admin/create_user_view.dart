import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateUserView extends StatefulWidget {
  const CreateUserView({super.key});

  @override
  State<CreateUserView> createState() => _CreateUserViewState();
}

class _CreateUserViewState extends State<CreateUserView> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  String _role = 'student';
  String _generatedPassword = '';
  File? _faceImage;

  final supabase = Supabase.instance.client;

  String _generatePassword({int length = 10}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%&';
    final rand = Random();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _pickFaceImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = await File(picked.path).copy(path);
      setState(() {
        _faceImage = file;
      });
    }
  }Future<void> _createUser() async {
  final email = _emailController.text.trim();
  final name = _nameController.text.trim();
  final password = _generatePassword();

  try {
    final response = await supabase.auth.admin.createUser(
      AdminUserAttributes(
        email: email,
        password: password,
        userMetadata: {'full_name': name, 'role': _role},
        emailConfirm: true,
      ),
    );

    final userId = response.user?.id;
    print('Created user ID: $userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل في إنشاء المستخدم في Auth")),
      );
      return;
    }

    if (_faceImage != null) {
      await supabase.storage
          .from('faces')
          .upload('$userId.jpg', _faceImage!);
      print('تم رفع صورة الوجه');
    }

    final insertResult = await supabase.from('students').insert({
      'id': userId,
      'name': name,
      'email': email,
      'role': _role,
    });

    print('Result from insert into students: $insertResult');

    setState(() {
      _generatedPassword = password;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم إنشاء المستخدم بنجاح")),
    );
  } catch (error) {
    print('Error during user creation: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("فشل في العملية")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إنشاء مستخدم جديد")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "الاسم الكامل"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "البريد الإلكتروني"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 'student', child: Text("طالب")),
                DropdownMenuItem(value: 'teacher', child: Text("معلم")),
              ],
              onChanged: (val) => setState(() => _role = val!),
              decoration: const InputDecoration(labelText: "نوع المستخدم"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFaceImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text("التقط صورة الوجه"),
            ),
            if (_faceImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.file(_faceImage!, height: 200),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createUser,
              child: const Text("إنشاء المستخدم"),
            ),
            if (_generatedPassword.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text("كلمة السر العشوائية:", style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_generatedPassword, style: const TextStyle(fontSize: 18)),
            ],
          ],
        ),
      ),
    );
  }
}
