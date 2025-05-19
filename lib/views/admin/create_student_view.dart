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
      final uri = Uri.parse('http://172.20.10.6:3000/create-student');
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
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: tr('student_name')),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: tr('student_email')),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFaceImage,
              icon: const Icon(Icons.camera_alt),
              label: Text(tr('capture_face_image')),
            ),
            if (_faceImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Image.file(_faceImage!, height: 200),
              ),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _createStudent,
                    child: Text(tr('create_account')),
                  ),
            const SizedBox(height: 20),
            if (_createdStudentId != null && _createdPassword != null) ...[
              Text(tr('new_student_info'), style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${tr('student_id')}: $_createdStudentId'),
              Text('${tr('password')}: $_createdPassword'),
            ],
          ],
        ),
      ),
    );
  }
}




/* import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
        const SnackBar(content: Text('يرجى ملء جميع الحقول واختيار صورة الوجه')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final uri = Uri.parse('http://172.20.10.6:3000/create-student');
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
          const SnackBar(content: Text('✅ تم إنشاء الطالب بنجاح')),
        );
      } else {
        debugPrint('Error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ فشل في إنشاء الطالب')),
        );
      }
    } catch (e) {
      debugPrint('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ حدث خطأ أثناء الاتصال بالخادم')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب طالب')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم الطالب'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني للطالب'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFaceImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('التقط صورة الوجه'),
            ),
            if (_faceImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Image.file(_faceImage!, height: 200),
              ),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _createStudent,
                    child: const Text('إنشاء الحساب'),
                  ),
            const SizedBox(height: 20),
            if (_createdStudentId != null && _createdPassword != null) ...[
              const Text('بيانات الطالب الجديد:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Student ID: $_createdStudentId'),
              Text('كلمة المرور: $_createdPassword'),
            ],
          ],
        ),
      ),
    );
  }
}
 */












































/* import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
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

  // توليد باسورد عشوائي
  String _generatePassword({int length = 10}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%&';
    final rand = Random();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  // اختيار صورة الوجه
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
  }

  // إرسال الإيميل بالباسورد للطالب
  Future<void> _sendPasswordEmail(String email, String password) async {
    final smtpServer = gmail('aishabaniamer4@gmail.com', 'Aisha@1410'); // استخدم حساب Gmail و App Password

    final message = Message()
      ..from = Address('your-email@gmail.com', 'Your App Name')
      ..recipients.add(email)
      ..subject = 'بيانات تسجيل الدخول الخاصة بك'
      ..text = '''
مرحبًا،

تم إنشاء حسابك بنجاح.

البريد الإلكتروني: $email
كلمة المرور: $password

يرجى تأكيد بريدك الإلكتروني عند تسجيل الدخول، ثم تغيير كلمة المرور الخاصة بك بعد الدخول لأول مرة.

تحياتنا،
فريق الدعم
''';

    try {
      final sendReport = await send(message, smtpServer);
      print('✅ تم إرسال الإيميل بنجاح: $sendReport');
    } on MailerException catch (e) {
      print('❌ فشل إرسال الإيميل: $e');
    }
  }

  // إنشاء مستخدم جديد
  Future<void> _createUser() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _generatePassword();

    if (email.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال جميع الحقول")),
      );
      return;
    }

    try {
      final response = await supabase.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          userMetadata: {'full_name': name, 'role': _role},
          emailConfirm: false, // مهم: نخليه false ليصل إيميل تأكيد
        ),
      );

      final userId = response.user?.id;
      print('✅ Created user ID: $userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("فشل في إنشاء المستخدم في Auth")),
        );
        return;
      }

      // رفع صورة الوجه
      if (_faceImage != null) {
        await supabase.storage
            .from('faces')
            .uploadBinary('$userId.jpg', await _faceImage!.readAsBytes());
        print('✅ تم رفع صورة الوجه');
      }

      // إضافة بيانات الطالب في students
      await supabase.from('students').insert({
        'id': userId,
        'name': name,
        'email': email,
        'role': _role,
      });

      print('✅ تم إدخال بيانات الطالب في جدول students');

      // إرسال الإيميل بكلمة المرور
      await _sendPasswordEmail(email, password);

      setState(() {
        _generatedPassword = password;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إنشاء المستخدم وإرسال كلمة المرور بنجاح")),
      );
    } catch (error) {
      print('❌ خطأ أثناء إنشاء المستخدم: $error');
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

/* import 'dart:math';
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
 */ */