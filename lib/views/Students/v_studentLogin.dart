import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewStudentLogin extends StatefulWidget {
  @override
  _ViewStudentLoginState createState() => _ViewStudentLoginState();
}

class _ViewStudentLoginState extends State<ViewStudentLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _student_idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _student_idController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تسجيل الدخول بنجاح!')));
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تسجيل الدخول، تحقق من البيانات';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تسجيل دخول الطالب')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _student_idController, decoration: InputDecoration(labelText: 'الإيميل')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'كلمة المرور'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('تسجيل الدخول')),
            if (_errorMessage.isNotEmpty) Text(_errorMessage, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

/* 

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewStudentLogin extends StatefulWidget {
  @override
  _ViewStudentLoginState createState() => _ViewStudentLoginState();
}

class _ViewStudentLoginState extends State<ViewStudentLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تسجيل الدخول بنجاح!')));
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تسجيل الدخول، تحقق من البيانات';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تسجيل دخول الطالب')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'الإيميل')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'كلمة المرور'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('تسجيل الدخول')),
            if (_errorMessage.isNotEmpty) Text(_errorMessage, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
 */