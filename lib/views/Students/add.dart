/* import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddStud extends StatelessWidget {
  const AddStud({super.key});

  Future<void> addStudent() async {
    final supabase = Supabase.instance.client;

    // بيانات الطالب
    final String Email = "student@example.com";
    final String password = "SecurePassword";
    final String name = "Student Name";
    final String major = "Computer Science";

    try {
      // 1. إنشاء المستخدم في auth
      final response = await supabase.auth.admin.createUser(
        AdminUserAttributes(
          email: Email,
      //    password: password,
       //   emailConfirm: true, // لتأكيد الحساب تلقائيًا
        ),
      );

      final userId = response.user?.id;

      if (userId != null) {
        // 2. إدخال بيانات الطالب في جدول students بنفس الـ ID
        await supabase.from('student').insert({
          'studentid': userId, // نفس ID المستخدم في auth
          'email': Email,
        //  'major': major,
        });

        print("تم إنشاء الطالب وربطه بنجاح");
      } else {
        print("فشل في إنشاء المستخدم");
      }
    } catch (error) {
      print("خطأ: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة طالب")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await addStudent();
          },
          child: const Text("إضافة طالب"),
        ),
      ),
    );
  }
}
 */