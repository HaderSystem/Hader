import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_2/services/hash_service.dart'; // استيراد ملف الهاش

class StudentRegisterView extends StatefulWidget {
  const StudentRegisterView({super.key});

  @override
  State<StudentRegisterView> createState() => _StudentRegisterViewState();
}

class _StudentRegisterViewState extends State<StudentRegisterView> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  File? _faceImage;
  bool _loading = false;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _pickFaceImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = await File(picked.path).copy(path);
      setState(() => _faceImage = file);
    }
  }

  Future<void> _registerStudent() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || name.isEmpty || password.isEmpty || _faceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("املأ كل الحقول + التقط صورة")),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال بريد إلكتروني صحيح")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // تسجيل الطالب بحساب جديد
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name, 'role': 'student'},
      );

      final user = response.user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("فشل في إنشاء حساب الطالب")),
        );
        setState(() => _loading = false);
        return;
      }

      final userId = user.id;

      // رفع صورة الوجه
      await supabase.storage.from('faces').upload(
        '$userId.jpg',
        _faceImage!,
        fileOptions: const FileOptions(upsert: true),
      );

      // 🔥 توليد هاش خاص بالطالب (مثلاً باستخدام الـ userId)
    //  final newHash = generateHash(userId);

      // تخزين بيانات الطالب + الهاش بالداتا بيس
      await supabase.from('students').insert({
        'id': userId,
        'name': name,
        'email': email,
        'role': 'student',
       // 'fingerprint_hash': newHash, // تأكدي يكون عندك عمود بهذا الاسم بجدول students
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم التسجيل بنجاح")),
      );

      // ذهاب إلى صفحة الطالب الرئيسية
      Navigator.pushReplacementNamed(context, '/student');
    } catch (e) {
      print("❌ خطأ أثناء التسجيل: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل حساب طالب")),
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
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "كلمة السر"),
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
                child: Image.file(_faceImage!, height: 150),
              ),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _registerStudent,
                    child: const Text("سجّل الحساب"),
                  ),
          ],
        ),
      ),
    );
  }
}


/* import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_2/services/hash_service.dart'; // استيراد الملف







class StudentRegisterView extends StatefulWidget {
  const StudentRegisterView({super.key});

  @override
  State<StudentRegisterView> createState() => _StudentRegisterViewState();
}

class _StudentRegisterViewState extends State<StudentRegisterView> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  File? _faceImage;
  bool _loading = false;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _pickFaceImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = await File(picked.path).copy(path);
      setState(() => _faceImage = file);
    }
  }

  Future<void> _registerStudent() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || name.isEmpty || password.isEmpty || _faceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("املأ كل الحقول + التقط صورة")),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال بريد إلكتروني صحيح")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name, 'role': 'student'},
      );





// بعد عملية التسجيل مباشرة
final user = response.user;

if (user == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("فشل في إنشاء حساب الطالب")),
  );
  return;
}

final userId = user.id;

// هون صار userId جاهز وآمن!








// ثم داخل الميثود بعد تسجيل الطالب:
final input = userId; // مثلا نستخدم userId كقيمة للهاش

// هون فقط نحسب هاش جديد للطالب ونخزنه
final newHash = generateHash(userId);

print("🔹 الهاش الجديد للطالب: $newHash");

// خزن newHash بالـ Supabase مثلاً بجدول students أو جدول biometric_hashes
await Supabase.instance.client
    .from('students')
    .update({'fingerprint_hash': newHash}) // افترضنا عندك عمود اسمه fingerprint_hash
    .eq('id', userId);



// بعدها ممكن تخزني newHash بجدول students أو جدول جديد مخصص للبصمات مثلا
   //   final userId = response.user?.id;
      print("✅ userId from response: $userId");

      if (userId == null) throw "فشل في الحصول على معرف المستخدم";

      await supabase.storage.from('faces').upload(
        '$userId.jpg',
        _faceImage!,
        fileOptions: const FileOptions(upsert: true),
      );


      print("✅ صورة الوجه تم رفعها");

      await supabase.from('students').insert({
        'id': userId,
        'name': name,
        'email': email,
        'role': 'student',
      });
      print("✅ الطالب تم إدخاله إلى قاعدة البيانات");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم التسجيل بنجاح")),
      );

      Navigator.pushReplacementNamed(context, '/student');
    } catch (e) {
      print("❌ خطأ أثناء التسجيل: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تسجيل حساب طالب")),
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
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "كلمة السر"),
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
                child: Image.file(_faceImage!, height: 150),
              ),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _registerStudent,
                    child: const Text("سجّل الحساب"),
                  ),
          ],
        ),
      ),
    );
  }
}
 */