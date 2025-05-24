import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

class CreateTeacherView extends StatefulWidget {
  const CreateTeacherView({super.key});

  @override
  State<CreateTeacherView> createState() => _CreateTeacherViewState();
}

class _CreateTeacherViewState extends State<CreateTeacherView> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  String? _password;
  int? _employeeId;

  Future<void> _createTeacher() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('enter_all_fields'))),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://172.20.10.6:3001/create_teacher_server'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _password = data['password'];
          _employeeId = data['employeeId'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('teacher_created'))),
        );
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('operation_failed')}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('create_teacher_account'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: tr('teacher_name'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: tr('email'),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createTeacher,
              icon: const Icon(Icons.person_add),
              label: Text(tr('create_account')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            if (_password != null && _employeeId != null) ...[
              Text(tr('teacher_created_successfully'), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${tr('employee_id')}: $_employeeId'),
              Text('${tr('generated_password')}: $_password', style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}



/* import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class CreateTeacherView extends StatefulWidget {
  const CreateTeacherView({super.key});

  @override
  State<CreateTeacherView> createState() => _CreateTeacherViewState();
}

class _CreateTeacherViewState extends State<CreateTeacherView> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  String _generatedPassword = '';

  final supabase = Supabase.instance.client;

  String _generatePassword({int length = 10}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%&';
    final rand = Random();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _createTeacher() async {
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
          userMetadata: {'name': name, 'role': 'teacher'},
          emailConfirm: true,
        ),
      );


      final userId = response.user?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("فشل في إنشاء المستخدم")),
        );
        return;
      }

      await supabase.from('teachers').insert({
        'id': userId,
        'email': email,
        'name': name,
      });

      setState(() {
        _generatedPassword = password;
      });

//await _sendPasswordEmail(email, password);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إنشاء حساب المعلم بنجاح")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في العملية: $e")),
      );
    }
  }

// اجرب انه الايميل ينبعث من السيرفر احسن 

/* 

Future<void> _sendPasswordEmail(String email, String password) async {
  final smtpServer = gmail('hadersystem@gmail.com', 'etmfpsahknesrejo');

  final message = Message()
    ..from = Address('hadersystem@gmail.com', 'Hader System')
    ..recipients.add(email)
    ..subject = 'Teacher Account Created'
    ..text = '''
Hello,

Your teacher account has been created successfully.

Email: $email
Password: $password

Please log in and change your password.

Regards,
Admin
''';

  try {
    await send(message, smtpServer);
    print('✅ Email sent successfully');
  } catch (e) {
    print('❌ Failed to send email: $e');
  }
}
 */


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إنشاء حساب معلم")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "اسم المعلم"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "البريد الإلكتروني"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createTeacher,
              child: const Text("إنشاء الحساب"),
            ),
            const SizedBox(height: 20),
            if (_generatedPassword.isNotEmpty) ...[
              const Text("كلمة السر العشوائية:", style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_generatedPassword, style: const TextStyle(fontSize: 18)),
            ],
          ],
        ),
      ),
    );
  }
}
 */